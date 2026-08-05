import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/studio_rules.dart';
import '../repository/studio_rules_repository.dart';

part 'studio_rules_controller.g.dart';

const _monthNamesLong = {
  1: 'Ocak', 2: 'Şubat', 3: 'Mart', 4: 'Nisan', 5: 'Mayıs', 6: 'Haziran',
  7: 'Temmuz', 8: 'Ağustos', 9: 'Eylül', 10: 'Ekim', 11: 'Kasım', 12: 'Aralık',
};

@riverpod
class StudioRulesController extends _$StudioRulesController {
  @override
  StudioRules build() => ref.watch(studioRulesRepositoryProvider).loadRules();

  void updateText(String text) {
    final now = DateTime.now();
    state = state.copyWith(text: text, lastUpdatedLabel: '${now.day} ${_monthNamesLong[now.month]} ${now.year}');
  }
}
