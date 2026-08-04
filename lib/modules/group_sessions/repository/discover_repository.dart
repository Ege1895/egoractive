import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/discover_item.dart';
import '../service/discover_service.dart';

part 'discover_repository.g.dart';

abstract interface class DiscoverRepository {
  List<DiscoverItem> loadItems();
}

class DiscoverRepositoryImpl implements DiscoverRepository {
  const DiscoverRepositoryImpl(this._service);

  final DiscoverService _service;

  @override
  List<DiscoverItem> loadItems() => _service.loadItems();
}

@riverpod
DiscoverRepository discoverRepository(DiscoverRepositoryRef ref) {
  return DiscoverRepositoryImpl(ref.watch(discoverServiceProvider));
}
