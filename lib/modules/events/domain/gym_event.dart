import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym_event.freezed.dart';

@freezed
class GymEvent with _$GymEvent {
  const factory GymEvent({
    required String id,
    required String name,
    required String location,
    required String day,
    required String month,
    required String meta,
    required int joined,
    int? capacity,
    @Default(false) bool isCancelled,
  }) = _GymEvent;

  const GymEvent._();

  /// [unlimitedLabel] RC'den (aktif dile göre) UI katmanında geçilir —
  /// domain katmanı Remote Config'e erişmiyor.
  String capacityLabel(String unlimitedLabel) =>
      capacity == null ? unlimitedLabel : '$capacity';
}
