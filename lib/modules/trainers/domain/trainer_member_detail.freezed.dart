// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_member_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SessionHistoryEntry {
  String get date => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get stateLabel => throw _privateConstructorUsedError;
  bool get isPositive => throw _privateConstructorUsedError;

  /// Create a copy of SessionHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionHistoryEntryCopyWith<SessionHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionHistoryEntryCopyWith<$Res> {
  factory $SessionHistoryEntryCopyWith(
    SessionHistoryEntry value,
    $Res Function(SessionHistoryEntry) then,
  ) = _$SessionHistoryEntryCopyWithImpl<$Res, SessionHistoryEntry>;
  @useResult
  $Res call({String date, String type, String stateLabel, bool isPositive});
}

/// @nodoc
class _$SessionHistoryEntryCopyWithImpl<$Res, $Val extends SessionHistoryEntry>
    implements $SessionHistoryEntryCopyWith<$Res> {
  _$SessionHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? type = null,
    Object? stateLabel = null,
    Object? isPositive = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            stateLabel: null == stateLabel
                ? _value.stateLabel
                : stateLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            isPositive: null == isPositive
                ? _value.isPositive
                : isPositive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionHistoryEntryImplCopyWith<$Res>
    implements $SessionHistoryEntryCopyWith<$Res> {
  factory _$$SessionHistoryEntryImplCopyWith(
    _$SessionHistoryEntryImpl value,
    $Res Function(_$SessionHistoryEntryImpl) then,
  ) = __$$SessionHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String date, String type, String stateLabel, bool isPositive});
}

