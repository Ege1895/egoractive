import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/discover_item.dart';
import '../repository/discover_repository.dart';

part 'discover_controller.g.dart';

@riverpod
class DiscoverController extends _$DiscoverController {
  @override
  List<DiscoverItem> build() => ref.watch(discoverRepositoryProvider).loadItems();

  void toggleJoin(String id) {
    state = [
      for (final item in state)
        if (item.id == id && !item.isFull)
          item.copyWith(joined: !item.joined, taken: item.joined ? item.taken - 1 : item.taken + 1)
        else
          item,
    ];
  }
}
