// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_confirmation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PendingConfirmation {
  String get id => throw _privateConstructorUsedError;
  String get memberInitials => throw _privateConstructorUsedError;
  String get memberName => throw _privateConstructorUsedError;
  String get meta => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;
  int get remainingBefore => throw _privateConstructorUsedError;

  /// Create a copy of PendingConfirmation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PendingConfirmationCopyWith<PendingConfirmation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PendingConfirmationCopyWith<$Res> {
  factory $PendingConfirmationCopyWith(
    PendingConfirmation value,
    $Res Function(PendingConfirmation) then,
  ) = _$PendingConfirmationCopyWithImpl<$Res, PendingConfirmation>;
  @useResult
  $Res call({
    String id,
    String memberInitials,
    String memberName,
    String meta,
    String time,
    int remainingBefore,
  });
}

/// @nodoc
class _$PendingConfirmationCopyWithImpl<$Res, $Val extends PendingConfirmation>
    implements $PendingConfirmationCopyWith<$Res> {
  _$PendingConfirmationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PendingConfirmation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memberInitials = null,
    Object? memberName = null,
    Object? meta = null,
    Object? time = null,
    Object? remainingBefore = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            memberInitials: null == memberInitials
                ? _value.memberInitials
                : memberInitials // ignore: cast_nullable_to_non_nullable
                      as String,
            memberName: null == memberName
                ? _value.memberName
                : memberName // ignore: cast_nullable_to_non_nullable
                      as String,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            remainingBefore: null == remainingBefore
                ? _value.remainingBefore
                : remainingBefore // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PendingConfirmationImplCopyWith<$Res>
    implements $PendingConfirmationCopyWith<$Res> {
  factory _$$PendingConfirmationImplCopyWith(
    _$PendingConfirmationImpl value,
    $Res Function(_$PendingConfirmationImpl) then,
  ) = __$$PendingConfirmationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String memberInitials,
    String memberName,
    String meta,
    String time,
    int remainingBefore,
  });
}

/// @nodoc
class __$$PendingConfirmationImplCopyWithImpl<$Res>
    extends _$PendingConfirmationCopyWithImpl<$Res, _$PendingConfirmationImpl>
    implements _$$PendingConfirmationImplCopyWith<$Res> {
  __$$PendingConfirmationImplCopyWithImpl(
    _$PendingConfirmationImpl _value,
    $Res Function(_$PendingConfirmationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PendingConfirmation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memberInitials = null,
    Object? memberName = null,
    Object? meta = null,
    Object? time = null,
    Object? remainingBefore = null,
  }) {
    return _then(
      _$PendingConfirmationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        memberInitials: null == memberInitials
            ? _value.memberInitials
            : memberInitials // ignore: cast_nullable_to_non_nullable
                  as String,
        memberName: null == memberName
            ? _value.memberName
            : memberName // ignore: cast_nullable_to_non_nullable
                  as String,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        remainingBefore: null == remainingBefore
            ? _value.remainingBefore
            : remainingBefore // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$PendingConfirmationImpl implements _PendingConfirmation {
  const _$PendingConfirmationImpl({
    required this.id,
    required this.memberInitials,
    required this.memberName,
    required this.meta,
    required this.time,
    required this.remainingBefore,
  });

  @override
  final String id;
  @override
  final String memberInitials;
  @override
  final String memberName;
  @override
  final String meta;
  @override
  final String time;
  @override
  final int remainingBefore;

  @override
  String toString() {
    return 'PendingConfirmation(id: $id, memberInitials: $memberInitials, memberName: $memberName, meta: $meta, time: $time, remainingBefore: $remainingBefore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PendingConfirmationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memberInitials, memberInitials) ||
                other.memberInitials == memberInitials) &&
            (identical(other.memberName, memberName) ||
                other.memberName == memberName) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.remainingBefore, remainingBefore) ||
                other.remainingBefore == remainingBefore));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    memberInitials,
    memberName,
    meta,
    time,
    remainingBefore,
  );

  /// Create a copy of PendingConfirmation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PendingConfirmationImplCopyWith<_$PendingConfirmationImpl> get copyWith =>
      __$$PendingConfirmationImplCopyWithImpl<_$PendingConfirmationImpl>(
        this,
        _$identity,
      );
}

abstract class _PendingConfirmation implements PendingConfirmation {
  const factory _PendingConfirmation({
    required final String id,
    required final String memberInitials,
    required final String memberName,
    required final String meta,
    required final String time,
    required final int remainingBefore,
  }) = _$PendingConfirmationImpl;

  @override
  String get id;
  @override
  String get memberInitials;
  @override
  String get memberName;
  @override
  String get meta;
  @override
  String get time;
  @override
  int get remainingBefore;

  /// Create a copy of PendingConfirmation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PendingConfirmationImplCopyWith<_$PendingConfirmationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
