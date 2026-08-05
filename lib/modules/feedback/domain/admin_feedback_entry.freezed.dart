// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_feedback_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdminFeedbackEntry {
  String get id => throw _privateConstructorUsedError;
  String get initials => throw _privateConstructorUsedError;
  String get memberName => throw _privateConstructorUsedError;
  String get meta => throw _privateConstructorUsedError;
  int get stars => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;

  /// Create a copy of AdminFeedbackEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminFeedbackEntryCopyWith<AdminFeedbackEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminFeedbackEntryCopyWith<$Res> {
  factory $AdminFeedbackEntryCopyWith(
    AdminFeedbackEntry value,
    $Res Function(AdminFeedbackEntry) then,
  ) = _$AdminFeedbackEntryCopyWithImpl<$Res, AdminFeedbackEntry>;
  @useResult
  $Res call({
    String id,
    String initials,
    String memberName,
    String meta,
    int stars,
    String comment,
  });
}

/// @nodoc
class _$AdminFeedbackEntryCopyWithImpl<$Res, $Val extends AdminFeedbackEntry>
    implements $AdminFeedbackEntryCopyWith<$Res> {
  _$AdminFeedbackEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminFeedbackEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initials = null,
    Object? memberName = null,
    Object? meta = null,
    Object? stars = null,
    Object? comment = null,
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
            memberName: null == memberName
                ? _value.memberName
                : memberName // ignore: cast_nullable_to_non_nullable
                      as String,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as String,
            stars: null == stars
                ? _value.stars
                : stars // ignore: cast_nullable_to_non_nullable
                      as int,
            comment: null == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminFeedbackEntryImplCopyWith<$Res>
    implements $AdminFeedbackEntryCopyWith<$Res> {
  factory _$$AdminFeedbackEntryImplCopyWith(
    _$AdminFeedbackEntryImpl value,
    $Res Function(_$AdminFeedbackEntryImpl) then,
  ) = __$$AdminFeedbackEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String initials,
    String memberName,
    String meta,
    int stars,
    String comment,
  });
}

/// @nodoc
class __$$AdminFeedbackEntryImplCopyWithImpl<$Res>
    extends _$AdminFeedbackEntryCopyWithImpl<$Res, _$AdminFeedbackEntryImpl>
    implements _$$AdminFeedbackEntryImplCopyWith<$Res> {
  __$$AdminFeedbackEntryImplCopyWithImpl(
    _$AdminFeedbackEntryImpl _value,
    $Res Function(_$AdminFeedbackEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminFeedbackEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initials = null,
    Object? memberName = null,
    Object? meta = null,
    Object? stars = null,
    Object? comment = null,
  }) {
    return _then(
      _$AdminFeedbackEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        initials: null == initials
            ? _value.initials
            : initials // ignore: cast_nullable_to_non_nullable
                  as String,
        memberName: null == memberName
            ? _value.memberName
            : memberName // ignore: cast_nullable_to_non_nullable
                  as String,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as String,
        stars: null == stars
            ? _value.stars
            : stars // ignore: cast_nullable_to_non_nullable
                  as int,
        comment: null == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$AdminFeedbackEntryImpl implements _AdminFeedbackEntry {
  const _$AdminFeedbackEntryImpl({
    required this.id,
    required this.initials,
    required this.memberName,
    required this.meta,
    required this.stars,
    required this.comment,
  });

  @override
  final String id;
  @override
  final String initials;
  @override
  final String memberName;
  @override
  final String meta;
  @override
  final int stars;
  @override
  final String comment;

  @override
  String toString() {
    return 'AdminFeedbackEntry(id: $id, initials: $initials, memberName: $memberName, meta: $meta, stars: $stars, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminFeedbackEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.initials, initials) ||
                other.initials == initials) &&
            (identical(other.memberName, memberName) ||
                other.memberName == memberName) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.stars, stars) || other.stars == stars) &&
            (identical(other.comment, comment) || other.comment == comment));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, initials, memberName, meta, stars, comment);

  /// Create a copy of AdminFeedbackEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminFeedbackEntryImplCopyWith<_$AdminFeedbackEntryImpl> get copyWith =>
      __$$AdminFeedbackEntryImplCopyWithImpl<_$AdminFeedbackEntryImpl>(
        this,
        _$identity,
      );
}

abstract class _AdminFeedbackEntry implements AdminFeedbackEntry {
  const factory _AdminFeedbackEntry({
    required final String id,
    required final String initials,
    required final String memberName,
    required final String meta,
    required final int stars,
    required final String comment,
  }) = _$AdminFeedbackEntryImpl;

  @override
  String get id;
  @override
  String get initials;
  @override
  String get memberName;
  @override
  String get meta;
  @override
  int get stars;
  @override
  String get comment;

  /// Create a copy of AdminFeedbackEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminFeedbackEntryImplCopyWith<_$AdminFeedbackEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AdminFeedbackSummary {
  double get average => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  Map<int, int> get starCounts => throw _privateConstructorUsedError;
  List<AdminFeedbackEntry> get entries => throw _privateConstructorUsedError;

