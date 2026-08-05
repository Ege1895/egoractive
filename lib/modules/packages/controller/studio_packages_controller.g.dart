// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'studio_packages_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$packagesForGymHash() => r'f0564683ad7dd427d9a8f55d514c16360c67c73f';

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

/// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
/// bu durumda [StudioPackagesController] mock repository'e düşer.
///
/// Copied from [_packagesForGym].
@ProviderFor(_packagesForGym)
const _packagesForGymProvider = _PackagesForGymFamily();

/// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
/// bu durumda [StudioPackagesController] mock repository'e düşer.
///
/// Copied from [_packagesForGym].
class _PackagesForGymFamily extends Family<AsyncValue<List<StudioPackage>>> {
  /// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
  /// bu durumda [StudioPackagesController] mock repository'e düşer.
  ///
  /// Copied from [_packagesForGym].
  const _PackagesForGymFamily();

  /// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
  /// bu durumda [StudioPackagesController] mock repository'e düşer.
  ///
  /// Copied from [_packagesForGym].
  _PackagesForGymProvider call(String gymId) {
    return _PackagesForGymProvider(gymId);
  }

  @override
  _PackagesForGymProvider getProviderOverride(
    covariant _PackagesForGymProvider provider,
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
  String? get name => r'_packagesForGymProvider';
}

/// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
/// bu durumda [StudioPackagesController] mock repository'e düşer.
///
/// Copied from [_packagesForGym].
class _PackagesForGymProvider
    extends AutoDisposeStreamProvider<List<StudioPackage>> {
  /// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
  /// bu durumda [StudioPackagesController] mock repository'e düşer.
  ///
  /// Copied from [_packagesForGym].
  _PackagesForGymProvider(String gymId)
    : this._internal(
        (ref) => _packagesForGym(ref as _PackagesForGymRef, gymId),
        from: _packagesForGymProvider,
        name: r'_packagesForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$packagesForGymHash,
        dependencies: _PackagesForGymFamily._dependencies,
        allTransitiveDependencies:
            _PackagesForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _PackagesForGymProvider._internal(
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
    Stream<List<StudioPackage>> Function(_PackagesForGymRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _PackagesForGymProvider._internal(
        (ref) => create(ref as _PackagesForGymRef),
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
  AutoDisposeStreamProviderElement<List<StudioPackage>> createElement() {
    return _PackagesForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _PackagesForGymProvider && other.gymId == gymId;
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
mixin _PackagesForGymRef on AutoDisposeStreamProviderRef<List<StudioPackage>> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _PackagesForGymProviderElement
    extends AutoDisposeStreamProviderElement<List<StudioPackage>>
    with _PackagesForGymRef {
  _PackagesForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _PackagesForGymProvider).gymId;
}

String _$studioPackagesControllerHash() =>
    r'73fa73f0256604c25149d15e098a4c38a5be2efd';

/// F3-1 — stüdyo paket kataloğu artık gerçek zamanlı `gyms/{gymId}/packages`
/// koleksiyonundan okunur/yazılır. Dış arayüz bilerce senkron
/// (`List<StudioPackage>`) tutuldu — panel tüketicileri `AsyncValue` bilmek
/// zorunda değil.
///
/// Copied from [StudioPackagesController].
@ProviderFor(StudioPackagesController)
final studioPackagesControllerProvider =
    AutoDisposeNotifierProvider<
      StudioPackagesController,
      List<StudioPackage>
    >.internal(
      StudioPackagesController.new,
      name: r'studioPackagesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studioPackagesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StudioPackagesController = AutoDisposeNotifier<List<StudioPackage>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
