// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_recipients.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ReportRecipients {
  String get gymReportEmail => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of ReportRecipients
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportRecipientsCopyWith<ReportRecipients> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportRecipientsCopyWith<$Res> {
  factory $ReportRecipientsCopyWith(
    ReportRecipients value,
    $Res Function(ReportRecipients) then,
  ) = _$ReportRecipientsCopyWithImpl<$Res, ReportRecipients>;
  @useResult
  $Res call({String gymReportEmail, bool isSaving, String? errorMessage});
}

/// @nodoc
class _$ReportRecipientsCopyWithImpl<$Res, $Val extends ReportRecipients>
    implements $ReportRecipientsCopyWith<$Res> {
  _$ReportRecipientsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportRecipients
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gymReportEmail = null,
    Object? isSaving = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            gymReportEmail: null == gymReportEmail
                ? _value.gymReportEmail
                : gymReportEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            isSaving: null == isSaving
                ? _value.isSaving
                : isSaving // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ReportRecipientsImplCopyWith<$Res>
    implements $ReportRecipientsCopyWith<$Res> {
  factory _$$ReportRecipientsImplCopyWith(
    _$ReportRecipientsImpl value,
    $Res Function(_$ReportRecipientsImpl) then,
  ) = __$$ReportRecipientsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String gymReportEmail, bool isSaving, String? errorMessage});
}

/// @nodoc
class __$$ReportRecipientsImplCopyWithImpl<$Res>
    extends _$ReportRecipientsCopyWithImpl<$Res, _$ReportRecipientsImpl>
    implements _$$ReportRecipientsImplCopyWith<$Res> {
  __$$ReportRecipientsImplCopyWithImpl(
    _$ReportRecipientsImpl _value,
    $Res Function(_$ReportRecipientsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReportRecipients
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gymReportEmail = null,
    Object? isSaving = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$ReportRecipientsImpl(
        gymReportEmail: null == gymReportEmail
            ? _value.gymReportEmail
            : gymReportEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        isSaving: null == isSaving
            ? _value.isSaving
            : isSaving // ignore: cast_nullable_to_non_nullable
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

class _$ReportRecipientsImpl implements _ReportRecipients {
  const _$ReportRecipientsImpl({
    this.gymReportEmail = '',
    this.isSaving = false,
    this.errorMessage,
  });

  @override
  @JsonKey()
  final String gymReportEmail;
  @override
  @JsonKey()
  final bool isSaving;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ReportRecipients(gymReportEmail: $gymReportEmail, isSaving: $isSaving, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportRecipientsImpl &&
            (identical(other.gymReportEmail, gymReportEmail) ||
                other.gymReportEmail == gymReportEmail) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, gymReportEmail, isSaving, errorMessage);

  /// Create a copy of ReportRecipients
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportRecipientsImplCopyWith<_$ReportRecipientsImpl> get copyWith =>
      __$$ReportRecipientsImplCopyWithImpl<_$ReportRecipientsImpl>(
        this,
        _$identity,
      );
}

abstract class _ReportRecipients implements ReportRecipients {
  const factory _ReportRecipients({
    final String gymReportEmail,
    final bool isSaving,
    final String? errorMessage,
  }) = _$ReportRecipientsImpl;

  @override
  String get gymReportEmail;
  @override
  bool get isSaving;
  @override
  String? get errorMessage;

  /// Create a copy of ReportRecipients
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportRecipientsImplCopyWith<_$ReportRecipientsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
