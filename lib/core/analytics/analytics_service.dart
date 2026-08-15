import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_service.g.dart';

/// F5-6 — tüm Analytics event isimleri burada toplanır; kod içinde hiçbir
/// yerde ham string event adı geçmez (kabul kriteri). Yeni bir event
/// eklemek bu enum'a bir değer + [_eventName]'e bir karşılık eklemek demek.
enum AnalyticsEvent {
  membershipCreated,
  sessionCompleted,
  sessionCancelled,
  packagePurchased,
  feedbackSubmitted,
}

extension on AnalyticsEvent {
  /// Firebase Analytics event adı kuralları: en fazla 40 karakter, sadece
  /// harf/rakam/alt çizgi, rakamla başlayamaz — bu yüzden enum adının
  /// camelCase'i değil, elle yazılmış snake_case karşılığı kullanılıyor.
  String get eventName => switch (this) {
        AnalyticsEvent.membershipCreated => 'membership_created',
        AnalyticsEvent.sessionCompleted => 'session_completed',
        AnalyticsEvent.sessionCancelled => 'session_cancelled',
        AnalyticsEvent.packagePurchased => 'package_purchased',
        AnalyticsEvent.feedbackSubmitted => 'feedback_submitted',
      };
}

/// `FirebaseAnalytics.instance` bu dosya dışında hiçbir yerde çağrılmaz —
/// tüm modüller event loglamak için bu servisi kullanır.
class AnalyticsService {
  const AnalyticsService();

  Future<void> logEvent(AnalyticsEvent event, {Map<String, Object> parameters = const {}}) {
    return FirebaseAnalytics.instance.logEvent(name: event.eventName, parameters: parameters);
  }
}

@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) => const AnalyticsService();
