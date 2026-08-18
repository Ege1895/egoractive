// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_member_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdminMemberDetail {
  String get id => throw _privateConstructorUsedError;
  String get initials => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get trainerName => throw _privateConstructorUsedError;
  int get remainingSessions => throw _privateConstructorUsedError;
  int get makeupSessions => throw _privateConstructorUsedError;
  String get packageEndDate => throw _privateConstructorUsedError;
  int get paymentTotalTl => throw _privateConstructorUsedError;
  int get paymentPaidTl => throw _privateConstructorUsedError;
  String get lastPaymentDate => throw _privateConstructorUsedError;
  List<SessionHistoryEntry> get history => throw _privateConstructorUsedError;
  Map<TrainerMetric, TrainerMetricSeries> get seriesByMetric =>
      throw _privateConstructorUsedError;
  TrainerMetric get selectedMetric => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get notFound => throw _privateConstructorUsedError;

  /// Create a copy of AdminMemberDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminMemberDetailCopyWith<AdminMemberDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminMemberDetailCopyWith<$Res> {
  factory $AdminMemberDetailCopyWith(
    AdminMemberDetail value,
    $Res Function(AdminMemberDetail) then,
  ) = _$AdminMemberDetailCopyWithImpl<$Res, AdminMemberDetail>;
  @useResult
  $Res call({
    String id,
    String initials,
    String name,
    String phone,
    String trainerName,
    int remainingSessions,
    int makeupSessions,
    String packageEndDate,
    int paymentTotalTl,
    int paymentPaidTl,
    String lastPaymentDate,
    List<SessionHistoryEntry> history,
    Map<TrainerMetric, TrainerMetricSeries> seriesByMetric,
    TrainerMetric selectedMetric,
    bool isLoading,
    bool notFound,
  });
}

/// @nodoc
class _$AdminMemberDetailCopyWithImpl<$Res, $Val extends AdminMemberDetail>
    implements $AdminMemberDetailCopyWith<$Res> {
  _$AdminMemberDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminMemberDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initials = null,
    Object? name = null,
    Object? phone = null,
    Object? trainerName = null,
    Object? remainingSessions = null,
    Object? makeupSessions = null,
    Object? packageEndDate = null,
    Object? paymentTotalTl = null,
    Object? paymentPaidTl = null,
    Object? lastPaymentDate = null,
    Object? history = null,
    Object? seriesByMetric = null,
    Object? selectedMetric = null,
    Object? isLoading = null,
    Object? notFound = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            initials: null == initials
                ? _value.initials
                : initials // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            trainerName: null == trainerName
                ? _value.trainerName
                : trainerName // ignore: cast_nullable_to_non_nullable
                      as String,
            remainingSessions: null == remainingSessions
                ? _value.remainingSessions
                : remainingSessions // ignore: cast_nullable_to_non_nullable
                      as int,
            makeupSessions: null == makeupSessions
                ? _value.makeupSessions
                : makeupSessions // ignore: cast_nullable_to_non_nullable
                      as int,
            packageEndDate: null == packageEndDate
                ? _value.packageEndDate
                : packageEndDate // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentTotalTl: null == paymentTotalTl
                ? _value.paymentTotalTl
                : paymentTotalTl // ignore: cast_nullable_to_non_nullable
                      as int,
            paymentPaidTl: null == paymentPaidTl
                ? _value.paymentPaidTl
                : paymentPaidTl // ignore: cast_nullable_to_non_nullable
                      as int,
            lastPaymentDate: null == lastPaymentDate
                ? _value.lastPaymentDate
                : lastPaymentDate // ignore: cast_nullable_to_non_nullable
                      as String,
            history: null == history
                ? _value.history
                : history // ignore: cast_nullable_to_non_nullable
                      as List<SessionHistoryEntry>,
            seriesByMetric: null == seriesByMetric
                ? _value.seriesByMetric
                : seriesByMetric // ignore: cast_nullable_to_non_nullable
                      as Map<TrainerMetric, TrainerMetricSeries>,
            selectedMetric: null == selectedMetric
                ? _value.selectedMetric
                : selectedMetric // ignore: cast_nullable_to_non_nullable
                      as TrainerMetric,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            notFound: null == notFound
                ? _value.notFound
                : notFound // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminMemberDetailImplCopyWith<$Res>
    implements $AdminMemberDetailCopyWith<$Res> {
  factory _$$AdminMemberDetailImplCopyWith(
    _$AdminMemberDetailImpl value,
    $Res Function(_$AdminMemberDetailImpl) then,
  ) = __$$AdminMemberDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String initials,
    String name,
    String phone,
    String trainerName,
    int remainingSessions,
    int makeupSessions,
    String packageEndDate,
    int paymentTotalTl,
    int paymentPaidTl,
    String lastPaymentDate,
    List<SessionHistoryEntry> history,
    Map<TrainerMetric, TrainerMetricSeries> seriesByMetric,
    TrainerMetric selectedMetric,
    bool isLoading,
    bool notFound,
  });
}

