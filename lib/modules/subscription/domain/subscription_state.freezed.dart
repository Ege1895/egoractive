// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SubscriptionState {
  SubscriptionStatus get status => throw _privateConstructorUsedError;
  DateTime? get trialStartedAt => throw _privateConstructorUsedError;
  DateTime? get trialEndsAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  String? get productId => throw _privateConstructorUsedError;
  bool get isPurchasing => throw _privateConstructorUsedError;

  /// Satın alma akışı başlatılan ürün — mağaza penceresi açıkken hangi
  /// plan kartının "bekleniyor" durumunda gösterileceğini belirler.
  String? get pendingProductId => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionStateCopyWith<SubscriptionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionStateCopyWith<$Res> {
  factory $SubscriptionStateCopyWith(
    SubscriptionState value,
    $Res Function(SubscriptionState) then,
  ) = _$SubscriptionStateCopyWithImpl<$Res, SubscriptionState>;
  @useResult
  $Res call({
    SubscriptionStatus status,
    DateTime? trialStartedAt,
    DateTime? trialEndsAt,
    DateTime? startedAt,
    DateTime? expiresAt,
    String? productId,
    bool isPurchasing,
    String? pendingProductId,
  });
}

/// @nodoc
class _$SubscriptionStateCopyWithImpl<$Res, $Val extends SubscriptionState>
    implements $SubscriptionStateCopyWith<$Res> {
  _$SubscriptionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? trialStartedAt = freezed,
    Object? trialEndsAt = freezed,
    Object? startedAt = freezed,
    Object? expiresAt = freezed,
    Object? productId = freezed,
    Object? isPurchasing = null,
    Object? pendingProductId = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SubscriptionStatus,
            trialStartedAt: freezed == trialStartedAt
                ? _value.trialStartedAt
                : trialStartedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            trialEndsAt: freezed == trialEndsAt
                ? _value.trialEndsAt
                : trialEndsAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPurchasing: null == isPurchasing
                ? _value.isPurchasing
                : isPurchasing // ignore: cast_nullable_to_non_nullable
                      as bool,
            pendingProductId: freezed == pendingProductId
                ? _value.pendingProductId
                : pendingProductId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionStateImplCopyWith<$Res>
    implements $SubscriptionStateCopyWith<$Res> {
  factory _$$SubscriptionStateImplCopyWith(
    _$SubscriptionStateImpl value,
    $Res Function(_$SubscriptionStateImpl) then,
  ) = __$$SubscriptionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    SubscriptionStatus status,
    DateTime? trialStartedAt,
    DateTime? trialEndsAt,
    DateTime? startedAt,
    DateTime? expiresAt,
    String? productId,
    bool isPurchasing,
    String? pendingProductId,
  });
}

