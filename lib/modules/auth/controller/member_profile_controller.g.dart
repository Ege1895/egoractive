// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileDocForUidHash() => r'795942d0d7e1d60ad89722c2b3149f29a07452b0';

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

/// See also [_profileDocForUid].
@ProviderFor(_profileDocForUid)
const _profileDocForUidProvider = _ProfileDocForUidFamily();

/// See also [_profileDocForUid].
class _ProfileDocForUidFamily
    extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [_profileDocForUid].
  const _ProfileDocForUidFamily();

  /// See also [_profileDocForUid].
  _ProfileDocForUidProvider call(String uid) {
    return _ProfileDocForUidProvider(uid);
  }

  @override
  _ProfileDocForUidProvider getProviderOverride(
    covariant _ProfileDocForUidProvider provider,
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
  String? get name => r'_profileDocForUidProvider';
}

/// See also [_profileDocForUid].
class _ProfileDocForUidProvider
    extends AutoDisposeStreamProvider<Map<String, dynamic>?> {
  /// See also [_profileDocForUid].
  _ProfileDocForUidProvider(String uid)
    : this._internal(
        (ref) => _profileDocForUid(ref as _ProfileDocForUidRef, uid),
        from: _profileDocForUidProvider,
        name: r'_profileDocForUidProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileDocForUidHash,
        dependencies: _ProfileDocForUidFamily._dependencies,
        allTransitiveDependencies:
            _ProfileDocForUidFamily._allTransitiveDependencies,
        uid: uid,
      );

  _ProfileDocForUidProvider._internal(
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
    Stream<Map<String, dynamic>?> Function(_ProfileDocForUidRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _ProfileDocForUidProvider._internal(
        (ref) => create(ref as _ProfileDocForUidRef),
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
    return _ProfileDocForUidProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _ProfileDocForUidProvider && other.uid == uid;
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
mixin _ProfileDocForUidRef
    on AutoDisposeStreamProviderRef<Map<String, dynamic>?> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _ProfileDocForUidProviderElement
    extends AutoDisposeStreamProviderElement<Map<String, dynamic>?>
    with _ProfileDocForUidRef {
  _ProfileDocForUidProviderElement(super.provider);

  @override
  String get uid => (origin as _ProfileDocForUidProvider).uid;
}

String _$memberProfileControllerHash() =>
    r'5ae91920851e4fe540979b2a817f6fd4dee7e81c';

/// [ProfilePanel]'in üst kartındaki gerçek kullanıcı adı/telefonu —
/// önceden `MemberMockProfile`'dan sabit ("Ayşe Yılmaz") değer geliyordu,
/// giriş yapan kullanıcı ne olursa olsun aynı isim gösteriliyordu.
///
/// `sessionReminderEnabled` de burada tutuluyor — önceden `AuthController`'da
/// sadece bellekte tutulup hiçbir yere yazılmıyordu, oturum kapatılınca
/// sessizce varsayılana dönüyordu.
///
/// Copied from [MemberProfileController].
@ProviderFor(MemberProfileController)
final memberProfileControllerProvider =
    AutoDisposeNotifierProvider<
      MemberProfileController,
      ({
        String name,
        String phoneE164,
        String email,
        bool sessionReminderEnabled,
      })
    >.internal(
      MemberProfileController.new,
      name: r'memberProfileControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$memberProfileControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MemberProfileController =
    AutoDisposeNotifier<
      ({
        String name,
        String phoneE164,
        String email,
        bool sessionReminderEnabled,
      })
    >;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
