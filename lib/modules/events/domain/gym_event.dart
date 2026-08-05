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
  }) = _GymEvent;

  const GymEvent._();

  String get capacityLabel => capacity == null ? 'Sınırsız' : '$capacity';
}
