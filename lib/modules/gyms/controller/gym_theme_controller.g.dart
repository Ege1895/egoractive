// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeStateForGymHash() => r'ef79f8f5cd4cecf26fd9aa02ce5c1bb3f0bdf238';

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

/// See also [_themeStateForGym].
@ProviderFor(_themeStateForGym)
const _themeStateForGymProvider = _ThemeStateForGymFamily();

/// See also [_themeStateForGym].
class _ThemeStateForGymFamily extends Family<AsyncValue<GymThemeState>> {
  /// See also [_themeStateForGym].
  const _ThemeStateForGymFamily();

  /// See also [_themeStateForGym].
  _ThemeStateForGymProvider call(String gymId) {
    return _ThemeStateForGymProvider(gymId);
  }

  @override
  _ThemeStateForGymProvider getProviderOverride(
    covariant _ThemeStateForGymProvider provider,
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
  String? get name => r'_themeStateForGymProvider';
}

/// See also [_themeStateForGym].
class _ThemeStateForGymProvider
    extends AutoDisposeStreamProvider<GymThemeState> {
  /// See also [_themeStateForGym].
  _ThemeStateForGymProvider(String gymId)
    : this._internal(
        (ref) => _themeStateForGym(ref as _ThemeStateForGymRef, gymId),
        from: _themeStateForGymProvider,
        name: r'_themeStateForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$themeStateForGymHash,
        dependencies: _ThemeStateForGymFamily._dependencies,
        allTransitiveDependencies:
            _ThemeStateForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _ThemeStateForGymProvider._internal(
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
    Stream<GymThemeState> Function(_ThemeStateForGymRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _ThemeStateForGymProvider._internal(
        (ref) => create(ref as _ThemeStateForGymRef),
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
  AutoDisposeStreamProviderElement<GymThemeState> createElement() {
    return _ThemeStateForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _ThemeStateForGymProvider && other.gymId == gymId;
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
mixin _ThemeStateForGymRef on AutoDisposeStreamProviderRef<GymThemeState> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _ThemeStateForGymProviderElement
    extends AutoDisposeStreamProviderElement<GymThemeState>
    with _ThemeStateForGymRef {
  _ThemeStateForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _ThemeStateForGymProvider).gymId;
}

String _$gymThemeControllerHash() =>
    r'de63452d90869510e228ae2403be33a374d7a856';

/// F4-6 — `gyms/{gymId}.themeColors`/`themePresets`, `ThemeController`
/// (F1-6) tarafından zaten stream olarak dinleniyor; buradaki yazmalar
/// sayesinde bir değişiklik, uygulamayı yeniden başlatmadan tüm aktif
/// client'larda anlık yansır (kabul kriteri).
///
/// Copied from [GymThemeController].
@ProviderFor(GymThemeController)
final gymThemeControllerProvider =
    AutoDisposeNotifierProvider<GymThemeController, GymThemeState>.internal(
      GymThemeController.new,
      name: r'gymThemeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gymThemeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GymThemeController = AutoDisposeNotifier<GymThemeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