/// @nodoc
class __$$AdminMemberDetailImplCopyWithImpl<$Res>
    extends _$AdminMemberDetailCopyWithImpl<$Res, _$AdminMemberDetailImpl>
    implements _$$AdminMemberDetailImplCopyWith<$Res> {
  __$$AdminMemberDetailImplCopyWithImpl(
    _$AdminMemberDetailImpl _value,
    $Res Function(_$AdminMemberDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminMemberDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initials = null,
    Object? name = null,
    Object? phone = null,
    Object? trainerName = null,
    Object? remainingSessions = null,
    Object? makeupSessions = null,
    Object? packageEndDate = null,
    Object? paymentTotalTl = null,
    Object? paymentPaidTl = null,
    Object? lastPaymentDate = null,
    Object? history = null,
    Object? seriesByMetric = null,
    Object? selectedMetric = null,
    Object? isLoading = null,
    Object? notFound = null,
  }) {
    return _then(
      _$AdminMemberDetailImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        initials: null == initials
            ? _value.initials
            : initials // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        trainerName: null == trainerName
            ? _value.trainerName
            : trainerName // ignore: cast_nullable_to_non_nullable
                  as String,
        remainingSessions: null == remainingSessions
            ? _value.remainingSessions
            : remainingSessions // ignore: cast_nullable_to_non_nullable
                  as int,
        makeupSessions: null == makeupSessions
            ? _value.makeupSessions
            : makeupSessions // ignore: cast_nullable_to_non_nullable
                  as int,
        packageEndDate: null == packageEndDate
            ? _value.packageEndDate
            : packageEndDate // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentTotalTl: null == paymentTotalTl
            ? _value.paymentTotalTl
            : paymentTotalTl // ignore: cast_nullable_to_non_nullable
                  as int,
        paymentPaidTl: null == paymentPaidTl
            ? _value.paymentPaidTl
            : paymentPaidTl // ignore: cast_nullable_to_non_nullable
                  as int,
        lastPaymentDate: null == lastPaymentDate
            ? _value.lastPaymentDate
            : lastPaymentDate // ignore: cast_nullable_to_non_nullable
                  as String,
        history: null == history
            ? _value._history
            : history // ignore: cast_nullable_to_non_nullable
                  as List<SessionHistoryEntry>,
        seriesByMetric: null == seriesByMetric
            ? _value._seriesByMetric
            : seriesByMetric // ignore: cast_nullable_to_non_nullable
                  as Map<TrainerMetric, TrainerMetricSeries>,
        selectedMetric: null == selectedMetric
            ? _value.selectedMetric
            : selectedMetric // ignore: cast_nullable_to_non_nullable
                  as TrainerMetric,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        notFound: null == notFound
            ? _value.notFound
            : notFound // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$AdminMemberDetailImpl extends _AdminMemberDetail {
  const _$AdminMemberDetailImpl({
    required this.id,
    required this.initials,
    required this.name,
    required this.phone,
    required this.trainerName,
    required this.remainingSessions,
    required this.makeupSessions,
    required this.packageEndDate,
    required this.paymentTotalTl,
    required this.paymentPaidTl,
    required this.lastPaymentDate,
    required final List<SessionHistoryEntry> history,
    required final Map<TrainerMetric, TrainerMetricSeries> seriesByMetric,
    this.selectedMetric = TrainerMetric.kilo,
    this.isLoading = false,
    this.notFound = false,
  }) : _history = history,
       _seriesByMetric = seriesByMetric,
       super._();

  @override
  final String id;
  @override
  final String initials;
  @override
  final String name;
  @override
  final String phone;
  @override
  final String trainerName;
  @override
  final int remainingSessions;
  @override
  final int makeupSessions;
  @override
  final String packageEndDate;
  @override
  final int paymentTotalTl;
  @override
  final int paymentPaidTl;
  @override
  final String lastPaymentDate;
  final List<SessionHistoryEntry> _history;
  @override
  List<SessionHistoryEntry> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  final Map<TrainerMetric, TrainerMetricSeries> _seriesByMetric;
  @override
  Map<TrainerMetric, TrainerMetricSeries> get seriesByMetric {
    if (_seriesByMetric is EqualUnmodifiableMapView) return _seriesByMetric;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_seriesByMetric);
  }

  @override
  @JsonKey()
  final TrainerMetric selectedMetric;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool notFound;

  @override
  String toString() {
    return 'AdminMemberDetail(id: $id, initials: $initials, name: $name, phone: $phone, trainerName: $trainerName, remainingSessions: $remainingSessions, makeupSessions: $makeupSessions, packageEndDate: $packageEndDate, paymentTotalTl: $paymentTotalTl, paymentPaidTl: $paymentPaidTl, lastPaymentDate: $lastPaymentDate, history: $history, seriesByMetric: $seriesByMetric, selectedMetric: $selectedMetric, isLoading: $isLoading, notFound: $notFound)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminMemberDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.initials, initials) ||
                other.initials == initials) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.trainerName, trainerName) ||
                other.trainerName == trainerName) &&
            (identical(other.remainingSessions, remainingSessions) ||
                other.remainingSessions == remainingSessions) &&
            (identical(other.makeupSessions, makeupSessions) ||
                other.makeupSessions == makeupSessions) &&
            (identical(other.packageEndDate, packageEndDate) ||
                other.packageEndDate == packageEndDate) &&
            (identical(other.paymentTotalTl, paymentTotalTl) ||
                other.paymentTotalTl == paymentTotalTl) &&
            (identical(other.paymentPaidTl, paymentPaidTl) ||
                other.paymentPaidTl == paymentPaidTl) &&
            (identical(other.lastPaymentDate, lastPaymentDate) ||
                other.lastPaymentDate == lastPaymentDate) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            const DeepCollectionEquality().equals(
              other._seriesByMetric,
              _seriesByMetric,
            ) &&
            (identical(other.selectedMetric, selectedMetric) ||
                other.selectedMetric == selectedMetric) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.notFound, notFound) ||
                other.notFound == notFound));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    initials,
    name,
    phone,
    trainerName,
    remainingSessions,
    makeupSessions,
    packageEndDate,
    paymentTotalTl,
    paymentPaidTl,
    lastPaymentDate,
    const DeepCollectionEquality().hash(_history),
    const DeepCollectionEquality().hash(_seriesByMetric),
    selectedMetric,
    isLoading,
    notFound,
  );

  /// Create a copy of AdminMemberDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminMemberDetailImplCopyWith<_$AdminMemberDetailImpl> get copyWith =>
      __$$AdminMemberDetailImplCopyWithImpl<_$AdminMemberDetailImpl>(
        this,
        _$identity,
      );
}

