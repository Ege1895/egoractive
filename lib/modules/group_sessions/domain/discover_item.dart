import 'package:freezed_annotation/freezed_annotation.dart';

part 'discover_item.freezed.dart';

enum DiscoverCategory { groupSessions, events }

@freezed
class DiscoverItem with _$DiscoverItem {
  const factory DiscoverItem({
    required String id,
    required DiscoverCategory category,
    required String day,
    required String month,
    required String title,
    required String meta,
    required int taken,
    required int capacity,
    @Default(false) bool joined,
  }) = _DiscoverItem;

  const DiscoverItem._();

  bool get isFull => taken >= capacity;
}
