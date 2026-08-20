import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym_theme.freezed.dart';

@freezed
class GymTheme with _$GymTheme {
  const factory GymTheme({
    required String id,
    required String name,
    required Color primary,
    required Color soft,
    required String note,
  }) = _GymTheme;
}

@freezed
class GymThemeState with _$GymThemeState {
  const factory GymThemeState({
    required List<GymTheme> themes,
    required String activeThemeId,
    @Default(true) bool watermarkEnabled,
    String? errorMessage,
  }) = _GymThemeState;
}
