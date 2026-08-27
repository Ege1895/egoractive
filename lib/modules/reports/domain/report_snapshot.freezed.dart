// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ReportSnapshot {
  String get id => throw _privateConstructorUsedError;
  ReportPeriod get period => throw _privateConstructorUsedError;
  DateTime get periodStart => throw _privateConstructorUsedError;
  DateTime get periodEnd => throw _privateConstructorUsedError;
  DashboardReport get report => throw _privateConstructorUsedError;

  /// Create a copy of ReportSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportSnapshotCopyWith<ReportSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportSnapshotCopyWith<$Res> {
  factory $ReportSnapshotCopyWith(
    ReportSnapshot value,
    $Res Function(ReportSnapshot) then,
  ) = _$ReportSnapshotCopyWithImpl<$Res, ReportSnapshot>;
  @useResult
  $Res call({
    String id,
    ReportPeriod period,
    DateTime periodStart,
    DateTime periodEnd,
    DashboardReport report,
  });

  $DashboardReportCopyWith<$Res> get report;
}

/// @nodoc
class _$ReportSnapshotCopyWithImpl<$Res, $Val extends ReportSnapshot>
    implements $ReportSnapshotCopyWith<$Res> {
  _$ReportSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? period = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? report = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as ReportPeriod,
            periodStart: null == periodStart
                ? _value.periodStart
                : periodStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            periodEnd: null == periodEnd
                ? _value.periodEnd
                : periodEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            report: null == report
                ? _value.report
                : report // ignore: cast_nullable_to_non_nullable
                      as DashboardReport,
          )
          as $Val,
    );
  }

  /// Create a copy of ReportSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardReportCopyWith<$Res> get report {
    return $DashboardReportCopyWith<$Res>(_value.report, (value) {
      return _then(_value.copyWith(report: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReportSnapshotImplCopyWith<$Res>
    implements $ReportSnapshotCopyWith<$Res> {
  factory _$$ReportSnapshotImplCopyWith(
    _$ReportSnapshotImpl value,
    $Res Function(_$ReportSnapshotImpl) then,
  ) = __$$ReportSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    ReportPeriod period,
    DateTime periodStart,
    DateTime periodEnd,
    DashboardReport report,
  });

  @override
  $DashboardReportCopyWith<$Res> get report;
}

/// @nodoc
class __$$ReportSnapshotImplCopyWithImpl<$Res>
    extends _$ReportSnapshotCopyWithImpl<$Res, _$ReportSnapshotImpl>
    implements _$$ReportSnapshotImplCopyWith<$Res> {
  __$$ReportSnapshotImplCopyWithImpl(
    _$ReportSnapshotImpl _value,
    $Res Function(_$ReportSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReportSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? period = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? report = null,
  }) {
    return _then(
      _$ReportSnapshotImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        period: null == period
            ? _value.period
            : period // ignore: cast_nullable_to_non_nullable
                  as ReportPeriod,
        periodStart: null == periodStart
            ? _value.periodStart
            : periodStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        periodEnd: null == periodEnd
            ? _value.periodEnd
            : periodEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        report: null == report
            ? _value.report
            : report // ignore: cast_nullable_to_non_nullable
                  as DashboardReport,
      ),
    );
  }
}

/// @nodoc

class _$ReportSnapshotImpl implements _ReportSnapshot {
  const _$ReportSnapshotImpl({
    required this.id,
    required this.period,
    required this.periodStart,
    required this.periodEnd,
    required this.report,
  });

  @override
  final String id;
  @override
  final ReportPeriod period;
  @override
  final DateTime periodStart;
  @override
  final DateTime periodEnd;
  @override
  final DashboardReport report;

  @override
  String toString() {
    return 'ReportSnapshot(id: $id, period: $period, periodStart: $periodStart, periodEnd: $periodEnd, report: $report)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportSnapshotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.report, report) || other.report == report));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, period, periodStart, periodEnd, report);

  /// Create a copy of ReportSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportSnapshotImplCopyWith<_$ReportSnapshotImpl> get copyWith =>
      __$$ReportSnapshotImplCopyWithImpl<_$ReportSnapshotImpl>(
        this,
        _$identity,
      );
}

abstract class _ReportSnapshot implements ReportSnapshot {
  const factory _ReportSnapshot({
    required final String id,
    required final ReportPeriod period,
    required final DateTime periodStart,
    required final DateTime periodEnd,
    required final DashboardReport report,
  }) = _$ReportSnapshotImpl;

  @override
  String get id;
  @override
  ReportPeriod get period;
  @override
  DateTime get periodStart;
  @override
  DateTime get periodEnd;
  @override
  DashboardReport get report;

  /// Create a copy of ReportSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportSnapshotImplCopyWith<_$ReportSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