/// @nodoc
class __$$SubscriptionStateImplCopyWithImpl<$Res>
    extends _$SubscriptionStateCopyWithImpl<$Res, _$SubscriptionStateImpl>
    implements _$$SubscriptionStateImplCopyWith<$Res> {
  __$$SubscriptionStateImplCopyWithImpl(
    _$SubscriptionStateImpl _value,
    $Res Function(_$SubscriptionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? trialStartedAt = freezed,
    Object? trialEndsAt = freezed,
    Object? startedAt = freezed,
    Object? expiresAt = freezed,
    Object? productId = freezed,
    Object? isPurchasing = null,
    Object? pendingProductId = freezed,
  }) {
    return _then(
      _$SubscriptionStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SubscriptionStatus,
        trialStartedAt: freezed == trialStartedAt
            ? _value.trialStartedAt
            : trialStartedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        trialEndsAt: freezed == trialEndsAt
            ? _value.trialEndsAt
            : trialEndsAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPurchasing: null == isPurchasing
            ? _value.isPurchasing
            : isPurchasing // ignore: cast_nullable_to_non_nullable
                  as bool,
        pendingProductId: freezed == pendingProductId
            ? _value.pendingProductId
            : pendingProductId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SubscriptionStateImpl implements _SubscriptionState {
  const _$SubscriptionStateImpl({
    this.status = SubscriptionStatus.none,
    this.trialStartedAt,
    this.trialEndsAt,
    this.startedAt,
    this.expiresAt,
    this.productId,
    this.isPurchasing = false,
    this.pendingProductId,
  });

  @override
  @JsonKey()
  final SubscriptionStatus status;
  @override
  final DateTime? trialStartedAt;
  @override
  final DateTime? trialEndsAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? expiresAt;
  @override
  final String? productId;
  @override
  @JsonKey()
  final bool isPurchasing;

  /// Satın alma akışı başlatılan ürün — mağaza penceresi açıkken hangi
  /// plan kartının "bekleniyor" durumunda gösterileceğini belirler.
  @override
  final String? pendingProductId;

  @override
  String toString() {
    return 'SubscriptionState(status: $status, trialStartedAt: $trialStartedAt, trialEndsAt: $trialEndsAt, startedAt: $startedAt, expiresAt: $expiresAt, productId: $productId, isPurchasing: $isPurchasing, pendingProductId: $pendingProductId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.trialStartedAt, trialStartedAt) ||
                other.trialStartedAt == trialStartedAt) &&
            (identical(other.trialEndsAt, trialEndsAt) ||
                other.trialEndsAt == trialEndsAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.isPurchasing, isPurchasing) ||
                other.isPurchasing == isPurchasing) &&
            (identical(other.pendingProductId, pendingProductId) ||
                other.pendingProductId == pendingProductId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    trialStartedAt,
    trialEndsAt,
    startedAt,
    expiresAt,
    productId,
    isPurchasing,
    pendingProductId,
  );

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionStateImplCopyWith<_$SubscriptionStateImpl> get copyWith =>
      __$$SubscriptionStateImplCopyWithImpl<_$SubscriptionStateImpl>(
        this,
        _$identity,
      );
}

abstract class _SubscriptionState implements SubscriptionState {
  const factory _SubscriptionState({
    final SubscriptionStatus status,
    final DateTime? trialStartedAt,
    final DateTime? trialEndsAt,
    final DateTime? startedAt,
    final DateTime? expiresAt,
    final String? productId,
    final bool isPurchasing,
    final String? pendingProductId,
  }) = _$SubscriptionStateImpl;

  @override
  SubscriptionStatus get status;
  @override
  DateTime? get trialStartedAt;
  @override
  DateTime? get trialEndsAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get expiresAt;
  @override
  String? get productId;
  @override
  bool get isPurchasing;

  /// Satın alma akışı başlatılan ürün — mağaza penceresi açıkken hangi
  /// plan kartının "bekleniyor" durumunda gösterileceğini belirler.
  @override
  String? get pendingProductId;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionStateImplCopyWith<_$SubscriptionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SubscriptionProduct {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get price => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionProductCopyWith<SubscriptionProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionProductCopyWith<$Res> {
  factory $SubscriptionProductCopyWith(
    SubscriptionProduct value,
    $Res Function(SubscriptionProduct) then,
  ) = _$SubscriptionProductCopyWithImpl<$Res, SubscriptionProduct>;
  @useResult
  $Res call({String id, String title, String description, String price});
}

/// @nodoc
class _$SubscriptionProductCopyWithImpl<$Res, $Val extends SubscriptionProduct>
    implements $SubscriptionProductCopyWith<$Res> {
  _$SubscriptionProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? price = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionProductImplCopyWith<$Res>
    implements $SubscriptionProductCopyWith<$Res> {
  factory _$$SubscriptionProductImplCopyWith(
    _$SubscriptionProductImpl value,
    $Res Function(_$SubscriptionProductImpl) then,
  ) = __$$SubscriptionProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String description, String price});
}

/// @nodoc
class __$$SubscriptionProductImplCopyWithImpl<$Res>
    extends _$SubscriptionProductCopyWithImpl<$Res, _$SubscriptionProductImpl>
    implements _$$SubscriptionProductImplCopyWith<$Res> {
  __$$SubscriptionProductImplCopyWithImpl(
    _$SubscriptionProductImpl _value,
    $Res Function(_$SubscriptionProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? price = null,
  }) {
    return _then(
      _$SubscriptionProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SubscriptionProductImpl implements _SubscriptionProduct {
  const _$SubscriptionProductImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String price;

  @override
  String toString() {
    return 'SubscriptionProduct(id: $id, title: $title, description: $description, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, price);

  /// Create a copy of SubscriptionProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionProductImplCopyWith<_$SubscriptionProductImpl> get copyWith =>
      __$$SubscriptionProductImplCopyWithImpl<_$SubscriptionProductImpl>(
        this,
        _$identity,
      );
}

abstract class _SubscriptionProduct implements SubscriptionProduct {
  const factory _SubscriptionProduct({
    required final String id,
    required final String title,
    required final String description,
    required final String price,
  }) = _$SubscriptionProductImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get price;

  /// Create a copy of SubscriptionProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionProductImplCopyWith<_$SubscriptionProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
