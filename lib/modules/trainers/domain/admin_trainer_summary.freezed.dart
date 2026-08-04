// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_trainer_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdminTrainerSummary {
  String get id => throw _privateConstructorUsedError;
  String get initials => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  List<String> get specialties => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;

  /// Create a copy of AdminTrainerSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminTrainerSummaryCopyWith<AdminTrainerSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminTrainerSummaryCopyWith<$Res> {
  factory $AdminTrainerSummaryCopyWith(
    AdminTrainerSummary value,
    $Res Function(AdminTrainerSummary) then,
  ) = _$AdminTrainerSummaryCopyWithImpl<$Res, AdminTrainerSummary>;
  @useResult
  $Res call({
    String id,
    String initials,
    String name,
    String phone,
    List<String> specialties,
    int memberCount,
  });
}

/// @nodoc
class _$AdminTrainerSummaryCopyWithImpl<$Res, $Val extends AdminTrainerSummary>
    implements $AdminTrainerSummaryCopyWith<$Res> {
  _$AdminTrainerSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminTrainerSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initials = null,
    Object? name = null,
    Object? phone = null,
    Object? specialties = null,
    Object? memberCount = null,
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
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            specialties: null == specialties
                ? _value.specialties
                : specialties // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            memberCount: null == memberCount
                ? _value.memberCount
                : memberCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminTrainerSummaryImplCopyWith<$Res>
    implements $AdminTrainerSummaryCopyWith<$Res> {
  factory _$$AdminTrainerSummaryImplCopyWith(
    _$AdminTrainerSummaryImpl value,
    $Res Function(_$AdminTrainerSummaryImpl) then,
  ) = __$$AdminTrainerSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String initials,
    String name,
    String phone,
    List<String> specialties,
    int memberCount,
  });
}

/// @nodoc
class __$$AdminTrainerSummaryImplCopyWithImpl<$Res>
    extends _$AdminTrainerSummaryCopyWithImpl<$Res, _$AdminTrainerSummaryImpl>
    implements _$$AdminTrainerSummaryImplCopyWith<$Res> {
  __$$AdminTrainerSummaryImplCopyWithImpl(
    _$AdminTrainerSummaryImpl _value,
    $Res Function(_$AdminTrainerSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminTrainerSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initials = null,
    Object? name = null,
    Object? phone = null,
    Object? specialties = null,
    Object? memberCount = null,
  }) {
    return _then(
      _$AdminTrainerSummaryImpl(
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
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        specialties: null == specialties
            ? _value._specialties
            : specialties // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        memberCount: null == memberCount
            ? _value.memberCount
            : memberCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$AdminTrainerSummaryImpl implements _AdminTrainerSummary {
  const _$AdminTrainerSummaryImpl({
    required this.id,
    required this.initials,
    required this.name,
    required this.phone,
    required final List<String> specialties,
    required this.memberCount,
  }) : _specialties = specialties;

  @override
  final String id;
  @override
  final String initials;
  @override
  final String name;
  @override
  final String phone;
  final List<String> _specialties;
  @override
  List<String> get specialties {
    if (_specialties is EqualUnmodifiableListView) return _specialties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_specialties);
  }

  @override
  final int memberCount;

  @override
  String toString() {
    return 'AdminTrainerSummary(id: $id, initials: $initials, name: $name, phone: $phone, specialties: $specialties, memberCount: $memberCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminTrainerSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.initials, initials) ||
                other.initials == initials) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            const DeepCollectionEquality().equals(
              other._specialties,
              _specialties,
            ) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    initials,
    name,
    phone,
    const DeepCollectionEquality().hash(_specialties),
    memberCount,
  );

  /// Create a copy of AdminTrainerSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminTrainerSummaryImplCopyWith<_$AdminTrainerSummaryImpl> get copyWith =>
      __$$AdminTrainerSummaryImplCopyWithImpl<_$AdminTrainerSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _AdminTrainerSummary implements AdminTrainerSummary {
  const factory _AdminTrainerSummary({
    required final String id,
    required final String initials,
    required final String name,
    required final String phone,
    required final List<String> specialties,
    required final int memberCount,
  }) = _$AdminTrainerSummaryImpl;

  @override
  String get id;
  @override
  String get initials;
  @override
  String get name;
  @override
  String get phone;
  @override
  List<String> get specialties;
  @override
  int get memberCount;

  /// Create a copy of AdminTrainerSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminTrainerSummaryImplCopyWith<_$AdminTrainerSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
