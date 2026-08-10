import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym_rules.freezed.dart';

/// F4-5 — Quill Delta JSON olarak tutulan zengin metin stüdyo kuralları.
/// Boş içerik = henüz hiç kural yazılmamış, tek satırlık boş bir doküman.
@freezed
class GymRules with _$GymRules {
  const factory GymRules({
    required List<dynamic> delta,
    String? lastUpdatedLabel,
  }) = _GymRules;

  static const empty = [
    {'insert': '\n'},
  ];
}
