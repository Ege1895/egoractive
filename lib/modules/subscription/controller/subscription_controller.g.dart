// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionStateForGymHash() =>
    r'57e774a29cfcd20df63918a20c420cc79ad009cc';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [_subscriptionStateForGym].
@ProviderFor(_subscriptionStateForGym)
const _subscriptionStateForGymProvider = _SubscriptionStateForGymFamily();

/// See also [_subscriptionStateForGym].
class _SubscriptionStateForGymFamily
    extends Family<AsyncValue<SubscriptionState>> {
  /// See also [_subscriptionStateForGym].
  const _SubscriptionStateForGymFamily();

  /// See also [_subscriptionStateForGym].
  _SubscriptionStateForGymProvider call(String gymId) {
    return _SubscriptionStateForGymProvider(gymId);
  }

  @override
  _SubscriptionStateForGymProvider getProviderOverride(
    covariant _SubscriptionStateForGymProvider provider,
  ) {
    return call(provider.gymId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_subscriptionStateForGymProvider';
}

/// See also [_subscriptionStateForGym].
class _SubscriptionStateForGymProvider
    extends AutoDisposeStreamProvider<SubscriptionState> {
  /// See also [_subscriptionStateForGym].
  _SubscriptionStateForGymProvider(String gymId)
    : this._internal(
        (ref) =>
            _subscriptionStateForGym(ref as _SubscriptionStateForGymRef, gymId),
        from: _subscriptionStateForGymProvider,
        name: r'_subscriptionStateForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subscriptionStateForGymHash,
        dependencies: _SubscriptionStateForGymFamily._dependencies,
        allTransitiveDependencies:
            _SubscriptionStateForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _SubscriptionStateForGymProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gymId,
  }) : super.internal();

  final String gymId;

  @override
  Override overrideWith(
    Stream<SubscriptionState> Function(_SubscriptionStateForGymRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _SubscriptionStateForGymProvider._internal(
        (ref) => create(ref as _SubscriptionStateForGymRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gymId: gymId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<SubscriptionState> createElement() {
    return _SubscriptionStateForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _SubscriptionStateForGymProvider && other.gymId == gymId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gymId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _SubscriptionStateForGymRef
    on AutoDisposeStreamProviderRef<SubscriptionState> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _SubscriptionStateForGymProviderElement
    extends AutoDisposeStreamProviderElement<SubscriptionState>
    with _SubscriptionStateForGymRef {
  _SubscriptionStateForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _SubscriptionStateForGymProvider).gymId;
}

String _$subscriptionControllerHash() =>
    r'7982866b60e4ea78e561ea364b11de237a026e6e';

/// F6-1 — aktif salonun abonelik durumunu okur ve mağaza satın alma akışını
/// başlatır. Satın alma tamamlandığında `verifySubscriptionPurchase`
/// callable'ını (F6-1d) çağırıp makbuzu doğrulatır — `gyms/{gymId}`'nin
/// abonelik alanlarını bu Controller ASLA doğrudan yazmaz (firestore.rules
/// zaten client yazımını engelliyor).
///
/// Copied from [SubscriptionController].
@ProviderFor(SubscriptionController)
final subscriptionControllerProvider =
    AutoDisposeNotifierProvider<
      SubscriptionController,
      SubscriptionState
    >.internal(
      SubscriptionController.new,
      name: r'subscriptionControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$subscriptionControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SubscriptionController = AutoDisposeNotifier<SubscriptionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
