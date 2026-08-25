// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_calendar_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TrainerCalendarState {
  DateTime get selectedDate => throw _privateConstructorUsedError;
  Map<int, List<ScheduleSlot>> get slotsByDayOfMonth =>
      throw _privateConstructorUsedError;

  /// Create a copy of TrainerCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerCalendarStateCopyWith<TrainerCalendarState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerCalendarStateCopyWith<$Res> {
  factory $TrainerCalendarStateCopyWith(
    TrainerCalendarState value,
    $Res Function(TrainerCalendarState) then,
  ) = _$TrainerCalendarStateCopyWithImpl<$Res, TrainerCalendarState>;
  @useResult
  $Res call({
    DateTime selectedDate,
    Map<int, List<ScheduleSlot>> slotsByDayOfMonth,
  });
}

/// @nodoc
class _$TrainerCalendarStateCopyWithImpl<
  $Res,
  $Val extends TrainerCalendarState
>
    implements $TrainerCalendarStateCopyWith<$Res> {
  _$TrainerCalendarStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? selectedDate = null, Object? slotsByDayOfMonth = null}) {
    return _then(
      _value.copyWith(
            selectedDate: null == selectedDate
                ? _value.selectedDate
                : selectedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            slotsByDayOfMonth: null == slotsByDayOfMonth
                ? _value.slotsByDayOfMonth
                : slotsByDayOfMonth // ignore: cast_nullable_to_non_nullable
                      as Map<int, List<ScheduleSlot>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerCalendarStateImplCopyWith<$Res>
    implements $TrainerCalendarStateCopyWith<$Res> {
  factory _$$TrainerCalendarStateImplCopyWith(
    _$TrainerCalendarStateImpl value,
    $Res Function(_$TrainerCalendarStateImpl) then,
  ) = __$$TrainerCalendarStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime selectedDate,
    Map<int, List<ScheduleSlot>> slotsByDayOfMonth,
  });
}

/// @nodoc
class __$$TrainerCalendarStateImplCopyWithImpl<$Res>
    extends _$TrainerCalendarStateCopyWithImpl<$Res, _$TrainerCalendarStateImpl>
    implements _$$TrainerCalendarStateImplCopyWith<$Res> {
  __$$TrainerCalendarStateImplCopyWithImpl(
    _$TrainerCalendarStateImpl _value,
    $Res Function(_$TrainerCalendarStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? selectedDate = null, Object? slotsByDayOfMonth = null}) {
    return _then(
      _$TrainerCalendarStateImpl(
        selectedDate: null == selectedDate
            ? _value.selectedDate
            : selectedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        slotsByDayOfMonth: null == slotsByDayOfMonth
            ? _value._slotsByDayOfMonth
            : slotsByDayOfMonth // ignore: cast_nullable_to_non_nullable
                  as Map<int, List<ScheduleSlot>>,
      ),
    );
  }
}

/// @nodoc

class _$TrainerCalendarStateImpl implements _TrainerCalendarState {
  const _$TrainerCalendarStateImpl({
    required this.selectedDate,
    required final Map<int, List<ScheduleSlot>> slotsByDayOfMonth,
  }) : _slotsByDayOfMonth = slotsByDayOfMonth;

  @override
  final DateTime selectedDate;
  final Map<int, List<ScheduleSlot>> _slotsByDayOfMonth;
  @override
  Map<int, List<ScheduleSlot>> get slotsByDayOfMonth {
    if (_slotsByDayOfMonth is EqualUnmodifiableMapView)
      return _slotsByDayOfMonth;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_slotsByDayOfMonth);
  }

  @override
  String toString() {
    return 'TrainerCalendarState(selectedDate: $selectedDate, slotsByDayOfMonth: $slotsByDayOfMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerCalendarStateImpl &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            const DeepCollectionEquality().equals(
              other._slotsByDayOfMonth,
              _slotsByDayOfMonth,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedDate,
    const DeepCollectionEquality().hash(_slotsByDayOfMonth),
  );

  /// Create a copy of TrainerCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerCalendarStateImplCopyWith<_$TrainerCalendarStateImpl>
  get copyWith =>
      __$$TrainerCalendarStateImplCopyWithImpl<_$TrainerCalendarStateImpl>(
        this,
        _$identity,
      );
}

abstract class _TrainerCalendarState implements TrainerCalendarState {
  const factory _TrainerCalendarState({
    required final DateTime selectedDate,
    required final Map<int, List<ScheduleSlot>> slotsByDayOfMonth,
  }) = _$TrainerCalendarStateImpl;

  @override
  DateTime get selectedDate;
  @override
  Map<int, List<ScheduleSlot>> get slotsByDayOfMonth;

  /// Create a copy of TrainerCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerCalendarStateImplCopyWith<_$TrainerCalendarStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
