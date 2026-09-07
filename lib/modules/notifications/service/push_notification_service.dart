import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/panels/panel_stack_controller.dart';
import '../../../core/router/app_access.dart';
import '../../../core/router/app_router.dart';
import '../../sessions/ui/panels/admin_session_management_panel.dart';
import '../../feedback/ui/panels/feedback_panel.dart';
import '../../sessions/ui/panels/attendance_confirm_panel.dart';
import '../../trainers/ui/panels/trainer_calendar_panel.dart';
import '../../../firebase_options.dart';
import '../../events/ui/panels/event_detail_panel.dart';
import '../../group_sessions/ui/panels/group_session_detail_panel.dart';
import '../../../core/remote_config/remote_config_service.dart';

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

  /// Kanal adı/açıklaması telefonun sistem ayarlarında görünür, o yüzden
  /// aktif dile göre RC'den okunuyor. Kanal bir kez oluşturulduktan sonra
  /// Android adı güncellemiyor — dil değişirse kullanıcı uygulamayı yeniden
  /// kurana kadar eski ad kalabilir; kabul edilen bir sınır.
  /// [init] çalıştıktan sonra dolu — bildirim gösterirken kanal
  /// id/adı buradan okunuyor.
  late AndroidNotificationChannel _channel;

  static AndroidNotificationChannel _androidChannel(
    String name,
    String description,
  ) => AndroidNotificationChannel(
    'session_reminders',
    name,
    description: description,
    importance: Importance.high,
  );

  Future<void> init(ProviderContainer container) async {
    await FirebaseMessaging.instance.requestPermission();

    _channel = _androidChannel(
      container.read(
        rcTextProvider(RemoteConfigKeys.notificationsAndroidChannelName),
      ),
      container.read(
        rcTextProvider(RemoteConfigKeys.notificationsAndroidChannelDescription),
      ),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

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
      // Çıkışta token artık dokümandan siliniyor (bkz.
      // [removeTokenForCurrentUser]) — bayrak burada sıfırlanmazsa AYNI
      // hesaba tekrar girildiğinde `user.uid == lastSavedForUid` olacağı
      // için token bir daha hiç yazılmaz ve kullanıcı sessizce bildirim
      // alamaz hale gelirdi.
      if (user == null) {
        lastSavedForUid = null;
        return;
      }
      if (user.uid == lastSavedForUid) return;
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
      unawaited(_navigateForData(container, initialMessage.data));
    }
  }

  /// [_saveToken]'ın tersi — çıkışta BU cihazın token'ını
  /// `users/{uid}.fcmTokens`'tan çıkarır. Token silinmediği için oturum
  /// kapandıktan sonra da cihaz o hesabın bildirimlerini almaya devam
  /// ediyordu; aynı cihazdan ikinci bir hesaba girildiğinde (salon tableti,
  /// cihaz devri, adminin ayrı bir antrenör hesabı kullanması) iki hesabın
  /// bildirimleri birden düşüyor ve yanlış role ait deep link'ler açılıyordu.
  ///
  /// Çağıran taraf HENÜZ `signOut()` etmemiş olmalı: `users/{uid}` üzerinde
  /// self-update imzalı oturum gerektiriyor (firestore.rules
  /// `match /users/{uid}` → `allow update`).
  ///
  /// Hesap SİLME akışında bilerek çağrılmıyor: `deleteAccount` Cloud
  /// Function'ı `users/{uid}` dokümanının tamamını siliyor, buradaki yazma
  /// ise silinmiş dokümanla yarışıp onu diriltebilirdi.
  static Future<void> removeTokenForCurrentUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    } on Exception {
      // Kasıtlı: token temizliği başarısız olsa bile (ağ yok, doküman
      // silinmiş, izin reddedilmiş) çıkış akışı ASLA durmamalı.
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
        android: AndroidNotificationDetails(_channel.id, _channel.name),
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
  Future<void> _navigateForPayload(
    ProviderContainer container,
    String? payload,
  ) async {
    if (payload == null) return;
    Map<String, dynamic> data;
    try {
      data = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    await _navigateForData(container, data);
  }

  Future<void> _navigateForData(
    ProviderContainer container,
    Map<String, dynamic> data,
  ) async {
    final panelStack = container.read(panelStackControllerProvider.notifier);
    switch (data['type'] as String?) {
      case 'session_reminder':
        panelStack.push(const AttendanceConfirmPanel());
      // Antrenör "Dersini onaylar mısın?" push'una dokununca doğrudan
      // Takvimim'e, o seansın tarihi seçili ve "Dersi onayla" sheet'i
      // otomatik açık şekilde gitmeli — genel onay bekleyenler listesine
      // değil (önceden TrainerNotificationsPanel açılıyordu).
      // `trainer_session_reminder` ("bugün şu seansların var") önceden hiç
      // yönlendirilmiyordu, aynı ekran onun da doğru hedefi.
      case 'session_completion':
      case 'trainer_session_reminder':
        await _navigateToSessionPanelForRole(
          container,
          data['sessionId'] as String?,
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

  /// F11-4 — antrenöre giden seans bildirimleri, "gölge antrenör"
  /// senaryosunda ADMIN'in cihazına düşüyor (`notificationProxyUid`
  /// yönlendirmesi, bkz. `functions/src/shared/staff-notifications.ts`).
  /// Admin oturumunda [TrainerCalendarPanel] açmak boş bir ekran demek: o
  /// panel oturumdaki uid ile sorguluyor, gölge antrenörün seansları ise
  /// admin uid'siyle eşleşmiyor.
  ///
  /// Rol okuması `app_deep_link_service.dart`'taki desenle aynı: ayrı/erken
  /// bir `currentRoleProvider` okuması YAPILMIYOR, uygulamanın kendi UI'ının
  /// da beklediği [appAccessProvider] beklenir — böylece bildirim hiçbir
  /// zaman normal giriş akışının önüne geçmez/onunla yarışmaz. Erişim
  /// `ready` değilse (hâlâ giriş ekranı, salon askıya alınmış vb.) sessizce
  /// yok sayılır.
  Future<void> _navigateToSessionPanelForRole(
    ProviderContainer container,
    String? sessionId,
  ) async {
    final access = await container.read(appAccessProvider.future);
    if (access.kind != AppAccessKind.ready) return;
    final panelStack = container.read(panelStackControllerProvider.notifier);
    if (access.role == AppRole.admin) {
      // Admin panelinde seans odaklama YOK: panel bugünü açıyor ve iki
      // bildirim de aynı gün içinde gidiyor (ders bitişi / o günün
      // seansları), dolayısıyla doğru gün zaten seçili geliyor. Panelin
      // gün seçimi ay bazlı slot listesiyle senkron olmadığı için (yerel
      // `_date` vs. `adminCalendarController`) başka bir aya atlamak
      // yanlış günün seanslarını gösterirdi.
      panelStack.push(const AdminSessionManagementPanel());
      return;
    }
    panelStack.push(TrainerCalendarPanel(focusSessionId: sessionId));
  }
}
