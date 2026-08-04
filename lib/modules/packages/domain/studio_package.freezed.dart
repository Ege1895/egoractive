// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'studio_package.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StudioPackage {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  PackageSessionType get sessionType => throw _privateConstructorUsedError;
  int get sessionCount => throw _privateConstructorUsedError;
  int get validityDays => throw _privateConstructorUsedError;
  int get priceTl => throw _privateConstructorUsedError;
  bool get activeForSale => throw _privateConstructorUsedError;

  /// Create a copy of StudioPackage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudioPackageCopyWith<StudioPackage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudioPackageCopyWith<$Res> {
  factory $StudioPackageCopyWith(
    StudioPackage value,
    $Res Function(StudioPackage) then,
  ) = _$StudioPackageCopyWithImpl<$Res, StudioPackage>;
  @useResult
  $Res call({
    String id,
    String name,
    PackageSessionType sessionType,
    int sessionCount,
    int validityDays,
    int priceTl,
    bool activeForSale,
  });
}

/// @nodoc
class _$StudioPackageCopyWithImpl<$Res, $Val extends StudioPackage>
    implements $StudioPackageCopyWith<$Res> {
  _$StudioPackageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudioPackage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sessionType = null,
    Object? sessionCount = null,
    Object? validityDays = null,
    Object? priceTl = null,
    Object? activeForSale = null,
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
            sessionType: null == sessionType
                ? _value.sessionType
                : sessionType // ignore: cast_nullable_to_non_nullable
                      as PackageSessionType,
            sessionCount: null == sessionCount
                ? _value.sessionCount
                : sessionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            validityDays: null == validityDays
                ? _value.validityDays
                : validityDays // ignore: cast_nullable_to_non_nullable
                      as int,
            priceTl: null == priceTl
                ? _value.priceTl
                : priceTl // ignore: cast_nullable_to_non_nullable
                      as int,
            activeForSale: null == activeForSale
                ? _value.activeForSale
                : activeForSale // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudioPackageImplCopyWith<$Res>
    implements $StudioPackageCopyWith<$Res> {
  factory _$$StudioPackageImplCopyWith(
    _$StudioPackageImpl value,
    $Res Function(_$StudioPackageImpl) then,
  ) = __$$StudioPackageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    PackageSessionType sessionType,
    int sessionCount,
    int validityDays,
    int priceTl,
    bool activeForSale,
  });
}

/// @nodoc
class __$$StudioPackageImplCopyWithImpl<$Res>
    extends _$StudioPackageCopyWithImpl<$Res, _$StudioPackageImpl>
    implements _$$StudioPackageImplCopyWith<$Res> {
  __$$StudioPackageImplCopyWithImpl(
    _$StudioPackageImpl _value,
    $Res Function(_$StudioPackageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudioPackage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sessionType = null,
    Object? sessionCount = null,
    Object? validityDays = null,
    Object? priceTl = null,
    Object? activeForSale = null,
  }) {
    return _then(
      _$StudioPackageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionType: null == sessionType
            ? _value.sessionType
            : sessionType // ignore: cast_nullable_to_non_nullable
                  as PackageSessionType,
        sessionCount: null == sessionCount
            ? _value.sessionCount
            : sessionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        validityDays: null == validityDays
            ? _value.validityDays
            : validityDays // ignore: cast_nullable_to_non_nullable
                  as int,
        priceTl: null == priceTl
            ? _value.priceTl
            : priceTl // ignore: cast_nullable_to_non_nullable
                  as int,
        activeForSale: null == activeForSale
            ? _value.activeForSale
            : activeForSale // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$StudioPackageImpl extends _StudioPackage {
  const _$StudioPackageImpl({
    required this.id,
    required this.name,
    required this.sessionType,
    required this.sessionCount,
    required this.validityDays,
    required this.priceTl,
    this.activeForSale = true,
  }) : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final PackageSessionType sessionType;
  @override
  final int sessionCount;
  @override
  final int validityDays;
  @override
  final int priceTl;
  @override
  @JsonKey()
  final bool activeForSale;

  @override
  String toString() {
    return 'StudioPackage(id: $id, name: $name, sessionType: $sessionType, sessionCount: $sessionCount, validityDays: $validityDays, priceTl: $priceTl, activeForSale: $activeForSale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudioPackageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sessionType, sessionType) ||
                other.sessionType == sessionType) &&
            (identical(other.sessionCount, sessionCount) ||
                other.sessionCount == sessionCount) &&
            (identical(other.validityDays, validityDays) ||
                other.validityDays == validityDays) &&
            (identical(other.priceTl, priceTl) || other.priceTl == priceTl) &&
            (identical(other.activeForSale, activeForSale) ||
                other.activeForSale == activeForSale));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    sessionType,
    sessionCount,
    validityDays,
    priceTl,
    activeForSale,
  );

  /// Create a copy of StudioPackage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudioPackageImplCopyWith<_$StudioPackageImpl> get copyWith =>
      __$$StudioPackageImplCopyWithImpl<_$StudioPackageImpl>(this, _$identity);
}

abstract class _StudioPackage extends StudioPackage {
  const factory _StudioPackage({
    required final String id,
    required final String name,
    required final PackageSessionType sessionType,
    required final int sessionCount,
    required final int validityDays,
    required final int priceTl,
    final bool activeForSale,
  }) = _$StudioPackageImpl;
  const _StudioPackage._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  PackageSessionType get sessionType;
  @override
  int get sessionCount;
  @override
  int get validityDays;
  @override
  int get priceTl;
  @override
  bool get activeForSale;

  /// Create a copy of StudioPackage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudioPackageImplCopyWith<_$StudioPackageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
