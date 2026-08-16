// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$membersForGymHash() => r'5e968bdde1adcdb5e7f23e3ee8449756cff26e2a';

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

/// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
/// bu durumda [AdminMembersController] mock listeye düşer.
///
/// F7-2 — bilerek SINIRSIZ: üye detayı/seans-antrenör seçici/bildirim
/// hedefi gibi tüketiciler tüm üye kümesi üzerinde arama/seçim yapabilmeli.
/// Ana liste ekranı (F2-2, `AdminMemberListPanel`) büyük salon ölçeğinde
/// bunun yerine sayfalı [AdminMemberListController]'ı kullanıyor — bu
/// provider sadece o üç tüketici için hâlâ geçerli.
///
/// Copied from [_membersForGym].
@ProviderFor(_membersForGym)
const _membersForGymProvider = _MembersForGymFamily();

/// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
/// bu durumda [AdminMembersController] mock listeye düşer.
///
/// F7-2 — bilerek SINIRSIZ: üye detayı/seans-antrenör seçici/bildirim
/// hedefi gibi tüketiciler tüm üye kümesi üzerinde arama/seçim yapabilmeli.
/// Ana liste ekranı (F2-2, `AdminMemberListPanel`) büyük salon ölçeğinde
/// bunun yerine sayfalı [AdminMemberListController]'ı kullanıyor — bu
/// provider sadece o üç tüketici için hâlâ geçerli.
///
/// Copied from [_membersForGym].
class _MembersForGymFamily
    extends Family<AsyncValue<List<AdminMemberSummary>>> {
  /// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
  /// bu durumda [AdminMembersController] mock listeye düşer.
  ///
  /// F7-2 — bilerek SINIRSIZ: üye detayı/seans-antrenör seçici/bildirim
  /// hedefi gibi tüketiciler tüm üye kümesi üzerinde arama/seçim yapabilmeli.
  /// Ana liste ekranı (F2-2, `AdminMemberListPanel`) büyük salon ölçeğinde
  /// bunun yerine sayfalı [AdminMemberListController]'ı kullanıyor — bu
  /// provider sadece o üç tüketici için hâlâ geçerli.
  ///
  /// Copied from [_membersForGym].
  const _MembersForGymFamily();

  /// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
  /// bu durumda [AdminMembersController] mock listeye düşer.
  ///
  /// F7-2 — bilerek SINIRSIZ: üye detayı/seans-antrenör seçici/bildirim
  /// hedefi gibi tüketiciler tüm üye kümesi üzerinde arama/seçim yapabilmeli.
  /// Ana liste ekranı (F2-2, `AdminMemberListPanel`) büyük salon ölçeğinde
  /// bunun yerine sayfalı [AdminMemberListController]'ı kullanıyor — bu
  /// provider sadece o üç tüketici için hâlâ geçerli.
  ///
  /// Copied from [_membersForGym].
  _MembersForGymProvider call(String gymId) {
    return _MembersForGymProvider(gymId);
  }

  @override
  _MembersForGymProvider getProviderOverride(
    covariant _MembersForGymProvider provider,
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
  String? get name => r'_membersForGymProvider';
}

/// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
/// bu durumda [AdminMembersController] mock listeye düşer.
///
/// F7-2 — bilerek SINIRSIZ: üye detayı/seans-antrenör seçici/bildirim
/// hedefi gibi tüketiciler tüm üye kümesi üzerinde arama/seçim yapabilmeli.
/// Ana liste ekranı (F2-2, `AdminMemberListPanel`) büyük salon ölçeğinde
/// bunun yerine sayfalı [AdminMemberListController]'ı kullanıyor — bu
/// provider sadece o üç tüketici için hâlâ geçerli.
///
/// Copied from [_membersForGym].
class _MembersForGymProvider
    extends AutoDisposeStreamProvider<List<AdminMemberSummary>> {
  /// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
  /// bu durumda [AdminMembersController] mock listeye düşer.
  ///
  /// F7-2 — bilerek SINIRSIZ: üye detayı/seans-antrenör seçici/bildirim
  /// hedefi gibi tüketiciler tüm üye kümesi üzerinde arama/seçim yapabilmeli.
  /// Ana liste ekranı (F2-2, `AdminMemberListPanel`) büyük salon ölçeğinde
  /// bunun yerine sayfalı [AdminMemberListController]'ı kullanıyor — bu
  /// provider sadece o üç tüketici için hâlâ geçerli.
  ///
  /// Copied from [_membersForGym].
  _MembersForGymProvider(String gymId)
    : this._internal(
        (ref) => _membersForGym(ref as _MembersForGymRef, gymId),
        from: _membersForGymProvider,
        name: r'_membersForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$membersForGymHash,
        dependencies: _MembersForGymFamily._dependencies,
        allTransitiveDependencies:
            _MembersForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _MembersForGymProvider._internal(
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
    Stream<List<AdminMemberSummary>> Function(_MembersForGymRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _MembersForGymProvider._internal(
        (ref) => create(ref as _MembersForGymRef),
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
  AutoDisposeStreamProviderElement<List<AdminMemberSummary>> createElement() {
    return _MembersForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _MembersForGymProvider && other.gymId == gymId;
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
mixin _MembersForGymRef
    on AutoDisposeStreamProviderRef<List<AdminMemberSummary>> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _MembersForGymProviderElement
    extends AutoDisposeStreamProviderElement<List<AdminMemberSummary>>
    with _MembersForGymRef {
  _MembersForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _MembersForGymProvider).gymId;
}

String _$adminMembersControllerHash() =>
    r'3885845e36aa49fc9723f25295cc7d5718a19d24';

/// Üye detayı/seans oluşturma/bildirim gönderme ekranlarının kullandığı,
/// aktif salonun üyelerini gerçek zamanlı listeleyen kontrolcü. Dış arayüz
/// bilerek senkron (`List<AdminMemberSummary>`) tutuldu — tüketiciler
/// `AsyncValue` bilmek zorunda değil; Firestore akışı burada sarmalanıyor.
///
/// Copied from [AdminMembersController].
@ProviderFor(AdminMembersController)
final adminMembersControllerProvider =
    AutoDisposeNotifierProvider<
      AdminMembersController,
      List<AdminMemberSummary>
    >.internal(
      AdminMembersController.new,
      name: r'adminMembersControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminMembersControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminMembersController =
    AutoDisposeNotifier<List<AdminMemberSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
