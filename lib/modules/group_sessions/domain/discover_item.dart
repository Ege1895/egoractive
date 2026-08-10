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
  }) = _DiscoverItem;

  const DiscoverItem._();

  bool get isFull => capacity != null && taken >= capacity!;

  /// F4-2 — başlangıca `lockHoursBefore` saatten az kaldıysa (veya
  /// geçtiyse) katılım/ayrılma UI'da kilitlenir.
  bool get isLocked {
    final start = startTime;
    if (start == null) return false;
    return DateTime.now().isAfter(start.subtract(Duration(hours: lockHoursBefore)));
  }
}
