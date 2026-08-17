import 'dart:ui' show PlatformDispatcher;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/panels/panel_stack_controller.dart';
import '../../sessions/ui/panels/attendance_confirm_panel.dart';
import '../../../firebase_options.dart';

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

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'session_reminders',
    'Ders Hatırlatmaları',
    description: 'Yaklaşan dersler için hatırlatma bildirimleri',
    importance: Importance.high,
  );

  Future<void> init(ProviderContainer container) async {
    await FirebaseMessaging.instance.requestPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (_) => _navigateToReminderPanel(container),
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

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((_) => _navigateToReminderPanel(container));

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _navigateToReminderPanel(container);
  }

  /// `locale` de burada kaydediliyor — Cloud Functions'ın gönderdiği push
  /// metinlerini kullanıcının cihaz diline göre seçebilmesi için (F3-4).
  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final locale = PlatformDispatcher.instance.locale.languageCode == 'tr' ? 'tr' : 'en';
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
        'locale': locale,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(_androidChannel.id, _androidChannel.name),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Bildirime dokununca gidilecek (mock) panel — seans hatırlatması,
  /// üyenin "Gelecek misin?" onay ekranına düşer (F2-7 kabul kriteri).
  void _navigateToReminderPanel(ProviderContainer container) {
    container.read(panelStackControllerProvider.notifier).push(const AttendanceConfirmPanel());
  }
}
