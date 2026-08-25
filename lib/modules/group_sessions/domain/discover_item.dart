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

    /// Gerçek başlangıç zamanı — vazgeçme kilidi kontrolü için.
    DateTime? startTime,

    /// F4-2/F4-3 — bir kez katılındıktan sonra "Katılmaktan Vazgeç"
    /// başlangıca kaç saat kalana kadar aktif; kategoriye göre ayrı RC
    /// anahtarından gelir (bkz. discover_controller.dart).
    @Default(24) int leaveLockHoursBefore,
  }) = _DiscoverItem;

  const DiscoverItem._();

  bool get isFull => capacity != null && taken >= capacity!;

  /// F4-2/F4-3 — katılım (henüz katılmamışken) her zaman açık, başlangıca
  /// kadar herkes katılabilir. Bir kez katılmış bir üye ise başlangıca
  /// `leaveLockHoursBefore` saatten az kaldıysa artık "Katılmaktan
  /// Vazgeç" diyemez (sadece bilgilendirme amaçlı, dokunulamaz
  /// "Katılıyorsun" gösterilir) — son anda kontenjanı boşaltıp
  /// organizasyonu/dersi aksatmasını önlemek için.
  bool get canLeave {
    final start = startTime;
    if (start == null) return true;
    return DateTime.now().isBefore(
      start.subtract(Duration(hours: leaveLockHoursBefore)),
    );
  }
}
