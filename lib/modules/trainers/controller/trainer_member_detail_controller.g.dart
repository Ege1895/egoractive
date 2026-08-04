// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_member_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trainerMemberDetailControllerHash() =>
    r'f63af0ce81e6f23915bad3e3b64fc0e5f555ff46';

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
