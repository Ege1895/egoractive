// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_permissions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$permissionsForGymHash() => r'f5c467721e965cfa48f07895614c4edfc39d9582';

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

/// See also [_permissionsForGym].
@ProviderFor(_permissionsForGym)
const _permissionsForGymProvider = _PermissionsForGymFamily();

/// See also [_permissionsForGym].
class _PermissionsForGymFamily extends Family<AsyncValue<AdminPermissions>> {
  /// See also [_permissionsForGym].
  const _PermissionsForGymFamily();

  /// See also [_permissionsForGym].
  _PermissionsForGymProvider call(String gymId) {
    return _PermissionsForGymProvider(gymId);
  }

  @override
  _PermissionsForGymProvider getProviderOverride(
    covariant _PermissionsForGymProvider provider,
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
  String? get name => r'_permissionsForGymProvider';
}

/// See also [_permissionsForGym].
class _PermissionsForGymProvider
    extends AutoDisposeStreamProvider<AdminPermissions> {
  /// See also [_permissionsForGym].
  _PermissionsForGymProvider(String gymId)
    : this._internal(
        (ref) => _permissionsForGym(ref as _PermissionsForGymRef, gymId),
        from: _permissionsForGymProvider,
        name: r'_permissionsForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$permissionsForGymHash,
        dependencies: _PermissionsForGymFamily._dependencies,
        allTransitiveDependencies:
            _PermissionsForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _PermissionsForGymProvider._internal(
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
    Stream<AdminPermissions> Function(_PermissionsForGymRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _PermissionsForGymProvider._internal(
        (ref) => create(ref as _PermissionsForGymRef),
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
  AutoDisposeStreamProviderElement<AdminPermissions> createElement() {
    return _PermissionsForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _PermissionsForGymProvider && other.gymId == gymId;
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
mixin _PermissionsForGymRef on AutoDisposeStreamProviderRef<AdminPermissions> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _PermissionsForGymProviderElement
    extends AutoDisposeStreamProviderElement<AdminPermissions>
    with _PermissionsForGymRef {
  _PermissionsForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _PermissionsForGymProvider).gymId;
}

String _$adminPermissionsControllerHash() =>
    r'c1f9e822e27d8eb62fc2245448ac0fc16fe0774b';

/// F3-6 — salon bazlı override `gyms/{gymId}.permissions` altında saklanır;
/// bir alan yazılmamışsa Remote Config'teki global varsayılana düşülür.
/// Aktif salon bilinmiyorsa (test ortamı vb.) tamamen RC varsayılanlarında
/// kalır.
///
/// Copied from [AdminPermissionsController].
@ProviderFor(AdminPermissionsController)
final adminPermissionsControllerProvider =
    AutoDisposeNotifierProvider<
      AdminPermissionsController,
      AdminPermissions
    >.internal(
      AdminPermissionsController.new,
      name: r'adminPermissionsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminPermissionsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminPermissionsController = AutoDisposeNotifier<AdminPermissions>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
