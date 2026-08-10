// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_events_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventsForGymHash() => r'b4d1c5d60c52303fa2a6f7abd3fd3b72ef93fcff';

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

/// See also [_eventsForGym].
@ProviderFor(_eventsForGym)
const _eventsForGymProvider = _EventsForGymFamily();

/// See also [_eventsForGym].
class _EventsForGymFamily extends Family<AsyncValue<List<GymEvent>>> {
  /// See also [_eventsForGym].
  const _EventsForGymFamily();

  /// See also [_eventsForGym].
  _EventsForGymProvider call(String gymId) {
    return _EventsForGymProvider(gymId);
  }

  @override
  _EventsForGymProvider getProviderOverride(
    covariant _EventsForGymProvider provider,
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
  String? get name => r'_eventsForGymProvider';
}

/// See also [_eventsForGym].
class _EventsForGymProvider extends AutoDisposeStreamProvider<List<GymEvent>> {
  /// See also [_eventsForGym].
  _EventsForGymProvider(String gymId)
    : this._internal(
        (ref) => _eventsForGym(ref as _EventsForGymRef, gymId),
        from: _eventsForGymProvider,
        name: r'_eventsForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$eventsForGymHash,
        dependencies: _EventsForGymFamily._dependencies,
        allTransitiveDependencies:
            _EventsForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _EventsForGymProvider._internal(
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
    Stream<List<GymEvent>> Function(_EventsForGymRef provider) create,
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
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<GymEvent>> createElement() {
    return _EventsForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _EventsForGymProvider && other.gymId == gymId;
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
mixin _EventsForGymRef on AutoDisposeStreamProviderRef<List<GymEvent>> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _EventsForGymProviderElement
    extends AutoDisposeStreamProviderElement<List<GymEvent>>
    with _EventsForGymRef {
  _EventsForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _EventsForGymProvider).gymId;
}

String _$gymEventsControllerHash() =>
    r'388c9883ae35aa8c628bd28f5cd7aefdd808a8f5';

/// F4-3 — salonun ileri tarihli, gerçek zamanlı etkinlikleri.
///
/// Copied from [GymEventsController].
@ProviderFor(GymEventsController)
final gymEventsControllerProvider =
    AutoDisposeNotifierProvider<GymEventsController, List<GymEvent>>.internal(
      GymEventsController.new,
      name: r'gymEventsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gymEventsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GymEventsController = AutoDisposeNotifier<List<GymEvent>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
