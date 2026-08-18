// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TrainerPerformance {
  String get name => throw _privateConstructorUsedError;
  int get sessionCount => throw _privateConstructorUsedError;
  double get ratio => throw _privateConstructorUsedError;

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
  $Res call({String name, int sessionCount, double ratio});
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
    Object? name = null,
    Object? sessionCount = null,
    Object? ratio = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionCount: null == sessionCount
                ? _value.sessionCount
                : sessionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            ratio: null == ratio
                ? _value.ratio
                : ratio // ignore: cast_nullable_to_non_nullable
                      as double,
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
  $Res call({String name, int sessionCount, double ratio});
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
    Object? name = null,
    Object? sessionCount = null,
    Object? ratio = null,
  }) {
    return _then(
      _$TrainerPerformanceImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionCount: null == sessionCount
            ? _value.sessionCount
            : sessionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        ratio: null == ratio
            ? _value.ratio
            : ratio // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$TrainerPerformanceImpl implements _TrainerPerformance {
  const _$TrainerPerformanceImpl({
    required this.name,
    required this.sessionCount,
    required this.ratio,
  });

  @override
  final String name;
  @override
  final int sessionCount;
  @override
  final double ratio;

  @override
  String toString() {
    return 'TrainerPerformance(name: $name, sessionCount: $sessionCount, ratio: $ratio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerPerformanceImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sessionCount, sessionCount) ||
                other.sessionCount == sessionCount) &&
            (identical(other.ratio, ratio) || other.ratio == ratio));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, sessionCount, ratio);

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

abstract class _TrainerPerformance implements TrainerPerformance {
  const factory _TrainerPerformance({
    required final String name,
    required final int sessionCount,
    required final double ratio,
  }) = _$TrainerPerformanceImpl;

  @override
  String get name;
  @override
  int get sessionCount;
  @override
  double get ratio;

  /// Create a copy of TrainerPerformance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerPerformanceImplCopyWith<_$TrainerPerformanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AdminHomeState {
  String get monthLabel => throw _privateConstructorUsedError;
  int get totalSessions => throw _privateConstructorUsedError;
  int get completedSessions => throw _privateConstructorUsedError;
  int get cancelledSessions => throw _privateConstructorUsedError;
  int get estimatedRevenueTl => throw _privateConstructorUsedError;
  int get expensesTl => throw _privateConstructorUsedError;
  List<TrainerPerformance> get trainerPerformance =>
      throw _privateConstructorUsedError;
  int get duePaymentMemberCount => throw _privateConstructorUsedError;
  int get duePaymentTotalTl => throw _privateConstructorUsedError;
  int get feedbackCount => throw _privateConstructorUsedError;

  /// Create a copy of AdminHomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminHomeStateCopyWith<AdminHomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminHomeStateCopyWith<$Res> {
  factory $AdminHomeStateCopyWith(
    AdminHomeState value,
    $Res Function(AdminHomeState) then,
  ) = _$AdminHomeStateCopyWithImpl<$Res, AdminHomeState>;
  @useResult
  $Res call({
    String monthLabel,
    int totalSessions,
    int completedSessions,
    int cancelledSessions,
    int estimatedRevenueTl,
    int expensesTl,
    List<TrainerPerformance> trainerPerformance,
    int duePaymentMemberCount,
    int duePaymentTotalTl,
    int feedbackCount,
  });
}

