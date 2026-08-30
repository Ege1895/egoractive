import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_activity_breakdown.freezed.dart';

/// [AdminTrainerDetailPanel]'in "BU AY"/"BU HAFTA" bölümleri — antrenörün
/// birebir ve düet seanslarını tamamlanan/planlanan olarak kırar. Grup
/// dersleri (`groupSessions`) burada YOK: o koleksiyon şu an bir antrenöre
/// atanmıyor (sadece admin oluşturabiliyor, `trainerName` her zaman
/// oluşturan admin'in adı) — bir trainer-picker eklenmeden doğru sayı
/// üretilemez.
@freezed
class TrainerActivityCounts with _$TrainerActivityCounts {
  const factory TrainerActivityCounts({
    required int individualCompleted,
    required int individualPlanned,
    required int duetCompleted,
    required int duetPlanned,
  }) = _TrainerActivityCounts;

  static const empty = TrainerActivityCounts(
    individualCompleted: 0,
    individualPlanned: 0,
    duetCompleted: 0,
    duetPlanned: 0,
  );
}

@freezed
class TrainerActivityBreakdown with _$TrainerActivityBreakdown {
  const factory TrainerActivityBreakdown({
    required TrainerActivityCounts monthly,
    required TrainerActivityCounts weekly,
  }) = _TrainerActivityBreakdown;

  static const empty = TrainerActivityBreakdown(
    monthly: TrainerActivityCounts.empty,
    weekly: TrainerActivityCounts.empty,
  );
}
