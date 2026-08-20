// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memberDocForIdHash() => r'a8aa8ae04cf3d97817320c8909ffa99dc7c6bbe9';

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

/// See also [_memberDocForId].
@ProviderFor(_memberDocForId)
const _memberDocForIdProvider = _MemberDocForIdFamily();

/// See also [_memberDocForId].
class _MemberDocForIdFamily extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [_memberDocForId].
  const _MemberDocForIdFamily();

  /// See also [_memberDocForId].
  _MemberDocForIdProvider call(String memberId) {
    return _MemberDocForIdProvider(memberId);
  }

  @override
  _MemberDocForIdProvider getProviderOverride(
    covariant _MemberDocForIdProvider provider,
  ) {
    return call(provider.memberId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_memberDocForIdProvider';
}

/// See also [_memberDocForId].
class _MemberDocForIdProvider
    extends AutoDisposeStreamProvider<Map<String, dynamic>?> {
  /// See also [_memberDocForId].
  _MemberDocForIdProvider(String memberId)
    : this._internal(
        (ref) => _memberDocForId(ref as _MemberDocForIdRef, memberId),
        from: _memberDocForIdProvider,
        name: r'_memberDocForIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$memberDocForIdHash,
        dependencies: _MemberDocForIdFamily._dependencies,
        allTransitiveDependencies:
            _MemberDocForIdFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _MemberDocForIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memberId,
  }) : super.internal();

  final String memberId;

  @override
  Override overrideWith(
    Stream<Map<String, dynamic>?> Function(_MemberDocForIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _MemberDocForIdProvider._internal(
        (ref) => create(ref as _MemberDocForIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memberId: memberId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Map<String, dynamic>?> createElement() {
    return _MemberDocForIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _MemberDocForIdProvider && other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _MemberDocForIdRef
    on AutoDisposeStreamProviderRef<Map<String, dynamic>?> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _MemberDocForIdProviderElement
    extends AutoDisposeStreamProviderElement<Map<String, dynamic>?>
    with _MemberDocForIdRef {
  _MemberDocForIdProviderElement(super.provider);

  @override
  String get memberId => (origin as _MemberDocForIdProvider).memberId;
}

String _$latestPackageDocForIdHash() =>
    r'd30e1f008c6abd58bf54fb232569d047f9434fad';

/// See also [_latestPackageDocForId].
@ProviderFor(_latestPackageDocForId)
const _latestPackageDocForIdProvider = _LatestPackageDocForIdFamily();

/// See also [_latestPackageDocForId].
class _LatestPackageDocForIdFamily
    extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [_latestPackageDocForId].
  const _LatestPackageDocForIdFamily();

  /// See also [_latestPackageDocForId].
  _LatestPackageDocForIdProvider call(String memberId) {
    return _LatestPackageDocForIdProvider(memberId);
  }

  @override
  _LatestPackageDocForIdProvider getProviderOverride(
    covariant _LatestPackageDocForIdProvider provider,
  ) {
    return call(provider.memberId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_latestPackageDocForIdProvider';
}

/// See also [_latestPackageDocForId].
class _LatestPackageDocForIdProvider
    extends AutoDisposeStreamProvider<Map<String, dynamic>?> {
  /// See also [_latestPackageDocForId].
  _LatestPackageDocForIdProvider(String memberId)
    : this._internal(
        (ref) =>
            _latestPackageDocForId(ref as _LatestPackageDocForIdRef, memberId),
        from: _latestPackageDocForIdProvider,
        name: r'_latestPackageDocForIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$latestPackageDocForIdHash,
        dependencies: _LatestPackageDocForIdFamily._dependencies,
        allTransitiveDependencies:
            _LatestPackageDocForIdFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _LatestPackageDocForIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memberId,
  }) : super.internal();

  final String memberId;

  @override
  Override overrideWith(
    Stream<Map<String, dynamic>?> Function(_LatestPackageDocForIdRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _LatestPackageDocForIdProvider._internal(
        (ref) => create(ref as _LatestPackageDocForIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memberId: memberId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Map<String, dynamic>?> createElement() {
    return _LatestPackageDocForIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _LatestPackageDocForIdProvider &&
        other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _LatestPackageDocForIdRef
    on AutoDisposeStreamProviderRef<Map<String, dynamic>?> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _LatestPackageDocForIdProviderElement
    extends AutoDisposeStreamProviderElement<Map<String, dynamic>?>
    with _LatestPackageDocForIdRef {
  _LatestPackageDocForIdProviderElement(super.provider);

  @override
  String get memberId => (origin as _LatestPackageDocForIdProvider).memberId;
}

String _$trainerSpecialtyForIdHash() =>
    r'582c4c591f2020d91febb51db6c1346f07270ed6';

/// See also [_trainerSpecialtyForId].
@ProviderFor(_trainerSpecialtyForId)
const _trainerSpecialtyForIdProvider = _TrainerSpecialtyForIdFamily();

/// See also [_trainerSpecialtyForId].
class _TrainerSpecialtyForIdFamily extends Family<AsyncValue<String>> {
  /// See also [_trainerSpecialtyForId].
  const _TrainerSpecialtyForIdFamily();

  /// See also [_trainerSpecialtyForId].
  _TrainerSpecialtyForIdProvider call(String trainerId) {
    return _TrainerSpecialtyForIdProvider(trainerId);
  }

  @override
  _TrainerSpecialtyForIdProvider getProviderOverride(
    covariant _TrainerSpecialtyForIdProvider provider,
  ) {
    return call(provider.trainerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_trainerSpecialtyForIdProvider';
}

/// See also [_trainerSpecialtyForId].
class _TrainerSpecialtyForIdProvider extends AutoDisposeFutureProvider<String> {
  /// See also [_trainerSpecialtyForId].
  _TrainerSpecialtyForIdProvider(String trainerId)
    : this._internal(
        (ref) =>
            _trainerSpecialtyForId(ref as _TrainerSpecialtyForIdRef, trainerId),
        from: _trainerSpecialtyForIdProvider,
        name: r'_trainerSpecialtyForIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainerSpecialtyForIdHash,
        dependencies: _TrainerSpecialtyForIdFamily._dependencies,
        allTransitiveDependencies:
            _TrainerSpecialtyForIdFamily._allTransitiveDependencies,
        trainerId: trainerId,
      );

  _TrainerSpecialtyForIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.trainerId,
  }) : super.internal();

  final String trainerId;

  @override
  Override overrideWith(
    FutureOr<String> Function(_TrainerSpecialtyForIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _TrainerSpecialtyForIdProvider._internal(
        (ref) => create(ref as _TrainerSpecialtyForIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        trainerId: trainerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _TrainerSpecialtyForIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _TrainerSpecialtyForIdProvider &&
        other.trainerId == trainerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, trainerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _TrainerSpecialtyForIdRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `trainerId` of this provider.
  String get trainerId;
}

class _TrainerSpecialtyForIdProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with _TrainerSpecialtyForIdRef {
  _TrainerSpecialtyForIdProviderElement(super.provider);

  @override
  String get trainerId => (origin as _TrainerSpecialtyForIdProvider).trainerId;
}

String _$packageControllerHash() => r'38514083e975e1ee04904f4d49d6a75628d0f9dc';

/// Üye 4 · Paketim. Oturum yoksa (test ortamı vb.) boş bir paket gösterir.
///
/// Copied from [PackageController].
@ProviderFor(PackageController)
final packageControllerProvider =
    AutoDisposeNotifierProvider<PackageController, MemberPackage>.internal(
      PackageController.new,
      name: r'packageControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$packageControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PackageController = AutoDisposeNotifier<MemberPackage>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
