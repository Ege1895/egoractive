// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$confirmationsForTrainerHash() =>
    r'02b31862e35e1eb59e2ac81ed9c2e189b9f4ecb0';

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

/// See also [_confirmationsForTrainer].
@ProviderFor(_confirmationsForTrainer)
const _confirmationsForTrainerProvider = _ConfirmationsForTrainerFamily();

/// See also [_confirmationsForTrainer].
class _ConfirmationsForTrainerFamily
    extends Family<AsyncValue<List<TrainerNotification>>> {
  /// See also [_confirmationsForTrainer].
  const _ConfirmationsForTrainerFamily();

  /// See also [_confirmationsForTrainer].
  _ConfirmationsForTrainerProvider call(String trainerId) {
    return _ConfirmationsForTrainerProvider(trainerId);
  }

  @override
  _ConfirmationsForTrainerProvider getProviderOverride(
    covariant _ConfirmationsForTrainerProvider provider,
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
  String? get name => r'_confirmationsForTrainerProvider';
}

/// See also [_confirmationsForTrainer].
class _ConfirmationsForTrainerProvider
    extends AutoDisposeStreamProvider<List<TrainerNotification>> {
  /// See also [_confirmationsForTrainer].
  _ConfirmationsForTrainerProvider(String trainerId)
    : this._internal(
        (ref) => _confirmationsForTrainer(
          ref as _ConfirmationsForTrainerRef,
          trainerId,
        ),
        from: _confirmationsForTrainerProvider,
        name: r'_confirmationsForTrainerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$confirmationsForTrainerHash,
        dependencies: _ConfirmationsForTrainerFamily._dependencies,
        allTransitiveDependencies:
            _ConfirmationsForTrainerFamily._allTransitiveDependencies,
        trainerId: trainerId,
      );

  _ConfirmationsForTrainerProvider._internal(
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
    Stream<List<TrainerNotification>> Function(
      _ConfirmationsForTrainerRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _ConfirmationsForTrainerProvider._internal(
        (ref) => create(ref as _ConfirmationsForTrainerRef),
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
  AutoDisposeStreamProviderElement<List<TrainerNotification>> createElement() {
    return _ConfirmationsForTrainerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _ConfirmationsForTrainerProvider &&
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
mixin _ConfirmationsForTrainerRef
    on AutoDisposeStreamProviderRef<List<TrainerNotification>> {
  /// The parameter `trainerId` of this provider.
  String get trainerId;
}

class _ConfirmationsForTrainerProviderElement
    extends AutoDisposeStreamProviderElement<List<TrainerNotification>>
    with _ConfirmationsForTrainerRef {
  _ConfirmationsForTrainerProviderElement(super.provider);

  @override
  String get trainerId =>
      (origin as _ConfirmationsForTrainerProvider).trainerId;
}

String _$trainerNotificationsControllerHash() =>
    r'9479d38e3b1a0a872420c01d2a128bffdc3f56c4';

/// Antrenörün kendi (`trainerId == uid`) seanslarına üyelerin verdiği
/// gelecek/gelmeyecek yanıtları gerçek zamanlı dinlenir. Oturum yoksa (test
/// ortamı vb.) mock repository'e düşer.
///
/// Copied from [TrainerNotificationsController].
@ProviderFor(TrainerNotificationsController)
final trainerNotificationsControllerProvider =
    AutoDisposeNotifierProvider<
      TrainerNotificationsController,
      List<TrainerNotification>
    >.internal(
      TrainerNotificationsController.new,
      name: r'trainerNotificationsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trainerNotificationsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TrainerNotificationsController =
    AutoDisposeNotifier<List<TrainerNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
