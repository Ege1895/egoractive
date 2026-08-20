// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trainerProfileDocForUidHash() =>
    r'18cf7af3a6ee9f1346752c1def8a1e8830759c35';

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

/// See also [_trainerProfileDocForUid].
@ProviderFor(_trainerProfileDocForUid)
const _trainerProfileDocForUidProvider = _TrainerProfileDocForUidFamily();

/// See also [_trainerProfileDocForUid].
class _TrainerProfileDocForUidFamily
    extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [_trainerProfileDocForUid].
  const _TrainerProfileDocForUidFamily();

  /// See also [_trainerProfileDocForUid].
  _TrainerProfileDocForUidProvider call(String uid) {
    return _TrainerProfileDocForUidProvider(uid);
  }

  @override
  _TrainerProfileDocForUidProvider getProviderOverride(
    covariant _TrainerProfileDocForUidProvider provider,
  ) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_trainerProfileDocForUidProvider';
}

/// See also [_trainerProfileDocForUid].
class _TrainerProfileDocForUidProvider
    extends AutoDisposeStreamProvider<Map<String, dynamic>?> {
  /// See also [_trainerProfileDocForUid].
  _TrainerProfileDocForUidProvider(String uid)
    : this._internal(
        (ref) =>
            _trainerProfileDocForUid(ref as _TrainerProfileDocForUidRef, uid),
        from: _trainerProfileDocForUidProvider,
        name: r'_trainerProfileDocForUidProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainerProfileDocForUidHash,
        dependencies: _TrainerProfileDocForUidFamily._dependencies,
        allTransitiveDependencies:
            _TrainerProfileDocForUidFamily._allTransitiveDependencies,
        uid: uid,
      );

  _TrainerProfileDocForUidProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    Stream<Map<String, dynamic>?> Function(_TrainerProfileDocForUidRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _TrainerProfileDocForUidProvider._internal(
        (ref) => create(ref as _TrainerProfileDocForUidRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Map<String, dynamic>?> createElement() {
    return _TrainerProfileDocForUidProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _TrainerProfileDocForUidProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _TrainerProfileDocForUidRef
    on AutoDisposeStreamProviderRef<Map<String, dynamic>?> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _TrainerProfileDocForUidProviderElement
    extends AutoDisposeStreamProviderElement<Map<String, dynamic>?>
    with _TrainerProfileDocForUidRef {
  _TrainerProfileDocForUidProviderElement(super.provider);

  @override
  String get uid => (origin as _TrainerProfileDocForUidProvider).uid;
}

String _$trainerProfileControllerHash() =>
    r'4d6d6db1ad14c1c941a72b8878b892d46c40f0e5';

/// [TrainerProfilePanel]'in üst kartındaki gerçek antrenör adı/uzmanlığı —
/// önceden `TrainerMockData`'dan sabit ("Berk Aydın") değer geliyordu,
/// giriş yapan antrenör ne olursa olsun aynı isim gösteriliyordu.
///
/// Copied from [TrainerProfileController].
@ProviderFor(TrainerProfileController)
final trainerProfileControllerProvider =
    AutoDisposeNotifierProvider<
      TrainerProfileController,
      ({String name, String initials, String specialty})
    >.internal(
      TrainerProfileController.new,
      name: r'trainerProfileControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trainerProfileControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TrainerProfileController =
    AutoDisposeNotifier<({String name, String initials, String specialty})>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
