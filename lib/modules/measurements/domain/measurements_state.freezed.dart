// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurements_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MeasurementsState {
  Map<MeasurementMetric, MeasurementPoint> get points =>
      throw _privateConstructorUsedError;
  Map<MeasurementMetric, MeasurementSeries> get series =>
      throw _privateConstructorUsedError;
  MeasurementsViewMode get viewMode => throw _privateConstructorUsedError;
  MeasurementMetric get selectedMetric => throw _privateConstructorUsedError;

  /// Avatar ekranında görüntülenen kayıt tarihi. `null` = en son kayıt.
  DateTime? get selectedDate => throw _privateConstructorUsedError;

  /// Geçmişe dönük tarih seçmek için — en yeniden en eskiye sıralı,
  /// gerçek veri yoksa boş.
  List<DateTime> get recordedDates => throw _privateConstructorUsedError;

  /// `users/{uid}.gender` alanının ham değeri ('erkek' | 'kadin' | null) —
  /// avatar silüetinin hangi görseli kullanacağını belirler.
  String? get gender => throw _privateConstructorUsedError;

  /// Create a copy of MeasurementsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeasurementsStateCopyWith<MeasurementsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementsStateCopyWith<$Res> {
  factory $MeasurementsStateCopyWith(
    MeasurementsState value,
    $Res Function(MeasurementsState) then,
  ) = _$MeasurementsStateCopyWithImpl<$Res, MeasurementsState>;
  @useResult
  $Res call({
    Map<MeasurementMetric, MeasurementPoint> points,
    Map<MeasurementMetric, MeasurementSeries> series,
    MeasurementsViewMode viewMode,
    MeasurementMetric selectedMetric,
    DateTime? selectedDate,
    List<DateTime> recordedDates,
    String? gender,
  });
}

