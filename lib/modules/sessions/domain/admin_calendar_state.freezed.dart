// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_calendar_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdminSessionSlot {
  String get id => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get meta => throw _privateConstructorUsedError;
  AdminSessionState get state => throw _privateConstructorUsedError;
  String get memberId =>
      throw _privateConstructorUsedError; // F7-x — düet dersler her üye için ayrı bir `sessions` dokümanı
  // olduğundan (aynı `duetGroupId`'yi paylaşırlar), takvimde tek satır
  // olarak gösterilebilmesi için birden fazla doküman id'si taşıyabilir.
  // `sessionType == 'individual'` olan slotlarda tek elemanlı, `id` ile
  // aynıdır.
  String get sessionType => throw _privateConstructorUsedError;
  List<String> get duetMemberNames => throw _privateConstructorUsedError;
  List<String> get sessionIds => throw _privateConstructorUsedError;

  /// Create a copy of AdminSessionSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminSessionSlotCopyWith<AdminSessionSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminSessionSlotCopyWith<$Res> {
  factory $AdminSessionSlotCopyWith(
    AdminSessionSlot value,
    $Res Function(AdminSessionSlot) then,
  ) = _$AdminSessionSlotCopyWithImpl<$Res, AdminSessionSlot>;
  @useResult
  $Res call({
    String id,
    String time,
    String title,
    String meta,
    AdminSessionState state,
    String memberId,
    String sessionType,
    List<String> duetMemberNames,
    List<String> sessionIds,
  });
}

/// @nodoc
class _$AdminSessionSlotCopyWithImpl<$Res, $Val extends AdminSessionSlot>
    implements $AdminSessionSlotCopyWith<$Res> {
  _$AdminSessionSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminSessionSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? title = null,
    Object? meta = null,
    Object? state = null,
    Object? memberId = null,
    Object? sessionType = null,
    Object? duetMemberNames = null,
    Object? sessionIds = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as String,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as AdminSessionState,
            memberId: null == memberId
                ? _value.memberId
                : memberId // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionType: null == sessionType
                ? _value.sessionType
                : sessionType // ignore: cast_nullable_to_non_nullable
                      as String,
            duetMemberNames: null == duetMemberNames
                ? _value.duetMemberNames
                : duetMemberNames // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            sessionIds: null == sessionIds
                ? _value.sessionIds
                : sessionIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminSessionSlotImplCopyWith<$Res>
    implements $AdminSessionSlotCopyWith<$Res> {
  factory _$$AdminSessionSlotImplCopyWith(
    _$AdminSessionSlotImpl value,
    $Res Function(_$AdminSessionSlotImpl) then,
  ) = __$$AdminSessionSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String time,
    String title,
    String meta,
    AdminSessionState state,
    String memberId,
    String sessionType,
    List<String> duetMemberNames,
    List<String> sessionIds,
  });
}

