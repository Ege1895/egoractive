// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthState {
  String get phoneDigits => throw _privateConstructorUsedError;
  bool get isRequestingLogin => throw _privateConstructorUsedError;
  String? get loginErrorMessage => throw _privateConstructorUsedError;
  bool get deleteAccountAcknowledged => throw _privateConstructorUsedError;
  bool get isDeletingAccount => throw _privateConstructorUsedError;
  int get selectedAvatarIndex => throw _privateConstructorUsedError;
  bool get sessionReminderEnabled => throw _privateConstructorUsedError;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthStateCopyWith<AuthState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
  @useResult
  $Res call({
    String phoneDigits,
    bool isRequestingLogin,
    String? loginErrorMessage,
    bool deleteAccountAcknowledged,
    bool isDeletingAccount,
    int selectedAvatarIndex,
    bool sessionReminderEnabled,
  });
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phoneDigits = null,
    Object? isRequestingLogin = null,
    Object? loginErrorMessage = freezed,
    Object? deleteAccountAcknowledged = null,
    Object? isDeletingAccount = null,
    Object? selectedAvatarIndex = null,
    Object? sessionReminderEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            phoneDigits: null == phoneDigits
                ? _value.phoneDigits
                : phoneDigits // ignore: cast_nullable_to_non_nullable
                      as String,
            isRequestingLogin: null == isRequestingLogin
                ? _value.isRequestingLogin
                : isRequestingLogin // ignore: cast_nullable_to_non_nullable
                      as bool,
            loginErrorMessage: freezed == loginErrorMessage
                ? _value.loginErrorMessage
                : loginErrorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            deleteAccountAcknowledged: null == deleteAccountAcknowledged
                ? _value.deleteAccountAcknowledged
                : deleteAccountAcknowledged // ignore: cast_nullable_to_non_nullable
                      as bool,
            isDeletingAccount: null == isDeletingAccount
                ? _value.isDeletingAccount
                : isDeletingAccount // ignore: cast_nullable_to_non_nullable
                      as bool,
            selectedAvatarIndex: null == selectedAvatarIndex
                ? _value.selectedAvatarIndex
                : selectedAvatarIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            sessionReminderEnabled: null == sessionReminderEnabled
                ? _value.sessionReminderEnabled
                : sessionReminderEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthStateImplCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory _$$AuthStateImplCopyWith(
    _$AuthStateImpl value,
    $Res Function(_$AuthStateImpl) then,
  ) = __$$AuthStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String phoneDigits,
    bool isRequestingLogin,
    String? loginErrorMessage,
    bool deleteAccountAcknowledged,
    bool isDeletingAccount,
    int selectedAvatarIndex,
    bool sessionReminderEnabled,
  });
}

/// @nodoc
class __$$AuthStateImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthStateImpl>
    implements _$$AuthStateImplCopyWith<$Res> {
  __$$AuthStateImplCopyWithImpl(
    _$AuthStateImpl _value,
    $Res Function(_$AuthStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phoneDigits = null,
    Object? isRequestingLogin = null,
    Object? loginErrorMessage = freezed,
    Object? deleteAccountAcknowledged = null,
    Object? isDeletingAccount = null,
    Object? selectedAvatarIndex = null,
    Object? sessionReminderEnabled = null,
  }) {
    return _then(
      _$AuthStateImpl(
        phoneDigits: null == phoneDigits
            ? _value.phoneDigits
            : phoneDigits // ignore: cast_nullable_to_non_nullable
                  as String,
        isRequestingLogin: null == isRequestingLogin
            ? _value.isRequestingLogin
            : isRequestingLogin // ignore: cast_nullable_to_non_nullable
                  as bool,
        loginErrorMessage: freezed == loginErrorMessage
            ? _value.loginErrorMessage
            : loginErrorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        deleteAccountAcknowledged: null == deleteAccountAcknowledged
            ? _value.deleteAccountAcknowledged
            : deleteAccountAcknowledged // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDeletingAccount: null == isDeletingAccount
            ? _value.isDeletingAccount
            : isDeletingAccount // ignore: cast_nullable_to_non_nullable
                  as bool,
        selectedAvatarIndex: null == selectedAvatarIndex
            ? _value.selectedAvatarIndex
            : selectedAvatarIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        sessionReminderEnabled: null == sessionReminderEnabled
            ? _value.sessionReminderEnabled
            : sessionReminderEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$AuthStateImpl extends _AuthState {
  const _$AuthStateImpl({
    this.phoneDigits = '',
    this.isRequestingLogin = false,
    this.loginErrorMessage,
    this.deleteAccountAcknowledged = false,
    this.isDeletingAccount = false,
    this.selectedAvatarIndex = 0,
    this.sessionReminderEnabled = true,
  }) : super._();

  @override
  @JsonKey()
  final String phoneDigits;
  @override
  @JsonKey()
  final bool isRequestingLogin;
  @override
  final String? loginErrorMessage;
  @override
  @JsonKey()
  final bool deleteAccountAcknowledged;
  @override
  @JsonKey()
  final bool isDeletingAccount;
  @override
  @JsonKey()
  final int selectedAvatarIndex;
  @override
  @JsonKey()
  final bool sessionReminderEnabled;

  @override
  String toString() {
    return 'AuthState(phoneDigits: $phoneDigits, isRequestingLogin: $isRequestingLogin, loginErrorMessage: $loginErrorMessage, deleteAccountAcknowledged: $deleteAccountAcknowledged, isDeletingAccount: $isDeletingAccount, selectedAvatarIndex: $selectedAvatarIndex, sessionReminderEnabled: $sessionReminderEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthStateImpl &&
            (identical(other.phoneDigits, phoneDigits) ||
                other.phoneDigits == phoneDigits) &&
            (identical(other.isRequestingLogin, isRequestingLogin) ||
                other.isRequestingLogin == isRequestingLogin) &&
            (identical(other.loginErrorMessage, loginErrorMessage) ||
                other.loginErrorMessage == loginErrorMessage) &&
            (identical(
                  other.deleteAccountAcknowledged,
                  deleteAccountAcknowledged,
                ) ||
                other.deleteAccountAcknowledged == deleteAccountAcknowledged) &&
            (identical(other.isDeletingAccount, isDeletingAccount) ||
                other.isDeletingAccount == isDeletingAccount) &&
            (identical(other.selectedAvatarIndex, selectedAvatarIndex) ||
                other.selectedAvatarIndex == selectedAvatarIndex) &&
            (identical(other.sessionReminderEnabled, sessionReminderEnabled) ||
                other.sessionReminderEnabled == sessionReminderEnabled));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    phoneDigits,
    isRequestingLogin,
    loginErrorMessage,
    deleteAccountAcknowledged,
    isDeletingAccount,
    selectedAvatarIndex,
    sessionReminderEnabled,
  );

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      __$$AuthStateImplCopyWithImpl<_$AuthStateImpl>(this, _$identity);
}

abstract class _AuthState extends AuthState {
  const factory _AuthState({
    final String phoneDigits,
    final bool isRequestingLogin,
    final String? loginErrorMessage,
    final bool deleteAccountAcknowledged,
    final bool isDeletingAccount,
    final int selectedAvatarIndex,
    final bool sessionReminderEnabled,
  }) = _$AuthStateImpl;
  const _AuthState._() : super._();

  @override
  String get phoneDigits;
  @override
  bool get isRequestingLogin;
  @override
  String? get loginErrorMessage;
  @override
  bool get deleteAccountAcknowledged;
  @override
  bool get isDeletingAccount;
  @override
  int get selectedAvatarIndex;
  @override
  bool get sessionReminderEnabled;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
