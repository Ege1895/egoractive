// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ExpenseEntry {
  String get id => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get amountTl => throw _privateConstructorUsedError;
  bool get recurring => throw _privateConstructorUsedError;

  /// Create a copy of ExpenseEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseEntryCopyWith<ExpenseEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseEntryCopyWith<$Res> {
  factory $ExpenseEntryCopyWith(
    ExpenseEntry value,
    $Res Function(ExpenseEntry) then,
  ) = _$ExpenseEntryCopyWithImpl<$Res, ExpenseEntry>;
  @useResult
  $Res call({
    String id,
    String category,
    String title,
    String date,
    int amountTl,
    bool recurring,
  });
}

/// @nodoc
class _$ExpenseEntryCopyWithImpl<$Res, $Val extends ExpenseEntry>
    implements $ExpenseEntryCopyWith<$Res> {
  _$ExpenseEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpenseEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? title = null,
    Object? date = null,
    Object? amountTl = null,
    Object? recurring = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            amountTl: null == amountTl
                ? _value.amountTl
                : amountTl // ignore: cast_nullable_to_non_nullable
                      as int,
            recurring: null == recurring
                ? _value.recurring
                : recurring // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpenseEntryImplCopyWith<$Res>
    implements $ExpenseEntryCopyWith<$Res> {
  factory _$$ExpenseEntryImplCopyWith(
    _$ExpenseEntryImpl value,
    $Res Function(_$ExpenseEntryImpl) then,
  ) = __$$ExpenseEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String category,
    String title,
    String date,
    int amountTl,
    bool recurring,
  });
}

/// @nodoc
class __$$ExpenseEntryImplCopyWithImpl<$Res>
    extends _$ExpenseEntryCopyWithImpl<$Res, _$ExpenseEntryImpl>
    implements _$$ExpenseEntryImplCopyWith<$Res> {
  __$$ExpenseEntryImplCopyWithImpl(
    _$ExpenseEntryImpl _value,
    $Res Function(_$ExpenseEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpenseEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? title = null,
    Object? date = null,
    Object? amountTl = null,
    Object? recurring = null,
  }) {
    return _then(
      _$ExpenseEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        amountTl: null == amountTl
            ? _value.amountTl
            : amountTl // ignore: cast_nullable_to_non_nullable
                  as int,
        recurring: null == recurring
            ? _value.recurring
            : recurring // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ExpenseEntryImpl implements _ExpenseEntry {
  const _$ExpenseEntryImpl({
    required this.id,
    required this.category,
    required this.title,
    required this.date,
    required this.amountTl,
    this.recurring = false,
  });

  @override
  final String id;
  @override
  final String category;
  @override
  final String title;
  @override
  final String date;
  @override
  final int amountTl;
  @override
  @JsonKey()
  final bool recurring;

  @override
  String toString() {
    return 'ExpenseEntry(id: $id, category: $category, title: $title, date: $date, amountTl: $amountTl, recurring: $recurring)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.amountTl, amountTl) ||
                other.amountTl == amountTl) &&
            (identical(other.recurring, recurring) ||
                other.recurring == recurring));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, category, title, date, amountTl, recurring);

  /// Create a copy of ExpenseEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseEntryImplCopyWith<_$ExpenseEntryImpl> get copyWith =>
      __$$ExpenseEntryImplCopyWithImpl<_$ExpenseEntryImpl>(this, _$identity);
}

abstract class _ExpenseEntry implements ExpenseEntry {
  const factory _ExpenseEntry({
    required final String id,
    required final String category,
    required final String title,
    required final String date,
    required final int amountTl,
    final bool recurring,
  }) = _$ExpenseEntryImpl;

  @override
  String get id;
  @override
  String get category;
  @override
  String get title;
  @override
  String get date;
  @override
  int get amountTl;
  @override
  bool get recurring;

  /// Create a copy of ExpenseEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseEntryImplCopyWith<_$ExpenseEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ExpenseCategoryTotal {
  String get category => throw _privateConstructorUsedError;
  int get amountTl => throw _privateConstructorUsedError;

