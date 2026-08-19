// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_trainer_detail_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdminTrainerDetailStats {
  int get totalSessions => throw _privateConstructorUsedError;
  int get completedSessions => throw _privateConstructorUsedError;
  int get cancelledSessions => throw _privateConstructorUsedError;
  int get plannedSessions => throw _privateConstructorUsedError;

  /// Create a copy of AdminTrainerDetailStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminTrainerDetailStatsCopyWith<AdminTrainerDetailStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminTrainerDetailStatsCopyWith<$Res> {
  factory $AdminTrainerDetailStatsCopyWith(
    AdminTrainerDetailStats value,
    $Res Function(AdminTrainerDetailStats) then,
  ) = _$AdminTrainerDetailStatsCopyWithImpl<$Res, AdminTrainerDetailStats>;
  @useResult
  $Res call({
    int totalSessions,
    int completedSessions,
    int cancelledSessions,
    int plannedSessions,
  });
}

/// @nodoc
class _$AdminTrainerDetailStatsCopyWithImpl<
  $Res,
  $Val extends AdminTrainerDetailStats
>
    implements $AdminTrainerDetailStatsCopyWith<$Res> {
  _$AdminTrainerDetailStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminTrainerDetailStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSessions = null,
    Object? completedSessions = null,
    Object? cancelledSessions = null,
    Object? plannedSessions = null,
  }) {
    return _then(
      _value.copyWith(
            totalSessions: null == totalSessions
                ? _value.totalSessions
                : totalSessions // ignore: cast_nullable_to_non_nullable
                      as int,
            completedSessions: null == completedSessions
                ? _value.completedSessions
                : completedSessions // ignore: cast_nullable_to_non_nullable
                      as int,
            cancelledSessions: null == cancelledSessions
                ? _value.cancelledSessions
                : cancelledSessions // ignore: cast_nullable_to_non_nullable
                      as int,
            plannedSessions: null == plannedSessions
                ? _value.plannedSessions
                : plannedSessions // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminTrainerDetailStatsImplCopyWith<$Res>
    implements $AdminTrainerDetailStatsCopyWith<$Res> {
  factory _$$AdminTrainerDetailStatsImplCopyWith(
    _$AdminTrainerDetailStatsImpl value,
    $Res Function(_$AdminTrainerDetailStatsImpl) then,
  ) = __$$AdminTrainerDetailStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalSessions,
    int completedSessions,
    int cancelledSessions,
    int plannedSessions,
  });
}

/// @nodoc
class __$$AdminTrainerDetailStatsImplCopyWithImpl<$Res>
    extends
        _$AdminTrainerDetailStatsCopyWithImpl<
          $Res,
          _$AdminTrainerDetailStatsImpl
        >
    implements _$$AdminTrainerDetailStatsImplCopyWith<$Res> {
  __$$AdminTrainerDetailStatsImplCopyWithImpl(
    _$AdminTrainerDetailStatsImpl _value,
    $Res Function(_$AdminTrainerDetailStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminTrainerDetailStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSessions = null,
    Object? completedSessions = null,
    Object? cancelledSessions = null,
    Object? plannedSessions = null,
  }) {
    return _then(
      _$AdminTrainerDetailStatsImpl(
        totalSessions: null == totalSessions
            ? _value.totalSessions
            : totalSessions // ignore: cast_nullable_to_non_nullable
                  as int,
        completedSessions: null == completedSessions
            ? _value.completedSessions
            : completedSessions // ignore: cast_nullable_to_non_nullable
                  as int,
        cancelledSessions: null == cancelledSessions
            ? _value.cancelledSessions
            : cancelledSessions // ignore: cast_nullable_to_non_nullable
                  as int,
        plannedSessions: null == plannedSessions
            ? _value.plannedSessions
            : plannedSessions // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$AdminTrainerDetailStatsImpl extends _AdminTrainerDetailStats {
  const _$AdminTrainerDetailStatsImpl({
    required this.totalSessions,
    required this.completedSessions,
    required this.cancelledSessions,
    required this.plannedSessions,
  }) : super._();

  @override
  final int totalSessions;
  @override
  final int completedSessions;
  @override
  final int cancelledSessions;
  @override
  final int plannedSessions;

  @override
  String toString() {
    return 'AdminTrainerDetailStats(totalSessions: $totalSessions, completedSessions: $completedSessions, cancelledSessions: $cancelledSessions, plannedSessions: $plannedSessions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminTrainerDetailStatsImpl &&
            (identical(other.totalSessions, totalSessions) ||
                other.totalSessions == totalSessions) &&
            (identical(other.completedSessions, completedSessions) ||
                other.completedSessions == completedSessions) &&
            (identical(other.cancelledSessions, cancelledSessions) ||
                other.cancelledSessions == cancelledSessions) &&
            (identical(other.plannedSessions, plannedSessions) ||
                other.plannedSessions == plannedSessions));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalSessions,
    completedSessions,
    cancelledSessions,
    plannedSessions,
  );

  /// Create a copy of AdminTrainerDetailStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminTrainerDetailStatsImplCopyWith<_$AdminTrainerDetailStatsImpl>
  get copyWith =>
      __$$AdminTrainerDetailStatsImplCopyWithImpl<
        _$AdminTrainerDetailStatsImpl
      >(this, _$identity);
}

abstract class _AdminTrainerDetailStats extends AdminTrainerDetailStats {
  const factory _AdminTrainerDetailStats({
    required final int totalSessions,
    required final int completedSessions,
    required final int cancelledSessions,
    required final int plannedSessions,
  }) = _$AdminTrainerDetailStatsImpl;
  const _AdminTrainerDetailStats._() : super._();

  @override
  int get totalSessions;
  @override
  int get completedSessions;
  @override
  int get cancelledSessions;
  @override
  int get plannedSessions;

  /// Create a copy of AdminTrainerDetailStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminTrainerDetailStatsImplCopyWith<_$AdminTrainerDetailStatsImpl>
  get copyWith => throw _privateConstructorUsedError;
}
