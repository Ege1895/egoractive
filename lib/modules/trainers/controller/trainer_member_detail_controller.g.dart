// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_member_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trainerDetailStreamForIdHash() =>
    r'cf435e6c34cb7e4b9429430d82342626ff7ee794';

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

/// See also [_trainerDetailStreamForId].
@ProviderFor(_trainerDetailStreamForId)
const _trainerDetailStreamForIdProvider = _TrainerDetailStreamForIdFamily();

/// See also [_trainerDetailStreamForId].
class _TrainerDetailStreamForIdFamily
    extends Family<AsyncValue<TrainerMemberDetail>> {
  /// See also [_trainerDetailStreamForId].
  const _TrainerDetailStreamForIdFamily();

  /// See also [_trainerDetailStreamForId].
  _TrainerDetailStreamForIdProvider call(String memberId) {
    return _TrainerDetailStreamForIdProvider(memberId);
  }

  @override
  _TrainerDetailStreamForIdProvider getProviderOverride(
    covariant _TrainerDetailStreamForIdProvider provider,
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
  String? get name => r'_trainerDetailStreamForIdProvider';
}

/// See also [_trainerDetailStreamForId].
class _TrainerDetailStreamForIdProvider
    extends AutoDisposeStreamProvider<TrainerMemberDetail> {
  /// See also [_trainerDetailStreamForId].
  _TrainerDetailStreamForIdProvider(String memberId)
    : this._internal(
        (ref) => _trainerDetailStreamForId(
          ref as _TrainerDetailStreamForIdRef,
          memberId,
        ),
        from: _trainerDetailStreamForIdProvider,
        name: r'_trainerDetailStreamForIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainerDetailStreamForIdHash,
        dependencies: _TrainerDetailStreamForIdFamily._dependencies,
        allTransitiveDependencies:
            _TrainerDetailStreamForIdFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _TrainerDetailStreamForIdProvider._internal(
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
    Stream<TrainerMemberDetail> Function(_TrainerDetailStreamForIdRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _TrainerDetailStreamForIdProvider._internal(
        (ref) => create(ref as _TrainerDetailStreamForIdRef),
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
  AutoDisposeStreamProviderElement<TrainerMemberDetail> createElement() {
    return _TrainerDetailStreamForIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _TrainerDetailStreamForIdProvider &&
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
mixin _TrainerDetailStreamForIdRef
    on AutoDisposeStreamProviderRef<TrainerMemberDetail> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _TrainerDetailStreamForIdProviderElement
    extends AutoDisposeStreamProviderElement<TrainerMemberDetail>
    with _TrainerDetailStreamForIdRef {
  _TrainerDetailStreamForIdProviderElement(super.provider);

  @override
  String get memberId => (origin as _TrainerDetailStreamForIdProvider).memberId;
}

String _$trainerMemberDetailControllerHash() =>
    r'c241b6937635296a745c1e31e13bbb8a16e9354c';

abstract class _$TrainerMemberDetailController
    extends BuildlessAutoDisposeNotifier<TrainerMemberDetail> {
  late final String memberId;

  TrainerMemberDetail build(String memberId);
}

/// See also [TrainerMemberDetailController].
@ProviderFor(TrainerMemberDetailController)
const trainerMemberDetailControllerProvider =
    TrainerMemberDetailControllerFamily();

/// See also [TrainerMemberDetailController].
class TrainerMemberDetailControllerFamily extends Family<TrainerMemberDetail> {
  /// See also [TrainerMemberDetailController].
  const TrainerMemberDetailControllerFamily();

  /// See also [TrainerMemberDetailController].
  TrainerMemberDetailControllerProvider call(String memberId) {
    return TrainerMemberDetailControllerProvider(memberId);
  }

  @override
  TrainerMemberDetailControllerProvider getProviderOverride(
    covariant TrainerMemberDetailControllerProvider provider,
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
  String? get name => r'trainerMemberDetailControllerProvider';
}

/// See also [TrainerMemberDetailController].
class TrainerMemberDetailControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          TrainerMemberDetailController,
          TrainerMemberDetail
        > {
  /// See also [TrainerMemberDetailController].
  TrainerMemberDetailControllerProvider(String memberId)
    : this._internal(
        () => TrainerMemberDetailController()..memberId = memberId,
        from: trainerMemberDetailControllerProvider,
        name: r'trainerMemberDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainerMemberDetailControllerHash,
        dependencies: TrainerMemberDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            TrainerMemberDetailControllerFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  TrainerMemberDetailControllerProvider._internal(
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
  TrainerMemberDetail runNotifierBuild(
    covariant TrainerMemberDetailController notifier,
  ) {
    return notifier.build(memberId);
  }

  @override
  Override overrideWith(TrainerMemberDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: TrainerMemberDetailControllerProvider._internal(
        () => create()..memberId = memberId,
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
  AutoDisposeNotifierProviderElement<
    TrainerMemberDetailController,
    TrainerMemberDetail
  >
  createElement() {
    return _TrainerMemberDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrainerMemberDetailControllerProvider &&
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
mixin TrainerMemberDetailControllerRef
    on AutoDisposeNotifierProviderRef<TrainerMemberDetail> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _TrainerMemberDetailControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          TrainerMemberDetailController,
          TrainerMemberDetail
        >
    with TrainerMemberDetailControllerRef {
  _TrainerMemberDetailControllerProviderElement(super.provider);

  @override
  String get memberId =>
      (origin as TrainerMemberDetailControllerProvider).memberId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
