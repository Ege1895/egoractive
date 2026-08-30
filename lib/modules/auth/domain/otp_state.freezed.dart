// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OtpState {
  String get code => throw _privateConstructorUsedError;
  bool get isVerifying => throw _privateConstructorUsedError;
  bool get isResending => throw _privateConstructorUsedError;
  int get secondsRemaining => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of OtpState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OtpStateCopyWith<OtpState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtpStateCopyWith<$Res> {
  factory $OtpStateCopyWith(OtpState value, $Res Function(OtpState) then) =
      _$OtpStateCopyWithImpl<$Res, OtpState>;
  @useResult
  $Res call({
    String code,
    bool isVerifying,
    bool isResending,
    int secondsRemaining,
    String? errorMessage,
  });
}

/// @nodoc
class _$OtpStateCopyWithImpl<$Res, $Val extends OtpState>
    implements $OtpStateCopyWith<$Res> {
  _$OtpStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OtpState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? isVerifying = null,
    Object? isResending = null,
    Object? secondsRemaining = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            isVerifying: null == isVerifying
                ? _value.isVerifying
                : isVerifying // ignore: cast_nullable_to_non_nullable
                      as bool,
            isResending: null == isResending
                ? _value.isResending
                : isResending // ignore: cast_nullable_to_non_nullable
                      as bool,
            secondsRemaining: null == secondsRemaining
                ? _value.secondsRemaining
                : secondsRemaining // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$OtpStateImplCopyWith<$Res>
    implements $OtpStateCopyWith<$Res> {
  factory _$$OtpStateImplCopyWith(
    _$OtpStateImpl value,
    $Res Function(_$OtpStateImpl) then,
  ) = __$$OtpStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String code,
    bool isVerifying,
    bool isResending,
    int secondsRemaining,
    String? errorMessage,
  });
}

/// @nodoc
class __$$OtpStateImplCopyWithImpl<$Res>
    extends _$OtpStateCopyWithImpl<$Res, _$OtpStateImpl>
    implements _$$OtpStateImplCopyWith<$Res> {
  __$$OtpStateImplCopyWithImpl(
    _$OtpStateImpl _value,
    $Res Function(_$OtpStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OtpState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? isVerifying = null,
    Object? isResending = null,
    Object? secondsRemaining = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$OtpStateImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        isVerifying: null == isVerifying
            ? _value.isVerifying
            : isVerifying // ignore: cast_nullable_to_non_nullable
                  as bool,
        isResending: null == isResending
            ? _value.isResending
            : isResending // ignore: cast_nullable_to_non_nullable
                  as bool,
        secondsRemaining: null == secondsRemaining
            ? _value.secondsRemaining
            : secondsRemaining // ignore: cast_nullable_to_non_nullable
                  as int,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$OtpStateImpl extends _OtpState {
  const _$OtpStateImpl({
    this.code = '',
    this.isVerifying = false,
    this.isResending = false,
    this.secondsRemaining = 0,
    this.errorMessage,
  }) : super._();

  @override
  @JsonKey()
  final String code;
  @override
  @JsonKey()
  final bool isVerifying;
  @override
  @JsonKey()
  final bool isResending;
  @override
  @JsonKey()
  final int secondsRemaining;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'OtpState(code: $code, isVerifying: $isVerifying, isResending: $isResending, secondsRemaining: $secondsRemaining, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpStateImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.isVerifying, isVerifying) ||
                other.isVerifying == isVerifying) &&
            (identical(other.isResending, isResending) ||
                other.isResending == isResending) &&
            (identical(other.secondsRemaining, secondsRemaining) ||
                other.secondsRemaining == secondsRemaining) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    isVerifying,
    isResending,
    secondsRemaining,
    errorMessage,
  );

  /// Create a copy of OtpState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpStateImplCopyWith<_$OtpStateImpl> get copyWith =>
      __$$OtpStateImplCopyWithImpl<_$OtpStateImpl>(this, _$identity);
}

abstract class _OtpState extends OtpState {
  const factory _OtpState({
    final String code,
    final bool isVerifying,
    final bool isResending,
    final int secondsRemaining,
    final String? errorMessage,
  }) = _$OtpStateImpl;
  const _OtpState._() : super._();

  @override
  String get code;
  @override
  bool get isVerifying;
  @override
  bool get isResending;
  @override
  int get secondsRemaining;
  @override
  String? get errorMessage;

  /// Create a copy of OtpState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtpStateImplCopyWith<_$OtpStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
