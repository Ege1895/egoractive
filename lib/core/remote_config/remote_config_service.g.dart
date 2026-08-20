// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$remoteConfigServiceHash() =>
    r'a9245fdeca4cc28dfe0cce99f11d2694a1a32b98';

/// See also [remoteConfigService].
@ProviderFor(remoteConfigService)
final remoteConfigServiceProvider = Provider<RemoteConfigService>.internal(
  remoteConfigService,
  name: r'remoteConfigServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$remoteConfigServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RemoteConfigServiceRef = ProviderRef<RemoteConfigService>;
String _$rcTextHash() => r'e8ef1f8ab624d037efc48429ef5b89680a048174';

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

/// Bir `lbl*` taban anahtarını aktif dile göre reaktif olarak çözer — bu
/// provider'ı `watch` eden her widget, [localeControllerProvider] değişince
/// otomatik yeniden çizilir (bkz. CLAUDE.md §2.5, `lbl*` metinleri).
///
/// Copied from [rcText].
@ProviderFor(rcText)
const rcTextProvider = RcTextFamily();

/// Bir `lbl*` taban anahtarını aktif dile göre reaktif olarak çözer — bu
/// provider'ı `watch` eden her widget, [localeControllerProvider] değişince
/// otomatik yeniden çizilir (bkz. CLAUDE.md §2.5, `lbl*` metinleri).
///
/// Copied from [rcText].
class RcTextFamily extends Family<String> {
  /// Bir `lbl*` taban anahtarını aktif dile göre reaktif olarak çözer — bu
  /// provider'ı `watch` eden her widget, [localeControllerProvider] değişince
  /// otomatik yeniden çizilir (bkz. CLAUDE.md §2.5, `lbl*` metinleri).
  ///
  /// Copied from [rcText].
  const RcTextFamily();

  /// Bir `lbl*` taban anahtarını aktif dile göre reaktif olarak çözer — bu
  /// provider'ı `watch` eden her widget, [localeControllerProvider] değişince
  /// otomatik yeniden çizilir (bkz. CLAUDE.md §2.5, `lbl*` metinleri).
  ///
  /// Copied from [rcText].
  RcTextProvider call(String baseKey) {
    return RcTextProvider(baseKey);
  }

  @override
  RcTextProvider getProviderOverride(covariant RcTextProvider provider) {
    return call(provider.baseKey);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'rcTextProvider';
}

/// Bir `lbl*` taban anahtarını aktif dile göre reaktif olarak çözer — bu
/// provider'ı `watch` eden her widget, [localeControllerProvider] değişince
/// otomatik yeniden çizilir (bkz. CLAUDE.md §2.5, `lbl*` metinleri).
///
/// Copied from [rcText].
class RcTextProvider extends AutoDisposeProvider<String> {
  /// Bir `lbl*` taban anahtarını aktif dile göre reaktif olarak çözer — bu
  /// provider'ı `watch` eden her widget, [localeControllerProvider] değişince
  /// otomatik yeniden çizilir (bkz. CLAUDE.md §2.5, `lbl*` metinleri).
  ///
  /// Copied from [rcText].
  RcTextProvider(String baseKey)
    : this._internal(
        (ref) => rcText(ref as RcTextRef, baseKey),
        from: rcTextProvider,
        name: r'rcTextProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$rcTextHash,
        dependencies: RcTextFamily._dependencies,
        allTransitiveDependencies: RcTextFamily._allTransitiveDependencies,
        baseKey: baseKey,
      );

  RcTextProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.baseKey,
  }) : super.internal();

  final String baseKey;

  @override
  Override overrideWith(String Function(RcTextRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: RcTextProvider._internal(
        (ref) => create(ref as RcTextRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        baseKey: baseKey,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _RcTextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RcTextProvider && other.baseKey == baseKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, baseKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RcTextRef on AutoDisposeProviderRef<String> {
  /// The parameter `baseKey` of this provider.
  String get baseKey;
}

class _RcTextProviderElement extends AutoDisposeProviderElement<String>
    with RcTextRef {
  _RcTextProviderElement(super.provider);

  @override
  String get baseKey => (origin as RcTextProvider).baseKey;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
