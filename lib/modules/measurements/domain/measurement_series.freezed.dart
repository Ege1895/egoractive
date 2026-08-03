// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement_series.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MeasurementSeries {
  MeasurementMetric get metric => throw _privateConstructorUsedError;
  List<String> get months => throw _privateConstructorUsedError;
  List<double> get values => throw _privateConstructorUsedError;
  String get totalDeltaLabel => throw _privateConstructorUsedError;

  /// Create a copy of MeasurementSeries
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeasurementSeriesCopyWith<MeasurementSeries> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementSeriesCopyWith<$Res> {
  factory $MeasurementSeriesCopyWith(
    MeasurementSeries value,
    $Res Function(MeasurementSeries) then,
  ) = _$MeasurementSeriesCopyWithImpl<$Res, MeasurementSeries>;
  @useResult
  $Res call({
    MeasurementMetric metric,
    List<String> months,
    List<double> values,
    String totalDeltaLabel,
  });
}

/// @nodoc
class _$MeasurementSeriesCopyWithImpl<$Res, $Val extends MeasurementSeries>
    implements $MeasurementSeriesCopyWith<$Res> {
  _$MeasurementSeriesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeasurementSeries
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric = null,
    Object? months = null,
    Object? values = null,
    Object? totalDeltaLabel = null,
  }) {
    return _then(
      _value.copyWith(
            metric: null == metric
                ? _value.metric
                : metric // ignore: cast_nullable_to_non_nullable
                      as MeasurementMetric,
            months: null == months
                ? _value.months
                : months // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            values: null == values
                ? _value.values
                : values // ignore: cast_nullable_to_non_nullable
                      as List<double>,
            totalDeltaLabel: null == totalDeltaLabel
                ? _value.totalDeltaLabel
                : totalDeltaLabel // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MeasurementSeriesImplCopyWith<$Res>
    implements $MeasurementSeriesCopyWith<$Res> {
  factory _$$MeasurementSeriesImplCopyWith(
    _$MeasurementSeriesImpl value,
    $Res Function(_$MeasurementSeriesImpl) then,
  ) = __$$MeasurementSeriesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MeasurementMetric metric,
    List<String> months,
    List<double> values,
    String totalDeltaLabel,
  });
}

/// @nodoc
class __$$MeasurementSeriesImplCopyWithImpl<$Res>
    extends _$MeasurementSeriesCopyWithImpl<$Res, _$MeasurementSeriesImpl>
    implements _$$MeasurementSeriesImplCopyWith<$Res> {
  __$$MeasurementSeriesImplCopyWithImpl(
    _$MeasurementSeriesImpl _value,
    $Res Function(_$MeasurementSeriesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeasurementSeries
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric = null,
    Object? months = null,
    Object? values = null,
    Object? totalDeltaLabel = null,
  }) {
    return _then(
      _$MeasurementSeriesImpl(
        metric: null == metric
            ? _value.metric
            : metric // ignore: cast_nullable_to_non_nullable
                  as MeasurementMetric,
        months: null == months
            ? _value._months
            : months // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        values: null == values
            ? _value._values
            : values // ignore: cast_nullable_to_non_nullable
                  as List<double>,
        totalDeltaLabel: null == totalDeltaLabel
            ? _value.totalDeltaLabel
            : totalDeltaLabel // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$MeasurementSeriesImpl implements _MeasurementSeries {
  const _$MeasurementSeriesImpl({
    required this.metric,
    required final List<String> months,
    required final List<double> values,
    required this.totalDeltaLabel,
  }) : _months = months,
       _values = values;

  @override
  final MeasurementMetric metric;
  final List<String> _months;
  @override
  List<String> get months {
    if (_months is EqualUnmodifiableListView) return _months;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_months);
  }

  final List<double> _values;
  @override
  List<double> get values {
    if (_values is EqualUnmodifiableListView) return _values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_values);
  }

  @override
  final String totalDeltaLabel;

  @override
  String toString() {
    return 'MeasurementSeries(metric: $metric, months: $months, values: $values, totalDeltaLabel: $totalDeltaLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementSeriesImpl &&
            (identical(other.metric, metric) || other.metric == metric) &&
            const DeepCollectionEquality().equals(other._months, _months) &&
            const DeepCollectionEquality().equals(other._values, _values) &&
            (identical(other.totalDeltaLabel, totalDeltaLabel) ||
                other.totalDeltaLabel == totalDeltaLabel));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    metric,
    const DeepCollectionEquality().hash(_months),
    const DeepCollectionEquality().hash(_values),
    totalDeltaLabel,
  );

  /// Create a copy of MeasurementSeries
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementSeriesImplCopyWith<_$MeasurementSeriesImpl> get copyWith =>
      __$$MeasurementSeriesImplCopyWithImpl<_$MeasurementSeriesImpl>(
        this,
        _$identity,
      );
}

abstract class _MeasurementSeries implements MeasurementSeries {
  const factory _MeasurementSeries({
    required final MeasurementMetric metric,
    required final List<String> months,
    required final List<double> values,
    required final String totalDeltaLabel,
  }) = _$MeasurementSeriesImpl;

  @override
  MeasurementMetric get metric;
  @override
  List<String> get months;
  @override
  List<double> get values;
  @override
  String get totalDeltaLabel;

  /// Create a copy of MeasurementSeries
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeasurementSeriesImplCopyWith<_$MeasurementSeriesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MeasurementHistoryEntry {
  String get date => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  String? get deltaLabel => throw _privateConstructorUsedError;
  bool? get isImprovement => throw _privateConstructorUsedError;

  /// Create a copy of MeasurementHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeasurementHistoryEntryCopyWith<MeasurementHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementHistoryEntryCopyWith<$Res> {
  factory $MeasurementHistoryEntryCopyWith(
    MeasurementHistoryEntry value,
    $Res Function(MeasurementHistoryEntry) then,
  ) = _$MeasurementHistoryEntryCopyWithImpl<$Res, MeasurementHistoryEntry>;
  @useResult
  $Res call({
    String date,
    double value,
    String? deltaLabel,
    bool? isImprovement,
  });
}

/// @nodoc
class _$MeasurementHistoryEntryCopyWithImpl<
  $Res,
  $Val extends MeasurementHistoryEntry
>
    implements $MeasurementHistoryEntryCopyWith<$Res> {
  _$MeasurementHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeasurementHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? value = null,
    Object? deltaLabel = freezed,
    Object? isImprovement = freezed,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as double,
            deltaLabel: freezed == deltaLabel
                ? _value.deltaLabel
                : deltaLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            isImprovement: freezed == isImprovement
                ? _value.isImprovement
                : isImprovement // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MeasurementHistoryEntryImplCopyWith<$Res>
    implements $MeasurementHistoryEntryCopyWith<$Res> {
  factory _$$MeasurementHistoryEntryImplCopyWith(
    _$MeasurementHistoryEntryImpl value,
    $Res Function(_$MeasurementHistoryEntryImpl) then,
  ) = __$$MeasurementHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    double value,
    String? deltaLabel,
    bool? isImprovement,
  });
}

/// @nodoc
class __$$MeasurementHistoryEntryImplCopyWithImpl<$Res>
    extends
        _$MeasurementHistoryEntryCopyWithImpl<
          $Res,
          _$MeasurementHistoryEntryImpl
        >
    implements _$$MeasurementHistoryEntryImplCopyWith<$Res> {
  __$$MeasurementHistoryEntryImplCopyWithImpl(
    _$MeasurementHistoryEntryImpl _value,
    $Res Function(_$MeasurementHistoryEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeasurementHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? value = null,
    Object? deltaLabel = freezed,
    Object? isImprovement = freezed,
  }) {
    return _then(
      _$MeasurementHistoryEntryImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as double,
        deltaLabel: freezed == deltaLabel
            ? _value.deltaLabel
            : deltaLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        isImprovement: freezed == isImprovement
            ? _value.isImprovement
            : isImprovement // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc

class _$MeasurementHistoryEntryImpl implements _MeasurementHistoryEntry {
  const _$MeasurementHistoryEntryImpl({
    required this.date,
    required this.value,
    required this.deltaLabel,
    required this.isImprovement,
  });

  @override
  final String date;
  @override
  final double value;
  @override
  final String? deltaLabel;
  @override
  final bool? isImprovement;

  @override
  String toString() {
    return 'MeasurementHistoryEntry(date: $date, value: $value, deltaLabel: $deltaLabel, isImprovement: $isImprovement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementHistoryEntryImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.deltaLabel, deltaLabel) ||
                other.deltaLabel == deltaLabel) &&
            (identical(other.isImprovement, isImprovement) ||
                other.isImprovement == isImprovement));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, date, value, deltaLabel, isImprovement);

  /// Create a copy of MeasurementHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementHistoryEntryImplCopyWith<_$MeasurementHistoryEntryImpl>
  get copyWith =>
      __$$MeasurementHistoryEntryImplCopyWithImpl<
        _$MeasurementHistoryEntryImpl
      >(this, _$identity);
}

abstract class _MeasurementHistoryEntry implements MeasurementHistoryEntry {
  const factory _MeasurementHistoryEntry({
    required final String date,
    required final double value,
    required final String? deltaLabel,
    required final bool? isImprovement,
  }) = _$MeasurementHistoryEntryImpl;

  @override
  String get date;
  @override
  double get value;
  @override
  String? get deltaLabel;
  @override
  bool? get isImprovement;

  /// Create a copy of MeasurementHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeasurementHistoryEntryImplCopyWith<_$MeasurementHistoryEntryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
