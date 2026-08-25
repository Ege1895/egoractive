// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_report_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TrainerReportBreakdown {
  String get title => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get solo => throw _privateConstructorUsedError;
  int get group => throw _privateConstructorUsedError;

  /// Create a copy of TrainerReportBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerReportBreakdownCopyWith<TrainerReportBreakdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerReportBreakdownCopyWith<$Res> {
  factory $TrainerReportBreakdownCopyWith(
    TrainerReportBreakdown value,
    $Res Function(TrainerReportBreakdown) then,
  ) = _$TrainerReportBreakdownCopyWithImpl<$Res, TrainerReportBreakdown>;
  @useResult
  $Res call({String title, int total, int solo, int group});
}

/// @nodoc
class _$TrainerReportBreakdownCopyWithImpl<
  $Res,
  $Val extends TrainerReportBreakdown
>
    implements $TrainerReportBreakdownCopyWith<$Res> {
  _$TrainerReportBreakdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerReportBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? total = null,
    Object? solo = null,
    Object? group = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            solo: null == solo
                ? _value.solo
                : solo // ignore: cast_nullable_to_non_nullable
                      as int,
            group: null == group
                ? _value.group
                : group // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerReportBreakdownImplCopyWith<$Res>
    implements $TrainerReportBreakdownCopyWith<$Res> {
  factory _$$TrainerReportBreakdownImplCopyWith(
    _$TrainerReportBreakdownImpl value,
    $Res Function(_$TrainerReportBreakdownImpl) then,
  ) = __$$TrainerReportBreakdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, int total, int solo, int group});
}

