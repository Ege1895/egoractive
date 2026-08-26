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

  /// Antrenör, üyelerinin seanslarını iptal edebilir mi —
  /// `firestore.rules`'taki `trainerPermission('canCancelMemberSessions')`
  /// ile canlı olarak zorlanır (bu sadece UI değil, gerçek bir kural).
  bool get canCancelMemberSessions => throw _privateConstructorUsedError;

  /// Antrenör, üyelerinin seanslarını erteleyebilir mi — aynı şekilde
  /// `trainerPermission('canRescheduleMemberSessions')` ile zorlanır.
  bool get canRescheduleMemberSessions => throw _privateConstructorUsedError;

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
    bool canCancelMemberSessions,
    bool canRescheduleMemberSessions,
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
    Object? canCancelMemberSessions = null,
    Object? canRescheduleMemberSessions = null,
  }) {
    return _then(
      _value.copyWith(
            trainerReminderDelay: null == trainerReminderDelay
                ? _value.trainerReminderDelay
                : trainerReminderDelay // ignore: cast_nullable_to_non_nullable
                      as TrainerReminderDelay,
            canCancelMemberSessions: null == canCancelMemberSessions
                ? _value.canCancelMemberSessions
                : canCancelMemberSessions // ignore: cast_nullable_to_non_nullable
                      as bool,
            canRescheduleMemberSessions: null == canRescheduleMemberSessions
                ? _value.canRescheduleMemberSessions
                : canRescheduleMemberSessions // ignore: cast_nullable_to_non_nullable
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
    bool canCancelMemberSessions,
    bool canRescheduleMemberSessions,
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
    Object? canCancelMemberSessions = null,
    Object? canRescheduleMemberSessions = null,
  }) {
    return _then(
      _$AdminPermissionsImpl(
        trainerReminderDelay: null == trainerReminderDelay
            ? _value.trainerReminderDelay
            : trainerReminderDelay // ignore: cast_nullable_to_non_nullable
                  as TrainerReminderDelay,
        canCancelMemberSessions: null == canCancelMemberSessions
            ? _value.canCancelMemberSessions
            : canCancelMemberSessions // ignore: cast_nullable_to_non_nullable
                  as bool,
        canRescheduleMemberSessions: null == canRescheduleMemberSessions
            ? _value.canRescheduleMemberSessions
            : canRescheduleMemberSessions // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$AdminPermissionsImpl implements _AdminPermissions {
  const _$AdminPermissionsImpl({
    this.trainerReminderDelay = TrainerReminderDelay.thirtyMinutes,
    this.canCancelMemberSessions = true,
    this.canRescheduleMemberSessions = true,
  });

  @override
  @JsonKey()
  final TrainerReminderDelay trainerReminderDelay;

  /// Antrenör, üyelerinin seanslarını iptal edebilir mi —
  /// `firestore.rules`'taki `trainerPermission('canCancelMemberSessions')`
  /// ile canlı olarak zorlanır (bu sadece UI değil, gerçek bir kural).
  @override
  @JsonKey()
  final bool canCancelMemberSessions;

  /// Antrenör, üyelerinin seanslarını erteleyebilir mi — aynı şekilde
  /// `trainerPermission('canRescheduleMemberSessions')` ile zorlanır.
  @override
  @JsonKey()
  final bool canRescheduleMemberSessions;

  @override
  String toString() {
    return 'AdminPermissions(trainerReminderDelay: $trainerReminderDelay, canCancelMemberSessions: $canCancelMemberSessions, canRescheduleMemberSessions: $canRescheduleMemberSessions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminPermissionsImpl &&
            (identical(other.trainerReminderDelay, trainerReminderDelay) ||
                other.trainerReminderDelay == trainerReminderDelay) &&
            (identical(
                  other.canCancelMemberSessions,
                  canCancelMemberSessions,
                ) ||
                other.canCancelMemberSessions == canCancelMemberSessions) &&
            (identical(
                  other.canRescheduleMemberSessions,
                  canRescheduleMemberSessions,
                ) ||
                other.canRescheduleMemberSessions ==
                    canRescheduleMemberSessions));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    trainerReminderDelay,
    canCancelMemberSessions,
    canRescheduleMemberSessions,
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
    final bool canCancelMemberSessions,
    final bool canRescheduleMemberSessions,
  }) = _$AdminPermissionsImpl;

  @override
  TrainerReminderDelay get trainerReminderDelay;

  /// Antrenör, üyelerinin seanslarını iptal edebilir mi —
  /// `firestore.rules`'taki `trainerPermission('canCancelMemberSessions')`
  /// ile canlı olarak zorlanır (bu sadece UI değil, gerçek bir kural).
  @override
  bool get canCancelMemberSessions;

  /// Antrenör, üyelerinin seanslarını erteleyebilir mi — aynı şekilde
  /// `trainerPermission('canRescheduleMemberSessions')` ile zorlanır.
  @override
  bool get canRescheduleMemberSessions;

  /// Create a copy of AdminPermissions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminPermissionsImplCopyWith<_$AdminPermissionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