abstract class _AdminMemberDetail extends AdminMemberDetail {
  const factory _AdminMemberDetail({
    required final String id,
    required final String initials,
    required final String name,
    required final String phone,
    required final String trainerName,
    required final int remainingSessions,
    required final int makeupSessions,
    required final String packageEndDate,
    required final int paymentTotalTl,
    required final int paymentPaidTl,
    required final String lastPaymentDate,
    required final List<SessionHistoryEntry> history,
    required final Map<TrainerMetric, TrainerMetricSeries> seriesByMetric,
    final TrainerMetric selectedMetric,
    final bool isLoading,
    final bool notFound,
  }) = _$AdminMemberDetailImpl;
  const _AdminMemberDetail._() : super._();

  @override
  String get id;
  @override
  String get initials;
  @override
  String get name;
  @override
  String get phone;
  @override
  String get trainerName;
  @override
  int get remainingSessions;
  @override
  int get makeupSessions;
  @override
  String get packageEndDate;
  @override
  int get paymentTotalTl;
  @override
  int get paymentPaidTl;
  @override
  String get lastPaymentDate;
  @override
  List<SessionHistoryEntry> get history;
  @override
  Map<TrainerMetric, TrainerMetricSeries> get seriesByMetric;
  @override
  TrainerMetric get selectedMetric;
  @override
  bool get isLoading;
  @override
  bool get notFound;

  /// Create a copy of AdminMemberDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminMemberDetailImplCopyWith<_$AdminMemberDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
