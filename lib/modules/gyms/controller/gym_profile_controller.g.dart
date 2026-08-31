// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileForGymHash() => r'8d06cad9acb10e371c2880830d03c909caa48d01';

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

/// See also [_profileForGym].
@ProviderFor(_profileForGym)
const _profileForGymProvider = _ProfileForGymFamily();

/// See also [_profileForGym].
class _ProfileForGymFamily extends Family<AsyncValue<GymProfile>> {
  /// See also [_profileForGym].
  const _ProfileForGymFamily();

  /// See also [_profileForGym].
  _ProfileForGymProvider call(String gymId) {
    return _ProfileForGymProvider(gymId);
  }

  @override
  _ProfileForGymProvider getProviderOverride(
    covariant _ProfileForGymProvider provider,
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
  String? get name => r'_profileForGymProvider';
}

/// See also [_profileForGym].
class _ProfileForGymProvider extends AutoDisposeStreamProvider<GymProfile> {
  /// See also [_profileForGym].
  _ProfileForGymProvider(String gymId)
    : this._internal(
        (ref) => _profileForGym(ref as _ProfileForGymRef, gymId),
        from: _profileForGymProvider,
        name: r'_profileForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileForGymHash,
        dependencies: _ProfileForGymFamily._dependencies,
        allTransitiveDependencies:
            _ProfileForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _ProfileForGymProvider._internal(
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
    Stream<GymProfile> Function(_ProfileForGymRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _ProfileForGymProvider._internal(
        (ref) => create(ref as _ProfileForGymRef),
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
  AutoDisposeStreamProviderElement<GymProfile> createElement() {
    return _ProfileForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _ProfileForGymProvider && other.gymId == gymId;
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
mixin _ProfileForGymRef on AutoDisposeStreamProviderRef<GymProfile> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _ProfileForGymProviderElement
    extends AutoDisposeStreamProviderElement<GymProfile>
    with _ProfileForGymRef {
  _ProfileForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _ProfileForGymProvider).gymId;
}

String _$gymProfileControllerHash() =>
    r'b102344803d9212b4c3abdd2cb07db086f8ce375';

/// See also [GymProfileController].
@ProviderFor(GymProfileController)
final gymProfileControllerProvider =
    AutoDisposeNotifierProvider<GymProfileController, GymProfile>.internal(
      GymProfileController.new,
      name: r'gymProfileControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gymProfileControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GymProfileController = AutoDisposeNotifier<GymProfile>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
