import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/panels/panel_stack_controller.dart';
import '../../feedback/ui/panels/feedback_panel.dart';
import '../../sessions/ui/panels/attendance_confirm_panel.dart';
import '../../trainers/ui/panels/trainer_calendar_panel.dart';
import '../../../firebase_options.dart';
import '../../events/ui/panels/event_detail_panel.dart';
import '../../group_sessions/ui/panels/group_session_detail_panel.dart';

/// Uygulama tamamen kapalıyken gelen bildirimler ayrı bir isolate'te işlenir
/// — bu yüzden top-level olmak zorunda ve kendi Firebase.initializeApp'ini
/// çağırır. Şimdilik sadece OS'un bildirimi otomatik göstermesine izin
/// veriyoruz (notification payload'lı mesajlarda ek işlem gerekmiyor).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// F2-7 — push bildirim altyapısı: izin ister, FCM token'ı alır/yeniler ve
/// `users/{uid}.fcmTokens`'a ekler (array union), ön plandaki bildirimleri
/// flutter_local_notifications ile gösterir, bildirime dokununca (ön/arka
/// plan/kapalıyken) ilgili (mock) panele yönlendirir.
class PushNotificationService {
  PushNotificationService();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'session_reminders',
    'Ders Hatırlatmaları',
    description: 'Yaklaşan dersler için hatırlatma bildirimleri',
    importance: Importance.high,
  );

  Future<void> init(ProviderContainer container) async {
    await FirebaseMessaging.instance.requestPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _navigateForPayload(container, response.payload),
    );

    // APNS token'ın cihaza/simülatöre ulaşması gecikebilir (ya da kullanıcı
    // bildirim iznini reddettiyse hiç gelmeyebilir) — getToken() bu durumda
    // fırlatıyor. init() burada çağrıldığı yerde (main.dart) await edildiği
    // için bu hata yakalanmazsa runApp() hiç çalışmaz, uygulama boş ekranda
    // takılı kalır. Token alınamazsa sessizce vazgeçilir, onTokenRefresh
    // ileride token gelince zaten _saveToken'ı tetikleyecek.
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _saveToken(token);
    } on Exception {
      // Kasıtlı: bildirim token'ı olmadan da uygulama normal çalışmaya devam etmeli.
    }
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);

    // init() bu haliyle main()'de, kullanıcı GİRİŞ YAPMADAN ÖNCE çağrılıyor
    // — o anda currentUser henüz null olduğu için yukarıdaki ilk
    // getToken()/_saveToken() denemesi sessizce no-op'a düşüyordu (bkz.
    // _saveToken'daki uid==null erken çıkışı) ve token FCM'de sık
    // yenilenmediği için giriş yapıldıktan sonra bir daha hiç
    // kaydedilmiyordu — üye/antrenör push token'ı hiç Firestore'a
    // yazılmadan kalıyordu. Şimdi her başarılı girişte (uid null'dan
    // dolu değere geçtiğinde) token tekrar okunup kaydediliyor.
    String? lastSavedForUid;
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null || user.uid == lastSavedForUid) return;
      lastSavedForUid = user.uid;
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) await _saveToken(token);
      } on Exception {
        // Aynı gerekçe: bildirim token'ı olmadan da giriş akışı devam etmeli.
      }
    });

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _navigateForData(container, message.data),
    );

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _navigateForData(container, initialMessage.data);
    }
  }

  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // `payload` tek bir string — antrenörün "Dersi onayla" push'una
      // dokununca hangi seansa gideceğini bilmek için `type` yetmiyor,
      // `sessionId`'nin de taşınması lazım. Ön plandaki bildirim bu yolla
      // (flutter_local_notifications) geçtiği için `data`'nın tamamı JSON
      // olarak kodlanıyor — arkaplan/kapalıyken gelen dokunuşlar zaten
      // `onMessageOpenedApp`/`getInitialMessage` ile ham `data` map'ini alıyor.
      payload: jsonEncode(message.data),
    );
  }

  /// Bildirime dokununca doğru panele yönlendirir — önceden `type` fark
  /// etmeksizin (bir salon duyurusu bile olsa) hep [AttendanceConfirmPanel]'e
  /// gidiliyordu. Cloud Functions tarafı zaten her push'ta `data.type`
  /// gönderiyor (bkz. session-reminder-check.ts, session-completion-check.ts,
  /// feedback-reminder-check.ts, send-manual-notification.ts).
  void _navigateForPayload(ProviderContainer container, String? payload) {
    if (payload == null) return;
    Map<String, dynamic> data;
    try {
      data = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    _navigateForData(container, data);
  }

  void _navigateForData(ProviderContainer container, Map<String, dynamic> data) {
    final panelStack = container.read(panelStackControllerProvider.notifier);
    switch (data['type'] as String?) {
      case 'session_reminder':
        panelStack.push(const AttendanceConfirmPanel());
      case 'session_completion':
        // Antrenör "Dersini onaylar mısın?" push'una dokununca doğrudan
        // Takvimim'e, o seansın tarihi seçili ve "Dersi onayla" sheet'i
        // otomatik açık şekilde gitmeli — genel onay bekleyenler listesine
        // değil (önceden TrainerNotificationsPanel açılıyordu).
        panelStack.push(
          TrainerCalendarPanel(focusSessionId: data['sessionId'] as String?),
        );
      case 'feedback_reminder':
        panelStack.push(const FeedbackPanel());
      // "Yarın grup dersi/etkinlik var, katılmak ister misin?" daveti —
      // bildirim metni "katılmak için dokun" diyor, dolayısıyla dokunuş
      // doğrudan O DERSİN/ETKİNLİĞİN detayına götürüyor; katılım butonu
      // zaten orada. Listeye düşürmek kullanıcıya aramayı bırakırdı.
      case 'group_session_invite':
        final groupSessionId = data['groupSessionId'] as String?;
        if (groupSessionId != null) {
          panelStack.push(
            GroupSessionDetailPanel(groupSessionId: groupSessionId),
          );
        }
      case 'event_invite':
        final eventId = data['eventId'] as String?;
        if (eventId != null) {
          panelStack.push(EventDetailPanel(eventId: eventId));
        }
      default:
        // manual_notification (salon duyurusu) ya da bilinmeyen bir tür —
        // ilgisiz bir onay ekranına zorlamak yerine uygulamayı sadece ön
        // plana getirmekle yetinilir.
        break;
    }
  }
}
