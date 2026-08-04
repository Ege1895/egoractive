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
mixin _$DuePayment {
  String get memberName => throw _privateConstructorUsedError;
  String get dueDate => throw _privateConstructorUsedError;
  String get amount => throw _privateConstructorUsedError;

  /// Create a copy of DuePayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DuePaymentCopyWith<DuePayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DuePaymentCopyWith<$Res> {
  factory $DuePaymentCopyWith(
    DuePayment value,
    $Res Function(DuePayment) then,
  ) = _$DuePaymentCopyWithImpl<$Res, DuePayment>;
  @useResult
  $Res call({String memberName, String dueDate, String amount});
}

/// @nodoc
class _$DuePaymentCopyWithImpl<$Res, $Val extends DuePayment>
    implements $DuePaymentCopyWith<$Res> {
  _$DuePaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DuePayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberName = null,
    Object? dueDate = null,
    Object? amount = null,
  }) {
    return _then(
      _value.copyWith(
            memberName: null == memberName
                ? _value.memberName
                : memberName // ignore: cast_nullable_to_non_nullable
                      as String,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DuePaymentImplCopyWith<$Res>
    implements $DuePaymentCopyWith<$Res> {
  factory _$$DuePaymentImplCopyWith(
    _$DuePaymentImpl value,
    $Res Function(_$DuePaymentImpl) then,
  ) = __$$DuePaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String memberName, String dueDate, String amount});
}

/// @nodoc
class __$$DuePaymentImplCopyWithImpl<$Res>
    extends _$DuePaymentCopyWithImpl<$Res, _$DuePaymentImpl>
    implements _$$DuePaymentImplCopyWith<$Res> {
  __$$DuePaymentImplCopyWithImpl(
    _$DuePaymentImpl _value,
    $Res Function(_$DuePaymentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DuePayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberName = null,
    Object? dueDate = null,
    Object? amount = null,
  }) {
    return _then(
      _$DuePaymentImpl(
        memberName: null == memberName
            ? _value.memberName
            : memberName // ignore: cast_nullable_to_non_nullable
                  as String,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$DuePaymentImpl implements _DuePayment {
  const _$DuePaymentImpl({
    required this.memberName,
    required this.dueDate,
    required this.amount,
  });

  @override
  final String memberName;
  @override
  final String dueDate;
  @override
  final String amount;

  @override
  String toString() {
    return 'DuePayment(memberName: $memberName, dueDate: $dueDate, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DuePaymentImpl &&
            (identical(other.memberName, memberName) ||
                other.memberName == memberName) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, memberName, dueDate, amount);

  /// Create a copy of DuePayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DuePaymentImplCopyWith<_$DuePaymentImpl> get copyWith =>
      __$$DuePaymentImplCopyWithImpl<_$DuePaymentImpl>(this, _$identity);
}

abstract class _DuePayment implements DuePayment {
  const factory _DuePayment({
    required final String memberName,
    required final String dueDate,
    required final String amount,
  }) = _$DuePaymentImpl;

  @override
  String get memberName;
  @override
  String get dueDate;
  @override
  String get amount;

  /// Create a copy of DuePayment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DuePaymentImplCopyWith<_$DuePaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AdminHomeState {
  String get monthLabel => throw _privateConstructorUsedError;
  int get totalSessions => throw _privateConstructorUsedError;
  int get completedSessions => throw _privateConstructorUsedError;
  int get cancelledSessions => throw _privateConstructorUsedError;
  String get estimatedRevenue => throw _privateConstructorUsedError;
  String get revenueChangeLabel => throw _privateConstructorUsedError;
  String get expenses => throw _privateConstructorUsedError;
  List<TrainerPerformance> get trainerPerformance =>
      throw _privateConstructorUsedError;
  List<DuePayment> get duePayments => throw _privateConstructorUsedError;
  int get pendingFeedbackCount => throw _privateConstructorUsedError;
  int get recentFeedbackDays => throw _privateConstructorUsedError;

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
    String estimatedRevenue,
    String revenueChangeLabel,
    String expenses,
    List<TrainerPerformance> trainerPerformance,
    List<DuePayment> duePayments,
    int pendingFeedbackCount,
    int recentFeedbackDays,
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
    Object? estimatedRevenue = null,
    Object? revenueChangeLabel = null,
    Object? expenses = null,
    Object? trainerPerformance = null,
    Object? duePayments = null,
    Object? pendingFeedbackCount = null,
    Object? recentFeedbackDays = null,
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
            estimatedRevenue: null == estimatedRevenue
                ? _value.estimatedRevenue
                : estimatedRevenue // ignore: cast_nullable_to_non_nullable
                      as String,
            revenueChangeLabel: null == revenueChangeLabel
                ? _value.revenueChangeLabel
                : revenueChangeLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            expenses: null == expenses
                ? _value.expenses
                : expenses // ignore: cast_nullable_to_non_nullable
                      as String,
            trainerPerformance: null == trainerPerformance
                ? _value.trainerPerformance
                : trainerPerformance // ignore: cast_nullable_to_non_nullable
                      as List<TrainerPerformance>,
            duePayments: null == duePayments
                ? _value.duePayments
                : duePayments // ignore: cast_nullable_to_non_nullable
                      as List<DuePayment>,
            pendingFeedbackCount: null == pendingFeedbackCount
                ? _value.pendingFeedbackCount
                : pendingFeedbackCount // ignore: cast_nullable_to_non_nullable
                      as int,
            recentFeedbackDays: null == recentFeedbackDays
                ? _value.recentFeedbackDays
                : recentFeedbackDays // ignore: cast_nullable_to_non_nullable
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
    String estimatedRevenue,
    String revenueChangeLabel,
    String expenses,
    List<TrainerPerformance> trainerPerformance,
    List<DuePayment> duePayments,
    int pendingFeedbackCount,
    int recentFeedbackDays,
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
    Object? estimatedRevenue = null,
    Object? revenueChangeLabel = null,
    Object? expenses = null,
    Object? trainerPerformance = null,
    Object? duePayments = null,
    Object? pendingFeedbackCount = null,
    Object? recentFeedbackDays = null,
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
        estimatedRevenue: null == estimatedRevenue
            ? _value.estimatedRevenue
            : estimatedRevenue // ignore: cast_nullable_to_non_nullable
                  as String,
        revenueChangeLabel: null == revenueChangeLabel
            ? _value.revenueChangeLabel
            : revenueChangeLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        expenses: null == expenses
            ? _value.expenses
            : expenses // ignore: cast_nullable_to_non_nullable
                  as String,
        trainerPerformance: null == trainerPerformance
            ? _value._trainerPerformance
            : trainerPerformance // ignore: cast_nullable_to_non_nullable
                  as List<TrainerPerformance>,
        duePayments: null == duePayments
            ? _value._duePayments
            : duePayments // ignore: cast_nullable_to_non_nullable
                  as List<DuePayment>,
        pendingFeedbackCount: null == pendingFeedbackCount
            ? _value.pendingFeedbackCount
            : pendingFeedbackCount // ignore: cast_nullable_to_non_nullable
                  as int,
        recentFeedbackDays: null == recentFeedbackDays
            ? _value.recentFeedbackDays
            : recentFeedbackDays // ignore: cast_nullable_to_non_nullable
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
    required this.estimatedRevenue,
    required this.revenueChangeLabel,
    required this.expenses,
    required final List<TrainerPerformance> trainerPerformance,
    required final List<DuePayment> duePayments,
    required this.pendingFeedbackCount,
    required this.recentFeedbackDays,
  }) : _trainerPerformance = trainerPerformance,
       _duePayments = duePayments,
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
  final String estimatedRevenue;
  @override
  final String revenueChangeLabel;
  @override
  final String expenses;
  final List<TrainerPerformance> _trainerPerformance;
  @override
  List<TrainerPerformance> get trainerPerformance {
    if (_trainerPerformance is EqualUnmodifiableListView)
      return _trainerPerformance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trainerPerformance);
  }

  final List<DuePayment> _duePayments;
  @override
  List<DuePayment> get duePayments {
    if (_duePayments is EqualUnmodifiableListView) return _duePayments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_duePayments);
  }

  @override
  final int pendingFeedbackCount;
  @override
  final int recentFeedbackDays;

  @override
  String toString() {
    return 'AdminHomeState(monthLabel: $monthLabel, totalSessions: $totalSessions, completedSessions: $completedSessions, cancelledSessions: $cancelledSessions, estimatedRevenue: $estimatedRevenue, revenueChangeLabel: $revenueChangeLabel, expenses: $expenses, trainerPerformance: $trainerPerformance, duePayments: $duePayments, pendingFeedbackCount: $pendingFeedbackCount, recentFeedbackDays: $recentFeedbackDays)';
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
            (identical(other.estimatedRevenue, estimatedRevenue) ||
                other.estimatedRevenue == estimatedRevenue) &&
            (identical(other.revenueChangeLabel, revenueChangeLabel) ||
                other.revenueChangeLabel == revenueChangeLabel) &&
            (identical(other.expenses, expenses) ||
                other.expenses == expenses) &&
            const DeepCollectionEquality().equals(
              other._trainerPerformance,
              _trainerPerformance,
            ) &&
            const DeepCollectionEquality().equals(
              other._duePayments,
              _duePayments,
            ) &&
            (identical(other.pendingFeedbackCount, pendingFeedbackCount) ||
                other.pendingFeedbackCount == pendingFeedbackCount) &&
            (identical(other.recentFeedbackDays, recentFeedbackDays) ||
                other.recentFeedbackDays == recentFeedbackDays));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    monthLabel,
    totalSessions,
    completedSessions,
    cancelledSessions,
    estimatedRevenue,
    revenueChangeLabel,
    expenses,
    const DeepCollectionEquality().hash(_trainerPerformance),
    const DeepCollectionEquality().hash(_duePayments),
    pendingFeedbackCount,
    recentFeedbackDays,
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
    required final String estimatedRevenue,
    required final String revenueChangeLabel,
    required final String expenses,
    required final List<TrainerPerformance> trainerPerformance,
    required final List<DuePayment> duePayments,
    required final int pendingFeedbackCount,
    required final int recentFeedbackDays,
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
  String get estimatedRevenue;
  @override
  String get revenueChangeLabel;
  @override
  String get expenses;
  @override
  List<TrainerPerformance> get trainerPerformance;
  @override
  List<DuePayment> get duePayments;
  @override
  int get pendingFeedbackCount;
  @override
  int get recentFeedbackDays;

  /// Create a copy of AdminHomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminHomeStateImplCopyWith<_$AdminHomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
