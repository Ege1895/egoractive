// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionStateForGymHash() =>
    r'cdf66ac32f2d0d78954934142eb17798684d48ed';

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

/// Salon Abonelik ve Erişim Akışı — `app_access.dart`'taki merkezi erişim
/// kapısı da bunu izler; ikisi AYRI birer `watchState()` çağrısı (dolayısıyla
/// ayrı birer Firestore listener'ı) açmak yerine bu TEK provider'ı paylaşır
/// (Riverpod aynı provider'ı izleyen tüm taraflar için tek bir alttaki
/// stream'i yeniden kullanır) — aksi halde admin oturumlarında aynı
/// `gyms/{gymId}` dokümanı için (biri bu controller'dan, biri erişim
/// kapısından) iki ayrı canlı dinleyici açık kalırdı.
///
/// Copied from [subscriptionStateForGym].
@ProviderFor(subscriptionStateForGym)
const subscriptionStateForGymProvider = SubscriptionStateForGymFamily();

/// Salon Abonelik ve Erişim Akışı — `app_access.dart`'taki merkezi erişim
/// kapısı da bunu izler; ikisi AYRI birer `watchState()` çağrısı (dolayısıyla
/// ayrı birer Firestore listener'ı) açmak yerine bu TEK provider'ı paylaşır
/// (Riverpod aynı provider'ı izleyen tüm taraflar için tek bir alttaki
/// stream'i yeniden kullanır) — aksi halde admin oturumlarında aynı
/// `gyms/{gymId}` dokümanı için (biri bu controller'dan, biri erişim
/// kapısından) iki ayrı canlı dinleyici açık kalırdı.
///
/// Copied from [subscriptionStateForGym].
class SubscriptionStateForGymFamily
    extends Family<AsyncValue<SubscriptionState>> {
  /// Salon Abonelik ve Erişim Akışı — `app_access.dart`'taki merkezi erişim
  /// kapısı da bunu izler; ikisi AYRI birer `watchState()` çağrısı (dolayısıyla
  /// ayrı birer Firestore listener'ı) açmak yerine bu TEK provider'ı paylaşır
  /// (Riverpod aynı provider'ı izleyen tüm taraflar için tek bir alttaki
  /// stream'i yeniden kullanır) — aksi halde admin oturumlarında aynı
  /// `gyms/{gymId}` dokümanı için (biri bu controller'dan, biri erişim
  /// kapısından) iki ayrı canlı dinleyici açık kalırdı.
  ///
  /// Copied from [subscriptionStateForGym].
  const SubscriptionStateForGymFamily();

  /// Salon Abonelik ve Erişim Akışı — `app_access.dart`'taki merkezi erişim
  /// kapısı da bunu izler; ikisi AYRI birer `watchState()` çağrısı (dolayısıyla
  /// ayrı birer Firestore listener'ı) açmak yerine bu TEK provider'ı paylaşır
  /// (Riverpod aynı provider'ı izleyen tüm taraflar için tek bir alttaki
  /// stream'i yeniden kullanır) — aksi halde admin oturumlarında aynı
  /// `gyms/{gymId}` dokümanı için (biri bu controller'dan, biri erişim
  /// kapısından) iki ayrı canlı dinleyici açık kalırdı.
  ///
  /// Copied from [subscriptionStateForGym].
  SubscriptionStateForGymProvider call(String gymId) {
    return SubscriptionStateForGymProvider(gymId);
  }

  @override
  SubscriptionStateForGymProvider getProviderOverride(
    covariant SubscriptionStateForGymProvider provider,
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
  String? get name => r'subscriptionStateForGymProvider';
}

/// Salon Abonelik ve Erişim Akışı — `app_access.dart`'taki merkezi erişim
/// kapısı da bunu izler; ikisi AYRI birer `watchState()` çağrısı (dolayısıyla
/// ayrı birer Firestore listener'ı) açmak yerine bu TEK provider'ı paylaşır
/// (Riverpod aynı provider'ı izleyen tüm taraflar için tek bir alttaki
/// stream'i yeniden kullanır) — aksi halde admin oturumlarında aynı
/// `gyms/{gymId}` dokümanı için (biri bu controller'dan, biri erişim
/// kapısından) iki ayrı canlı dinleyici açık kalırdı.
///
/// Copied from [subscriptionStateForGym].
class SubscriptionStateForGymProvider
    extends AutoDisposeStreamProvider<SubscriptionState> {
  /// Salon Abonelik ve Erişim Akışı — `app_access.dart`'taki merkezi erişim
  /// kapısı da bunu izler; ikisi AYRI birer `watchState()` çağrısı (dolayısıyla
  /// ayrı birer Firestore listener'ı) açmak yerine bu TEK provider'ı paylaşır
  /// (Riverpod aynı provider'ı izleyen tüm taraflar için tek bir alttaki
  /// stream'i yeniden kullanır) — aksi halde admin oturumlarında aynı
  /// `gyms/{gymId}` dokümanı için (biri bu controller'dan, biri erişim
  /// kapısından) iki ayrı canlı dinleyici açık kalırdı.
  ///
  /// Copied from [subscriptionStateForGym].
  SubscriptionStateForGymProvider(String gymId)
    : this._internal(
        (ref) =>
            subscriptionStateForGym(ref as SubscriptionStateForGymRef, gymId),
        from: subscriptionStateForGymProvider,
        name: r'subscriptionStateForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subscriptionStateForGymHash,
        dependencies: SubscriptionStateForGymFamily._dependencies,
        allTransitiveDependencies:
            SubscriptionStateForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  SubscriptionStateForGymProvider._internal(
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
    Stream<SubscriptionState> Function(SubscriptionStateForGymRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubscriptionStateForGymProvider._internal(
        (ref) => create(ref as SubscriptionStateForGymRef),
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
    return other is SubscriptionStateForGymProvider && other.gymId == gymId;
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
mixin SubscriptionStateForGymRef
    on AutoDisposeStreamProviderRef<SubscriptionState> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _SubscriptionStateForGymProviderElement
    extends AutoDisposeStreamProviderElement<SubscriptionState>
    with SubscriptionStateForGymRef {
  _SubscriptionStateForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as SubscriptionStateForGymProvider).gymId;
}

String _$subscriptionControllerHash() =>
    r'82109ddb73322192c8c470292d9f4ee4ad3b356c';

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
