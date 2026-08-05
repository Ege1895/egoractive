import 'package:freezed_annotation/freezed_annotation.dart';

part 'studio_rules.freezed.dart';

const studioRulesMaxLength = 2000;

@freezed
class StudioRules with _$StudioRules {
  const factory StudioRules({
    required String text,
    required String lastUpdatedLabel,
  }) = _StudioRules;
}
