import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge_item.freezed.dart';

@freezed
class BadgeItem with _$BadgeItem {
  const factory BadgeItem({
    required String id,
    required String title,
    required String note,
    required bool earned,
  }) = _BadgeItem;
}