/// @nodoc
class _$MeasurementsStateCopyWithImpl<$Res, $Val extends MeasurementsState>
    implements $MeasurementsStateCopyWith<$Res> {
  _$MeasurementsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeasurementsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? points = null,
    Object? series = null,
    Object? viewMode = null,
    Object? selectedMetric = null,
    Object? selectedDate = freezed,
    Object? recordedDates = null,
    Object? gender = freezed,
  }) {
    return _then(
      _value.copyWith(
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as Map<MeasurementMetric, MeasurementPoint>,
            series: null == series
                ? _value.series
                : series // ignore: cast_nullable_to_non_nullable
                      as Map<MeasurementMetric, MeasurementSeries>,
            viewMode: null == viewMode
                ? _value.viewMode
                : viewMode // ignore: cast_nullable_to_non_nullable
                      as MeasurementsViewMode,
            selectedMetric: null == selectedMetric
                ? _value.selectedMetric
                : selectedMetric // ignore: cast_nullable_to_non_nullable
                      as MeasurementMetric,
            selectedDate: freezed == selectedDate
                ? _value.selectedDate
                : selectedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            recordedDates: null == recordedDates
                ? _value.recordedDates
                : recordedDates // ignore: cast_nullable_to_non_nullable
                      as List<DateTime>,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MeasurementsStateImplCopyWith<$Res>
    implements $MeasurementsStateCopyWith<$Res> {
  factory _$$MeasurementsStateImplCopyWith(
    _$MeasurementsStateImpl value,
    $Res Function(_$MeasurementsStateImpl) then,
  ) = __$$MeasurementsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<MeasurementMetric, MeasurementPoint> points,
    Map<MeasurementMetric, MeasurementSeries> series,
    MeasurementsViewMode viewMode,
    MeasurementMetric selectedMetric,
    DateTime? selectedDate,
    List<DateTime> recordedDates,
    String? gender,
  });
}

/// @nodoc
class __$$MeasurementsStateImplCopyWithImpl<$Res>
    extends _$MeasurementsStateCopyWithImpl<$Res, _$MeasurementsStateImpl>
    implements _$$MeasurementsStateImplCopyWith<$Res> {
  __$$MeasurementsStateImplCopyWithImpl(
    _$MeasurementsStateImpl _value,
    $Res Function(_$MeasurementsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeasurementsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? points = null,
    Object? series = null,
    Object? viewMode = null,
    Object? selectedMetric = null,
    Object? selectedDate = freezed,
    Object? recordedDates = null,
    Object? gender = freezed,
  }) {
    return _then(
      _$MeasurementsStateImpl(
        points: null == points
            ? _value._points
            : points // ignore: cast_nullable_to_non_nullable
                  as Map<MeasurementMetric, MeasurementPoint>,
        series: null == series
            ? _value._series
            : series // ignore: cast_nullable_to_non_nullable
                  as Map<MeasurementMetric, MeasurementSeries>,
        viewMode: null == viewMode
            ? _value.viewMode
            : viewMode // ignore: cast_nullable_to_non_nullable
                  as MeasurementsViewMode,
        selectedMetric: null == selectedMetric
            ? _value.selectedMetric
            : selectedMetric // ignore: cast_nullable_to_non_nullable
                  as MeasurementMetric,
        selectedDate: freezed == selectedDate
            ? _value.selectedDate
            : selectedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        recordedDates: null == recordedDates
            ? _value._recordedDates
            : recordedDates // ignore: cast_nullable_to_non_nullable
                  as List<DateTime>,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$MeasurementsStateImpl implements _MeasurementsState {
  const _$MeasurementsStateImpl({
    required final Map<MeasurementMetric, MeasurementPoint> points,
    required final Map<MeasurementMetric, MeasurementSeries> series,
    this.viewMode = MeasurementsViewMode.avatar,
    this.selectedMetric = MeasurementMetric.bel,
    this.selectedDate,
    final List<DateTime> recordedDates = const <DateTime>[],
    this.gender,
  }) : _points = points,
       _series = series,
       _recordedDates = recordedDates;

  final Map<MeasurementMetric, MeasurementPoint> _points;
  @override
  Map<MeasurementMetric, MeasurementPoint> get points {
    if (_points is EqualUnmodifiableMapView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_points);
  }

  final Map<MeasurementMetric, MeasurementSeries> _series;
  @override
  Map<MeasurementMetric, MeasurementSeries> get series {
    if (_series is EqualUnmodifiableMapView) return _series;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_series);
  }

  @override
  @JsonKey()
  final MeasurementsViewMode viewMode;
  @override
  @JsonKey()
  final MeasurementMetric selectedMetric;

  /// Avatar ekranında görüntülenen kayıt tarihi. `null` = en son kayıt.
  @override
  final DateTime? selectedDate;

  /// Geçmişe dönük tarih seçmek için — en yeniden en eskiye sıralı,
  /// gerçek veri yoksa boş.
  final List<DateTime> _recordedDates;

  /// Geçmişe dönük tarih seçmek için — en yeniden en eskiye sıralı,
  /// gerçek veri yoksa boş.
  @override
  @JsonKey()
  List<DateTime> get recordedDates {
    if (_recordedDates is EqualUnmodifiableListView) return _recordedDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recordedDates);
  }

  /// `users/{uid}.gender` alanının ham değeri ('erkek' | 'kadin' | null) —
  /// avatar silüetinin hangi görseli kullanacağını belirler.
  @override
  final String? gender;

  @override
  String toString() {
    return 'MeasurementsState(points: $points, series: $series, viewMode: $viewMode, selectedMetric: $selectedMetric, selectedDate: $selectedDate, recordedDates: $recordedDates, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementsStateImpl &&
            const DeepCollectionEquality().equals(other._points, _points) &&
            const DeepCollectionEquality().equals(other._series, _series) &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode) &&
            (identical(other.selectedMetric, selectedMetric) ||
                other.selectedMetric == selectedMetric) &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            const DeepCollectionEquality().equals(
              other._recordedDates,
              _recordedDates,
            ) &&
            (identical(other.gender, gender) || other.gender == gender));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_points),
    const DeepCollectionEquality().hash(_series),
    viewMode,
    selectedMetric,
    selectedDate,
    const DeepCollectionEquality().hash(_recordedDates),
    gender,
  );

  /// Create a copy of MeasurementsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementsStateImplCopyWith<_$MeasurementsStateImpl> get copyWith =>
      __$$MeasurementsStateImplCopyWithImpl<_$MeasurementsStateImpl>(
        this,
        _$identity,
      );
}

abstract class _MeasurementsState implements MeasurementsState {
  const factory _MeasurementsState({
    required final Map<MeasurementMetric, MeasurementPoint> points,
    required final Map<MeasurementMetric, MeasurementSeries> series,
    final MeasurementsViewMode viewMode,
    final MeasurementMetric selectedMetric,
    final DateTime? selectedDate,
    final List<DateTime> recordedDates,
    final String? gender,
  }) = _$MeasurementsStateImpl;

  @override
  Map<MeasurementMetric, MeasurementPoint> get points;
  @override
  Map<MeasurementMetric, MeasurementSeries> get series;
  @override
  MeasurementsViewMode get viewMode;
  @override
  MeasurementMetric get selectedMetric;

  /// Avatar ekranında görüntülenen kayıt tarihi. `null` = en son kayıt.
  @override
  DateTime? get selectedDate;

  /// Geçmişe dönük tarih seçmek için — en yeniden en eskiye sıralı,
  /// gerçek veri yoksa boş.
  @override
  List<DateTime> get recordedDates;

  /// `users/{uid}.gender` alanının ham değeri ('erkek' | 'kadin' | null) —
  /// avatar silüetinin hangi görseli kullanacağını belirler.
  @override
  String? get gender;

  /// Create a copy of MeasurementsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeasurementsStateImplCopyWith<_$MeasurementsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