/// @nodoc
class _$AdminHomeStateCopyWithImpl<$Res, $Val extends AdminHomeState>
    implements $AdminHomeStateCopyWith<$Res> {
  _$AdminHomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminHomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthLabel = null,
    Object? totalSessions = null,
    Object? completedSessions = null,
    Object? cancelledSessions = null,
    Object? estimatedRevenueTl = null,
    Object? expensesTl = null,
    Object? trainerPerformance = null,
    Object? duePaymentMemberCount = null,
    Object? duePaymentTotalTl = null,
    Object? feedbackCount = null,
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
            estimatedRevenueTl: null == estimatedRevenueTl
                ? _value.estimatedRevenueTl
                : estimatedRevenueTl // ignore: cast_nullable_to_non_nullable
                      as int,
            expensesTl: null == expensesTl
                ? _value.expensesTl
                : expensesTl // ignore: cast_nullable_to_non_nullable
                      as int,
            trainerPerformance: null == trainerPerformance
                ? _value.trainerPerformance
                : trainerPerformance // ignore: cast_nullable_to_non_nullable
                      as List<TrainerPerformance>,
            duePaymentMemberCount: null == duePaymentMemberCount
                ? _value.duePaymentMemberCount
                : duePaymentMemberCount // ignore: cast_nullable_to_non_nullable
                      as int,
            duePaymentTotalTl: null == duePaymentTotalTl
                ? _value.duePaymentTotalTl
                : duePaymentTotalTl // ignore: cast_nullable_to_non_nullable
                      as int,
            feedbackCount: null == feedbackCount
                ? _value.feedbackCount
                : feedbackCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminHomeStateImplCopyWith<$Res>
    implements $AdminHomeStateCopyWith<$Res> {
  factory _$$AdminHomeStateImplCopyWith(
    _$AdminHomeStateImpl value,
    $Res Function(_$AdminHomeStateImpl) then,
  ) = __$$AdminHomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String monthLabel,
    int totalSessions,
    int completedSessions,
    int cancelledSessions,
    int estimatedRevenueTl,
    int expensesTl,
    List<TrainerPerformance> trainerPerformance,
    int duePaymentMemberCount,
    int duePaymentTotalTl,
    int feedbackCount,
  });
}

