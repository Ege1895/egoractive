// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_permissions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdminPermissions {
  TrainerReminderDelay get trainerReminderDelay =>
      throw _privateConstructorUsedError;
  bool get onlineBookingEnabled => throw _privateConstructorUsedError;
  bool get allowSessionsAfterPackageExpiry =>
      throw _privateConstructorUsedError;
  bool get memberCanCancelSession => throw _privateConstructorUsedError;

  /// Create a copy of AdminPermissions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminPermissionsCopyWith<AdminPermissions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminPermissionsCopyWith<$Res> {
  factory $AdminPermissionsCopyWith(
    AdminPermissions value,
    $Res Function(AdminPermissions) then,
  ) = _$AdminPermissionsCopyWithImpl<$Res, AdminPermissions>;
  @useResult
  $Res call({
    TrainerReminderDelay trainerReminderDelay,
    bool onlineBookingEnabled,
    bool allowSessionsAfterPackageExpiry,
    bool memberCanCancelSession,
  });
}

/// @nodoc
class _$AdminPermissionsCopyWithImpl<$Res, $Val extends AdminPermissions>
    implements $AdminPermissionsCopyWith<$Res> {
  _$AdminPermissionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminPermissions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trainerReminderDelay = null,
    Object? onlineBookingEnabled = null,
    Object? allowSessionsAfterPackageExpiry = null,
    Object? memberCanCancelSession = null,
  }) {
    return _then(
      _value.copyWith(
            trainerReminderDelay: null == trainerReminderDelay
                ? _value.trainerReminderDelay
                : trainerReminderDelay // ignore: cast_nullable_to_non_nullable
                      as TrainerReminderDelay,
            onlineBookingEnabled: null == onlineBookingEnabled
                ? _value.onlineBookingEnabled
                : onlineBookingEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            allowSessionsAfterPackageExpiry:
                null == allowSessionsAfterPackageExpiry
                ? _value.allowSessionsAfterPackageExpiry
                : allowSessionsAfterPackageExpiry // ignore: cast_nullable_to_non_nullable
                      as bool,
            memberCanCancelSession: null == memberCanCancelSession
                ? _value.memberCanCancelSession
                : memberCanCancelSession // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminPermissionsImplCopyWith<$Res>
    implements $AdminPermissionsCopyWith<$Res> {
  factory _$$AdminPermissionsImplCopyWith(
    _$AdminPermissionsImpl value,
    $Res Function(_$AdminPermissionsImpl) then,
  ) = __$$AdminPermissionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    TrainerReminderDelay trainerReminderDelay,
    bool onlineBookingEnabled,
    bool allowSessionsAfterPackageExpiry,
    bool memberCanCancelSession,
  });
}

/// @nodoc
class __$$AdminPermissionsImplCopyWithImpl<$Res>
    extends _$AdminPermissionsCopyWithImpl<$Res, _$AdminPermissionsImpl>
    implements _$$AdminPermissionsImplCopyWith<$Res> {
  __$$AdminPermissionsImplCopyWithImpl(
    _$AdminPermissionsImpl _value,
    $Res Function(_$AdminPermissionsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminPermissions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trainerReminderDelay = null,
    Object? onlineBookingEnabled = null,
    Object? allowSessionsAfterPackageExpiry = null,
    Object? memberCanCancelSession = null,
  }) {
    return _then(
      _$AdminPermissionsImpl(
        trainerReminderDelay: null == trainerReminderDelay
            ? _value.trainerReminderDelay
            : trainerReminderDelay // ignore: cast_nullable_to_non_nullable
                  as TrainerReminderDelay,
        onlineBookingEnabled: null == onlineBookingEnabled
            ? _value.onlineBookingEnabled
            : onlineBookingEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        allowSessionsAfterPackageExpiry: null == allowSessionsAfterPackageExpiry
            ? _value.allowSessionsAfterPackageExpiry
            : allowSessionsAfterPackageExpiry // ignore: cast_nullable_to_non_nullable
                  as bool,
        memberCanCancelSession: null == memberCanCancelSession
            ? _value.memberCanCancelSession
            : memberCanCancelSession // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$AdminPermissionsImpl implements _AdminPermissions {
  const _$AdminPermissionsImpl({
    this.trainerReminderDelay = TrainerReminderDelay.thirtyMinutes,
    this.onlineBookingEnabled = true,
    this.allowSessionsAfterPackageExpiry = false,
    this.memberCanCancelSession = true,
  });

  @override
  @JsonKey()
  final TrainerReminderDelay trainerReminderDelay;
  @override
  @JsonKey()
  final bool onlineBookingEnabled;
  @override
  @JsonKey()
  final bool allowSessionsAfterPackageExpiry;
  @override
  @JsonKey()
  final bool memberCanCancelSession;

  @override
  String toString() {
    return 'AdminPermissions(trainerReminderDelay: $trainerReminderDelay, onlineBookingEnabled: $onlineBookingEnabled, allowSessionsAfterPackageExpiry: $allowSessionsAfterPackageExpiry, memberCanCancelSession: $memberCanCancelSession)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminPermissionsImpl &&
            (identical(other.trainerReminderDelay, trainerReminderDelay) ||
                other.trainerReminderDelay == trainerReminderDelay) &&
            (identical(other.onlineBookingEnabled, onlineBookingEnabled) ||
                other.onlineBookingEnabled == onlineBookingEnabled) &&
            (identical(
                  other.allowSessionsAfterPackageExpiry,
                  allowSessionsAfterPackageExpiry,
                ) ||
                other.allowSessionsAfterPackageExpiry ==
                    allowSessionsAfterPackageExpiry) &&
            (identical(other.memberCanCancelSession, memberCanCancelSession) ||
                other.memberCanCancelSession == memberCanCancelSession));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    trainerReminderDelay,
    onlineBookingEnabled,
    allowSessionsAfterPackageExpiry,
    memberCanCancelSession,
  );

  /// Create a copy of AdminPermissions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminPermissionsImplCopyWith<_$AdminPermissionsImpl> get copyWith =>
      __$$AdminPermissionsImplCopyWithImpl<_$AdminPermissionsImpl>(
        this,
        _$identity,
      );
}

abstract class _AdminPermissions implements AdminPermissions {
  const factory _AdminPermissions({
    final TrainerReminderDelay trainerReminderDelay,
    final bool onlineBookingEnabled,
    final bool allowSessionsAfterPackageExpiry,
    final bool memberCanCancelSession,
  }) = _$AdminPermissionsImpl;

  @override
  TrainerReminderDelay get trainerReminderDelay;
  @override
  bool get onlineBookingEnabled;
  @override
  bool get allowSessionsAfterPackageExpiry;
  @override
  bool get memberCanCancelSession;

  /// Create a copy of AdminPermissions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminPermissionsImplCopyWith<_$AdminPermissionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
