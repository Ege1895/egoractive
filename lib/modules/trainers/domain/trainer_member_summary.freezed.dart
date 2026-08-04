// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_member_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TrainerMemberSummary {
  String get id => throw _privateConstructorUsedError;
  String get initials => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get packageName => throw _privateConstructorUsedError;
  int get remainingSessions => throw _privateConstructorUsedError;

  /// Create a copy of TrainerMemberSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerMemberSummaryCopyWith<TrainerMemberSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerMemberSummaryCopyWith<$Res> {
  factory $TrainerMemberSummaryCopyWith(
    TrainerMemberSummary value,
    $Res Function(TrainerMemberSummary) then,
  ) = _$TrainerMemberSummaryCopyWithImpl<$Res, TrainerMemberSummary>;
  @useResult
  $Res call({
    String id,
    String initials,
    String name,
    String packageName,
    int remainingSessions,
  });
}

/// @nodoc
class _$TrainerMemberSummaryCopyWithImpl<
  $Res,
  $Val extends TrainerMemberSummary
>
    implements $TrainerMemberSummaryCopyWith<$Res> {
  _$TrainerMemberSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerMemberSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initials = null,
    Object? name = null,
    Object? packageName = null,
    Object? remainingSessions = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            initials: null == initials
                ? _value.initials
                : initials // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            packageName: null == packageName
                ? _value.packageName
                : packageName // ignore: cast_nullable_to_non_nullable
                      as String,
            remainingSessions: null == remainingSessions
                ? _value.remainingSessions
                : remainingSessions // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerMemberSummaryImplCopyWith<$Res>
    implements $TrainerMemberSummaryCopyWith<$Res> {
  factory _$$TrainerMemberSummaryImplCopyWith(
    _$TrainerMemberSummaryImpl value,
    $Res Function(_$TrainerMemberSummaryImpl) then,
  ) = __$$TrainerMemberSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String initials,
    String name,
    String packageName,
    int remainingSessions,
  });
}

/// @nodoc
class __$$TrainerMemberSummaryImplCopyWithImpl<$Res>
    extends _$TrainerMemberSummaryCopyWithImpl<$Res, _$TrainerMemberSummaryImpl>
    implements _$$TrainerMemberSummaryImplCopyWith<$Res> {
  __$$TrainerMemberSummaryImplCopyWithImpl(
    _$TrainerMemberSummaryImpl _value,
    $Res Function(_$TrainerMemberSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerMemberSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initials = null,
    Object? name = null,
    Object? packageName = null,
    Object? remainingSessions = null,
  }) {
    return _then(
      _$TrainerMemberSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        initials: null == initials
            ? _value.initials
            : initials // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        packageName: null == packageName
            ? _value.packageName
            : packageName // ignore: cast_nullable_to_non_nullable
                  as String,
        remainingSessions: null == remainingSessions
            ? _value.remainingSessions
            : remainingSessions // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$TrainerMemberSummaryImpl implements _TrainerMemberSummary {
  const _$TrainerMemberSummaryImpl({
    required this.id,
    required this.initials,
    required this.name,
    required this.packageName,
    required this.remainingSessions,
  });

  @override
  final String id;
  @override
  final String initials;
  @override
  final String name;
  @override
  final String packageName;
  @override
  final int remainingSessions;

  @override
  String toString() {
    return 'TrainerMemberSummary(id: $id, initials: $initials, name: $name, packageName: $packageName, remainingSessions: $remainingSessions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerMemberSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.initials, initials) ||
                other.initials == initials) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.packageName, packageName) ||
                other.packageName == packageName) &&
            (identical(other.remainingSessions, remainingSessions) ||
                other.remainingSessions == remainingSessions));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    initials,
    name,
    packageName,
    remainingSessions,
  );

  /// Create a copy of TrainerMemberSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerMemberSummaryImplCopyWith<_$TrainerMemberSummaryImpl>
  get copyWith =>
      __$$TrainerMemberSummaryImplCopyWithImpl<_$TrainerMemberSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _TrainerMemberSummary implements TrainerMemberSummary {
  const factory _TrainerMemberSummary({
    required final String id,
    required final String initials,
    required final String name,
    required final String packageName,
    required final int remainingSessions,
  }) = _$TrainerMemberSummaryImpl;

  @override
  String get id;
  @override
  String get initials;
  @override
  String get name;
  @override
  String get packageName;
  @override
  int get remainingSessions;

  /// Create a copy of TrainerMemberSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerMemberSummaryImplCopyWith<_$TrainerMemberSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
