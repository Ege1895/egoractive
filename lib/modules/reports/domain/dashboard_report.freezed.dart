// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TrainerPerformance {
  String get trainerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get completedSessions => throw _privateConstructorUsedError;
  int get totalSessions => throw _privateConstructorUsedError;

  /// Create a copy of TrainerPerformance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerPerformanceCopyWith<TrainerPerformance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerPerformanceCopyWith<$Res> {
  factory $TrainerPerformanceCopyWith(
    TrainerPerformance value,
    $Res Function(TrainerPerformance) then,
  ) = _$TrainerPerformanceCopyWithImpl<$Res, TrainerPerformance>;
  @useResult
  $Res call({
    String trainerId,
    String name,
    int completedSessions,
    int totalSessions,
  });
}

/// @nodoc
class _$TrainerPerformanceCopyWithImpl<$Res, $Val extends TrainerPerformance>
    implements $TrainerPerformanceCopyWith<$Res> {
  _$TrainerPerformanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerPerformance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trainerId = null,
    Object? name = null,
    Object? completedSessions = null,
    Object? totalSessions = null,
  }) {
    return _then(
      _value.copyWith(
            trainerId: null == trainerId
                ? _value.trainerId
                : trainerId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            completedSessions: null == completedSessions
                ? _value.completedSessions
                : completedSessions // ignore: cast_nullable_to_non_nullable
                      as int,
            totalSessions: null == totalSessions
                ? _value.totalSessions
                : totalSessions // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerPerformanceImplCopyWith<$Res>
    implements $TrainerPerformanceCopyWith<$Res> {
  factory _$$TrainerPerformanceImplCopyWith(
    _$TrainerPerformanceImpl value,
    $Res Function(_$TrainerPerformanceImpl) then,
  ) = __$$TrainerPerformanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String trainerId,
    String name,
    int completedSessions,
    int totalSessions,
  });
}

/// @nodoc
class __$$TrainerPerformanceImplCopyWithImpl<$Res>
    extends _$TrainerPerformanceCopyWithImpl<$Res, _$TrainerPerformanceImpl>
    implements _$$TrainerPerformanceImplCopyWith<$Res> {
  __$$TrainerPerformanceImplCopyWithImpl(
    _$TrainerPerformanceImpl _value,
    $Res Function(_$TrainerPerformanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerPerformance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trainerId = null,
    Object? name = null,
    Object? completedSessions = null,
    Object? totalSessions = null,
  }) {
    return _then(
      _$TrainerPerformanceImpl(
        trainerId: null == trainerId
            ? _value.trainerId
            : trainerId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        completedSessions: null == completedSessions
            ? _value.completedSessions
            : completedSessions // ignore: cast_nullable_to_non_nullable
                  as int,
        totalSessions: null == totalSessions
            ? _value.totalSessions
            : totalSessions // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$TrainerPerformanceImpl extends _TrainerPerformance {
  const _$TrainerPerformanceImpl({
    required this.trainerId,
    required this.name,
    required this.completedSessions,
    required this.totalSessions,
  }) : super._();

  @override
  final String trainerId;
  @override
  final String name;
  @override
  final int completedSessions;
  @override
  final int totalSessions;

  @override
  String toString() {
    return 'TrainerPerformance(trainerId: $trainerId, name: $name, completedSessions: $completedSessions, totalSessions: $totalSessions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerPerformanceImpl &&
            (identical(other.trainerId, trainerId) ||
                other.trainerId == trainerId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.completedSessions, completedSessions) ||
                other.completedSessions == completedSessions) &&
            (identical(other.totalSessions, totalSessions) ||
                other.totalSessions == totalSessions));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    trainerId,
    name,
    completedSessions,
    totalSessions,
  );

  /// Create a copy of TrainerPerformance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerPerformanceImplCopyWith<_$TrainerPerformanceImpl> get copyWith =>
      __$$TrainerPerformanceImplCopyWithImpl<_$TrainerPerformanceImpl>(
        this,
        _$identity,
      );
}

abstract class _TrainerPerformance extends TrainerPerformance {
  const factory _TrainerPerformance({
    required final String trainerId,
    required final String name,
    required final int completedSessions,
    required final int totalSessions,
  }) = _$TrainerPerformanceImpl;
  const _TrainerPerformance._() : super._();

  @override
  String get trainerId;
  @override
  String get name;
  @override
  int get completedSessions;
  @override
  int get totalSessions;

  /// Create a copy of TrainerPerformance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerPerformanceImplCopyWith<_$TrainerPerformanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DashboardReport {
  String get monthLabel => throw _privateConstructorUsedError;
  int get totalSessions => throw _privateConstructorUsedError;
  int get completedSessions => throw _privateConstructorUsedError;
  int get cancelledSessions => throw _privateConstructorUsedError;
  List<TrainerPerformance> get trainerPerformance =>
      throw _privateConstructorUsedError;
  int get estimatedRevenueTl => throw _privateConstructorUsedError;
  int get totalExpensesTl => throw _privateConstructorUsedError;

  /// Create a copy of DashboardReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardReportCopyWith<DashboardReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardReportCopyWith<$Res> {
  factory $DashboardReportCopyWith(
    DashboardReport value,
    $Res Function(DashboardReport) then,
  ) = _$DashboardReportCopyWithImpl<$Res, DashboardReport>;
  @useResult
  $Res call({
    String monthLabel,
    int totalSessions,
    int completedSessions,
    int cancelledSessions,
    List<TrainerPerformance> trainerPerformance,
    int estimatedRevenueTl,
    int totalExpensesTl,
  });
}

/// @nodoc
class _$DashboardReportCopyWithImpl<$Res, $Val extends DashboardReport>
    implements $DashboardReportCopyWith<$Res> {
  _$DashboardReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthLabel = null,
    Object? totalSessions = null,
    Object? completedSessions = null,
    Object? cancelledSessions = null,
    Object? trainerPerformance = null,
    Object? estimatedRevenueTl = null,
    Object? totalExpensesTl = null,
  }) {
    return _then(
      _value.copyWith(
            monthLabel: null == monthLabel
                ? _value.monthLabel
                : monthLabel // ignore: cast_nullable_to_non_nullable
                      as String,
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
            trainerPerformance: null == trainerPerformance
                ? _value.trainerPerformance
                : trainerPerformance // ignore: cast_nullable_to_non_nullable
                      as List<TrainerPerformance>,
            estimatedRevenueTl: null == estimatedRevenueTl
                ? _value.estimatedRevenueTl
                : estimatedRevenueTl // ignore: cast_nullable_to_non_nullable
                      as int,
            totalExpensesTl: null == totalExpensesTl
                ? _value.totalExpensesTl
                : totalExpensesTl // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardReportImplCopyWith<$Res>
    implements $DashboardReportCopyWith<$Res> {
  factory _$$DashboardReportImplCopyWith(
    _$DashboardReportImpl value,
    $Res Function(_$DashboardReportImpl) then,
  ) = __$$DashboardReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String monthLabel,
    int totalSessions,
    int completedSessions,
    int cancelledSessions,
    List<TrainerPerformance> trainerPerformance,
    int estimatedRevenueTl,
    int totalExpensesTl,
  });
}

/// @nodoc
class __$$DashboardReportImplCopyWithImpl<$Res>
    extends _$DashboardReportCopyWithImpl<$Res, _$DashboardReportImpl>
    implements _$$DashboardReportImplCopyWith<$Res> {
  __$$DashboardReportImplCopyWithImpl(
    _$DashboardReportImpl _value,
    $Res Function(_$DashboardReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthLabel = null,
    Object? totalSessions = null,
    Object? completedSessions = null,
    Object? cancelledSessions = null,
    Object? trainerPerformance = null,
    Object? estimatedRevenueTl = null,
    Object? totalExpensesTl = null,
  }) {
    return _then(
      _$DashboardReportImpl(
        monthLabel: null == monthLabel
            ? _value.monthLabel
            : monthLabel // ignore: cast_nullable_to_non_nullable
                  as String,
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
        trainerPerformance: null == trainerPerformance
            ? _value._trainerPerformance
            : trainerPerformance // ignore: cast_nullable_to_non_nullable
                  as List<TrainerPerformance>,
        estimatedRevenueTl: null == estimatedRevenueTl
            ? _value.estimatedRevenueTl
            : estimatedRevenueTl // ignore: cast_nullable_to_non_nullable
                  as int,
        totalExpensesTl: null == totalExpensesTl
            ? _value.totalExpensesTl
            : totalExpensesTl // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$DashboardReportImpl extends _DashboardReport {
  const _$DashboardReportImpl({
    required this.monthLabel,
    required this.totalSessions,
    required this.completedSessions,
    required this.cancelledSessions,
    required final List<TrainerPerformance> trainerPerformance,
    required this.estimatedRevenueTl,
    required this.totalExpensesTl,
  }) : _trainerPerformance = trainerPerformance,
       super._();

  @override
  final String monthLabel;
  @override
  final int totalSessions;
  @override
  final int completedSessions;
  @override
  final int cancelledSessions;
  final List<TrainerPerformance> _trainerPerformance;
  @override
  List<TrainerPerformance> get trainerPerformance {
    if (_trainerPerformance is EqualUnmodifiableListView)
      return _trainerPerformance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trainerPerformance);
  }

  @override
  final int estimatedRevenueTl;
  @override
  final int totalExpensesTl;

  @override
  String toString() {
    return 'DashboardReport(monthLabel: $monthLabel, totalSessions: $totalSessions, completedSessions: $completedSessions, cancelledSessions: $cancelledSessions, trainerPerformance: $trainerPerformance, estimatedRevenueTl: $estimatedRevenueTl, totalExpensesTl: $totalExpensesTl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardReportImpl &&
            (identical(other.monthLabel, monthLabel) ||
                other.monthLabel == monthLabel) &&
            (identical(other.totalSessions, totalSessions) ||
                other.totalSessions == totalSessions) &&
            (identical(other.completedSessions, completedSessions) ||
                other.completedSessions == completedSessions) &&
            (identical(other.cancelledSessions, cancelledSessions) ||
                other.cancelledSessions == cancelledSessions) &&
            const DeepCollectionEquality().equals(
              other._trainerPerformance,
              _trainerPerformance,
            ) &&
            (identical(other.estimatedRevenueTl, estimatedRevenueTl) ||
                other.estimatedRevenueTl == estimatedRevenueTl) &&
            (identical(other.totalExpensesTl, totalExpensesTl) ||
                other.totalExpensesTl == totalExpensesTl));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    monthLabel,
    totalSessions,
    completedSessions,
    cancelledSessions,
    const DeepCollectionEquality().hash(_trainerPerformance),
    estimatedRevenueTl,
    totalExpensesTl,
  );

  /// Create a copy of DashboardReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardReportImplCopyWith<_$DashboardReportImpl> get copyWith =>
      __$$DashboardReportImplCopyWithImpl<_$DashboardReportImpl>(
        this,
        _$identity,
      );
}

abstract class _DashboardReport extends DashboardReport {
  const factory _DashboardReport({
    required final String monthLabel,
    required final int totalSessions,
    required final int completedSessions,
    required final int cancelledSessions,
    required final List<TrainerPerformance> trainerPerformance,
    required final int estimatedRevenueTl,
    required final int totalExpensesTl,
  }) = _$DashboardReportImpl;
  const _DashboardReport._() : super._();

  @override
  String get monthLabel;
  @override
  int get totalSessions;
  @override
  int get completedSessions;
  @override
  int get cancelledSessions;
  @override
  List<TrainerPerformance> get trainerPerformance;
  @override
  int get estimatedRevenueTl;
  @override
  int get totalExpensesTl;

  /// Create a copy of DashboardReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardReportImplCopyWith<_$DashboardReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
