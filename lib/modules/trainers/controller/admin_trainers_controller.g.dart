// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_trainers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trainerDocsForGymHash() => r'4093dc80a28d8b90d956507a8578408cde9606b4';

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

/// See also [_trainerDocsForGym].
@ProviderFor(_trainerDocsForGym)
const _trainerDocsForGymProvider = _TrainerDocsForGymFamily();

/// See also [_trainerDocsForGym].
class _TrainerDocsForGymFamily
    extends
        Family<AsyncValue<List<QueryDocumentSnapshot<Map<String, dynamic>>>>> {
  /// See also [_trainerDocsForGym].
  const _TrainerDocsForGymFamily();

  /// See also [_trainerDocsForGym].
  _TrainerDocsForGymProvider call(String gymId) {
    return _TrainerDocsForGymProvider(gymId);
  }

  @override
  _TrainerDocsForGymProvider getProviderOverride(
    covariant _TrainerDocsForGymProvider provider,
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
  String? get name => r'_trainerDocsForGymProvider';
}

/// See also [_trainerDocsForGym].
class _TrainerDocsForGymProvider
    extends
        AutoDisposeStreamProvider<
          List<QueryDocumentSnapshot<Map<String, dynamic>>>
        > {
  /// See also [_trainerDocsForGym].
  _TrainerDocsForGymProvider(String gymId)
    : this._internal(
        (ref) => _trainerDocsForGym(ref as _TrainerDocsForGymRef, gymId),
        from: _trainerDocsForGymProvider,
        name: r'_trainerDocsForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainerDocsForGymHash,
        dependencies: _TrainerDocsForGymFamily._dependencies,
        allTransitiveDependencies:
            _TrainerDocsForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _TrainerDocsForGymProvider._internal(
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
    Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> Function(
      _TrainerDocsForGymRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _TrainerDocsForGymProvider._internal(
        (ref) => create(ref as _TrainerDocsForGymRef),
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
  AutoDisposeStreamProviderElement<
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
  >
  createElement() {
    return _TrainerDocsForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _TrainerDocsForGymProvider && other.gymId == gymId;
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
mixin _TrainerDocsForGymRef
    on
        AutoDisposeStreamProviderRef<
          List<QueryDocumentSnapshot<Map<String, dynamic>>>
        > {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _TrainerDocsForGymProviderElement
    extends
        AutoDisposeStreamProviderElement<
          List<QueryDocumentSnapshot<Map<String, dynamic>>>
        >
    with _TrainerDocsForGymRef {
  _TrainerDocsForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _TrainerDocsForGymProvider).gymId;
}

String _$adminTrainersControllerHash() =>
    r'f9938bc265082acbaea5918abc5ee7fa354c8b7a';

/// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz — bu
/// durumda [AdminTrainersController] mock listeye düşer (bkz.
/// [AdminMembersController]'daki aynı desen).
///
/// Copied from [AdminTrainersController].
@ProviderFor(AdminTrainersController)
final adminTrainersControllerProvider =
    AutoDisposeNotifierProvider<
      AdminTrainersController,
      List<AdminTrainerSummary>
    >.internal(
      AdminTrainersController.new,
      name: r'adminTrainersControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminTrainersControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminTrainersController =
    AutoDisposeNotifier<List<AdminTrainerSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
