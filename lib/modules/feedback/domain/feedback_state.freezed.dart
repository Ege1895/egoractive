// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FeedbackState {
  int get rating => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  bool get isSubmitted => throw _privateConstructorUsedError;

  /// Create a copy of FeedbackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedbackStateCopyWith<FeedbackState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedbackStateCopyWith<$Res> {
  factory $FeedbackStateCopyWith(
    FeedbackState value,
    $Res Function(FeedbackState) then,
  ) = _$FeedbackStateCopyWithImpl<$Res, FeedbackState>;
  @useResult
  $Res call({int rating, String comment, bool isSubmitting, bool isSubmitted});
}

/// @nodoc
class _$FeedbackStateCopyWithImpl<$Res, $Val extends FeedbackState>
    implements $FeedbackStateCopyWith<$Res> {
  _$FeedbackStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedbackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rating = null,
    Object? comment = null,
    Object? isSubmitting = null,
    Object? isSubmitted = null,
  }) {
    return _then(
      _value.copyWith(
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as int,
            comment: null == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String,
            isSubmitting: null == isSubmitting
                ? _value.isSubmitting
                : isSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSubmitted: null == isSubmitted
                ? _value.isSubmitted
                : isSubmitted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeedbackStateImplCopyWith<$Res>
    implements $FeedbackStateCopyWith<$Res> {
  factory _$$FeedbackStateImplCopyWith(
    _$FeedbackStateImpl value,
    $Res Function(_$FeedbackStateImpl) then,
  ) = __$$FeedbackStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rating, String comment, bool isSubmitting, bool isSubmitted});
}

/// @nodoc
class __$$FeedbackStateImplCopyWithImpl<$Res>
    extends _$FeedbackStateCopyWithImpl<$Res, _$FeedbackStateImpl>
    implements _$$FeedbackStateImplCopyWith<$Res> {
  __$$FeedbackStateImplCopyWithImpl(
    _$FeedbackStateImpl _value,
    $Res Function(_$FeedbackStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeedbackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rating = null,
    Object? comment = null,
    Object? isSubmitting = null,
    Object? isSubmitted = null,
  }) {
    return _then(
      _$FeedbackStateImpl(
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as int,
        comment: null == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String,
        isSubmitting: null == isSubmitting
            ? _value.isSubmitting
            : isSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSubmitted: null == isSubmitted
            ? _value.isSubmitted
            : isSubmitted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$FeedbackStateImpl implements _FeedbackState {
  const _$FeedbackStateImpl({
    this.rating = 0,
    this.comment = '',
    this.isSubmitting = false,
    this.isSubmitted = false,
  });

  @override
  @JsonKey()
  final int rating;
  @override
  @JsonKey()
  final String comment;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  @JsonKey()
  final bool isSubmitted;

  @override
  String toString() {
    return 'FeedbackState(rating: $rating, comment: $comment, isSubmitting: $isSubmitting, isSubmitted: $isSubmitted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedbackStateImpl &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.isSubmitted, isSubmitted) ||
                other.isSubmitted == isSubmitted));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, rating, comment, isSubmitting, isSubmitted);

  /// Create a copy of FeedbackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedbackStateImplCopyWith<_$FeedbackStateImpl> get copyWith =>
      __$$FeedbackStateImplCopyWithImpl<_$FeedbackStateImpl>(this, _$identity);
}

abstract class _FeedbackState implements FeedbackState {
  const factory _FeedbackState({
    final int rating,
    final String comment,
    final bool isSubmitting,
    final bool isSubmitted,
  }) = _$FeedbackStateImpl;

  @override
  int get rating;
  @override
  String get comment;
  @override
  bool get isSubmitting;
  @override
  bool get isSubmitted;

  /// Create a copy of FeedbackState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedbackStateImplCopyWith<_$FeedbackStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