  /// Create a copy of ExpenseCategoryTotal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseCategoryTotalCopyWith<ExpenseCategoryTotal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseCategoryTotalCopyWith<$Res> {
  factory $ExpenseCategoryTotalCopyWith(
    ExpenseCategoryTotal value,
    $Res Function(ExpenseCategoryTotal) then,
  ) = _$ExpenseCategoryTotalCopyWithImpl<$Res, ExpenseCategoryTotal>;
  @useResult
  $Res call({String category, int amountTl});
}

/// @nodoc
class _$ExpenseCategoryTotalCopyWithImpl<
  $Res,
  $Val extends ExpenseCategoryTotal
>
    implements $ExpenseCategoryTotalCopyWith<$Res> {
  _$ExpenseCategoryTotalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpenseCategoryTotal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? category = null, Object? amountTl = null}) {
    return _then(
      _value.copyWith(
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            amountTl: null == amountTl
                ? _value.amountTl
                : amountTl // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpenseCategoryTotalImplCopyWith<$Res>
    implements $ExpenseCategoryTotalCopyWith<$Res> {
  factory _$$ExpenseCategoryTotalImplCopyWith(
    _$ExpenseCategoryTotalImpl value,
    $Res Function(_$ExpenseCategoryTotalImpl) then,
  ) = __$$ExpenseCategoryTotalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String category, int amountTl});
}

/// @nodoc
class __$$ExpenseCategoryTotalImplCopyWithImpl<$Res>
    extends _$ExpenseCategoryTotalCopyWithImpl<$Res, _$ExpenseCategoryTotalImpl>
    implements _$$ExpenseCategoryTotalImplCopyWith<$Res> {
  __$$ExpenseCategoryTotalImplCopyWithImpl(
    _$ExpenseCategoryTotalImpl _value,
    $Res Function(_$ExpenseCategoryTotalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpenseCategoryTotal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? category = null, Object? amountTl = null}) {
    return _then(
      _$ExpenseCategoryTotalImpl(
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        amountTl: null == amountTl
            ? _value.amountTl
            : amountTl // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ExpenseCategoryTotalImpl implements _ExpenseCategoryTotal {
  const _$ExpenseCategoryTotalImpl({
    required this.category,
    required this.amountTl,
  });

  @override
  final String category;
  @override
  final int amountTl;

  @override
  String toString() {
    return 'ExpenseCategoryTotal(category: $category, amountTl: $amountTl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseCategoryTotalImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.amountTl, amountTl) ||
                other.amountTl == amountTl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, category, amountTl);

  /// Create a copy of ExpenseCategoryTotal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseCategoryTotalImplCopyWith<_$ExpenseCategoryTotalImpl>
  get copyWith =>
      __$$ExpenseCategoryTotalImplCopyWithImpl<_$ExpenseCategoryTotalImpl>(
        this,
        _$identity,
      );
}

abstract class _ExpenseCategoryTotal implements ExpenseCategoryTotal {
  const factory _ExpenseCategoryTotal({
    required final String category,
    required final int amountTl,
  }) = _$ExpenseCategoryTotalImpl;

  @override
  String get category;
  @override
  int get amountTl;

  /// Create a copy of ExpenseCategoryTotal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseCategoryTotalImplCopyWith<_$ExpenseCategoryTotalImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ExpensesState {
  String get monthLabel => throw _privateConstructorUsedError;
  String get revenueRatioLabel => throw _privateConstructorUsedError;
  List<ExpenseEntry> get entries => throw _privateConstructorUsedError;

  /// Create a copy of ExpensesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpensesStateCopyWith<ExpensesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpensesStateCopyWith<$Res> {
  factory $ExpensesStateCopyWith(
    ExpensesState value,
    $Res Function(ExpensesState) then,
  ) = _$ExpensesStateCopyWithImpl<$Res, ExpensesState>;
  @useResult
  $Res call({
    String monthLabel,
    String revenueRatioLabel,
    List<ExpenseEntry> entries,
  });
}

/// @nodoc
class _$ExpensesStateCopyWithImpl<$Res, $Val extends ExpensesState>
    implements $ExpensesStateCopyWith<$Res> {
  _$ExpensesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpensesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthLabel = null,
    Object? revenueRatioLabel = null,
    Object? entries = null,
  }) {
    return _then(
      _value.copyWith(
            monthLabel: null == monthLabel
                ? _value.monthLabel
                : monthLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            revenueRatioLabel: null == revenueRatioLabel
                ? _value.revenueRatioLabel
                : revenueRatioLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            entries: null == entries
                ? _value.entries
                : entries // ignore: cast_nullable_to_non_nullable
                      as List<ExpenseEntry>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpensesStateImplCopyWith<$Res>
    implements $ExpensesStateCopyWith<$Res> {
  factory _$$ExpensesStateImplCopyWith(
    _$ExpensesStateImpl value,
    $Res Function(_$ExpensesStateImpl) then,
  ) = __$$ExpensesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String monthLabel,
    String revenueRatioLabel,
    List<ExpenseEntry> entries,
  });
}

/// @nodoc
class __$$ExpensesStateImplCopyWithImpl<$Res>
    extends _$ExpensesStateCopyWithImpl<$Res, _$ExpensesStateImpl>
    implements _$$ExpensesStateImplCopyWith<$Res> {
  __$$ExpensesStateImplCopyWithImpl(
    _$ExpensesStateImpl _value,
    $Res Function(_$ExpensesStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpensesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthLabel = null,
    Object? revenueRatioLabel = null,
    Object? entries = null,
  }) {
    return _then(
      _$ExpensesStateImpl(
        monthLabel: null == monthLabel
            ? _value.monthLabel
            : monthLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        revenueRatioLabel: null == revenueRatioLabel
            ? _value.revenueRatioLabel
            : revenueRatioLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        entries: null == entries
            ? _value._entries
            : entries // ignore: cast_nullable_to_non_nullable
                  as List<ExpenseEntry>,
      ),
    );
  }
}

/// @nodoc

class _$ExpensesStateImpl extends _ExpensesState {
  const _$ExpensesStateImpl({
    required this.monthLabel,
    required this.revenueRatioLabel,
    required final List<ExpenseEntry> entries,
  }) : _entries = entries,
       super._();

  @override
  final String monthLabel;
  @override
  final String revenueRatioLabel;
  final List<ExpenseEntry> _entries;
  @override
  List<ExpenseEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  String toString() {
    return 'ExpensesState(monthLabel: $monthLabel, revenueRatioLabel: $revenueRatioLabel, entries: $entries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpensesStateImpl &&
            (identical(other.monthLabel, monthLabel) ||
                other.monthLabel == monthLabel) &&
            (identical(other.revenueRatioLabel, revenueRatioLabel) ||
                other.revenueRatioLabel == revenueRatioLabel) &&
            const DeepCollectionEquality().equals(other._entries, _entries));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    monthLabel,
    revenueRatioLabel,
    const DeepCollectionEquality().hash(_entries),
  );

  /// Create a copy of ExpensesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpensesStateImplCopyWith<_$ExpensesStateImpl> get copyWith =>
      __$$ExpensesStateImplCopyWithImpl<_$ExpensesStateImpl>(this, _$identity);
}

abstract class _ExpensesState extends ExpensesState {
  const factory _ExpensesState({
    required final String monthLabel,
    required final String revenueRatioLabel,
    required final List<ExpenseEntry> entries,
  }) = _$ExpensesStateImpl;
  const _ExpensesState._() : super._();

  @override
  String get monthLabel;
  @override
  String get revenueRatioLabel;
  @override
  List<ExpenseEntry> get entries;

  /// Create a copy of ExpensesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpensesStateImplCopyWith<_$ExpensesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
