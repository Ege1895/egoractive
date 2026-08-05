// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Session {
  String get id => throw _privateConstructorUsedError;
  String get day => throw _privateConstructorUsedError;
  String get month => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get meta => throw _privateConstructorUsedError;
  SessionStatus get status => throw _privateConstructorUsedError;
  AttendanceAnswer get confirmation => throw _privateConstructorUsedError;

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionCopyWith<Session> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionCopyWith<$Res> {
  factory $SessionCopyWith(Session value, $Res Function(Session) then) =
      _$SessionCopyWithImpl<$Res, Session>;
  @useResult
  $Res call({
    String id,
    String day,
    String month,
    String title,
    String meta,
    SessionStatus status,
    AttendanceAnswer confirmation,
  });
}

/// @nodoc
class _$SessionCopyWithImpl<$Res, $Val extends Session>
    implements $SessionCopyWith<$Res> {
  _$SessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? day = null,
    Object? month = null,
    Object? title = null,
    Object? meta = null,
    Object? status = null,
    Object? confirmation = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            day: null == day
                ? _value.day
                : day // ignore: cast_nullable_to_non_nullable
                      as String,
            month: null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SessionStatus,
            confirmation: null == confirmation
                ? _value.confirmation
                : confirmation // ignore: cast_nullable_to_non_nullable
                      as AttendanceAnswer,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionImplCopyWith<$Res> implements $SessionCopyWith<$Res> {
  factory _$$SessionImplCopyWith(
    _$SessionImpl value,
    $Res Function(_$SessionImpl) then,
  ) = __$$SessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String day,
    String month,
    String title,
    String meta,
    SessionStatus status,
    AttendanceAnswer confirmation,
  });
}

/// @nodoc
class __$$SessionImplCopyWithImpl<$Res>
    extends _$SessionCopyWithImpl<$Res, _$SessionImpl>
    implements _$$SessionImplCopyWith<$Res> {
  __$$SessionImplCopyWithImpl(
    _$SessionImpl _value,
    $Res Function(_$SessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? day = null,
    Object? month = null,
    Object? title = null,
    Object? meta = null,
    Object? status = null,
    Object? confirmation = null,
  }) {
    return _then(
      _$SessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        day: null == day
            ? _value.day
            : day // ignore: cast_nullable_to_non_nullable
                  as String,
        month: null == month
            ? _value.month
            : month // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SessionStatus,
        confirmation: null == confirmation
            ? _value.confirmation
            : confirmation // ignore: cast_nullable_to_non_nullable
                  as AttendanceAnswer,
      ),
    );
  }
}

/// @nodoc

class _$SessionImpl implements _Session {
  const _$SessionImpl({
    required this.id,
    required this.day,
    required this.month,
    required this.title,
    required this.meta,
    required this.status,
    this.confirmation = AttendanceAnswer.pending,
  });

  @override
  final String id;
  @override
  final String day;
  @override
  final String month;
  @override
  final String title;
  @override
  final String meta;
  @override
  final SessionStatus status;
  @override
  @JsonKey()
  final AttendanceAnswer confirmation;

  @override
  String toString() {
    return 'Session(id: $id, day: $day, month: $month, title: $title, meta: $meta, status: $status, confirmation: $confirmation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.confirmation, confirmation) ||
                other.confirmation == confirmation));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    day,
    month,
    title,
    meta,
    status,
    confirmation,
  );

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionImplCopyWith<_$SessionImpl> get copyWith =>
      __$$SessionImplCopyWithImpl<_$SessionImpl>(this, _$identity);
}

abstract class _Session implements Session {
  const factory _Session({
    required final String id,
    required final String day,
    required final String month,
    required final String title,
    required final String meta,
    required final SessionStatus status,
    final AttendanceAnswer confirmation,
  }) = _$SessionImpl;

  @override
  String get id;
  @override
  String get day;
  @override
  String get month;
  @override
  String get title;
  @override
  String get meta;
  @override
  SessionStatus get status;
  @override
  AttendanceAnswer get confirmation;

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionImplCopyWith<_$SessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
