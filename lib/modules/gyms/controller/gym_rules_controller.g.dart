// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_rules_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rulesForGymHash() => r'5d7e2e1f23991bbeaf824d18f43925ed5062b96f';

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

/// See also [_rulesForGym].
@ProviderFor(_rulesForGym)
const _rulesForGymProvider = _RulesForGymFamily();

/// See also [_rulesForGym].
class _RulesForGymFamily extends Family<AsyncValue<GymRules>> {
  /// See also [_rulesForGym].
  const _RulesForGymFamily();

  /// See also [_rulesForGym].
  _RulesForGymProvider call(String gymId) {
    return _RulesForGymProvider(gymId);
  }

  @override
  _RulesForGymProvider getProviderOverride(
    covariant _RulesForGymProvider provider,
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
  String? get name => r'_rulesForGymProvider';
}

/// See also [_rulesForGym].
class _RulesForGymProvider extends AutoDisposeStreamProvider<GymRules> {
  /// See also [_rulesForGym].
  _RulesForGymProvider(String gymId)
    : this._internal(
        (ref) => _rulesForGym(ref as _RulesForGymRef, gymId),
        from: _rulesForGymProvider,
        name: r'_rulesForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$rulesForGymHash,
        dependencies: _RulesForGymFamily._dependencies,
        allTransitiveDependencies:
            _RulesForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _RulesForGymProvider._internal(
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
    Stream<GymRules> Function(_RulesForGymRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _RulesForGymProvider._internal(
        (ref) => create(ref as _RulesForGymRef),
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
  AutoDisposeStreamProviderElement<GymRules> createElement() {
    return _RulesForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _RulesForGymProvider && other.gymId == gymId;
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
mixin _RulesForGymRef on AutoDisposeStreamProviderRef<GymRules> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _RulesForGymProviderElement
    extends AutoDisposeStreamProviderElement<GymRules>
    with _RulesForGymRef {
  _RulesForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _RulesForGymProvider).gymId;
}

String _$gymRulesControllerHash() =>
    r'976585919d4e4d3b7c6bd004c490921b24b612c2';

/// F4-5 — `gyms/{gymId}.rulesContent` (Quill Delta JSON), her rol için
/// gerçek zamanlı dinlenir. Aktif salon bilinmiyorsa (test ortamı vb.) boş
/// bir doküman gösterilir.
///
/// Copied from [GymRulesController].
@ProviderFor(GymRulesController)
final gymRulesControllerProvider =
    AutoDisposeNotifierProvider<GymRulesController, GymRules>.internal(
      GymRulesController.new,
      name: r'gymRulesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gymRulesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GymRulesController = AutoDisposeNotifier<GymRules>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
