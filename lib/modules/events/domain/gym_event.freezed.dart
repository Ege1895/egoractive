// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gym_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GymEvent {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get day => throw _privateConstructorUsedError;
  String get month => throw _privateConstructorUsedError;
  String get meta => throw _privateConstructorUsedError;
  int get joined => throw _privateConstructorUsedError;
  int? get capacity => throw _privateConstructorUsedError;
  bool get isCancelled => throw _privateConstructorUsedError;

  /// Create a copy of GymEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GymEventCopyWith<GymEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GymEventCopyWith<$Res> {
  factory $GymEventCopyWith(GymEvent value, $Res Function(GymEvent) then) =
      _$GymEventCopyWithImpl<$Res, GymEvent>;
  @useResult
  $Res call({
    String id,
    String name,
    String location,
    String day,
    String month,
    String meta,
    int joined,
    int? capacity,
    bool isCancelled,
  });
}

/// @nodoc
class _$GymEventCopyWithImpl<$Res, $Val extends GymEvent>
    implements $GymEventCopyWith<$Res> {
  _$GymEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GymEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? location = null,
    Object? day = null,
    Object? month = null,
    Object? meta = null,
    Object? joined = null,
    Object? capacity = freezed,
    Object? isCancelled = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String,
            day: null == day
                ? _value.day
                : day // ignore: cast_nullable_to_non_nullable
                      as String,
            month: null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                      as String,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as String,
            joined: null == joined
                ? _value.joined
                : joined // ignore: cast_nullable_to_non_nullable
                      as int,
            capacity: freezed == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int?,
            isCancelled: null == isCancelled
                ? _value.isCancelled
                : isCancelled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GymEventImplCopyWith<$Res>
    implements $GymEventCopyWith<$Res> {
  factory _$$GymEventImplCopyWith(
    _$GymEventImpl value,
    $Res Function(_$GymEventImpl) then,
  ) = __$$GymEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String location,
    String day,
    String month,
    String meta,
    int joined,
    int? capacity,
    bool isCancelled,
  });
}

/// @nodoc
class __$$GymEventImplCopyWithImpl<$Res>
    extends _$GymEventCopyWithImpl<$Res, _$GymEventImpl>
    implements _$$GymEventImplCopyWith<$Res> {
  __$$GymEventImplCopyWithImpl(
    _$GymEventImpl _value,
    $Res Function(_$GymEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GymEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? location = null,
    Object? day = null,
    Object? month = null,
    Object? meta = null,
    Object? joined = null,
    Object? capacity = freezed,
    Object? isCancelled = null,
  }) {
    return _then(
      _$GymEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String,
        day: null == day
            ? _value.day
            : day // ignore: cast_nullable_to_non_nullable
                  as String,
        month: null == month
            ? _value.month
            : month // ignore: cast_nullable_to_non_nullable
                  as String,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as String,
        joined: null == joined
            ? _value.joined
            : joined // ignore: cast_nullable_to_non_nullable
                  as int,
        capacity: freezed == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int?,
        isCancelled: null == isCancelled
            ? _value.isCancelled
            : isCancelled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$GymEventImpl extends _GymEvent {
  const _$GymEventImpl({
    required this.id,
    required this.name,
    required this.location,
    required this.day,
    required this.month,
    required this.meta,
    required this.joined,
    this.capacity,
    this.isCancelled = false,
  }) : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final String location;
  @override
  final String day;
  @override
  final String month;
  @override
  final String meta;
  @override
  final int joined;
  @override
  final int? capacity;
  @override
  @JsonKey()
  final bool isCancelled;

  @override
  String toString() {
    return 'GymEvent(id: $id, name: $name, location: $location, day: $day, month: $month, meta: $meta, joined: $joined, capacity: $capacity, isCancelled: $isCancelled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GymEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.joined, joined) || other.joined == joined) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.isCancelled, isCancelled) ||
                other.isCancelled == isCancelled));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    location,
    day,
    month,
    meta,
    joined,
    capacity,
    isCancelled,
  );

  /// Create a copy of GymEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GymEventImplCopyWith<_$GymEventImpl> get copyWith =>
      __$$GymEventImplCopyWithImpl<_$GymEventImpl>(this, _$identity);
}

abstract class _GymEvent extends GymEvent {
  const factory _GymEvent({
    required final String id,
    required final String name,
    required final String location,
    required final String day,
    required final String month,
    required final String meta,
    required final int joined,
    final int? capacity,
    final bool isCancelled,
  }) = _$GymEventImpl;
  const _GymEvent._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  String get location;
  @override
  String get day;
  @override
  String get month;
  @override
  String get meta;
  @override
  int get joined;
  @override
  int? get capacity;
  @override
  bool get isCancelled;

  /// Create a copy of GymEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GymEventImplCopyWith<_$GymEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