/// @nodoc
class __$$AdminSessionSlotImplCopyWithImpl<$Res>
    extends _$AdminSessionSlotCopyWithImpl<$Res, _$AdminSessionSlotImpl>
    implements _$$AdminSessionSlotImplCopyWith<$Res> {
  __$$AdminSessionSlotImplCopyWithImpl(
    _$AdminSessionSlotImpl _value,
    $Res Function(_$AdminSessionSlotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminSessionSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? title = null,
    Object? meta = null,
    Object? state = null,
    Object? memberId = null,
    Object? sessionType = null,
    Object? duetMemberNames = null,
    Object? sessionIds = null,
  }) {
    return _then(
      _$AdminSessionSlotImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as AdminSessionState,
        memberId: null == memberId
            ? _value.memberId
            : memberId // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionType: null == sessionType
            ? _value.sessionType
            : sessionType // ignore: cast_nullable_to_non_nullable
                  as String,
        duetMemberNames: null == duetMemberNames
            ? _value._duetMemberNames
            : duetMemberNames // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        sessionIds: null == sessionIds
            ? _value._sessionIds
            : sessionIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

class _$AdminSessionSlotImpl extends _AdminSessionSlot {
  const _$AdminSessionSlotImpl({
    required this.id,
    required this.time,
    required this.title,
    required this.meta,
    required this.state,
    this.memberId = '',
    this.sessionType = 'individual',
    final List<String> duetMemberNames = const <String>[],
    final List<String> sessionIds = const <String>[],
  }) : _duetMemberNames = duetMemberNames,
       _sessionIds = sessionIds,
       super._();

  @override
  final String id;
  @override
  final String time;
  @override
  final String title;
  @override
  final String meta;
  @override
  final AdminSessionState state;
  @override
  @JsonKey()
  final String memberId;
  // F7-x — düet dersler her üye için ayrı bir `sessions` dokümanı
  // olduğundan (aynı `duetGroupId`'yi paylaşırlar), takvimde tek satır
  // olarak gösterilebilmesi için birden fazla doküman id'si taşıyabilir.
  // `sessionType == 'individual'` olan slotlarda tek elemanlı, `id` ile
  // aynıdır.
  @override
  @JsonKey()
  final String sessionType;
  final List<String> _duetMemberNames;
  @override
  @JsonKey()
  List<String> get duetMemberNames {
    if (_duetMemberNames is EqualUnmodifiableListView) return _duetMemberNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_duetMemberNames);
  }

  final List<String> _sessionIds;
  @override
  @JsonKey()
  List<String> get sessionIds {
    if (_sessionIds is EqualUnmodifiableListView) return _sessionIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sessionIds);
  }

  @override
  String toString() {
    return 'AdminSessionSlot(id: $id, time: $time, title: $title, meta: $meta, state: $state, memberId: $memberId, sessionType: $sessionType, duetMemberNames: $duetMemberNames, sessionIds: $sessionIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminSessionSlotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.sessionType, sessionType) ||
                other.sessionType == sessionType) &&
            const DeepCollectionEquality().equals(
              other._duetMemberNames,
              _duetMemberNames,
            ) &&
            const DeepCollectionEquality().equals(
              other._sessionIds,
              _sessionIds,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    time,
    title,
    meta,
    state,
    memberId,
    sessionType,
    const DeepCollectionEquality().hash(_duetMemberNames),
    const DeepCollectionEquality().hash(_sessionIds),
  );

  /// Create a copy of AdminSessionSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminSessionSlotImplCopyWith<_$AdminSessionSlotImpl> get copyWith =>
      __$$AdminSessionSlotImplCopyWithImpl<_$AdminSessionSlotImpl>(
        this,
        _$identity,
      );
}

abstract class _AdminSessionSlot extends AdminSessionSlot {
  const factory _AdminSessionSlot({
    required final String id,
    required final String time,
    required final String title,
    required final String meta,
    required final AdminSessionState state,
    final String memberId,
    final String sessionType,
    final List<String> duetMemberNames,
    final List<String> sessionIds,
  }) = _$AdminSessionSlotImpl;
  const _AdminSessionSlot._() : super._();

  @override
  String get id;
  @override
  String get time;
  @override
  String get title;
  @override
  String get meta;
  @override
  AdminSessionState get state;
  @override
  String get memberId; // F7-x — düet dersler her üye için ayrı bir `sessions` dokümanı
  // olduğundan (aynı `duetGroupId`'yi paylaşırlar), takvimde tek satır
  // olarak gösterilebilmesi için birden fazla doküman id'si taşıyabilir.
  // `sessionType == 'individual'` olan slotlarda tek elemanlı, `id` ile
  // aynıdır.
  @override
  String get sessionType;
  @override
  List<String> get duetMemberNames;
  @override
  List<String> get sessionIds;

  /// Create a copy of AdminSessionSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminSessionSlotImplCopyWith<_$AdminSessionSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AdminCalendarState {
  DateTime get selectedDate => throw _privateConstructorUsedError;
  Map<int, List<AdminSessionSlot>> get slotsByDayOfMonth =>
      throw _privateConstructorUsedError;

  /// Gün numarası → o gün eklenmiş gider kayıtları. Takvimde bildirim
  /// rozeti sayısı için `.length`, seçili gün panelinde liste için
  /// doğrudan kullanılır.
  Map<int, List<ExpenseEntry>> get expensesByDayOfMonth =>
      throw _privateConstructorUsedError;

  /// Create a copy of AdminCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminCalendarStateCopyWith<AdminCalendarState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminCalendarStateCopyWith<$Res> {
  factory $AdminCalendarStateCopyWith(
    AdminCalendarState value,
    $Res Function(AdminCalendarState) then,
  ) = _$AdminCalendarStateCopyWithImpl<$Res, AdminCalendarState>;
  @useResult
  $Res call({
    DateTime selectedDate,
    Map<int, List<AdminSessionSlot>> slotsByDayOfMonth,
    Map<int, List<ExpenseEntry>> expensesByDayOfMonth,
  });
}

/// @nodoc
class _$AdminCalendarStateCopyWithImpl<$Res, $Val extends AdminCalendarState>
    implements $AdminCalendarStateCopyWith<$Res> {
  _$AdminCalendarStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = null,
    Object? slotsByDayOfMonth = null,
    Object? expensesByDayOfMonth = null,
  }) {
    return _then(
      _value.copyWith(
            selectedDate: null == selectedDate
                ? _value.selectedDate
                : selectedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            slotsByDayOfMonth: null == slotsByDayOfMonth
                ? _value.slotsByDayOfMonth
                : slotsByDayOfMonth // ignore: cast_nullable_to_non_nullable
                      as Map<int, List<AdminSessionSlot>>,
            expensesByDayOfMonth: null == expensesByDayOfMonth
                ? _value.expensesByDayOfMonth
                : expensesByDayOfMonth // ignore: cast_nullable_to_non_nullable
                      as Map<int, List<ExpenseEntry>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminCalendarStateImplCopyWith<$Res>
    implements $AdminCalendarStateCopyWith<$Res> {
  factory _$$AdminCalendarStateImplCopyWith(
    _$AdminCalendarStateImpl value,
    $Res Function(_$AdminCalendarStateImpl) then,
  ) = __$$AdminCalendarStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime selectedDate,
    Map<int, List<AdminSessionSlot>> slotsByDayOfMonth,
    Map<int, List<ExpenseEntry>> expensesByDayOfMonth,
  });
}

/// @nodoc
class __$$AdminCalendarStateImplCopyWithImpl<$Res>
    extends _$AdminCalendarStateCopyWithImpl<$Res, _$AdminCalendarStateImpl>
    implements _$$AdminCalendarStateImplCopyWith<$Res> {
  __$$AdminCalendarStateImplCopyWithImpl(
    _$AdminCalendarStateImpl _value,
    $Res Function(_$AdminCalendarStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = null,
    Object? slotsByDayOfMonth = null,
    Object? expensesByDayOfMonth = null,
  }) {
    return _then(
      _$AdminCalendarStateImpl(
        selectedDate: null == selectedDate
            ? _value.selectedDate
            : selectedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        slotsByDayOfMonth: null == slotsByDayOfMonth
            ? _value._slotsByDayOfMonth
            : slotsByDayOfMonth // ignore: cast_nullable_to_non_nullable
                  as Map<int, List<AdminSessionSlot>>,
        expensesByDayOfMonth: null == expensesByDayOfMonth
            ? _value._expensesByDayOfMonth
            : expensesByDayOfMonth // ignore: cast_nullable_to_non_nullable
                  as Map<int, List<ExpenseEntry>>,
      ),
    );
  }
}

/// @nodoc

class _$AdminCalendarStateImpl implements _AdminCalendarState {
  const _$AdminCalendarStateImpl({
    required this.selectedDate,
    required final Map<int, List<AdminSessionSlot>> slotsByDayOfMonth,
    final Map<int, List<ExpenseEntry>> expensesByDayOfMonth =
        const <int, List<ExpenseEntry>>{},
  }) : _slotsByDayOfMonth = slotsByDayOfMonth,
       _expensesByDayOfMonth = expensesByDayOfMonth;

  @override
  final DateTime selectedDate;
  final Map<int, List<AdminSessionSlot>> _slotsByDayOfMonth;
  @override
  Map<int, List<AdminSessionSlot>> get slotsByDayOfMonth {
    if (_slotsByDayOfMonth is EqualUnmodifiableMapView)
      return _slotsByDayOfMonth;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_slotsByDayOfMonth);
  }

  /// Gün numarası → o gün eklenmiş gider kayıtları. Takvimde bildirim
  /// rozeti sayısı için `.length`, seçili gün panelinde liste için
  /// doğrudan kullanılır.
  final Map<int, List<ExpenseEntry>> _expensesByDayOfMonth;

  /// Gün numarası → o gün eklenmiş gider kayıtları. Takvimde bildirim
  /// rozeti sayısı için `.length`, seçili gün panelinde liste için
  /// doğrudan kullanılır.
  @override
  @JsonKey()
  Map<int, List<ExpenseEntry>> get expensesByDayOfMonth {
    if (_expensesByDayOfMonth is EqualUnmodifiableMapView)
      return _expensesByDayOfMonth;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_expensesByDayOfMonth);
  }

  @override
  String toString() {
    return 'AdminCalendarState(selectedDate: $selectedDate, slotsByDayOfMonth: $slotsByDayOfMonth, expensesByDayOfMonth: $expensesByDayOfMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminCalendarStateImpl &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            const DeepCollectionEquality().equals(
              other._slotsByDayOfMonth,
              _slotsByDayOfMonth,
            ) &&
            const DeepCollectionEquality().equals(
              other._expensesByDayOfMonth,
              _expensesByDayOfMonth,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedDate,
    const DeepCollectionEquality().hash(_slotsByDayOfMonth),
    const DeepCollectionEquality().hash(_expensesByDayOfMonth),
  );

  /// Create a copy of AdminCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminCalendarStateImplCopyWith<_$AdminCalendarStateImpl> get copyWith =>
      __$$AdminCalendarStateImplCopyWithImpl<_$AdminCalendarStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AdminCalendarState implements AdminCalendarState {
  const factory _AdminCalendarState({
    required final DateTime selectedDate,
    required final Map<int, List<AdminSessionSlot>> slotsByDayOfMonth,
    final Map<int, List<ExpenseEntry>> expensesByDayOfMonth,
  }) = _$AdminCalendarStateImpl;

  @override
  DateTime get selectedDate;
  @override
  Map<int, List<AdminSessionSlot>> get slotsByDayOfMonth;

  /// Gün numarası → o gün eklenmiş gider kayıtları. Takvimde bildirim
  /// rozeti sayısı için `.length`, seçili gün panelinde liste için
  /// doğrudan kullanılır.
  @override
  Map<int, List<ExpenseEntry>> get expensesByDayOfMonth;

  /// Create a copy of AdminCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminCalendarStateImplCopyWith<_$AdminCalendarStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
