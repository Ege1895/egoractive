// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discover_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DiscoverItem {
  String get id => throw _privateConstructorUsedError;
  DiscoverCategory get category => throw _privateConstructorUsedError;
  String get day => throw _privateConstructorUsedError;
  String get month => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get meta => throw _privateConstructorUsedError;
  int get taken => throw _privateConstructorUsedError;

  /// `null` = sınırsız kontenjan (bazı etkinliklerde olduğu gibi).
  int? get capacity => throw _privateConstructorUsedError;
  bool get joined => throw _privateConstructorUsedError;

  /// Gerçek başlangıç zamanı — vazgeçme kilidi kontrolü için.
  DateTime? get startTime => throw _privateConstructorUsedError;

  /// F4-2/F4-3 — bir kez katılındıktan sonra "Katılmaktan Vazgeç"
  /// başlangıca kaç saat kalana kadar aktif; kategoriye göre ayrı RC
  /// anahtarından gelir (bkz. discover_controller.dart).
  int get leaveLockHoursBefore => throw _privateConstructorUsedError;

  /// Create a copy of DiscoverItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscoverItemCopyWith<DiscoverItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoverItemCopyWith<$Res> {
  factory $DiscoverItemCopyWith(
    DiscoverItem value,
    $Res Function(DiscoverItem) then,
  ) = _$DiscoverItemCopyWithImpl<$Res, DiscoverItem>;
  @useResult
  $Res call({
    String id,
    DiscoverCategory category,
    String day,
    String month,
    String title,
    String meta,
    int taken,
    int? capacity,
    bool joined,
    DateTime? startTime,
    int leaveLockHoursBefore,
  });
}

/// @nodoc
class _$DiscoverItemCopyWithImpl<$Res, $Val extends DiscoverItem>
    implements $DiscoverItemCopyWith<$Res> {
  _$DiscoverItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscoverItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? day = null,
    Object? month = null,
    Object? title = null,
    Object? meta = null,
    Object? taken = null,
    Object? capacity = freezed,
    Object? joined = null,
    Object? startTime = freezed,
    Object? leaveLockHoursBefore = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as DiscoverCategory,
            day: null == day
                ? _value.day
                : day // ignore: cast_nullable_to_non_nullable
                      as String,
            month: null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as String,
            taken: null == taken
                ? _value.taken
                : taken // ignore: cast_nullable_to_non_nullable
                      as int,
            capacity: freezed == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int?,
            joined: null == joined
                ? _value.joined
                : joined // ignore: cast_nullable_to_non_nullable
                      as bool,
            startTime: freezed == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            leaveLockHoursBefore: null == leaveLockHoursBefore
                ? _value.leaveLockHoursBefore
                : leaveLockHoursBefore // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiscoverItemImplCopyWith<$Res>
    implements $DiscoverItemCopyWith<$Res> {
  factory _$$DiscoverItemImplCopyWith(
    _$DiscoverItemImpl value,
    $Res Function(_$DiscoverItemImpl) then,
  ) = __$$DiscoverItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DiscoverCategory category,
    String day,
    String month,
    String title,
    String meta,
    int taken,
    int? capacity,
    bool joined,
    DateTime? startTime,
    int leaveLockHoursBefore,
  });
}

