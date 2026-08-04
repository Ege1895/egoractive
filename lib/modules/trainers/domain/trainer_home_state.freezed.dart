// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TrainerHomeState {
  int get todaySessionCount => throw _privateConstructorUsedError;
  int get completedCount => throw _privateConstructorUsedError;
  int get freeSlotCount => throw _privateConstructorUsedError;
  List<PendingConfirmation> get pendingConfirmations =>
      throw _privateConstructorUsedError;
  List<ScheduleSlot> get todaySchedule => throw _privateConstructorUsedError;

  /// Create a copy of TrainerHomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerHomeStateCopyWith<TrainerHomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerHomeStateCopyWith<$Res> {
  factory $TrainerHomeStateCopyWith(
    TrainerHomeState value,
    $Res Function(TrainerHomeState) then,
  ) = _$TrainerHomeStateCopyWithImpl<$Res, TrainerHomeState>;
  @useResult
  $Res call({
    int todaySessionCount,
    int completedCount,
    int freeSlotCount,
    List<PendingConfirmation> pendingConfirmations,
    List<ScheduleSlot> todaySchedule,
  });
}

/// @nodoc
class _$TrainerHomeStateCopyWithImpl<$Res, $Val extends TrainerHomeState>
    implements $TrainerHomeStateCopyWith<$Res> {
  _$TrainerHomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerHomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todaySessionCount = null,
    Object? completedCount = null,
    Object? freeSlotCount = null,
    Object? pendingConfirmations = null,
    Object? todaySchedule = null,
  }) {
    return _then(
      _value.copyWith(
            todaySessionCount: null == todaySessionCount
                ? _value.todaySessionCount
                : todaySessionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            completedCount: null == completedCount
                ? _value.completedCount
                : completedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            freeSlotCount: null == freeSlotCount
                ? _value.freeSlotCount
                : freeSlotCount // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingConfirmations: null == pendingConfirmations
                ? _value.pendingConfirmations
                : pendingConfirmations // ignore: cast_nullable_to_non_nullable
                      as List<PendingConfirmation>,
            todaySchedule: null == todaySchedule
                ? _value.todaySchedule
                : todaySchedule // ignore: cast_nullable_to_non_nullable
                      as List<ScheduleSlot>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerHomeStateImplCopyWith<$Res>
    implements $TrainerHomeStateCopyWith<$Res> {
  factory _$$TrainerHomeStateImplCopyWith(
    _$TrainerHomeStateImpl value,
    $Res Function(_$TrainerHomeStateImpl) then,
  ) = __$$TrainerHomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int todaySessionCount,
    int completedCount,
    int freeSlotCount,
    List<PendingConfirmation> pendingConfirmations,
    List<ScheduleSlot> todaySchedule,
  });
}

/// @nodoc
class __$$TrainerHomeStateImplCopyWithImpl<$Res>
    extends _$TrainerHomeStateCopyWithImpl<$Res, _$TrainerHomeStateImpl>
    implements _$$TrainerHomeStateImplCopyWith<$Res> {
  __$$TrainerHomeStateImplCopyWithImpl(
    _$TrainerHomeStateImpl _value,
    $Res Function(_$TrainerHomeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerHomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todaySessionCount = null,
    Object? completedCount = null,
    Object? freeSlotCount = null,
    Object? pendingConfirmations = null,
    Object? todaySchedule = null,
  }) {
    return _then(
      _$TrainerHomeStateImpl(
        todaySessionCount: null == todaySessionCount
            ? _value.todaySessionCount
            : todaySessionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        completedCount: null == completedCount
            ? _value.completedCount
            : completedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        freeSlotCount: null == freeSlotCount
            ? _value.freeSlotCount
            : freeSlotCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingConfirmations: null == pendingConfirmations
            ? _value._pendingConfirmations
            : pendingConfirmations // ignore: cast_nullable_to_non_nullable
                  as List<PendingConfirmation>,
        todaySchedule: null == todaySchedule
            ? _value._todaySchedule
            : todaySchedule // ignore: cast_nullable_to_non_nullable
                  as List<ScheduleSlot>,
      ),
    );
  }
}

/// @nodoc

class _$TrainerHomeStateImpl implements _TrainerHomeState {
  const _$TrainerHomeStateImpl({
    required this.todaySessionCount,
    required this.completedCount,
    required this.freeSlotCount,
    required final List<PendingConfirmation> pendingConfirmations,
    required final List<ScheduleSlot> todaySchedule,
  }) : _pendingConfirmations = pendingConfirmations,
       _todaySchedule = todaySchedule;

  @override
  final int todaySessionCount;
  @override
  final int completedCount;
  @override
  final int freeSlotCount;
  final List<PendingConfirmation> _pendingConfirmations;
  @override
  List<PendingConfirmation> get pendingConfirmations {
    if (_pendingConfirmations is EqualUnmodifiableListView)
      return _pendingConfirmations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingConfirmations);
  }

  final List<ScheduleSlot> _todaySchedule;
  @override
  List<ScheduleSlot> get todaySchedule {
    if (_todaySchedule is EqualUnmodifiableListView) return _todaySchedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todaySchedule);
  }

  @override
  String toString() {
    return 'TrainerHomeState(todaySessionCount: $todaySessionCount, completedCount: $completedCount, freeSlotCount: $freeSlotCount, pendingConfirmations: $pendingConfirmations, todaySchedule: $todaySchedule)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerHomeStateImpl &&
            (identical(other.todaySessionCount, todaySessionCount) ||
                other.todaySessionCount == todaySessionCount) &&
            (identical(other.completedCount, completedCount) ||
                other.completedCount == completedCount) &&
            (identical(other.freeSlotCount, freeSlotCount) ||
                other.freeSlotCount == freeSlotCount) &&
            const DeepCollectionEquality().equals(
              other._pendingConfirmations,
              _pendingConfirmations,
            ) &&
            const DeepCollectionEquality().equals(
              other._todaySchedule,
              _todaySchedule,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    todaySessionCount,
    completedCount,
    freeSlotCount,
    const DeepCollectionEquality().hash(_pendingConfirmations),
    const DeepCollectionEquality().hash(_todaySchedule),
  );

  /// Create a copy of TrainerHomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerHomeStateImplCopyWith<_$TrainerHomeStateImpl> get copyWith =>
      __$$TrainerHomeStateImplCopyWithImpl<_$TrainerHomeStateImpl>(
        this,
        _$identity,
      );
}

abstract class _TrainerHomeState implements TrainerHomeState {
  const factory _TrainerHomeState({
    required final int todaySessionCount,
    required final int completedCount,
    required final int freeSlotCount,
    required final List<PendingConfirmation> pendingConfirmations,
    required final List<ScheduleSlot> todaySchedule,
  }) = _$TrainerHomeStateImpl;

  @override
  int get todaySessionCount;
  @override
  int get completedCount;
  @override
  int get freeSlotCount;
  @override
  List<PendingConfirmation> get pendingConfirmations;
  @override
  List<ScheduleSlot> get todaySchedule;

  /// Create a copy of TrainerHomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerHomeStateImplCopyWith<_$TrainerHomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
