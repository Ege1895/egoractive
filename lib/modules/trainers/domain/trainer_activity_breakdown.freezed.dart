// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_activity_breakdown.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TrainerActivityCounts {
  int get individualCompleted => throw _privateConstructorUsedError;
  int get individualPlanned => throw _privateConstructorUsedError;
  int get duetCompleted => throw _privateConstructorUsedError;
  int get duetPlanned => throw _privateConstructorUsedError;

  /// Create a copy of TrainerActivityCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerActivityCountsCopyWith<TrainerActivityCounts> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerActivityCountsCopyWith<$Res> {
  factory $TrainerActivityCountsCopyWith(
    TrainerActivityCounts value,
    $Res Function(TrainerActivityCounts) then,
  ) = _$TrainerActivityCountsCopyWithImpl<$Res, TrainerActivityCounts>;
  @useResult
  $Res call({
    int individualCompleted,
    int individualPlanned,
    int duetCompleted,
    int duetPlanned,
  });
}

/// @nodoc
class _$TrainerActivityCountsCopyWithImpl<
  $Res,
  $Val extends TrainerActivityCounts
>
    implements $TrainerActivityCountsCopyWith<$Res> {
  _$TrainerActivityCountsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerActivityCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? individualCompleted = null,
    Object? individualPlanned = null,
    Object? duetCompleted = null,
    Object? duetPlanned = null,
  }) {
    return _then(
      _value.copyWith(
            individualCompleted: null == individualCompleted
                ? _value.individualCompleted
                : individualCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            individualPlanned: null == individualPlanned
                ? _value.individualPlanned
                : individualPlanned // ignore: cast_nullable_to_non_nullable
                      as int,
            duetCompleted: null == duetCompleted
                ? _value.duetCompleted
                : duetCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            duetPlanned: null == duetPlanned
                ? _value.duetPlanned
                : duetPlanned // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerActivityCountsImplCopyWith<$Res>
    implements $TrainerActivityCountsCopyWith<$Res> {
  factory _$$TrainerActivityCountsImplCopyWith(
    _$TrainerActivityCountsImpl value,
    $Res Function(_$TrainerActivityCountsImpl) then,
  ) = __$$TrainerActivityCountsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int individualCompleted,
    int individualPlanned,
    int duetCompleted,
    int duetPlanned,
  });
}

/// @nodoc
class __$$TrainerActivityCountsImplCopyWithImpl<$Res>
    extends
        _$TrainerActivityCountsCopyWithImpl<$Res, _$TrainerActivityCountsImpl>
    implements _$$TrainerActivityCountsImplCopyWith<$Res> {
  __$$TrainerActivityCountsImplCopyWithImpl(
    _$TrainerActivityCountsImpl _value,
    $Res Function(_$TrainerActivityCountsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerActivityCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? individualCompleted = null,
    Object? individualPlanned = null,
    Object? duetCompleted = null,
    Object? duetPlanned = null,
  }) {
    return _then(
      _$TrainerActivityCountsImpl(
        individualCompleted: null == individualCompleted
            ? _value.individualCompleted
            : individualCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        individualPlanned: null == individualPlanned
            ? _value.individualPlanned
            : individualPlanned // ignore: cast_nullable_to_non_nullable
                  as int,
        duetCompleted: null == duetCompleted
            ? _value.duetCompleted
            : duetCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        duetPlanned: null == duetPlanned
            ? _value.duetPlanned
            : duetPlanned // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$TrainerActivityCountsImpl implements _TrainerActivityCounts {
  const _$TrainerActivityCountsImpl({
    required this.individualCompleted,
    required this.individualPlanned,
    required this.duetCompleted,
    required this.duetPlanned,
  });

  @override
  final int individualCompleted;
  @override
  final int individualPlanned;
  @override
  final int duetCompleted;
  @override
  final int duetPlanned;

  @override
  String toString() {
    return 'TrainerActivityCounts(individualCompleted: $individualCompleted, individualPlanned: $individualPlanned, duetCompleted: $duetCompleted, duetPlanned: $duetPlanned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerActivityCountsImpl &&
            (identical(other.individualCompleted, individualCompleted) ||
                other.individualCompleted == individualCompleted) &&
            (identical(other.individualPlanned, individualPlanned) ||
                other.individualPlanned == individualPlanned) &&
            (identical(other.duetCompleted, duetCompleted) ||
                other.duetCompleted == duetCompleted) &&
            (identical(other.duetPlanned, duetPlanned) ||
                other.duetPlanned == duetPlanned));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    individualCompleted,
    individualPlanned,
    duetCompleted,
    duetPlanned,
  );

  /// Create a copy of TrainerActivityCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerActivityCountsImplCopyWith<_$TrainerActivityCountsImpl>
  get copyWith =>
      __$$TrainerActivityCountsImplCopyWithImpl<_$TrainerActivityCountsImpl>(
        this,
        _$identity,
      );
}

abstract class _TrainerActivityCounts implements TrainerActivityCounts {
  const factory _TrainerActivityCounts({
    required final int individualCompleted,
    required final int individualPlanned,
    required final int duetCompleted,
    required final int duetPlanned,
  }) = _$TrainerActivityCountsImpl;

  @override
  int get individualCompleted;
  @override
  int get individualPlanned;
  @override
  int get duetCompleted;
  @override
  int get duetPlanned;

  /// Create a copy of TrainerActivityCounts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerActivityCountsImplCopyWith<_$TrainerActivityCountsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TrainerActivityBreakdown {
  TrainerActivityCounts get monthly => throw _privateConstructorUsedError;
  TrainerActivityCounts get weekly => throw _privateConstructorUsedError;

  /// Create a copy of TrainerActivityBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerActivityBreakdownCopyWith<TrainerActivityBreakdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerActivityBreakdownCopyWith<$Res> {
  factory $TrainerActivityBreakdownCopyWith(
    TrainerActivityBreakdown value,
    $Res Function(TrainerActivityBreakdown) then,
  ) = _$TrainerActivityBreakdownCopyWithImpl<$Res, TrainerActivityBreakdown>;
  @useResult
  $Res call({TrainerActivityCounts monthly, TrainerActivityCounts weekly});

  $TrainerActivityCountsCopyWith<$Res> get monthly;
  $TrainerActivityCountsCopyWith<$Res> get weekly;
}

/// @nodoc
class _$TrainerActivityBreakdownCopyWithImpl<
  $Res,
  $Val extends TrainerActivityBreakdown
>
    implements $TrainerActivityBreakdownCopyWith<$Res> {
  _$TrainerActivityBreakdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerActivityBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? monthly = null, Object? weekly = null}) {
    return _then(
      _value.copyWith(
            monthly: null == monthly
                ? _value.monthly
                : monthly // ignore: cast_nullable_to_non_nullable
                      as TrainerActivityCounts,
            weekly: null == weekly
                ? _value.weekly
                : weekly // ignore: cast_nullable_to_non_nullable
                      as TrainerActivityCounts,
          )
          as $Val,
    );
  }

  /// Create a copy of TrainerActivityBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrainerActivityCountsCopyWith<$Res> get monthly {
    return $TrainerActivityCountsCopyWith<$Res>(_value.monthly, (value) {
      return _then(_value.copyWith(monthly: value) as $Val);
    });
  }

  /// Create a copy of TrainerActivityBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrainerActivityCountsCopyWith<$Res> get weekly {
    return $TrainerActivityCountsCopyWith<$Res>(_value.weekly, (value) {
      return _then(_value.copyWith(weekly: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrainerActivityBreakdownImplCopyWith<$Res>
    implements $TrainerActivityBreakdownCopyWith<$Res> {
  factory _$$TrainerActivityBreakdownImplCopyWith(
    _$TrainerActivityBreakdownImpl value,
    $Res Function(_$TrainerActivityBreakdownImpl) then,
  ) = __$$TrainerActivityBreakdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TrainerActivityCounts monthly, TrainerActivityCounts weekly});

  @override
  $TrainerActivityCountsCopyWith<$Res> get monthly;
  @override
  $TrainerActivityCountsCopyWith<$Res> get weekly;
}

/// @nodoc
class __$$TrainerActivityBreakdownImplCopyWithImpl<$Res>
    extends
        _$TrainerActivityBreakdownCopyWithImpl<
          $Res,
          _$TrainerActivityBreakdownImpl
        >
    implements _$$TrainerActivityBreakdownImplCopyWith<$Res> {
  __$$TrainerActivityBreakdownImplCopyWithImpl(
    _$TrainerActivityBreakdownImpl _value,
    $Res Function(_$TrainerActivityBreakdownImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerActivityBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? monthly = null, Object? weekly = null}) {
    return _then(
      _$TrainerActivityBreakdownImpl(
        monthly: null == monthly
            ? _value.monthly
            : monthly // ignore: cast_nullable_to_non_nullable
                  as TrainerActivityCounts,
        weekly: null == weekly
            ? _value.weekly
            : weekly // ignore: cast_nullable_to_non_nullable
                  as TrainerActivityCounts,
      ),
    );
  }
}

/// @nodoc

class _$TrainerActivityBreakdownImpl implements _TrainerActivityBreakdown {
  const _$TrainerActivityBreakdownImpl({
    required this.monthly,
    required this.weekly,
  });

  @override
  final TrainerActivityCounts monthly;
  @override
  final TrainerActivityCounts weekly;

  @override
  String toString() {
    return 'TrainerActivityBreakdown(monthly: $monthly, weekly: $weekly)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerActivityBreakdownImpl &&
            (identical(other.monthly, monthly) || other.monthly == monthly) &&
            (identical(other.weekly, weekly) || other.weekly == weekly));
  }

  @override
  int get hashCode => Object.hash(runtimeType, monthly, weekly);

  /// Create a copy of TrainerActivityBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerActivityBreakdownImplCopyWith<_$TrainerActivityBreakdownImpl>
  get copyWith =>
      __$$TrainerActivityBreakdownImplCopyWithImpl<
        _$TrainerActivityBreakdownImpl
      >(this, _$identity);
}

abstract class _TrainerActivityBreakdown implements TrainerActivityBreakdown {
  const factory _TrainerActivityBreakdown({
    required final TrainerActivityCounts monthly,
    required final TrainerActivityCounts weekly,
  }) = _$TrainerActivityBreakdownImpl;

  @override
  TrainerActivityCounts get monthly;
  @override
  TrainerActivityCounts get weekly;

  /// Create a copy of TrainerActivityBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerActivityBreakdownImplCopyWith<_$TrainerActivityBreakdownImpl>
  get copyWith => throw _privateConstructorUsedError;
}
