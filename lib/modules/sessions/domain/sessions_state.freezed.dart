// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sessions_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WeekActivityDay {
  String get label => throw _privateConstructorUsedError;
  double get intensity => throw _privateConstructorUsedError; // 0.0 - 1.0
  bool get isRestDay => throw _privateConstructorUsedError;

  /// Create a copy of WeekActivityDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeekActivityDayCopyWith<WeekActivityDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeekActivityDayCopyWith<$Res> {
  factory $WeekActivityDayCopyWith(
    WeekActivityDay value,
    $Res Function(WeekActivityDay) then,
  ) = _$WeekActivityDayCopyWithImpl<$Res, WeekActivityDay>;
  @useResult
  $Res call({String label, double intensity, bool isRestDay});
}

/// @nodoc
class _$WeekActivityDayCopyWithImpl<$Res, $Val extends WeekActivityDay>
    implements $WeekActivityDayCopyWith<$Res> {
  _$WeekActivityDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeekActivityDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? intensity = null,
    Object? isRestDay = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            intensity: null == intensity
                ? _value.intensity
                : intensity // ignore: cast_nullable_to_non_nullable
                      as double,
            isRestDay: null == isRestDay
                ? _value.isRestDay
                : isRestDay // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeekActivityDayImplCopyWith<$Res>
    implements $WeekActivityDayCopyWith<$Res> {
  factory _$$WeekActivityDayImplCopyWith(
    _$WeekActivityDayImpl value,
    $Res Function(_$WeekActivityDayImpl) then,
  ) = __$$WeekActivityDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, double intensity, bool isRestDay});
}

/// @nodoc
class __$$WeekActivityDayImplCopyWithImpl<$Res>
    extends _$WeekActivityDayCopyWithImpl<$Res, _$WeekActivityDayImpl>
    implements _$$WeekActivityDayImplCopyWith<$Res> {
  __$$WeekActivityDayImplCopyWithImpl(
    _$WeekActivityDayImpl _value,
    $Res Function(_$WeekActivityDayImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeekActivityDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? intensity = null,
    Object? isRestDay = null,
  }) {
    return _then(
      _$WeekActivityDayImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        intensity: null == intensity
            ? _value.intensity
            : intensity // ignore: cast_nullable_to_non_nullable
                  as double,
        isRestDay: null == isRestDay
            ? _value.isRestDay
            : isRestDay // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$WeekActivityDayImpl implements _WeekActivityDay {
  const _$WeekActivityDayImpl({
    required this.label,
    required this.intensity,
    required this.isRestDay,
  });

  @override
  final String label;
  @override
  final double intensity;
  // 0.0 - 1.0
  @override
  final bool isRestDay;

  @override
  String toString() {
    return 'WeekActivityDay(label: $label, intensity: $intensity, isRestDay: $isRestDay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeekActivityDayImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.intensity, intensity) ||
                other.intensity == intensity) &&
            (identical(other.isRestDay, isRestDay) ||
                other.isRestDay == isRestDay));
  }

  @override
  int get hashCode => Object.hash(runtimeType, label, intensity, isRestDay);

  /// Create a copy of WeekActivityDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeekActivityDayImplCopyWith<_$WeekActivityDayImpl> get copyWith =>
      __$$WeekActivityDayImplCopyWithImpl<_$WeekActivityDayImpl>(
        this,
        _$identity,
      );
}

abstract class _WeekActivityDay implements WeekActivityDay {
  const factory _WeekActivityDay({
    required final String label,
    required final double intensity,
    required final bool isRestDay,
  }) = _$WeekActivityDayImpl;

  @override
  String get label;
  @override
  double get intensity; // 0.0 - 1.0
  @override
  bool get isRestDay;

  /// Create a copy of WeekActivityDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeekActivityDayImplCopyWith<_$WeekActivityDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PaymentWarning {
  String get amount => throw _privateConstructorUsedError;
  String get dueDate => throw _privateConstructorUsedError;

