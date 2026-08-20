// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_member_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdminMemberListState {
  List<AdminMemberSummary> get items => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  bool get isSearching => throw _privateConstructorUsedError;
  List<AdminMemberSummary>? get searchResults =>
      throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of AdminMemberListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminMemberListStateCopyWith<AdminMemberListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminMemberListStateCopyWith<$Res> {
  factory $AdminMemberListStateCopyWith(
    AdminMemberListState value,
    $Res Function(AdminMemberListState) then,
  ) = _$AdminMemberListStateCopyWithImpl<$Res, AdminMemberListState>;
  @useResult
  $Res call({
    List<AdminMemberSummary> items,
    bool isLoading,
    bool isLoadingMore,
    bool hasMore,
    bool isSearching,
    List<AdminMemberSummary>? searchResults,
    String? errorMessage,
  });
}

/// @nodoc
class _$AdminMemberListStateCopyWithImpl<
  $Res,
  $Val extends AdminMemberListState
>
    implements $AdminMemberListStateCopyWith<$Res> {
  _$AdminMemberListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminMemberListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? isSearching = null,
    Object? searchResults = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<AdminMemberSummary>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingMore: null == isLoadingMore
                ? _value.isLoadingMore
                : isLoadingMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSearching: null == isSearching
                ? _value.isSearching
                : isSearching // ignore: cast_nullable_to_non_nullable
                      as bool,
            searchResults: freezed == searchResults
                ? _value.searchResults
                : searchResults // ignore: cast_nullable_to_non_nullable
                      as List<AdminMemberSummary>?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminMemberListStateImplCopyWith<$Res>
    implements $AdminMemberListStateCopyWith<$Res> {
  factory _$$AdminMemberListStateImplCopyWith(
    _$AdminMemberListStateImpl value,
    $Res Function(_$AdminMemberListStateImpl) then,
  ) = __$$AdminMemberListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<AdminMemberSummary> items,
    bool isLoading,
    bool isLoadingMore,
    bool hasMore,
    bool isSearching,
    List<AdminMemberSummary>? searchResults,
    String? errorMessage,
  });
}

/// @nodoc
class __$$AdminMemberListStateImplCopyWithImpl<$Res>
    extends _$AdminMemberListStateCopyWithImpl<$Res, _$AdminMemberListStateImpl>
    implements _$$AdminMemberListStateImplCopyWith<$Res> {
  __$$AdminMemberListStateImplCopyWithImpl(
    _$AdminMemberListStateImpl _value,
    $Res Function(_$AdminMemberListStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminMemberListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? isSearching = null,
    Object? searchResults = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$AdminMemberListStateImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<AdminMemberSummary>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingMore: null == isLoadingMore
            ? _value.isLoadingMore
            : isLoadingMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSearching: null == isSearching
            ? _value.isSearching
            : isSearching // ignore: cast_nullable_to_non_nullable
                  as bool,
        searchResults: freezed == searchResults
            ? _value._searchResults
            : searchResults // ignore: cast_nullable_to_non_nullable
                  as List<AdminMemberSummary>?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$AdminMemberListStateImpl implements _AdminMemberListState {
  const _$AdminMemberListStateImpl({
    final List<AdminMemberSummary> items = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.isSearching = false,
    final List<AdminMemberSummary>? searchResults,
    this.errorMessage,
  }) : _items = items,
       _searchResults = searchResults;

  final List<AdminMemberSummary> _items;
  @override
  @JsonKey()
  List<AdminMemberSummary> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final bool isSearching;
  final List<AdminMemberSummary>? _searchResults;
  @override
  List<AdminMemberSummary>? get searchResults {
    final value = _searchResults;
    if (value == null) return null;
    if (_searchResults is EqualUnmodifiableListView) return _searchResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'AdminMemberListState(items: $items, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasMore: $hasMore, isSearching: $isSearching, searchResults: $searchResults, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminMemberListStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.isSearching, isSearching) ||
                other.isSearching == isSearching) &&
            const DeepCollectionEquality().equals(
              other._searchResults,
              _searchResults,
            ) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    isLoading,
    isLoadingMore,
    hasMore,
    isSearching,
    const DeepCollectionEquality().hash(_searchResults),
    errorMessage,
  );

  /// Create a copy of AdminMemberListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminMemberListStateImplCopyWith<_$AdminMemberListStateImpl>
  get copyWith =>
      __$$AdminMemberListStateImplCopyWithImpl<_$AdminMemberListStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AdminMemberListState implements AdminMemberListState {
  const factory _AdminMemberListState({
    final List<AdminMemberSummary> items,
    final bool isLoading,
    final bool isLoadingMore,
    final bool hasMore,
    final bool isSearching,
    final List<AdminMemberSummary>? searchResults,
    final String? errorMessage,
  }) = _$AdminMemberListStateImpl;

  @override
  List<AdminMemberSummary> get items;
  @override
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override
  bool get hasMore;
  @override
  bool get isSearching;
  @override
  List<AdminMemberSummary>? get searchResults;
  @override
  String? get errorMessage;

  /// Create a copy of AdminMemberListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminMemberListStateImplCopyWith<_$AdminMemberListStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