/// @nodoc
class __$$AdminHomeStateImplCopyWithImpl<$Res>
    extends _$AdminHomeStateCopyWithImpl<$Res, _$AdminHomeStateImpl>
    implements _$$AdminHomeStateImplCopyWith<$Res> {
  __$$AdminHomeStateImplCopyWithImpl(
    _$AdminHomeStateImpl _value,
    $Res Function(_$AdminHomeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminHomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthLabel = null,
    Object? totalSessions = null,
    Object? completedSessions = null,
    Object? cancelledSessions = null,
    Object? estimatedRevenueTl = null,
    Object? expensesTl = null,
    Object? trainerPerformance = null,
    Object? duePaymentMemberCount = null,
    Object? duePaymentTotalTl = null,
    Object? feedbackCount = null,
  }) {
    return _then(
      _$AdminHomeStateImpl(
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
        estimatedRevenueTl: null == estimatedRevenueTl
            ? _value.estimatedRevenueTl
            : estimatedRevenueTl // ignore: cast_nullable_to_non_nullable
                  as int,
        expensesTl: null == expensesTl
            ? _value.expensesTl
            : expensesTl // ignore: cast_nullable_to_non_nullable
                  as int,
        trainerPerformance: null == trainerPerformance
            ? _value._trainerPerformance
            : trainerPerformance // ignore: cast_nullable_to_non_nullable
                  as List<TrainerPerformance>,
        duePaymentMemberCount: null == duePaymentMemberCount
            ? _value.duePaymentMemberCount
            : duePaymentMemberCount // ignore: cast_nullable_to_non_nullable
                  as int,
        duePaymentTotalTl: null == duePaymentTotalTl
            ? _value.duePaymentTotalTl
            : duePaymentTotalTl // ignore: cast_nullable_to_non_nullable
                  as int,
        feedbackCount: null == feedbackCount
            ? _value.feedbackCount
            : feedbackCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$AdminHomeStateImpl extends _AdminHomeState {
  const _$AdminHomeStateImpl({
    required this.monthLabel,
    required this.totalSessions,
    required this.completedSessions,
    required this.cancelledSessions,
    required this.estimatedRevenueTl,
    required this.expensesTl,
    required final List<TrainerPerformance> trainerPerformance,
    required this.duePaymentMemberCount,
    required this.duePaymentTotalTl,
    required this.feedbackCount,
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
  @override
  final int estimatedRevenueTl;
  @override
  final int expensesTl;
  final List<TrainerPerformance> _trainerPerformance;
  @override
  List<TrainerPerformance> get trainerPerformance {
    if (_trainerPerformance is EqualUnmodifiableListView)
      return _trainerPerformance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trainerPerformance);
  }

  @override
  final int duePaymentMemberCount;
  @override
  final int duePaymentTotalTl;
  @override
  final int feedbackCount;

  @override
  String toString() {
    return 'AdminHomeState(monthLabel: $monthLabel, totalSessions: $totalSessions, completedSessions: $completedSessions, cancelledSessions: $cancelledSessions, estimatedRevenueTl: $estimatedRevenueTl, expensesTl: $expensesTl, trainerPerformance: $trainerPerformance, duePaymentMemberCount: $duePaymentMemberCount, duePaymentTotalTl: $duePaymentTotalTl, feedbackCount: $feedbackCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminHomeStateImpl &&
            (identical(other.monthLabel, monthLabel) ||
                other.monthLabel == monthLabel) &&
            (identical(other.totalSessions, totalSessions) ||
                other.totalSessions == totalSessions) &&
            (identical(other.completedSessions, completedSessions) ||
                other.completedSessions == completedSessions) &&
            (identical(other.cancelledSessions, cancelledSessions) ||
                other.cancelledSessions == cancelledSessions) &&
            (identical(other.estimatedRevenueTl, estimatedRevenueTl) ||
                other.estimatedRevenueTl == estimatedRevenueTl) &&
            (identical(other.expensesTl, expensesTl) ||
                other.expensesTl == expensesTl) &&
            const DeepCollectionEquality().equals(
              other._trainerPerformance,
              _trainerPerformance,
            ) &&
            (identical(other.duePaymentMemberCount, duePaymentMemberCount) ||
                other.duePaymentMemberCount == duePaymentMemberCount) &&
            (identical(other.duePaymentTotalTl, duePaymentTotalTl) ||
                other.duePaymentTotalTl == duePaymentTotalTl) &&
            (identical(other.feedbackCount, feedbackCount) ||
                other.feedbackCount == feedbackCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    monthLabel,
    totalSessions,
    completedSessions,
    cancelledSessions,
    estimatedRevenueTl,
    expensesTl,
    const DeepCollectionEquality().hash(_trainerPerformance),
    duePaymentMemberCount,
    duePaymentTotalTl,
    feedbackCount,
  );

  /// Create a copy of AdminHomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminHomeStateImplCopyWith<_$AdminHomeStateImpl> get copyWith =>
      __$$AdminHomeStateImplCopyWithImpl<_$AdminHomeStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AdminHomeState extends AdminHomeState {
  const factory _AdminHomeState({
    required final String monthLabel,
    required final int totalSessions,
    required final int completedSessions,
    required final int cancelledSessions,
    required final int estimatedRevenueTl,
    required final int expensesTl,
    required final List<TrainerPerformance> trainerPerformance,
    required final int duePaymentMemberCount,
    required final int duePaymentTotalTl,
    required final int feedbackCount,
  }) = _$AdminHomeStateImpl;
  const _AdminHomeState._() : super._();

  @override
  String get monthLabel;
  @override
  int get totalSessions;
  @override
  int get completedSessions;
  @override
  int get cancelledSessions;
  @override
  int get estimatedRevenueTl;
  @override
  int get expensesTl;
  @override
  List<TrainerPerformance> get trainerPerformance;
  @override
  int get duePaymentMemberCount;
  @override
  int get duePaymentTotalTl;
  @override
  int get feedbackCount;

  /// Create a copy of AdminHomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminHomeStateImplCopyWith<_$AdminHomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
