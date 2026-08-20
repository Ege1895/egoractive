// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'send_notification_form.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SendNotificationForm {
  NotificationTargetType get targetType =>
      throw _privateConstructorUsedError; // id -> isim, seçim sırasını korumak için Map yerine LinkedHashMap
  // davranışına sahip Dart'ın varsayılan Map'i kullanılıyor.
  Map<String, String> get targetMembers => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  bool get sent => throw _privateConstructorUsedError;
  bool get isSending => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of SendNotificationForm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SendNotificationFormCopyWith<SendNotificationForm> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendNotificationFormCopyWith<$Res> {
  factory $SendNotificationFormCopyWith(
    SendNotificationForm value,
    $Res Function(SendNotificationForm) then,
  ) = _$SendNotificationFormCopyWithImpl<$Res, SendNotificationForm>;
  @useResult
  $Res call({
    NotificationTargetType targetType,
    Map<String, String> targetMembers,
    String title,
    String message,
    bool sent,
    bool isSending,
    String? errorMessage,
  });
}

/// @nodoc
class _$SendNotificationFormCopyWithImpl<
  $Res,
  $Val extends SendNotificationForm
>
    implements $SendNotificationFormCopyWith<$Res> {
  _$SendNotificationFormCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SendNotificationForm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targetType = null,
    Object? targetMembers = null,
    Object? title = null,
    Object? message = null,
    Object? sent = null,
    Object? isSending = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            targetType: null == targetType
                ? _value.targetType
                : targetType // ignore: cast_nullable_to_non_nullable
                      as NotificationTargetType,
            targetMembers: null == targetMembers
                ? _value.targetMembers
                : targetMembers // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            sent: null == sent
                ? _value.sent
                : sent // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSending: null == isSending
                ? _value.isSending
                : isSending // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$SendNotificationFormImplCopyWith<$Res>
    implements $SendNotificationFormCopyWith<$Res> {
  factory _$$SendNotificationFormImplCopyWith(
    _$SendNotificationFormImpl value,
    $Res Function(_$SendNotificationFormImpl) then,
  ) = __$$SendNotificationFormImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    NotificationTargetType targetType,
    Map<String, String> targetMembers,
    String title,
    String message,
    bool sent,
    bool isSending,
    String? errorMessage,
  });
}

/// @nodoc
class __$$SendNotificationFormImplCopyWithImpl<$Res>
    extends _$SendNotificationFormCopyWithImpl<$Res, _$SendNotificationFormImpl>
    implements _$$SendNotificationFormImplCopyWith<$Res> {
  __$$SendNotificationFormImplCopyWithImpl(
    _$SendNotificationFormImpl _value,
    $Res Function(_$SendNotificationFormImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SendNotificationForm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targetType = null,
    Object? targetMembers = null,
    Object? title = null,
    Object? message = null,
    Object? sent = null,
    Object? isSending = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$SendNotificationFormImpl(
        targetType: null == targetType
            ? _value.targetType
            : targetType // ignore: cast_nullable_to_non_nullable
                  as NotificationTargetType,
        targetMembers: null == targetMembers
            ? _value._targetMembers
            : targetMembers // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        sent: null == sent
            ? _value.sent
            : sent // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSending: null == isSending
            ? _value.isSending
            : isSending // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SendNotificationFormImpl implements _SendNotificationForm {
  const _$SendNotificationFormImpl({
    this.targetType = NotificationTargetType.wholeGym,
    final Map<String, String> targetMembers = const <String, String>{},
    this.title = '',
    this.message = '',
    this.sent = false,
    this.isSending = false,
    this.errorMessage,
  }) : _targetMembers = targetMembers;

  @override
  @JsonKey()
  final NotificationTargetType targetType;
  // id -> isim, seçim sırasını korumak için Map yerine LinkedHashMap
  // davranışına sahip Dart'ın varsayılan Map'i kullanılıyor.
  final Map<String, String> _targetMembers;
  // id -> isim, seçim sırasını korumak için Map yerine LinkedHashMap
  // davranışına sahip Dart'ın varsayılan Map'i kullanılıyor.
  @override
  @JsonKey()
  Map<String, String> get targetMembers {
    if (_targetMembers is EqualUnmodifiableMapView) return _targetMembers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_targetMembers);
  }

  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String message;
  @override
  @JsonKey()
  final bool sent;
  @override
  @JsonKey()
  final bool isSending;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'SendNotificationForm(targetType: $targetType, targetMembers: $targetMembers, title: $title, message: $message, sent: $sent, isSending: $isSending, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendNotificationFormImpl &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            const DeepCollectionEquality().equals(
              other._targetMembers,
              _targetMembers,
            ) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.sent, sent) || other.sent == sent) &&
            (identical(other.isSending, isSending) ||
                other.isSending == isSending) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    targetType,
    const DeepCollectionEquality().hash(_targetMembers),
    title,
    message,
    sent,
    isSending,
    errorMessage,
  );

  /// Create a copy of SendNotificationForm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendNotificationFormImplCopyWith<_$SendNotificationFormImpl>
  get copyWith =>
      __$$SendNotificationFormImplCopyWithImpl<_$SendNotificationFormImpl>(
        this,
        _$identity,
      );
}

abstract class _SendNotificationForm implements SendNotificationForm {
  const factory _SendNotificationForm({
    final NotificationTargetType targetType,
    final Map<String, String> targetMembers,
    final String title,
    final String message,
    final bool sent,
    final bool isSending,
    final String? errorMessage,
  }) = _$SendNotificationFormImpl;

  @override
  NotificationTargetType get targetType; // id -> isim, seçim sırasını korumak için Map yerine LinkedHashMap
  // davranışına sahip Dart'ın varsayılan Map'i kullanılıyor.
  @override
  Map<String, String> get targetMembers;
  @override
  String get title;
  @override
  String get message;
  @override
  bool get sent;
  @override
  bool get isSending;
  @override
  String? get errorMessage;

  /// Create a copy of SendNotificationForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendNotificationFormImplCopyWith<_$SendNotificationFormImpl>
  get copyWith => throw _privateConstructorUsedError;
}