/// @nodoc
class __$$TrainerReportBreakdownImplCopyWithImpl<$Res>
    extends
        _$TrainerReportBreakdownCopyWithImpl<$Res, _$TrainerReportBreakdownImpl>
    implements _$$TrainerReportBreakdownImplCopyWith<$Res> {
  __$$TrainerReportBreakdownImplCopyWithImpl(
    _$TrainerReportBreakdownImpl _value,
    $Res Function(_$TrainerReportBreakdownImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerReportBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? total = null,
    Object? solo = null,
    Object? group = null,
  }) {
    return _then(
      _$TrainerReportBreakdownImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        solo: null == solo
            ? _value.solo
            : solo // ignore: cast_nullable_to_non_nullable
                  as int,
        group: null == group
            ? _value.group
            : group // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$TrainerReportBreakdownImpl implements _TrainerReportBreakdown {
  const _$TrainerReportBreakdownImpl({
    required this.title,
    required this.total,
    required this.solo,
    required this.group,
  });

  @override
  final String title;
  @override
  final int total;
  @override
  final int solo;
  @override
  final int group;

  @override
  String toString() {
    return 'TrainerReportBreakdown(title: $title, total: $total, solo: $solo, group: $group)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerReportBreakdownImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.solo, solo) || other.solo == solo) &&
            (identical(other.group, group) || other.group == group));
  }

  @override
  int get hashCode => Object.hash(runtimeType, title, total, solo, group);

  /// Create a copy of TrainerReportBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerReportBreakdownImplCopyWith<_$TrainerReportBreakdownImpl>
  get copyWith =>
      __$$TrainerReportBreakdownImplCopyWithImpl<_$TrainerReportBreakdownImpl>(
        this,
        _$identity,
      );
}

abstract class _TrainerReportBreakdown implements TrainerReportBreakdown {
  const factory _TrainerReportBreakdown({
    required final String title,
    required final int total,
    required final int solo,
    required final int group,
  }) = _$TrainerReportBreakdownImpl;

  @override
  String get title;
  @override
  int get total;
  @override
  int get solo;
  @override
  int get group;

  /// Create a copy of TrainerReportBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerReportBreakdownImplCopyWith<_$TrainerReportBreakdownImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TrainerReportState {
  String get startDate => throw _privateConstructorUsedError;
  String get endDate => throw _privateConstructorUsedError;
  TrainerReportPeriod get period => throw _privateConstructorUsedError;
  DateTime get periodStart => throw _privateConstructorUsedError;
  DateTime get periodEnd => throw _privateConstructorUsedError;

  /// Antrenörün salona katıldığı tarih ("Tüm zamanlar" alt sınırı ve
  /// "Özel" tarih seçicisinin firstDate'i) — `users/{uid}.createdAt`.
  DateTime get gymJoinedAt => throw _privateConstructorUsedError;
  List<TrainerReportBreakdown> get breakdown =>
      throw _privateConstructorUsedError;

  /// Create a copy of TrainerReportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerReportStateCopyWith<TrainerReportState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerReportStateCopyWith<$Res> {
  factory $TrainerReportStateCopyWith(
    TrainerReportState value,
    $Res Function(TrainerReportState) then,
  ) = _$TrainerReportStateCopyWithImpl<$Res, TrainerReportState>;
  @useResult
  $Res call({
    String startDate,
    String endDate,
    TrainerReportPeriod period,
    DateTime periodStart,
    DateTime periodEnd,
    DateTime gymJoinedAt,
    List<TrainerReportBreakdown> breakdown,
  });
}

/// @nodoc
class _$TrainerReportStateCopyWithImpl<$Res, $Val extends TrainerReportState>
    implements $TrainerReportStateCopyWith<$Res> {
  _$TrainerReportStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerReportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
    Object? period = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? gymJoinedAt = null,
    Object? breakdown = null,
  }) {
    return _then(
      _value.copyWith(
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as String,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as String,
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as TrainerReportPeriod,
            periodStart: null == periodStart
                ? _value.periodStart
                : periodStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            periodEnd: null == periodEnd
                ? _value.periodEnd
                : periodEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            gymJoinedAt: null == gymJoinedAt
                ? _value.gymJoinedAt
                : gymJoinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            breakdown: null == breakdown
                ? _value.breakdown
                : breakdown // ignore: cast_nullable_to_non_nullable
                      as List<TrainerReportBreakdown>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerReportStateImplCopyWith<$Res>
    implements $TrainerReportStateCopyWith<$Res> {
  factory _$$TrainerReportStateImplCopyWith(
    _$TrainerReportStateImpl value,
    $Res Function(_$TrainerReportStateImpl) then,
  ) = __$$TrainerReportStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String startDate,
    String endDate,
    TrainerReportPeriod period,
    DateTime periodStart,
    DateTime periodEnd,
    DateTime gymJoinedAt,
    List<TrainerReportBreakdown> breakdown,
  });
}

/// @nodoc
class __$$TrainerReportStateImplCopyWithImpl<$Res>
    extends _$TrainerReportStateCopyWithImpl<$Res, _$TrainerReportStateImpl>
    implements _$$TrainerReportStateImplCopyWith<$Res> {
  __$$TrainerReportStateImplCopyWithImpl(
    _$TrainerReportStateImpl _value,
    $Res Function(_$TrainerReportStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerReportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
    Object? period = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? gymJoinedAt = null,
    Object? breakdown = null,
  }) {
    return _then(
      _$TrainerReportStateImpl(
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as String,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as String,
        period: null == period
            ? _value.period
            : period // ignore: cast_nullable_to_non_nullable
                  as TrainerReportPeriod,
        periodStart: null == periodStart
            ? _value.periodStart
            : periodStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        periodEnd: null == periodEnd
            ? _value.periodEnd
            : periodEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        gymJoinedAt: null == gymJoinedAt
            ? _value.gymJoinedAt
            : gymJoinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        breakdown: null == breakdown
            ? _value._breakdown
            : breakdown // ignore: cast_nullable_to_non_nullable
                  as List<TrainerReportBreakdown>,
      ),
    );
  }
}

/// @nodoc

class _$TrainerReportStateImpl implements _TrainerReportState {
  const _$TrainerReportStateImpl({
    required this.startDate,
    required this.endDate,
    required this.period,
    required this.periodStart,
    required this.periodEnd,
    required this.gymJoinedAt,
    required final List<TrainerReportBreakdown> breakdown,
  }) : _breakdown = breakdown;

  @override
  final String startDate;
  @override
  final String endDate;
  @override
  final TrainerReportPeriod period;
  @override
  final DateTime periodStart;
  @override
  final DateTime periodEnd;

  /// Antrenörün salona katıldığı tarih ("Tüm zamanlar" alt sınırı ve
  /// "Özel" tarih seçicisinin firstDate'i) — `users/{uid}.createdAt`.
  @override
  final DateTime gymJoinedAt;
  final List<TrainerReportBreakdown> _breakdown;
  @override
  List<TrainerReportBreakdown> get breakdown {
    if (_breakdown is EqualUnmodifiableListView) return _breakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_breakdown);
  }

  @override
  String toString() {
    return 'TrainerReportState(startDate: $startDate, endDate: $endDate, period: $period, periodStart: $periodStart, periodEnd: $periodEnd, gymJoinedAt: $gymJoinedAt, breakdown: $breakdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerReportStateImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.gymJoinedAt, gymJoinedAt) ||
                other.gymJoinedAt == gymJoinedAt) &&
            const DeepCollectionEquality().equals(
              other._breakdown,
              _breakdown,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    startDate,
    endDate,
    period,
    periodStart,
    periodEnd,
    gymJoinedAt,
    const DeepCollectionEquality().hash(_breakdown),
  );

  /// Create a copy of TrainerReportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerReportStateImplCopyWith<_$TrainerReportStateImpl> get copyWith =>
      __$$TrainerReportStateImplCopyWithImpl<_$TrainerReportStateImpl>(
        this,
        _$identity,
      );
}

abstract class _TrainerReportState implements TrainerReportState {
  const factory _TrainerReportState({
    required final String startDate,
    required final String endDate,
    required final TrainerReportPeriod period,
    required final DateTime periodStart,
    required final DateTime periodEnd,
    required final DateTime gymJoinedAt,
    required final List<TrainerReportBreakdown> breakdown,
  }) = _$TrainerReportStateImpl;

  @override
  String get startDate;
  @override
  String get endDate;
  @override
  TrainerReportPeriod get period;
  @override
  DateTime get periodStart;
  @override
  DateTime get periodEnd;

  /// Antrenörün salona katıldığı tarih ("Tüm zamanlar" alt sınırı ve
  /// "Özel" tarih seçicisinin firstDate'i) — `users/{uid}.createdAt`.
  @override
  DateTime get gymJoinedAt;
  @override
  List<TrainerReportBreakdown> get breakdown;

  /// Create a copy of TrainerReportState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerReportStateImplCopyWith<_$TrainerReportStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
