// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ScheduleSlot {
  String get id => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get meta => throw _privateConstructorUsedError;
  ScheduleSlotState get state => throw _privateConstructorUsedError;

  /// Seansın gerçek başlangıç zamanı — antrenörün "Dersi onayla"
  /// sheet'inin 24 saatlik onay penceresini hesaplamak için gerekli
  /// (bkz. `trainer_calendar_panel.dart`, `_showSlotDetail`).
  DateTime get startTime => throw _privateConstructorUsedError;
  String get memberId => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleSlotCopyWith<ScheduleSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleSlotCopyWith<$Res> {
  factory $ScheduleSlotCopyWith(
    ScheduleSlot value,
    $Res Function(ScheduleSlot) then,
  ) = _$ScheduleSlotCopyWithImpl<$Res, ScheduleSlot>;
  @useResult
  $Res call({
    String id,
    String time,
    String name,
    String meta,
    ScheduleSlotState state,
    DateTime startTime,
    String memberId,
  });
}

/// @nodoc
class _$ScheduleSlotCopyWithImpl<$Res, $Val extends ScheduleSlot>
    implements $ScheduleSlotCopyWith<$Res> {
  _$ScheduleSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? name = null,
    Object? meta = null,
    Object? state = null,
    Object? startTime = null,
    Object? memberId = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as String,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as ScheduleSlotState,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            memberId: null == memberId
                ? _value.memberId
                : memberId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScheduleSlotImplCopyWith<$Res>
    implements $ScheduleSlotCopyWith<$Res> {
  factory _$$ScheduleSlotImplCopyWith(
    _$ScheduleSlotImpl value,
    $Res Function(_$ScheduleSlotImpl) then,
  ) = __$$ScheduleSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String time,
    String name,
    String meta,
    ScheduleSlotState state,
    DateTime startTime,
    String memberId,
  });
}

/// @nodoc
class __$$ScheduleSlotImplCopyWithImpl<$Res>
    extends _$ScheduleSlotCopyWithImpl<$Res, _$ScheduleSlotImpl>
    implements _$$ScheduleSlotImplCopyWith<$Res> {
  __$$ScheduleSlotImplCopyWithImpl(
    _$ScheduleSlotImpl _value,
    $Res Function(_$ScheduleSlotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScheduleSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? name = null,
    Object? meta = null,
    Object? state = null,
    Object? startTime = null,
    Object? memberId = null,
  }) {
    return _then(
      _$ScheduleSlotImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as ScheduleSlotState,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        memberId: null == memberId
            ? _value.memberId
            : memberId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ScheduleSlotImpl implements _ScheduleSlot {
  const _$ScheduleSlotImpl({
    required this.id,
    required this.time,
    required this.name,
    required this.meta,
    required this.state,
    required this.startTime,
    this.memberId = '',
  });

  @override
  final String id;
  @override
  final String time;
  @override
  final String name;
  @override
  final String meta;
  @override
  final ScheduleSlotState state;

  /// Seansın gerçek başlangıç zamanı — antrenörün "Dersi onayla"
  /// sheet'inin 24 saatlik onay penceresini hesaplamak için gerekli
  /// (bkz. `trainer_calendar_panel.dart`, `_showSlotDetail`).
  @override
  final DateTime startTime;
  @override
  @JsonKey()
  final String memberId;

  @override
  String toString() {
    return 'ScheduleSlot(id: $id, time: $time, name: $name, meta: $meta, state: $state, startTime: $startTime, memberId: $memberId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleSlotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    time,
    name,
    meta,
    state,
    startTime,
    memberId,
  );

  /// Create a copy of ScheduleSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleSlotImplCopyWith<_$ScheduleSlotImpl> get copyWith =>
      __$$ScheduleSlotImplCopyWithImpl<_$ScheduleSlotImpl>(this, _$identity);
}

abstract class _ScheduleSlot implements ScheduleSlot {
  const factory _ScheduleSlot({
    required final String id,
    required final String time,
    required final String name,
    required final String meta,
    required final ScheduleSlotState state,
    required final DateTime startTime,
    final String memberId,
  }) = _$ScheduleSlotImpl;

  @override
  String get id;
  @override
  String get time;
  @override
  String get name;
  @override
  String get meta;
  @override
  ScheduleSlotState get state;

  /// Seansın gerçek başlangıç zamanı — antrenörün "Dersi onayla"
  /// sheet'inin 24 saatlik onay penceresini hesaplamak için gerekli
  /// (bkz. `trainer_calendar_panel.dart`, `_showSlotDetail`).
  @override
  DateTime get startTime;
  @override
  String get memberId;

  /// Create a copy of ScheduleSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleSlotImplCopyWith<_$ScheduleSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
