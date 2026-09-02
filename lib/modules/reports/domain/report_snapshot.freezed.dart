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
mixin _$ReportPackageSale {
  String get packageName => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Create a copy of ReportPackageSale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportPackageSaleCopyWith<ReportPackageSale> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportPackageSaleCopyWith<$Res> {
  factory $ReportPackageSaleCopyWith(
    ReportPackageSale value,
    $Res Function(ReportPackageSale) then,
  ) = _$ReportPackageSaleCopyWithImpl<$Res, ReportPackageSale>;
  @useResult
  $Res call({String packageName, int count});
}

/// @nodoc
class _$ReportPackageSaleCopyWithImpl<$Res, $Val extends ReportPackageSale>
    implements $ReportPackageSaleCopyWith<$Res> {
  _$ReportPackageSaleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportPackageSale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? packageName = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            packageName: null == packageName
                ? _value.packageName
                : packageName // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReportPackageSaleImplCopyWith<$Res>
    implements $ReportPackageSaleCopyWith<$Res> {
  factory _$$ReportPackageSaleImplCopyWith(
    _$ReportPackageSaleImpl value,
    $Res Function(_$ReportPackageSaleImpl) then,
  ) = __$$ReportPackageSaleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String packageName, int count});
}

/// @nodoc
class __$$ReportPackageSaleImplCopyWithImpl<$Res>
    extends _$ReportPackageSaleCopyWithImpl<$Res, _$ReportPackageSaleImpl>
    implements _$$ReportPackageSaleImplCopyWith<$Res> {
  __$$ReportPackageSaleImplCopyWithImpl(
    _$ReportPackageSaleImpl _value,
    $Res Function(_$ReportPackageSaleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReportPackageSale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? packageName = null, Object? count = null}) {
    return _then(
      _$ReportPackageSaleImpl(
        packageName: null == packageName
            ? _value.packageName
            : packageName // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ReportPackageSaleImpl implements _ReportPackageSale {
  const _$ReportPackageSaleImpl({
    required this.packageName,
    required this.count,
  });

  @override
  final String packageName;
  @override
  final int count;

  @override
  String toString() {
    return 'ReportPackageSale(packageName: $packageName, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportPackageSaleImpl &&
            (identical(other.packageName, packageName) ||
                other.packageName == packageName) &&
            (identical(other.count, count) || other.count == count));
  }

  @override
  int get hashCode => Object.hash(runtimeType, packageName, count);

  /// Create a copy of ReportPackageSale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportPackageSaleImplCopyWith<_$ReportPackageSaleImpl> get copyWith =>
      __$$ReportPackageSaleImplCopyWithImpl<_$ReportPackageSaleImpl>(
        this,
        _$identity,
      );
}

abstract class _ReportPackageSale implements ReportPackageSale {
  const factory _ReportPackageSale({
    required final String packageName,
    required final int count,
  }) = _$ReportPackageSaleImpl;

  @override
  String get packageName;
  @override
  int get count;

  /// Create a copy of ReportPackageSale
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportPackageSaleImplCopyWith<_$ReportPackageSaleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ReportOccupancy {
  int get count => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  int get attendance => throw _privateConstructorUsedError;

  /// Create a copy of ReportOccupancy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportOccupancyCopyWith<ReportOccupancy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportOccupancyCopyWith<$Res> {
  factory $ReportOccupancyCopyWith(
    ReportOccupancy value,
    $Res Function(ReportOccupancy) then,
  ) = _$ReportOccupancyCopyWithImpl<$Res, ReportOccupancy>;
  @useResult
  $Res call({int count, int capacity, int attendance});
}

/// @nodoc
class _$ReportOccupancyCopyWithImpl<$Res, $Val extends ReportOccupancy>
    implements $ReportOccupancyCopyWith<$Res> {
  _$ReportOccupancyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportOccupancy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? capacity = null,
    Object? attendance = null,
  }) {
    return _then(
      _value.copyWith(
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            capacity: null == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int,
            attendance: null == attendance
                ? _value.attendance
                : attendance // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReportOccupancyImplCopyWith<$Res>
    implements $ReportOccupancyCopyWith<$Res> {
  factory _$$ReportOccupancyImplCopyWith(
    _$ReportOccupancyImpl value,
    $Res Function(_$ReportOccupancyImpl) then,
  ) = __$$ReportOccupancyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int count, int capacity, int attendance});
}

/// @nodoc
class __$$ReportOccupancyImplCopyWithImpl<$Res>
    extends _$ReportOccupancyCopyWithImpl<$Res, _$ReportOccupancyImpl>
    implements _$$ReportOccupancyImplCopyWith<$Res> {
  __$$ReportOccupancyImplCopyWithImpl(
    _$ReportOccupancyImpl _value,
    $Res Function(_$ReportOccupancyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReportOccupancy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? capacity = null,
    Object? attendance = null,
  }) {
    return _then(
      _$ReportOccupancyImpl(
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        capacity: null == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int,
        attendance: null == attendance
            ? _value.attendance
            : attendance // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ReportOccupancyImpl extends _ReportOccupancy {
  const _$ReportOccupancyImpl({
    required this.count,
    required this.capacity,
    required this.attendance,
  }) : super._();

  @override
  final int count;
  @override
  final int capacity;
  @override
  final int attendance;

  @override
  String toString() {
    return 'ReportOccupancy(count: $count, capacity: $capacity, attendance: $attendance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportOccupancyImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.attendance, attendance) ||
                other.attendance == attendance));
  }

  @override
  int get hashCode => Object.hash(runtimeType, count, capacity, attendance);

  /// Create a copy of ReportOccupancy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportOccupancyImplCopyWith<_$ReportOccupancyImpl> get copyWith =>
      __$$ReportOccupancyImplCopyWithImpl<_$ReportOccupancyImpl>(
        this,
        _$identity,
      );
}

abstract class _ReportOccupancy extends ReportOccupancy {
  const factory _ReportOccupancy({
    required final int count,
    required final int capacity,
    required final int attendance,
  }) = _$ReportOccupancyImpl;
  const _ReportOccupancy._() : super._();

  @override
  int get count;
  @override
  int get capacity;
  @override
  int get attendance;

  /// Create a copy of ReportOccupancy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportOccupancyImplCopyWith<_$ReportOccupancyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ReportSnapshot {
  String get id => throw _privateConstructorUsedError;
  ReportPeriod get period => throw _privateConstructorUsedError;
  DateTime get periodStart => throw _privateConstructorUsedError;
  DateTime get periodEnd => throw _privateConstructorUsedError;
  DashboardReport get report => throw _privateConstructorUsedError;
  List<ReportPackageSale> get packages => throw _privateConstructorUsedError;
  ReportOccupancy get groupSessions => throw _privateConstructorUsedError;
  ReportOccupancy get events => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

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
    List<ReportPackageSale> packages,
    ReportOccupancy groupSessions,
    ReportOccupancy events,
    String currency,
  });

  $DashboardReportCopyWith<$Res> get report;
  $ReportOccupancyCopyWith<$Res> get groupSessions;
  $ReportOccupancyCopyWith<$Res> get events;
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
    Object? packages = null,
    Object? groupSessions = null,
    Object? events = null,
    Object? currency = null,
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
            packages: null == packages
                ? _value.packages
                : packages // ignore: cast_nullable_to_non_nullable
                      as List<ReportPackageSale>,
            groupSessions: null == groupSessions
                ? _value.groupSessions
                : groupSessions // ignore: cast_nullable_to_non_nullable
                      as ReportOccupancy,
            events: null == events
                ? _value.events
                : events // ignore: cast_nullable_to_non_nullable
                      as ReportOccupancy,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
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

  /// Create a copy of ReportSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReportOccupancyCopyWith<$Res> get groupSessions {
    return $ReportOccupancyCopyWith<$Res>(_value.groupSessions, (value) {
      return _then(_value.copyWith(groupSessions: value) as $Val);
    });
  }

  /// Create a copy of ReportSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReportOccupancyCopyWith<$Res> get events {
    return $ReportOccupancyCopyWith<$Res>(_value.events, (value) {
      return _then(_value.copyWith(events: value) as $Val);
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
    List<ReportPackageSale> packages,
    ReportOccupancy groupSessions,
    ReportOccupancy events,
    String currency,
  });

  @override
  $DashboardReportCopyWith<$Res> get report;
  @override
  $ReportOccupancyCopyWith<$Res> get groupSessions;
  @override
  $ReportOccupancyCopyWith<$Res> get events;
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
    Object? packages = null,
    Object? groupSessions = null,
    Object? events = null,
    Object? currency = null,
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
        packages: null == packages
            ? _value._packages
            : packages // ignore: cast_nullable_to_non_nullable
                  as List<ReportPackageSale>,
        groupSessions: null == groupSessions
            ? _value.groupSessions
            : groupSessions // ignore: cast_nullable_to_non_nullable
                  as ReportOccupancy,
        events: null == events
            ? _value.events
            : events // ignore: cast_nullable_to_non_nullable
                  as ReportOccupancy,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
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
    required final List<ReportPackageSale> packages,
    required this.groupSessions,
    required this.events,
    required this.currency,
  }) : _packages = packages;

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
  final List<ReportPackageSale> _packages;
  @override
  List<ReportPackageSale> get packages {
    if (_packages is EqualUnmodifiableListView) return _packages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_packages);
  }

  @override
  final ReportOccupancy groupSessions;
  @override
  final ReportOccupancy events;
  @override
  final String currency;

  @override
  String toString() {
    return 'ReportSnapshot(id: $id, period: $period, periodStart: $periodStart, periodEnd: $periodEnd, report: $report, packages: $packages, groupSessions: $groupSessions, events: $events, currency: $currency)';
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
            (identical(other.report, report) || other.report == report) &&
            const DeepCollectionEquality().equals(other._packages, _packages) &&
            (identical(other.groupSessions, groupSessions) ||
                other.groupSessions == groupSessions) &&
            (identical(other.events, events) || other.events == events) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    period,
    periodStart,
    periodEnd,
    report,
    const DeepCollectionEquality().hash(_packages),
    groupSessions,
    events,
    currency,
  );

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
    required final List<ReportPackageSale> packages,
    required final ReportOccupancy groupSessions,
    required final ReportOccupancy events,
    required final String currency,
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
  @override
  List<ReportPackageSale> get packages;
  @override
  ReportOccupancy get groupSessions;
  @override
  ReportOccupancy get events;
  @override
  String get currency;

  /// Create a copy of ReportSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportSnapshotImplCopyWith<_$ReportSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
