// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gym_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GymProfile {
  String get name => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;

  /// Create a copy of GymProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GymProfileCopyWith<GymProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GymProfileCopyWith<$Res> {
  factory $GymProfileCopyWith(
    GymProfile value,
    $Res Function(GymProfile) then,
  ) = _$GymProfileCopyWithImpl<$Res, GymProfile>;
  @useResult
  $Res call({String name, String city, String phone, String address});
}

/// @nodoc
class _$GymProfileCopyWithImpl<$Res, $Val extends GymProfile>
    implements $GymProfileCopyWith<$Res> {
  _$GymProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GymProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? city = null,
    Object? phone = null,
    Object? address = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GymProfileImplCopyWith<$Res>
    implements $GymProfileCopyWith<$Res> {
  factory _$$GymProfileImplCopyWith(
    _$GymProfileImpl value,
    $Res Function(_$GymProfileImpl) then,
  ) = __$$GymProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String city, String phone, String address});
}

/// @nodoc
class __$$GymProfileImplCopyWithImpl<$Res>
    extends _$GymProfileCopyWithImpl<$Res, _$GymProfileImpl>
    implements _$$GymProfileImplCopyWith<$Res> {
  __$$GymProfileImplCopyWithImpl(
    _$GymProfileImpl _value,
    $Res Function(_$GymProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GymProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? city = null,
    Object? phone = null,
    Object? address = null,
  }) {
    return _then(
      _$GymProfileImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GymProfileImpl implements _GymProfile {
  const _$GymProfileImpl({
    required this.name,
    required this.city,
    required this.phone,
    required this.address,
  });

  @override
  final String name;
  @override
  final String city;
  @override
  final String phone;
  @override
  final String address;

  @override
  String toString() {
    return 'GymProfile(name: $name, city: $city, phone: $phone, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GymProfileImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, city, phone, address);

  /// Create a copy of GymProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GymProfileImplCopyWith<_$GymProfileImpl> get copyWith =>
      __$$GymProfileImplCopyWithImpl<_$GymProfileImpl>(this, _$identity);
}

abstract class _GymProfile implements GymProfile {
  const factory _GymProfile({
    required final String name,
    required final String city,
    required final String phone,
    required final String address,
  }) = _$GymProfileImpl;

  @override
  String get name;
  @override
  String get city;
  @override
  String get phone;
  @override
  String get address;

  /// Create a copy of GymProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GymProfileImplCopyWith<_$GymProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
