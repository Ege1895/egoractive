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

String _$selfUserDocHash() => r'3f32846abce36422a2b47fcf7c2731a79b62a9c0';

/// See also [_selfUserDoc].
@ProviderFor(_selfUserDoc)
const _selfUserDocProvider = _SelfUserDocFamily();

/// See also [_selfUserDoc].
class _SelfUserDocFamily extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [_selfUserDoc].
  const _SelfUserDocFamily();

  /// See also [_selfUserDoc].
  _SelfUserDocProvider call(String uid) {
    return _SelfUserDocProvider(uid);
  }

  @override
  _SelfUserDocProvider getProviderOverride(
    covariant _SelfUserDocProvider provider,
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
  String? get name => r'_selfUserDocProvider';
}

/// See also [_selfUserDoc].
class _SelfUserDocProvider
    extends AutoDisposeStreamProvider<Map<String, dynamic>?> {
  /// See also [_selfUserDoc].
  _SelfUserDocProvider(String uid)
    : this._internal(
        (ref) => _selfUserDoc(ref as _SelfUserDocRef, uid),
        from: _selfUserDocProvider,
        name: r'_selfUserDocProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$selfUserDocHash,
        dependencies: _SelfUserDocFamily._dependencies,
        allTransitiveDependencies:
            _SelfUserDocFamily._allTransitiveDependencies,
        uid: uid,
      );

  _SelfUserDocProvider._internal(
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
    Stream<Map<String, dynamic>?> Function(_SelfUserDocRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _SelfUserDocProvider._internal(
        (ref) => create(ref as _SelfUserDocRef),
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
    return _SelfUserDocProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _SelfUserDocProvider && other.uid == uid;
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
mixin _SelfUserDocRef on AutoDisposeStreamProviderRef<Map<String, dynamic>?> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _SelfUserDocProviderElement
    extends AutoDisposeStreamProviderElement<Map<String, dynamic>?>
    with _SelfUserDocRef {
  _SelfUserDocProviderElement(super.provider);

  @override
  String get uid => (origin as _SelfUserDocProvider).uid;
}

String _$selfTrainerProfileUidHash() =>
    r'65ef8d563f79ed2b43c6c66aa8b8daeac487f3cf';

/// F11-1 — admin kendini antrenör olarak eklediyse, oluşan "gölge antrenör"
/// dokümanının id'si; eklemediyse `null`.
///
/// Kaynak BİLEREK adminin KENDİ dokümanındaki `trainerProfileUid` alanı,
/// antrenör listesi değil: antrenörlükten çıkıldığında gölge doküman
/// `isActive: false` ile listeden düşer ([_trainerDocsForGym] filtresi) ama
/// bağlantı korunmalı — aksi halde toggle yeniden görünür ve İKİNCİ bir
/// gölge doküman açılır, aylık istatistikler iki kayda bölünürdü (bkz.
/// görev listesi F11-5).
///
/// Copied from [selfTrainerProfileUid].
@ProviderFor(selfTrainerProfileUid)
final selfTrainerProfileUidProvider = AutoDisposeProvider<String?>.internal(
  selfTrainerProfileUid,
  name: r'selfTrainerProfileUidProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selfTrainerProfileUidHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelfTrainerProfileUidRef = AutoDisposeProviderRef<String?>;
String _$adminTrainersControllerHash() =>
    r'2cc6020d3631f1d0d2a0a6bc6ab072aad9232fc9';

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
