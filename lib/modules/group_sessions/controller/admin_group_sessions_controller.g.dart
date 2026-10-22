// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_group_sessions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupSessionsForGymHash() =>
    r'b9708051d1072cf446666a0b5e946b954ca1c534';

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
    extends Family<AsyncValue<List<AdminGroupSession>>> {
  /// See also [_groupSessionsForGym].
  const _GroupSessionsForGymFamily();

  /// See also [_groupSessionsForGym].
  _GroupSessionsForGymProvider call(String gymId) {
    return _GroupSessionsForGymProvider(gymId);
  }

  @override
  _GroupSessionsForGymProvider getProviderOverride(
    covariant _GroupSessionsForGymProvider provider,
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
  String? get name => r'_groupSessionsForGymProvider';
}

/// See also [_groupSessionsForGym].
class _GroupSessionsForGymProvider
    extends AutoDisposeStreamProvider<List<AdminGroupSession>> {
  /// See also [_groupSessionsForGym].
  _GroupSessionsForGymProvider(String gymId)
    : this._internal(
        (ref) => _groupSessionsForGym(ref as _GroupSessionsForGymRef, gymId),
        from: _groupSessionsForGymProvider,
        name: r'_groupSessionsForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupSessionsForGymHash,
        dependencies: _GroupSessionsForGymFamily._dependencies,
        allTransitiveDependencies:
            _GroupSessionsForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _GroupSessionsForGymProvider._internal(
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
    Stream<List<AdminGroupSession>> Function(_GroupSessionsForGymRef provider)
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
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AdminGroupSession>> createElement() {
    return _GroupSessionsForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _GroupSessionsForGymProvider && other.gymId == gymId;
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
mixin _GroupSessionsForGymRef
    on AutoDisposeStreamProviderRef<List<AdminGroupSession>> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _GroupSessionsForGymProviderElement
    extends AutoDisposeStreamProviderElement<List<AdminGroupSession>>
    with _GroupSessionsForGymRef {
  _GroupSessionsForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _GroupSessionsForGymProvider).gymId;
}

String _$adminGroupSessionsControllerHash() =>
    r'4c85be2459376a1862371ab06d5d9727d9232311';

/// F4-2 — salonun ileri tarihli, gerçek zamanlı grup dersleri.
///
/// Copied from [AdminGroupSessionsController].
@ProviderFor(AdminGroupSessionsController)
final adminGroupSessionsControllerProvider =
    AutoDisposeNotifierProvider<
      AdminGroupSessionsController,
      List<AdminGroupSession>
    >.internal(
      AdminGroupSessionsController.new,
      name: r'adminGroupSessionsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminGroupSessionsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminGroupSessionsController =
    AutoDisposeNotifier<List<AdminGroupSession>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
