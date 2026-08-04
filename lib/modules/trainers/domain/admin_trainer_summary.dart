import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_trainer_summary.freezed.dart';

const trainerSpecialtyOptions = ['Fonksiyonel', 'Pilates', 'Yoga', 'Kickbox'];

@freezed
class AdminTrainerSummary with _$AdminTrainerSummary {
  const factory AdminTrainerSummary({
    required String id,
    required String initials,
    required String name,
    required String phone,
    required List<String> specialties,
    required int memberCount,
  }) = _AdminTrainerSummary;
}
