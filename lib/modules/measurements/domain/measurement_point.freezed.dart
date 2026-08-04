// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MeasurementPoint {
  MeasurementMetric get metric => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  String get delta => throw _privateConstructorUsedError;
  bool get isImprovement => throw _privateConstructorUsedError;
  String get since => throw _privateConstructorUsedError;
  double get fx => throw _privateConstructorUsedError;
  double get fy => throw _privateConstructorUsedError;
  AvatarSide get side => throw _privateConstructorUsedError;

  /// Create a copy of MeasurementPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeasurementPointCopyWith<MeasurementPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementPointCopyWith<$Res> {
  factory $MeasurementPointCopyWith(
    MeasurementPoint value,
    $Res Function(MeasurementPoint) then,
  ) = _$MeasurementPointCopyWithImpl<$Res, MeasurementPoint>;
  @useResult
  $Res call({
    MeasurementMetric metric,
    String value,
    String delta,
    bool isImprovement,
    String since,
    double fx,
    double fy,
    AvatarSide side,
  });
}

/// @nodoc
class _$MeasurementPointCopyWithImpl<$Res, $Val extends MeasurementPoint>
    implements $MeasurementPointCopyWith<$Res> {
  _$MeasurementPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeasurementPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric = null,
    Object? value = null,
    Object? delta = null,
    Object? isImprovement = null,
    Object? since = null,
    Object? fx = null,
    Object? fy = null,
    Object? side = null,
  }) {
    return _then(
      _value.copyWith(
            metric: null == metric
                ? _value.metric
                : metric // ignore: cast_nullable_to_non_nullable
                      as MeasurementMetric,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            delta: null == delta
                ? _value.delta
                : delta // ignore: cast_nullable_to_non_nullable
                      as String,
            isImprovement: null == isImprovement
                ? _value.isImprovement
                : isImprovement // ignore: cast_nullable_to_non_nullable
                      as bool,
            since: null == since
                ? _value.since
                : since // ignore: cast_nullable_to_non_nullable
                      as String,
            fx: null == fx
                ? _value.fx
                : fx // ignore: cast_nullable_to_non_nullable
                      as double,
            fy: null == fy
                ? _value.fy
                : fy // ignore: cast_nullable_to_non_nullable
                      as double,
            side: null == side
                ? _value.side
                : side // ignore: cast_nullable_to_non_nullable
                      as AvatarSide,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MeasurementPointImplCopyWith<$Res>
    implements $MeasurementPointCopyWith<$Res> {
  factory _$$MeasurementPointImplCopyWith(
    _$MeasurementPointImpl value,
    $Res Function(_$MeasurementPointImpl) then,
  ) = __$$MeasurementPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MeasurementMetric metric,
    String value,
    String delta,
    bool isImprovement,
    String since,
    double fx,
    double fy,
    AvatarSide side,
  });
}

/// @nodoc
class __$$MeasurementPointImplCopyWithImpl<$Res>
    extends _$MeasurementPointCopyWithImpl<$Res, _$MeasurementPointImpl>
    implements _$$MeasurementPointImplCopyWith<$Res> {
  __$$MeasurementPointImplCopyWithImpl(
    _$MeasurementPointImpl _value,
    $Res Function(_$MeasurementPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeasurementPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric = null,
    Object? value = null,
    Object? delta = null,
    Object? isImprovement = null,
    Object? since = null,
    Object? fx = null,
    Object? fy = null,
    Object? side = null,
  }) {
    return _then(
      _$MeasurementPointImpl(
        metric: null == metric
            ? _value.metric
            : metric // ignore: cast_nullable_to_non_nullable
                  as MeasurementMetric,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        delta: null == delta
            ? _value.delta
            : delta // ignore: cast_nullable_to_non_nullable
                  as String,
        isImprovement: null == isImprovement
            ? _value.isImprovement
            : isImprovement // ignore: cast_nullable_to_non_nullable
                  as bool,
        since: null == since
            ? _value.since
            : since // ignore: cast_nullable_to_non_nullable
                  as String,
        fx: null == fx
            ? _value.fx
            : fx // ignore: cast_nullable_to_non_nullable
                  as double,
        fy: null == fy
            ? _value.fy
            : fy // ignore: cast_nullable_to_non_nullable
                  as double,
        side: null == side
            ? _value.side
            : side // ignore: cast_nullable_to_non_nullable
                  as AvatarSide,
      ),
    );
  }
}

/// @nodoc

class _$MeasurementPointImpl implements _MeasurementPoint {
  const _$MeasurementPointImpl({
    required this.metric,
    required this.value,
    required this.delta,
    required this.isImprovement,
    required this.since,
    required this.fx,
    required this.fy,
    required this.side,
  });

  @override
  final MeasurementMetric metric;
  @override
  final String value;
  @override
  final String delta;
  @override
  final bool isImprovement;
  @override
  final String since;
  @override
  final double fx;
  @override
  final double fy;
  @override
  final AvatarSide side;

  @override
  String toString() {
    return 'MeasurementPoint(metric: $metric, value: $value, delta: $delta, isImprovement: $isImprovement, since: $since, fx: $fx, fy: $fy, side: $side)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementPointImpl &&
            (identical(other.metric, metric) || other.metric == metric) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.delta, delta) || other.delta == delta) &&
            (identical(other.isImprovement, isImprovement) ||
                other.isImprovement == isImprovement) &&
            (identical(other.since, since) || other.since == since) &&
            (identical(other.fx, fx) || other.fx == fx) &&
            (identical(other.fy, fy) || other.fy == fy) &&
            (identical(other.side, side) || other.side == side));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    metric,
    value,
    delta,
    isImprovement,
    since,
    fx,
    fy,
    side,
  );

  /// Create a copy of MeasurementPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementPointImplCopyWith<_$MeasurementPointImpl> get copyWith =>
      __$$MeasurementPointImplCopyWithImpl<_$MeasurementPointImpl>(
        this,
        _$identity,
      );
}

abstract class _MeasurementPoint implements MeasurementPoint {
  const factory _MeasurementPoint({
    required final MeasurementMetric metric,
    required final String value,
    required final String delta,
    required final bool isImprovement,
    required final String since,
    required final double fx,
    required final double fy,
    required final AvatarSide side,
  }) = _$MeasurementPointImpl;

  @override
  MeasurementMetric get metric;
  @override
  String get value;
  @override
  String get delta;
  @override
  bool get isImprovement;
  @override
  String get since;
  @override
  double get fx;
  @override
  double get fy;
  @override
  AvatarSide get side;

  /// Create a copy of MeasurementPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeasurementPointImplCopyWith<_$MeasurementPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