  /// Create a copy of PaymentWarning
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentWarningCopyWith<PaymentWarning> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentWarningCopyWith<$Res> {
  factory $PaymentWarningCopyWith(
    PaymentWarning value,
    $Res Function(PaymentWarning) then,
  ) = _$PaymentWarningCopyWithImpl<$Res, PaymentWarning>;
  @useResult
  $Res call({String amount, String dueDate});
}

/// @nodoc
class _$PaymentWarningCopyWithImpl<$Res, $Val extends PaymentWarning>
    implements $PaymentWarningCopyWith<$Res> {
  _$PaymentWarningCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentWarning
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? amount = null, Object? dueDate = null}) {
    return _then(
      _value.copyWith(
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as String,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentWarningImplCopyWith<$Res>
    implements $PaymentWarningCopyWith<$Res> {
  factory _$$PaymentWarningImplCopyWith(
    _$PaymentWarningImpl value,
    $Res Function(_$PaymentWarningImpl) then,
  ) = __$$PaymentWarningImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String amount, String dueDate});
}

/// @nodoc
class __$$PaymentWarningImplCopyWithImpl<$Res>
    extends _$PaymentWarningCopyWithImpl<$Res, _$PaymentWarningImpl>
    implements _$$PaymentWarningImplCopyWith<$Res> {
  __$$PaymentWarningImplCopyWithImpl(
    _$PaymentWarningImpl _value,
    $Res Function(_$PaymentWarningImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentWarning
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? amount = null, Object? dueDate = null}) {
    return _then(
      _$PaymentWarningImpl(
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as String,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PaymentWarningImpl implements _PaymentWarning {
  const _$PaymentWarningImpl({required this.amount, required this.dueDate});

  @override
  final String amount;
  @override
  final String dueDate;

  @override
  String toString() {
    return 'PaymentWarning(amount: $amount, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentWarningImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, amount, dueDate);

  /// Create a copy of PaymentWarning
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentWarningImplCopyWith<_$PaymentWarningImpl> get copyWith =>
      __$$PaymentWarningImplCopyWithImpl<_$PaymentWarningImpl>(
        this,
        _$identity,
      );
}

abstract class _PaymentWarning implements PaymentWarning {
  const factory _PaymentWarning({
    required final String amount,
    required final String dueDate,
  }) = _$PaymentWarningImpl;

  @override
  String get amount;
  @override
  String get dueDate;

  /// Create a copy of PaymentWarning
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentWarningImplCopyWith<_$PaymentWarningImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SessionsState {
  Session get nextSession => throw _privateConstructorUsedError;
  List<Session> get upcoming => throw _privateConstructorUsedError;
  List<Session> get past => throw _privateConstructorUsedError;
  List<WeekActivityDay> get week => throw _privateConstructorUsedError;
  PaymentWarning? get paymentWarning => throw _privateConstructorUsedError;
  SessionsViewMode get viewMode => throw _privateConstructorUsedError;
  AttendanceAnswer get attendanceAnswer => throw _privateConstructorUsedError;
  String? get attendanceErrorMessage => throw _privateConstructorUsedError;

  /// Admin `MemberInfoPanel`'den açtıysa `true` — kapalıyken üye ana
  /// ekranında "Gelicem"/"Gelmeyeceğim" bildirimi yapamaz.
  bool get canConfirmAttendance => throw _privateConstructorUsedError;

  /// Create a copy of SessionsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionsStateCopyWith<SessionsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionsStateCopyWith<$Res> {
  factory $SessionsStateCopyWith(
    SessionsState value,
    $Res Function(SessionsState) then,
  ) = _$SessionsStateCopyWithImpl<$Res, SessionsState>;
  @useResult
  $Res call({
    Session nextSession,
    List<Session> upcoming,
    List<Session> past,
    List<WeekActivityDay> week,
    PaymentWarning? paymentWarning,
    SessionsViewMode viewMode,
    AttendanceAnswer attendanceAnswer,
    String? attendanceErrorMessage,
    bool canConfirmAttendance,
  });

  $SessionCopyWith<$Res> get nextSession;
  $PaymentWarningCopyWith<$Res>? get paymentWarning;
}

/// @nodoc
class _$SessionsStateCopyWithImpl<$Res, $Val extends SessionsState>
    implements $SessionsStateCopyWith<$Res> {
  _$SessionsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nextSession = null,
    Object? upcoming = null,
    Object? past = null,
    Object? week = null,
    Object? paymentWarning = freezed,
    Object? viewMode = null,
    Object? attendanceAnswer = null,
    Object? attendanceErrorMessage = freezed,
    Object? canConfirmAttendance = null,
  }) {
    return _then(
      _value.copyWith(
            nextSession: null == nextSession
                ? _value.nextSession
                : nextSession // ignore: cast_nullable_to_non_nullable
                      as Session,
            upcoming: null == upcoming
                ? _value.upcoming
                : upcoming // ignore: cast_nullable_to_non_nullable
                      as List<Session>,
            past: null == past
                ? _value.past
                : past // ignore: cast_nullable_to_non_nullable
                      as List<Session>,
            week: null == week
                ? _value.week
                : week // ignore: cast_nullable_to_non_nullable
                      as List<WeekActivityDay>,
            paymentWarning: freezed == paymentWarning
                ? _value.paymentWarning
                : paymentWarning // ignore: cast_nullable_to_non_nullable
                      as PaymentWarning?,
            viewMode: null == viewMode
                ? _value.viewMode
                : viewMode // ignore: cast_nullable_to_non_nullable
                      as SessionsViewMode,
            attendanceAnswer: null == attendanceAnswer
                ? _value.attendanceAnswer
                : attendanceAnswer // ignore: cast_nullable_to_non_nullable
                      as AttendanceAnswer,
            attendanceErrorMessage: freezed == attendanceErrorMessage
                ? _value.attendanceErrorMessage
                : attendanceErrorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            canConfirmAttendance: null == canConfirmAttendance
                ? _value.canConfirmAttendance
                : canConfirmAttendance // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of SessionsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionCopyWith<$Res> get nextSession {
    return $SessionCopyWith<$Res>(_value.nextSession, (value) {
      return _then(_value.copyWith(nextSession: value) as $Val);
    });
  }

  /// Create a copy of SessionsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaymentWarningCopyWith<$Res>? get paymentWarning {
    if (_value.paymentWarning == null) {
      return null;
    }

    return $PaymentWarningCopyWith<$Res>(_value.paymentWarning!, (value) {
      return _then(_value.copyWith(paymentWarning: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SessionsStateImplCopyWith<$Res>
    implements $SessionsStateCopyWith<$Res> {
  factory _$$SessionsStateImplCopyWith(
    _$SessionsStateImpl value,
    $Res Function(_$SessionsStateImpl) then,
  ) = __$$SessionsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Session nextSession,
    List<Session> upcoming,
    List<Session> past,
    List<WeekActivityDay> week,
    PaymentWarning? paymentWarning,
    SessionsViewMode viewMode,
    AttendanceAnswer attendanceAnswer,
    String? attendanceErrorMessage,
    bool canConfirmAttendance,
  });

  @override
  $SessionCopyWith<$Res> get nextSession;
  @override
  $PaymentWarningCopyWith<$Res>? get paymentWarning;
}

/// @nodoc
class __$$SessionsStateImplCopyWithImpl<$Res>
    extends _$SessionsStateCopyWithImpl<$Res, _$SessionsStateImpl>
    implements _$$SessionsStateImplCopyWith<$Res> {
  __$$SessionsStateImplCopyWithImpl(
    _$SessionsStateImpl _value,
    $Res Function(_$SessionsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nextSession = null,
    Object? upcoming = null,
    Object? past = null,
    Object? week = null,
    Object? paymentWarning = freezed,
    Object? viewMode = null,
    Object? attendanceAnswer = null,
    Object? attendanceErrorMessage = freezed,
    Object? canConfirmAttendance = null,
  }) {
    return _then(
      _$SessionsStateImpl(
        nextSession: null == nextSession
            ? _value.nextSession
            : nextSession // ignore: cast_nullable_to_non_nullable
                  as Session,
        upcoming: null == upcoming
            ? _value._upcoming
            : upcoming // ignore: cast_nullable_to_non_nullable
                  as List<Session>,
        past: null == past
            ? _value._past
            : past // ignore: cast_nullable_to_non_nullable
                  as List<Session>,
        week: null == week
            ? _value._week
            : week // ignore: cast_nullable_to_non_nullable
                  as List<WeekActivityDay>,
        paymentWarning: freezed == paymentWarning
            ? _value.paymentWarning
            : paymentWarning // ignore: cast_nullable_to_non_nullable
                  as PaymentWarning?,
        viewMode: null == viewMode
            ? _value.viewMode
            : viewMode // ignore: cast_nullable_to_non_nullable
                  as SessionsViewMode,
        attendanceAnswer: null == attendanceAnswer
            ? _value.attendanceAnswer
            : attendanceAnswer // ignore: cast_nullable_to_non_nullable
                  as AttendanceAnswer,
        attendanceErrorMessage: freezed == attendanceErrorMessage
            ? _value.attendanceErrorMessage
            : attendanceErrorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        canConfirmAttendance: null == canConfirmAttendance
            ? _value.canConfirmAttendance
            : canConfirmAttendance // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$SessionsStateImpl implements _SessionsState {
  const _$SessionsStateImpl({
    required this.nextSession,
    required final List<Session> upcoming,
    required final List<Session> past,
    required final List<WeekActivityDay> week,
    required this.paymentWarning,
    this.viewMode = SessionsViewMode.list,
    this.attendanceAnswer = AttendanceAnswer.pending,
    this.attendanceErrorMessage,
    this.canConfirmAttendance = false,
  }) : _upcoming = upcoming,
       _past = past,
       _week = week;

  @override
  final Session nextSession;
  final List<Session> _upcoming;
  @override
  List<Session> get upcoming {
    if (_upcoming is EqualUnmodifiableListView) return _upcoming;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_upcoming);
  }

  final List<Session> _past;
  @override
  List<Session> get past {
    if (_past is EqualUnmodifiableListView) return _past;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_past);
  }

  final List<WeekActivityDay> _week;
  @override
  List<WeekActivityDay> get week {
    if (_week is EqualUnmodifiableListView) return _week;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_week);
  }

  @override
  final PaymentWarning? paymentWarning;
  @override
  @JsonKey()
  final SessionsViewMode viewMode;
  @override
  @JsonKey()
  final AttendanceAnswer attendanceAnswer;
  @override
  final String? attendanceErrorMessage;

  /// Admin `MemberInfoPanel`'den açtıysa `true` — kapalıyken üye ana
  /// ekranında "Gelicem"/"Gelmeyeceğim" bildirimi yapamaz.
  @override
  @JsonKey()
  final bool canConfirmAttendance;

  @override
  String toString() {
    return 'SessionsState(nextSession: $nextSession, upcoming: $upcoming, past: $past, week: $week, paymentWarning: $paymentWarning, viewMode: $viewMode, attendanceAnswer: $attendanceAnswer, attendanceErrorMessage: $attendanceErrorMessage, canConfirmAttendance: $canConfirmAttendance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionsStateImpl &&
            (identical(other.nextSession, nextSession) ||
                other.nextSession == nextSession) &&
            const DeepCollectionEquality().equals(other._upcoming, _upcoming) &&
            const DeepCollectionEquality().equals(other._past, _past) &&
            const DeepCollectionEquality().equals(other._week, _week) &&
            (identical(other.paymentWarning, paymentWarning) ||
                other.paymentWarning == paymentWarning) &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode) &&
            (identical(other.attendanceAnswer, attendanceAnswer) ||
                other.attendanceAnswer == attendanceAnswer) &&
            (identical(other.attendanceErrorMessage, attendanceErrorMessage) ||
                other.attendanceErrorMessage == attendanceErrorMessage) &&
            (identical(other.canConfirmAttendance, canConfirmAttendance) ||
                other.canConfirmAttendance == canConfirmAttendance));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    nextSession,
    const DeepCollectionEquality().hash(_upcoming),
    const DeepCollectionEquality().hash(_past),
    const DeepCollectionEquality().hash(_week),
    paymentWarning,
    viewMode,
    attendanceAnswer,
    attendanceErrorMessage,
    canConfirmAttendance,
  );

  /// Create a copy of SessionsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionsStateImplCopyWith<_$SessionsStateImpl> get copyWith =>
      __$$SessionsStateImplCopyWithImpl<_$SessionsStateImpl>(this, _$identity);
}

abstract class _SessionsState implements SessionsState {
  const factory _SessionsState({
    required final Session nextSession,
    required final List<Session> upcoming,
    required final List<Session> past,
    required final List<WeekActivityDay> week,
    required final PaymentWarning? paymentWarning,
    final SessionsViewMode viewMode,
    final AttendanceAnswer attendanceAnswer,
    final String? attendanceErrorMessage,
    final bool canConfirmAttendance,
  }) = _$SessionsStateImpl;

  @override
  Session get nextSession;
  @override
  List<Session> get upcoming;
  @override
  List<Session> get past;
  @override
  List<WeekActivityDay> get week;
  @override
  PaymentWarning? get paymentWarning;
  @override
  SessionsViewMode get viewMode;
  @override
  AttendanceAnswer get attendanceAnswer;
  @override
  String? get attendanceErrorMessage;

  /// Admin `MemberInfoPanel`'den açtıysa `true` — kapalıyken üye ana
  /// ekranında "Gelicem"/"Gelmeyeceğim" bildirimi yapamaz.
  @override
  bool get canConfirmAttendance;

  /// Create a copy of SessionsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionsStateImplCopyWith<_$SessionsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
