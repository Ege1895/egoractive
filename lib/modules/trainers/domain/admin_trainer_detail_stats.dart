import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_trainer_detail_stats.freezed.dart';

/// [AdminTrainerDetailPanel]'in "TÜM ZAMANLAR" bölümü — antrenörün
/// `sessions` koleksiyonundaki tüm zamanlı toplam sayıları.
@freezed
class AdminTrainerDetailStats with _$AdminTrainerDetailStats {
  const factory AdminTrainerDetailStats({
    required int totalSessions,
    required int completedSessions,
    required int cancelledSessions,
    required int plannedSessions,
  }) = _AdminTrainerDetailStats;

  const AdminTrainerDetailStats._();

  static const empty = AdminTrainerDetailStats(
    totalSessions: 0,
    completedSessions: 0,
    cancelledSessions: 0,
    plannedSessions: 0,
  );
}
