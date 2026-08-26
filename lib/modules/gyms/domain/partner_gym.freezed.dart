// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner_gym.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PartnerGym {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get logoUrl => throw _privateConstructorUsedError;

  /// Create a copy of PartnerGym
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartnerGymCopyWith<PartnerGym> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartnerGymCopyWith<$Res> {
  factory $PartnerGymCopyWith(
    PartnerGym value,
    $Res Function(PartnerGym) then,
  ) = _$PartnerGymCopyWithImpl<$Res, PartnerGym>;
  @useResult
  $Res call({
    String id,
    String name,
    String phone,
    String city,
    String address,
    String logoUrl,
  });
}

/// @nodoc
class _$PartnerGymCopyWithImpl<$Res, $Val extends PartnerGym>
    implements $PartnerGymCopyWith<$Res> {
  _$PartnerGymCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PartnerGym
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = null,
    Object? city = null,
    Object? address = null,
    Object? logoUrl = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            logoUrl: null == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PartnerGymImplCopyWith<$Res>
    implements $PartnerGymCopyWith<$Res> {
  factory _$$PartnerGymImplCopyWith(
    _$PartnerGymImpl value,
    $Res Function(_$PartnerGymImpl) then,
  ) = __$$PartnerGymImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String phone,
    String city,
    String address,
    String logoUrl,
  });
}

/// @nodoc
class __$$PartnerGymImplCopyWithImpl<$Res>
    extends _$PartnerGymCopyWithImpl<$Res, _$PartnerGymImpl>
    implements _$$PartnerGymImplCopyWith<$Res> {
  __$$PartnerGymImplCopyWithImpl(
    _$PartnerGymImpl _value,
    $Res Function(_$PartnerGymImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PartnerGym
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = null,
    Object? city = null,
    Object? address = null,
    Object? logoUrl = null,
  }) {
    return _then(
      _$PartnerGymImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        logoUrl: null == logoUrl
            ? _value.logoUrl
            : logoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PartnerGymImpl implements _PartnerGym {
  const _$PartnerGymImpl({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.address,
    this.logoUrl = '',
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final String phone;
  @override
  final String city;
  @override
  final String address;
  @override
  @JsonKey()
  final String logoUrl;

  @override
  String toString() {
    return 'PartnerGym(id: $id, name: $name, phone: $phone, city: $city, address: $address, logoUrl: $logoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartnerGymImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, phone, city, address, logoUrl);

  /// Create a copy of PartnerGym
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartnerGymImplCopyWith<_$PartnerGymImpl> get copyWith =>
      __$$PartnerGymImplCopyWithImpl<_$PartnerGymImpl>(this, _$identity);
}

abstract class _PartnerGym implements PartnerGym {
  const factory _PartnerGym({
    required final String id,
    required final String name,
    required final String phone,
    required final String city,
    required final String address,
    final String logoUrl,
  }) = _$PartnerGymImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get phone;
  @override
  String get city;
  @override
  String get address;
  @override
  String get logoUrl;

  /// Create a copy of PartnerGym
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartnerGymImplCopyWith<_$PartnerGymImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
