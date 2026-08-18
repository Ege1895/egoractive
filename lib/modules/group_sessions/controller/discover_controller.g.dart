// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupSessionsForGymHash() =>
    r'3156fbbdd5e6dc62b65dba112372fe434a55b584';

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

/// See also [_groupSessionsForGym].
@ProviderFor(_groupSessionsForGym)
const _groupSessionsForGymProvider = _GroupSessionsForGymFamily();

/// See also [_groupSessionsForGym].
class _GroupSessionsForGymFamily
    extends Family<AsyncValue<List<DiscoverItem>>> {
  /// See also [_groupSessionsForGym].
  const _GroupSessionsForGymFamily();

  /// See also [_groupSessionsForGym].
  _GroupSessionsForGymProvider call(String gymId, String myUid) {
    return _GroupSessionsForGymProvider(gymId, myUid);
  }

  @override
  _GroupSessionsForGymProvider getProviderOverride(
    covariant _GroupSessionsForGymProvider provider,
  ) {
    return call(provider.gymId, provider.myUid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_groupSessionsForGymProvider';
}

/// See also [_groupSessionsForGym].
class _GroupSessionsForGymProvider
    extends AutoDisposeStreamProvider<List<DiscoverItem>> {
  /// See also [_groupSessionsForGym].
  _GroupSessionsForGymProvider(String gymId, String myUid)
    : this._internal(
        (ref) =>
            _groupSessionsForGym(ref as _GroupSessionsForGymRef, gymId, myUid),
        from: _groupSessionsForGymProvider,
        name: r'_groupSessionsForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupSessionsForGymHash,
        dependencies: _GroupSessionsForGymFamily._dependencies,
        allTransitiveDependencies:
            _GroupSessionsForGymFamily._allTransitiveDependencies,
        gymId: gymId,
        myUid: myUid,
      );

  _GroupSessionsForGymProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gymId,
    required this.myUid,
  }) : super.internal();

  final String gymId;
  final String myUid;

  @override
  Override overrideWith(
    Stream<List<DiscoverItem>> Function(_GroupSessionsForGymRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _GroupSessionsForGymProvider._internal(
        (ref) => create(ref as _GroupSessionsForGymRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gymId: gymId,
        myUid: myUid,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<DiscoverItem>> createElement() {
    return _GroupSessionsForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _GroupSessionsForGymProvider &&
        other.gymId == gymId &&
        other.myUid == myUid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gymId.hashCode);
    hash = _SystemHash.combine(hash, myUid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _GroupSessionsForGymRef
    on AutoDisposeStreamProviderRef<List<DiscoverItem>> {
  /// The parameter `gymId` of this provider.
  String get gymId;

  /// The parameter `myUid` of this provider.
  String get myUid;
}

class _GroupSessionsForGymProviderElement
    extends AutoDisposeStreamProviderElement<List<DiscoverItem>>
    with _GroupSessionsForGymRef {
  _GroupSessionsForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _GroupSessionsForGymProvider).gymId;
  @override
  String get myUid => (origin as _GroupSessionsForGymProvider).myUid;
}

String _$eventsForGymHash() => r'4873549f21c61b0dcb82f792106fd06a71af1d39';

/// See also [_eventsForGym].
@ProviderFor(_eventsForGym)
const _eventsForGymProvider = _EventsForGymFamily();

/// See also [_eventsForGym].
class _EventsForGymFamily extends Family<AsyncValue<List<DiscoverItem>>> {
  /// See also [_eventsForGym].
  const _EventsForGymFamily();

  /// See also [_eventsForGym].
  _EventsForGymProvider call(String gymId, String myUid) {
    return _EventsForGymProvider(gymId, myUid);
  }

  @override
  _EventsForGymProvider getProviderOverride(
    covariant _EventsForGymProvider provider,
  ) {
    return call(provider.gymId, provider.myUid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_eventsForGymProvider';
}

/// See also [_eventsForGym].
class _EventsForGymProvider
    extends AutoDisposeStreamProvider<List<DiscoverItem>> {
  /// See also [_eventsForGym].
  _EventsForGymProvider(String gymId, String myUid)
    : this._internal(
        (ref) => _eventsForGym(ref as _EventsForGymRef, gymId, myUid),
        from: _eventsForGymProvider,
        name: r'_eventsForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$eventsForGymHash,
        dependencies: _EventsForGymFamily._dependencies,
        allTransitiveDependencies:
            _EventsForGymFamily._allTransitiveDependencies,
        gymId: gymId,
        myUid: myUid,
      );

  _EventsForGymProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gymId,
    required this.myUid,
  }) : super.internal();

  final String gymId;
  final String myUid;

  @override
  Override overrideWith(
    Stream<List<DiscoverItem>> Function(_EventsForGymRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _EventsForGymProvider._internal(
        (ref) => create(ref as _EventsForGymRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gymId: gymId,
        myUid: myUid,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<DiscoverItem>> createElement() {
    return _EventsForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _EventsForGymProvider &&
        other.gymId == gymId &&
        other.myUid == myUid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gymId.hashCode);
    hash = _SystemHash.combine(hash, myUid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _EventsForGymRef on AutoDisposeStreamProviderRef<List<DiscoverItem>> {
  /// The parameter `gymId` of this provider.
  String get gymId;

  /// The parameter `myUid` of this provider.
  String get myUid;
}

class _EventsForGymProviderElement
    extends AutoDisposeStreamProviderElement<List<DiscoverItem>>
    with _EventsForGymRef {
  _EventsForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _EventsForGymProvider).gymId;
  @override
  String get myUid => (origin as _EventsForGymProvider).myUid;
}

String _$discoverControllerHash() =>
    r'f3e1bbd2fc4dfc6e99f52a891c97b4852205d0f3';

/// F4-2/F4-3 — üyenin salonunda ileri tarihli, gerçek zamanlı grup dersleri
/// ve etkinlikler. Kontenjan katılım/ayrılma her iki kategori için de
/// `CapacityService` üzerinden ortak mantıkla yapılır.
///
/// Copied from [DiscoverController].
@ProviderFor(DiscoverController)
final discoverControllerProvider =
    AutoDisposeNotifierProvider<
      DiscoverController,
      List<DiscoverItem>
    >.internal(
      DiscoverController.new,
      name: r'discoverControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$discoverControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DiscoverController = AutoDisposeNotifier<List<DiscoverItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
