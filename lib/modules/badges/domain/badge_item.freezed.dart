// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badge_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BadgeItem {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  bool get earned => throw _privateConstructorUsedError;

  /// Create a copy of BadgeItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BadgeItemCopyWith<BadgeItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeItemCopyWith<$Res> {
  factory $BadgeItemCopyWith(BadgeItem value, $Res Function(BadgeItem) then) =
      _$BadgeItemCopyWithImpl<$Res, BadgeItem>;
  @useResult
  $Res call({String id, String title, String note, bool earned});
}

/// @nodoc
class _$BadgeItemCopyWithImpl<$Res, $Val extends BadgeItem>
    implements $BadgeItemCopyWith<$Res> {
  _$BadgeItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BadgeItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? note = null,
    Object? earned = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
            earned: null == earned
                ? _value.earned
                : earned // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BadgeItemImplCopyWith<$Res>
    implements $BadgeItemCopyWith<$Res> {
  factory _$$BadgeItemImplCopyWith(
    _$BadgeItemImpl value,
    $Res Function(_$BadgeItemImpl) then,
  ) = __$$BadgeItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String note, bool earned});
}

/// @nodoc
class __$$BadgeItemImplCopyWithImpl<$Res>
    extends _$BadgeItemCopyWithImpl<$Res, _$BadgeItemImpl>
    implements _$$BadgeItemImplCopyWith<$Res> {
  __$$BadgeItemImplCopyWithImpl(
    _$BadgeItemImpl _value,
    $Res Function(_$BadgeItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BadgeItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? note = null,
    Object? earned = null,
  }) {
    return _then(
      _$BadgeItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
        earned: null == earned
            ? _value.earned
            : earned // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$BadgeItemImpl implements _BadgeItem {
  const _$BadgeItemImpl({
    required this.id,
    required this.title,
    required this.note,
    required this.earned,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String note;
  @override
  final bool earned;

  @override
  String toString() {
    return 'BadgeItem(id: $id, title: $title, note: $note, earned: $earned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.earned, earned) || other.earned == earned));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, note, earned);

  /// Create a copy of BadgeItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeItemImplCopyWith<_$BadgeItemImpl> get copyWith =>
      __$$BadgeItemImplCopyWithImpl<_$BadgeItemImpl>(this, _$identity);
}

abstract class _BadgeItem implements BadgeItem {
  const factory _BadgeItem({
    required final String id,
    required final String title,
    required final String note,
    required final bool earned,
  }) = _$BadgeItemImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get note;
  @override
  bool get earned;

  /// Create a copy of BadgeItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BadgeItemImplCopyWith<_$BadgeItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
