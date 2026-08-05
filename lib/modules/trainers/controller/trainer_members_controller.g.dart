// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$membersForTrainerHash() => r'efbe7ae7d381daad82e8cf89d43f6908fc95a298';

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

/// F2-3 — sadece bu antrenöre (`trainerId == uid`) atanmış üyeleri gerçek
/// zamanlı dinler. Security Rules ile de garanti altına alınacak (F2-6) —
/// bu sorgu client tarafı ilk savunma hattı.
///
/// Copied from [_membersForTrainer].
@ProviderFor(_membersForTrainer)
const _membersForTrainerProvider = _MembersForTrainerFamily();

/// F2-3 — sadece bu antrenöre (`trainerId == uid`) atanmış üyeleri gerçek
/// zamanlı dinler. Security Rules ile de garanti altına alınacak (F2-6) —
/// bu sorgu client tarafı ilk savunma hattı.
///
/// Copied from [_membersForTrainer].
class _MembersForTrainerFamily
    extends Family<AsyncValue<List<TrainerMemberSummary>>> {
  /// F2-3 — sadece bu antrenöre (`trainerId == uid`) atanmış üyeleri gerçek
  /// zamanlı dinler. Security Rules ile de garanti altına alınacak (F2-6) —
  /// bu sorgu client tarafı ilk savunma hattı.
  ///
  /// Copied from [_membersForTrainer].
  const _MembersForTrainerFamily();

  /// F2-3 — sadece bu antrenöre (`trainerId == uid`) atanmış üyeleri gerçek
  /// zamanlı dinler. Security Rules ile de garanti altına alınacak (F2-6) —
  /// bu sorgu client tarafı ilk savunma hattı.
  ///
  /// Copied from [_membersForTrainer].
  _MembersForTrainerProvider call(String trainerUid) {
    return _MembersForTrainerProvider(trainerUid);
  }

  @override
  _MembersForTrainerProvider getProviderOverride(
    covariant _MembersForTrainerProvider provider,
  ) {
    return call(provider.trainerUid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_membersForTrainerProvider';
}

/// F2-3 — sadece bu antrenöre (`trainerId == uid`) atanmış üyeleri gerçek
/// zamanlı dinler. Security Rules ile de garanti altına alınacak (F2-6) —
/// bu sorgu client tarafı ilk savunma hattı.
///
/// Copied from [_membersForTrainer].
class _MembersForTrainerProvider
    extends AutoDisposeStreamProvider<List<TrainerMemberSummary>> {
  /// F2-3 — sadece bu antrenöre (`trainerId == uid`) atanmış üyeleri gerçek
  /// zamanlı dinler. Security Rules ile de garanti altına alınacak (F2-6) —
  /// bu sorgu client tarafı ilk savunma hattı.
  ///
  /// Copied from [_membersForTrainer].
  _MembersForTrainerProvider(String trainerUid)
    : this._internal(
        (ref) => _membersForTrainer(ref as _MembersForTrainerRef, trainerUid),
        from: _membersForTrainerProvider,
        name: r'_membersForTrainerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$membersForTrainerHash,
        dependencies: _MembersForTrainerFamily._dependencies,
        allTransitiveDependencies:
            _MembersForTrainerFamily._allTransitiveDependencies,
        trainerUid: trainerUid,
      );

  _MembersForTrainerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.trainerUid,
  }) : super.internal();

  final String trainerUid;

  @override
  Override overrideWith(
    Stream<List<TrainerMemberSummary>> Function(_MembersForTrainerRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _MembersForTrainerProvider._internal(
        (ref) => create(ref as _MembersForTrainerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        trainerUid: trainerUid,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TrainerMemberSummary>> createElement() {
    return _MembersForTrainerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _MembersForTrainerProvider &&
        other.trainerUid == trainerUid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, trainerUid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _MembersForTrainerRef
    on AutoDisposeStreamProviderRef<List<TrainerMemberSummary>> {
  /// The parameter `trainerUid` of this provider.
  String get trainerUid;
}

class _MembersForTrainerProviderElement
    extends AutoDisposeStreamProviderElement<List<TrainerMemberSummary>>
    with _MembersForTrainerRef {
  _MembersForTrainerProviderElement(super.provider);

  @override
  String get trainerUid => (origin as _MembersForTrainerProvider).trainerUid;
}

String _$trainerMembersControllerHash() =>
    r'9e49db08ea34e141640bd754afb49254d8623d29';

/// Dış arayüz bilerek senkron (`List<TrainerMemberSummary>`) tutuldu — mevcut
/// panel `AsyncValue` bilmek zorunda değil. Oturum yoksa (uid bilinmiyorsa)
/// mock listeye düşer.
///
/// Copied from [TrainerMembersController].
@ProviderFor(TrainerMembersController)
final trainerMembersControllerProvider =
    AutoDisposeNotifierProvider<
      TrainerMembersController,
      List<TrainerMemberSummary>
    >.internal(
      TrainerMembersController.new,
      name: r'trainerMembersControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trainerMembersControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TrainerMembersController =
    AutoDisposeNotifier<List<TrainerMemberSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