/// @nodoc
class __$$SessionHistoryEntryImplCopyWithImpl<$Res>
    extends _$SessionHistoryEntryCopyWithImpl<$Res, _$SessionHistoryEntryImpl>
    implements _$$SessionHistoryEntryImplCopyWith<$Res> {
  __$$SessionHistoryEntryImplCopyWithImpl(
    _$SessionHistoryEntryImpl _value,
    $Res Function(_$SessionHistoryEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? type = null,
    Object? stateLabel = null,
    Object? isPositive = null,
  }) {
    return _then(
      _$SessionHistoryEntryImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        stateLabel: null == stateLabel
            ? _value.stateLabel
            : stateLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        isPositive: null == isPositive
            ? _value.isPositive
            : isPositive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$SessionHistoryEntryImpl implements _SessionHistoryEntry {
  const _$SessionHistoryEntryImpl({
    required this.date,
    required this.type,
    required this.stateLabel,
    required this.isPositive,
  });

  @override
  final String date;
  @override
  final String type;
  @override
  final String stateLabel;
  @override
  final bool isPositive;

  @override
  String toString() {
    return 'SessionHistoryEntry(date: $date, type: $type, stateLabel: $stateLabel, isPositive: $isPositive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionHistoryEntryImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.stateLabel, stateLabel) ||
                other.stateLabel == stateLabel) &&
            (identical(other.isPositive, isPositive) ||
                other.isPositive == isPositive));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, date, type, stateLabel, isPositive);

  /// Create a copy of SessionHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionHistoryEntryImplCopyWith<_$SessionHistoryEntryImpl> get copyWith =>
      __$$SessionHistoryEntryImplCopyWithImpl<_$SessionHistoryEntryImpl>(
        this,
        _$identity,
      );
}

abstract class _SessionHistoryEntry implements SessionHistoryEntry {
  const factory _SessionHistoryEntry({
    required final String date,
    required final String type,
    required final String stateLabel,
    required final bool isPositive,
  }) = _$SessionHistoryEntryImpl;

  @override
  String get date;
  @override
  String get type;
  @override
  String get stateLabel;
  @override
  bool get isPositive;

  /// Create a copy of SessionHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionHistoryEntryImplCopyWith<_$SessionHistoryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TrainerMetricSeries {
  TrainerMetric get metric => throw _privateConstructorUsedError;
  List<double> get values => throw _privateConstructorUsedError;
  List<String> get months => throw _privateConstructorUsedError;

  /// Create a copy of TrainerMetricSeries
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerMetricSeriesCopyWith<TrainerMetricSeries> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerMetricSeriesCopyWith<$Res> {
  factory $TrainerMetricSeriesCopyWith(
    TrainerMetricSeries value,
    $Res Function(TrainerMetricSeries) then,
  ) = _$TrainerMetricSeriesCopyWithImpl<$Res, TrainerMetricSeries>;
  @useResult
  $Res call({TrainerMetric metric, List<double> values, List<String> months});
}

/// @nodoc
class _$TrainerMetricSeriesCopyWithImpl<$Res, $Val extends TrainerMetricSeries>
    implements $TrainerMetricSeriesCopyWith<$Res> {
  _$TrainerMetricSeriesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerMetricSeries
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric = null,
    Object? values = null,
    Object? months = null,
  }) {
    return _then(
      _value.copyWith(
            metric: null == metric
                ? _value.metric
                : metric // ignore: cast_nullable_to_non_nullable
                      as TrainerMetric,
            values: null == values
                ? _value.values
                : values // ignore: cast_nullable_to_non_nullable
                      as List<double>,
            months: null == months
                ? _value.months
                : months // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerMetricSeriesImplCopyWith<$Res>
    implements $TrainerMetricSeriesCopyWith<$Res> {
  factory _$$TrainerMetricSeriesImplCopyWith(
    _$TrainerMetricSeriesImpl value,
    $Res Function(_$TrainerMetricSeriesImpl) then,
  ) = __$$TrainerMetricSeriesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TrainerMetric metric, List<double> values, List<String> months});
}

/// @nodoc
class __$$TrainerMetricSeriesImplCopyWithImpl<$Res>
    extends _$TrainerMetricSeriesCopyWithImpl<$Res, _$TrainerMetricSeriesImpl>
    implements _$$TrainerMetricSeriesImplCopyWith<$Res> {
  __$$TrainerMetricSeriesImplCopyWithImpl(
    _$TrainerMetricSeriesImpl _value,
    $Res Function(_$TrainerMetricSeriesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerMetricSeries
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric = null,
    Object? values = null,
    Object? months = null,
  }) {
    return _then(
      _$TrainerMetricSeriesImpl(
        metric: null == metric
            ? _value.metric
            : metric // ignore: cast_nullable_to_non_nullable
                  as TrainerMetric,
        values: null == values
            ? _value._values
            : values // ignore: cast_nullable_to_non_nullable
                  as List<double>,
        months: null == months
            ? _value._months
            : months // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

class _$TrainerMetricSeriesImpl implements _TrainerMetricSeries {
  const _$TrainerMetricSeriesImpl({
    required this.metric,
    required final List<double> values,
    required final List<String> months,
  }) : _values = values,
       _months = months;

  @override
  final TrainerMetric metric;
  final List<double> _values;
  @override
  List<double> get values {
    if (_values is EqualUnmodifiableListView) return _values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_values);
  }

  final List<String> _months;
  @override
  List<String> get months {
    if (_months is EqualUnmodifiableListView) return _months;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_months);
  }

  @override
  String toString() {
    return 'TrainerMetricSeries(metric: $metric, values: $values, months: $months)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerMetricSeriesImpl &&
            (identical(other.metric, metric) || other.metric == metric) &&
            const DeepCollectionEquality().equals(other._values, _values) &&
            const DeepCollectionEquality().equals(other._months, _months));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    metric,
    const DeepCollectionEquality().hash(_values),
    const DeepCollectionEquality().hash(_months),
  );

  /// Create a copy of TrainerMetricSeries
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerMetricSeriesImplCopyWith<_$TrainerMetricSeriesImpl> get copyWith =>
      __$$TrainerMetricSeriesImplCopyWithImpl<_$TrainerMetricSeriesImpl>(
        this,
        _$identity,
      );
}

abstract class _TrainerMetricSeries implements TrainerMetricSeries {
  const factory _TrainerMetricSeries({
    required final TrainerMetric metric,
    required final List<double> values,
    required final List<String> months,
  }) = _$TrainerMetricSeriesImpl;

  @override
  TrainerMetric get metric;
  @override
  List<double> get values;
  @override
  List<String> get months;

  /// Create a copy of TrainerMetricSeries
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerMetricSeriesImplCopyWith<_$TrainerMetricSeriesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TrainerMemberDetail {
  String get id => throw _privateConstructorUsedError;
  String get initials => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get memberSince => throw _privateConstructorUsedError;
  int get remainingSessions => throw _privateConstructorUsedError;
  String get packageEndDate => throw _privateConstructorUsedError;
  List<SessionHistoryEntry> get history => throw _privateConstructorUsedError;
  Map<TrainerMetric, TrainerMetricSeries> get seriesByMetric =>
      throw _privateConstructorUsedError;
  TrainerMetric get selectedMetric => throw _privateConstructorUsedError;

  /// Create a copy of TrainerMemberDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerMemberDetailCopyWith<TrainerMemberDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerMemberDetailCopyWith<$Res> {
  factory $TrainerMemberDetailCopyWith(
    TrainerMemberDetail value,
    $Res Function(TrainerMemberDetail) then,
  ) = _$TrainerMemberDetailCopyWithImpl<$Res, TrainerMemberDetail>;
  @useResult
  $Res call({
    String id,
    String initials,
    String name,
    String phone,
    String memberSince,
    int remainingSessions,
    String packageEndDate,
    List<SessionHistoryEntry> history,
    Map<TrainerMetric, TrainerMetricSeries> seriesByMetric,
    TrainerMetric selectedMetric,
  });
}

/// @nodoc
class _$TrainerMemberDetailCopyWithImpl<$Res, $Val extends TrainerMemberDetail>
    implements $TrainerMemberDetailCopyWith<$Res> {
  _$TrainerMemberDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerMemberDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initials = null,
    Object? name = null,
    Object? phone = null,
    Object? memberSince = null,
    Object? remainingSessions = null,
    Object? packageEndDate = null,
    Object? history = null,
    Object? seriesByMetric = null,
    Object? selectedMetric = null,
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
            memberSince: null == memberSince
                ? _value.memberSince
                : memberSince // ignore: cast_nullable_to_non_nullable
                      as String,
            remainingSessions: null == remainingSessions
                ? _value.remainingSessions
                : remainingSessions // ignore: cast_nullable_to_non_nullable
                      as int,
            packageEndDate: null == packageEndDate
                ? _value.packageEndDate
                : packageEndDate // ignore: cast_nullable_to_non_nullable
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerMemberDetailImplCopyWith<$Res>
    implements $TrainerMemberDetailCopyWith<$Res> {
  factory _$$TrainerMemberDetailImplCopyWith(
    _$TrainerMemberDetailImpl value,
    $Res Function(_$TrainerMemberDetailImpl) then,
  ) = __$$TrainerMemberDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String initials,
    String name,
    String phone,
    String memberSince,
    int remainingSessions,
    String packageEndDate,
    List<SessionHistoryEntry> history,
    Map<TrainerMetric, TrainerMetricSeries> seriesByMetric,
    TrainerMetric selectedMetric,
  });
}

/// @nodoc
class __$$TrainerMemberDetailImplCopyWithImpl<$Res>
    extends _$TrainerMemberDetailCopyWithImpl<$Res, _$TrainerMemberDetailImpl>
    implements _$$TrainerMemberDetailImplCopyWith<$Res> {
  __$$TrainerMemberDetailImplCopyWithImpl(
    _$TrainerMemberDetailImpl _value,
    $Res Function(_$TrainerMemberDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerMemberDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initials = null,
    Object? name = null,
    Object? phone = null,
    Object? memberSince = null,
    Object? remainingSessions = null,
    Object? packageEndDate = null,
    Object? history = null,
    Object? seriesByMetric = null,
    Object? selectedMetric = null,
  }) {
    return _then(
      _$TrainerMemberDetailImpl(
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
        memberSince: null == memberSince
            ? _value.memberSince
            : memberSince // ignore: cast_nullable_to_non_nullable
                  as String,
        remainingSessions: null == remainingSessions
            ? _value.remainingSessions
            : remainingSessions // ignore: cast_nullable_to_non_nullable
                  as int,
        packageEndDate: null == packageEndDate
            ? _value.packageEndDate
            : packageEndDate // ignore: cast_nullable_to_non_nullable
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
      ),
    );
  }
}

/// @nodoc

class _$TrainerMemberDetailImpl implements _TrainerMemberDetail {
  const _$TrainerMemberDetailImpl({
    required this.id,
    required this.initials,
    required this.name,
    required this.phone,
    required this.memberSince,
    required this.remainingSessions,
    required this.packageEndDate,
    required final List<SessionHistoryEntry> history,
    required final Map<TrainerMetric, TrainerMetricSeries> seriesByMetric,
    this.selectedMetric = TrainerMetric.kilo,
  }) : _history = history,
       _seriesByMetric = seriesByMetric;

  @override
  final String id;
  @override
  final String initials;
  @override
  final String name;
  @override
  final String phone;
  @override
  final String memberSince;
  @override
  final int remainingSessions;
  @override
  final String packageEndDate;
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
  String toString() {
    return 'TrainerMemberDetail(id: $id, initials: $initials, name: $name, phone: $phone, memberSince: $memberSince, remainingSessions: $remainingSessions, packageEndDate: $packageEndDate, history: $history, seriesByMetric: $seriesByMetric, selectedMetric: $selectedMetric)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerMemberDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.initials, initials) ||
                other.initials == initials) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.memberSince, memberSince) ||
                other.memberSince == memberSince) &&
            (identical(other.remainingSessions, remainingSessions) ||
                other.remainingSessions == remainingSessions) &&
            (identical(other.packageEndDate, packageEndDate) ||
                other.packageEndDate == packageEndDate) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            const DeepCollectionEquality().equals(
              other._seriesByMetric,
              _seriesByMetric,
            ) &&
            (identical(other.selectedMetric, selectedMetric) ||
                other.selectedMetric == selectedMetric));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    initials,
    name,
    phone,
    memberSince,
    remainingSessions,
    packageEndDate,
    const DeepCollectionEquality().hash(_history),
    const DeepCollectionEquality().hash(_seriesByMetric),
    selectedMetric,
  );

  /// Create a copy of TrainerMemberDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerMemberDetailImplCopyWith<_$TrainerMemberDetailImpl> get copyWith =>
      __$$TrainerMemberDetailImplCopyWithImpl<_$TrainerMemberDetailImpl>(
        this,
        _$identity,
      );
}

abstract class _TrainerMemberDetail implements TrainerMemberDetail {
  const factory _TrainerMemberDetail({
    required final String id,
    required final String initials,
    required final String name,
    required final String phone,
    required final String memberSince,
    required final int remainingSessions,
    required final String packageEndDate,
    required final List<SessionHistoryEntry> history,
    required final Map<TrainerMetric, TrainerMetricSeries> seriesByMetric,
    final TrainerMetric selectedMetric,
  }) = _$TrainerMemberDetailImpl;

  @override
  String get id;
  @override
  String get initials;
  @override
  String get name;
  @override
  String get phone;
  @override
  String get memberSince;
  @override
  int get remainingSessions;
  @override
  String get packageEndDate;
  @override
  List<SessionHistoryEntry> get history;
  @override
  Map<TrainerMetric, TrainerMetricSeries> get seriesByMetric;
  @override
  TrainerMetric get selectedMetric;

  /// Create a copy of TrainerMemberDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerMemberDetailImplCopyWith<_$TrainerMemberDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
