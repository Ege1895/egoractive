import 'package:freezed_annotation/freezed_annotation.dart';

part 'discover_item.freezed.dart';

enum DiscoverCategory { groupSessions, events }

@freezed
class DiscoverItem with _$DiscoverItem {
  const factory DiscoverItem({
    required String id,
    required DiscoverCategory category,
    required String day,
    required String month,
    required String title,
    required String meta,
    required int taken,

    /// `null` = sınırsız kontenjan (bazı etkinliklerde olduğu gibi).
    int? capacity,
    @Default(false) bool joined,

    /// Gerçek başlangıç zamanı — kilit kontrolü için.
    DateTime? startTime,
    @Default(24) int lockHoursBefore,

    /// F4-3 — sadece `events` için: bir kez katılındıktan sonra
    /// "Katılmaktan Vazgeç" başlangıca kaç saat kalana kadar aktif.
    @Default(24) int leaveLockHoursBefore,
  }) = _DiscoverItem;

  const DiscoverItem._();

  bool get isFull => capacity != null && taken >= capacity!;

  /// F4-2 — başlangıca `lockHoursBefore` saatten az kaldıysa (veya
  /// geçtiyse) katılım UI'da kilitlenir. Bu kural sadece tekrarlayan
  /// stüdyo derslerini (`groupSessions`) hedefliyor — `events` (Museum
  /// Yoga gibi tek seferlik dış mekan etkinlikleri) kategorisi
  /// başlangıcına kadar her zaman katılıma açık kalır.
  bool get isLocked {
    if (category == DiscoverCategory.events) return false;
    final start = startTime;
    if (start == null) return false;
    return DateTime.now().isAfter(
      start.subtract(Duration(hours: lockHoursBefore)),
    );
  }

  /// F4-3 — bir etkinliğe zaten katılmış bir üye, başlangıca
  /// `leaveLockHoursBefore` saatten az kaldıysa artık "Katılmaktan
  /// Vazgeç" diyemez (sadece bilgilendirme amaçlı "Katılıyorsun"
  /// gösterilir) — son anda kontenjanı boşaltıp organizasyonu
  /// aksatmasını önlemek için. Grup dersleri için zaten `isLocked` aynı
  /// anda hem katılımı hem ayrılmayı kilitliyor, bu getter'a ihtiyaç
  /// duymuyor.
  bool get canLeaveEvent {
    if (category != DiscoverCategory.events) return true;
    final start = startTime;
    if (start == null) return true;
    return DateTime.now().isBefore(
      start.subtract(Duration(hours: leaveLockHoursBefore)),
    );
  }
}