/// @nodoc
class __$$DiscoverItemImplCopyWithImpl<$Res>
    extends _$DiscoverItemCopyWithImpl<$Res, _$DiscoverItemImpl>
    implements _$$DiscoverItemImplCopyWith<$Res> {
  __$$DiscoverItemImplCopyWithImpl(
    _$DiscoverItemImpl _value,
    $Res Function(_$DiscoverItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscoverItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? day = null,
    Object? month = null,
    Object? title = null,
    Object? meta = null,
    Object? taken = null,
    Object? capacity = freezed,
    Object? joined = null,
    Object? startTime = freezed,
    Object? leaveLockHoursBefore = null,
  }) {
    return _then(
      _$DiscoverItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as DiscoverCategory,
        day: null == day
            ? _value.day
            : day // ignore: cast_nullable_to_non_nullable
                  as String,
        month: null == month
            ? _value.month
            : month // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as String,
        taken: null == taken
            ? _value.taken
            : taken // ignore: cast_nullable_to_non_nullable
                  as int,
        capacity: freezed == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int?,
        joined: null == joined
            ? _value.joined
            : joined // ignore: cast_nullable_to_non_nullable
                  as bool,
        startTime: freezed == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        leaveLockHoursBefore: null == leaveLockHoursBefore
            ? _value.leaveLockHoursBefore
            : leaveLockHoursBefore // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$DiscoverItemImpl extends _DiscoverItem {
  const _$DiscoverItemImpl({
    required this.id,
    required this.category,
    required this.day,
    required this.month,
    required this.title,
    required this.meta,
    required this.taken,
    this.capacity,
    this.joined = false,
    this.startTime,
    this.leaveLockHoursBefore = 24,
  }) : super._();

  @override
  final String id;
  @override
  final DiscoverCategory category;
  @override
  final String day;
  @override
  final String month;
  @override
  final String title;
  @override
  final String meta;
  @override
  final int taken;

  /// `null` = sınırsız kontenjan (bazı etkinliklerde olduğu gibi).
  @override
  final int? capacity;
  @override
  @JsonKey()
  final bool joined;

  /// Gerçek başlangıç zamanı — vazgeçme kilidi kontrolü için.
  @override
  final DateTime? startTime;

  /// F4-2/F4-3 — bir kez katılındıktan sonra "Katılmaktan Vazgeç"
  /// başlangıca kaç saat kalana kadar aktif; kategoriye göre ayrı RC
  /// anahtarından gelir (bkz. discover_controller.dart).
  @override
  @JsonKey()
  final int leaveLockHoursBefore;

  @override
  String toString() {
    return 'DiscoverItem(id: $id, category: $category, day: $day, month: $month, title: $title, meta: $meta, taken: $taken, capacity: $capacity, joined: $joined, startTime: $startTime, leaveLockHoursBefore: $leaveLockHoursBefore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscoverItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.taken, taken) || other.taken == taken) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.joined, joined) || other.joined == joined) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.leaveLockHoursBefore, leaveLockHoursBefore) ||
                other.leaveLockHoursBefore == leaveLockHoursBefore));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    category,
    day,
    month,
    title,
    meta,
    taken,
    capacity,
    joined,
    startTime,
    leaveLockHoursBefore,
  );

  /// Create a copy of DiscoverItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscoverItemImplCopyWith<_$DiscoverItemImpl> get copyWith =>
      __$$DiscoverItemImplCopyWithImpl<_$DiscoverItemImpl>(this, _$identity);
}

abstract class _DiscoverItem extends DiscoverItem {
  const factory _DiscoverItem({
    required final String id,
    required final DiscoverCategory category,
    required final String day,
    required final String month,
    required final String title,
    required final String meta,
    required final int taken,
    final int? capacity,
    final bool joined,
    final DateTime? startTime,
    final int leaveLockHoursBefore,
  }) = _$DiscoverItemImpl;
  const _DiscoverItem._() : super._();

  @override
  String get id;
  @override
  DiscoverCategory get category;
  @override
  String get day;
  @override
  String get month;
  @override
  String get title;
  @override
  String get meta;
  @override
  int get taken;

  /// `null` = sınırsız kontenjan (bazı etkinliklerde olduğu gibi).
  @override
  int? get capacity;
  @override
  bool get joined;

  /// Gerçek başlangıç zamanı — vazgeçme kilidi kontrolü için.
  @override
  DateTime? get startTime;

  /// F4-2/F4-3 — bir kez katılındıktan sonra "Katılmaktan Vazgeç"
  /// başlangıca kaç saat kalana kadar aktif; kategoriye göre ayrı RC
  /// anahtarından gelir (bkz. discover_controller.dart).
  @override
  int get leaveLockHoursBefore;

  /// Create a copy of DiscoverItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscoverItemImplCopyWith<_$DiscoverItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