  /// Create a copy of AdminFeedbackSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminFeedbackSummaryCopyWith<AdminFeedbackSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminFeedbackSummaryCopyWith<$Res> {
  factory $AdminFeedbackSummaryCopyWith(
    AdminFeedbackSummary value,
    $Res Function(AdminFeedbackSummary) then,
  ) = _$AdminFeedbackSummaryCopyWithImpl<$Res, AdminFeedbackSummary>;
  @useResult
  $Res call({
    double average,
    int totalCount,
    Map<int, int> starCounts,
    List<AdminFeedbackEntry> entries,
  });
}

/// @nodoc
class _$AdminFeedbackSummaryCopyWithImpl<
  $Res,
  $Val extends AdminFeedbackSummary
>
    implements $AdminFeedbackSummaryCopyWith<$Res> {
  _$AdminFeedbackSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminFeedbackSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? average = null,
    Object? totalCount = null,
    Object? starCounts = null,
    Object? entries = null,
  }) {
    return _then(
      _value.copyWith(
            average: null == average
                ? _value.average
                : average // ignore: cast_nullable_to_non_nullable
                      as double,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            starCounts: null == starCounts
                ? _value.starCounts
                : starCounts // ignore: cast_nullable_to_non_nullable
                      as Map<int, int>,
            entries: null == entries
                ? _value.entries
                : entries // ignore: cast_nullable_to_non_nullable
                      as List<AdminFeedbackEntry>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminFeedbackSummaryImplCopyWith<$Res>
    implements $AdminFeedbackSummaryCopyWith<$Res> {
  factory _$$AdminFeedbackSummaryImplCopyWith(
    _$AdminFeedbackSummaryImpl value,
    $Res Function(_$AdminFeedbackSummaryImpl) then,
  ) = __$$AdminFeedbackSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double average,
    int totalCount,
    Map<int, int> starCounts,
    List<AdminFeedbackEntry> entries,
  });
}

/// @nodoc
class __$$AdminFeedbackSummaryImplCopyWithImpl<$Res>
    extends _$AdminFeedbackSummaryCopyWithImpl<$Res, _$AdminFeedbackSummaryImpl>
    implements _$$AdminFeedbackSummaryImplCopyWith<$Res> {
  __$$AdminFeedbackSummaryImplCopyWithImpl(
    _$AdminFeedbackSummaryImpl _value,
    $Res Function(_$AdminFeedbackSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminFeedbackSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? average = null,
    Object? totalCount = null,
    Object? starCounts = null,
    Object? entries = null,
  }) {
    return _then(
      _$AdminFeedbackSummaryImpl(
        average: null == average
            ? _value.average
            : average // ignore: cast_nullable_to_non_nullable
                  as double,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        starCounts: null == starCounts
            ? _value._starCounts
            : starCounts // ignore: cast_nullable_to_non_nullable
                  as Map<int, int>,
        entries: null == entries
            ? _value._entries
            : entries // ignore: cast_nullable_to_non_nullable
                  as List<AdminFeedbackEntry>,
      ),
    );
  }
}

/// @nodoc

class _$AdminFeedbackSummaryImpl implements _AdminFeedbackSummary {
  const _$AdminFeedbackSummaryImpl({
    required this.average,
    required this.totalCount,
    required final Map<int, int> starCounts,
    required final List<AdminFeedbackEntry> entries,
  }) : _starCounts = starCounts,
       _entries = entries;

  @override
  final double average;
  @override
  final int totalCount;
  final Map<int, int> _starCounts;
  @override
  Map<int, int> get starCounts {
    if (_starCounts is EqualUnmodifiableMapView) return _starCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_starCounts);
  }

  final List<AdminFeedbackEntry> _entries;
  @override
  List<AdminFeedbackEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  String toString() {
    return 'AdminFeedbackSummary(average: $average, totalCount: $totalCount, starCounts: $starCounts, entries: $entries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminFeedbackSummaryImpl &&
            (identical(other.average, average) || other.average == average) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            const DeepCollectionEquality().equals(
              other._starCounts,
              _starCounts,
            ) &&
            const DeepCollectionEquality().equals(other._entries, _entries));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    average,
    totalCount,
    const DeepCollectionEquality().hash(_starCounts),
    const DeepCollectionEquality().hash(_entries),
  );

  /// Create a copy of AdminFeedbackSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminFeedbackSummaryImplCopyWith<_$AdminFeedbackSummaryImpl>
  get copyWith =>
      __$$AdminFeedbackSummaryImplCopyWithImpl<_$AdminFeedbackSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _AdminFeedbackSummary implements AdminFeedbackSummary {
  const factory _AdminFeedbackSummary({
    required final double average,
    required final int totalCount,
    required final Map<int, int> starCounts,
    required final List<AdminFeedbackEntry> entries,
  }) = _$AdminFeedbackSummaryImpl;

  @override
  double get average;
  @override
  int get totalCount;
  @override
  Map<int, int> get starCounts;
  @override
  List<AdminFeedbackEntry> get entries;

  /// Create a copy of AdminFeedbackSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminFeedbackSummaryImplCopyWith<_$AdminFeedbackSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
