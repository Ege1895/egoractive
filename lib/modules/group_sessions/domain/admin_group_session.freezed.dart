// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_group_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdminGroupSession {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get meta => throw _privateConstructorUsedError;
  int get taken => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  bool get isCancelled => throw _privateConstructorUsedError;

  /// Create a copy of AdminGroupSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminGroupSessionCopyWith<AdminGroupSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminGroupSessionCopyWith<$Res> {
  factory $AdminGroupSessionCopyWith(
    AdminGroupSession value,
    $Res Function(AdminGroupSession) then,
  ) = _$AdminGroupSessionCopyWithImpl<$Res, AdminGroupSession>;
  @useResult
  $Res call({
    String id,
    String name,
    String meta,
    int taken,
    int capacity,
    bool isCancelled,
  });
}

/// @nodoc
class _$AdminGroupSessionCopyWithImpl<$Res, $Val extends AdminGroupSession>
    implements $AdminGroupSessionCopyWith<$Res> {
  _$AdminGroupSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminGroupSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? meta = null,
    Object? taken = null,
    Object? capacity = null,
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
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as String,
            taken: null == taken
                ? _value.taken
                : taken // ignore: cast_nullable_to_non_nullable
                      as int,
            capacity: null == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$AdminGroupSessionImplCopyWith<$Res>
    implements $AdminGroupSessionCopyWith<$Res> {
  factory _$$AdminGroupSessionImplCopyWith(
    _$AdminGroupSessionImpl value,
    $Res Function(_$AdminGroupSessionImpl) then,
  ) = __$$AdminGroupSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String meta,
    int taken,
    int capacity,
    bool isCancelled,
  });
}

/// @nodoc
class __$$AdminGroupSessionImplCopyWithImpl<$Res>
    extends _$AdminGroupSessionCopyWithImpl<$Res, _$AdminGroupSessionImpl>
    implements _$$AdminGroupSessionImplCopyWith<$Res> {
  __$$AdminGroupSessionImplCopyWithImpl(
    _$AdminGroupSessionImpl _value,
    $Res Function(_$AdminGroupSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminGroupSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? meta = null,
    Object? taken = null,
    Object? capacity = null,
    Object? isCancelled = null,
  }) {
    return _then(
      _$AdminGroupSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as String,
        taken: null == taken
            ? _value.taken
            : taken // ignore: cast_nullable_to_non_nullable
                  as int,
        capacity: null == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int,
        isCancelled: null == isCancelled
            ? _value.isCancelled
            : isCancelled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$AdminGroupSessionImpl extends _AdminGroupSession {
  const _$AdminGroupSessionImpl({
    required this.id,
    required this.name,
    required this.meta,
    required this.taken,
    required this.capacity,
    this.isCancelled = false,
  }) : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final String meta;
  @override
  final int taken;
  @override
  final int capacity;
  @override
  @JsonKey()
  final bool isCancelled;

  @override
  String toString() {
    return 'AdminGroupSession(id: $id, name: $name, meta: $meta, taken: $taken, capacity: $capacity, isCancelled: $isCancelled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminGroupSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.taken, taken) || other.taken == taken) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.isCancelled, isCancelled) ||
                other.isCancelled == isCancelled));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, meta, taken, capacity, isCancelled);

  /// Create a copy of AdminGroupSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminGroupSessionImplCopyWith<_$AdminGroupSessionImpl> get copyWith =>
      __$$AdminGroupSessionImplCopyWithImpl<_$AdminGroupSessionImpl>(
        this,
        _$identity,
      );
}

abstract class _AdminGroupSession extends AdminGroupSession {
  const factory _AdminGroupSession({
    required final String id,
    required final String name,
    required final String meta,
    required final int taken,
    required final int capacity,
    final bool isCancelled,
  }) = _$AdminGroupSessionImpl;
  const _AdminGroupSession._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  String get meta;
  @override
  int get taken;
  @override
  int get capacity;
  @override
  bool get isCancelled;

  /// Create a copy of AdminGroupSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminGroupSessionImplCopyWith<_$AdminGroupSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
