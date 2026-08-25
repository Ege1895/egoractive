// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badges_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$badgesHash() => r'1762e30c21d45e00dfe5dce8f5cb549e4d3ec7c7';

/// See also [_badges].
@ProviderFor(_badges)
final _badgesProvider = AutoDisposeStreamProvider<List<BadgeItem>>.internal(
  _badges,
  name: r'_badgesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$badgesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef _BadgesRef = AutoDisposeStreamProviderRef<List<BadgeItem>>;
String _$memberBadgesHash() => r'ea7d5cd5f9210f88d14c5faffc0a2599a20a09dd';

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

/// Admin üye detay ekranındaki rozet bölümü — [BadgesController]'dan farklı
/// olarak oturum açan kullanıcı değil, `memberId` ile belirtilen ÜYENİN
/// rozetleri okunur. `earnedBadgeIds`/`buildBadges` zaten `uid` parametreli
/// olduğu için ek bir servis/rule değişikliği gerekmiyor — firestore.rules
/// admin'in kendi salonundaki her üyenin `users/{uid}` dokümanını zaten
/// okuyabilmesine izin veriyor.
///
/// Copied from [memberBadges].
@ProviderFor(memberBadges)
const memberBadgesProvider = MemberBadgesFamily();

/// Admin üye detay ekranındaki rozet bölümü — [BadgesController]'dan farklı
/// olarak oturum açan kullanıcı değil, `memberId` ile belirtilen ÜYENİN
/// rozetleri okunur. `earnedBadgeIds`/`buildBadges` zaten `uid` parametreli
/// olduğu için ek bir servis/rule değişikliği gerekmiyor — firestore.rules
/// admin'in kendi salonundaki her üyenin `users/{uid}` dokümanını zaten
/// okuyabilmesine izin veriyor.
///
/// Copied from [memberBadges].
class MemberBadgesFamily extends Family<AsyncValue<List<BadgeItem>>> {
  /// Admin üye detay ekranındaki rozet bölümü — [BadgesController]'dan farklı
  /// olarak oturum açan kullanıcı değil, `memberId` ile belirtilen ÜYENİN
  /// rozetleri okunur. `earnedBadgeIds`/`buildBadges` zaten `uid` parametreli
  /// olduğu için ek bir servis/rule değişikliği gerekmiyor — firestore.rules
  /// admin'in kendi salonundaki her üyenin `users/{uid}` dokümanını zaten
  /// okuyabilmesine izin veriyor.
  ///
  /// Copied from [memberBadges].
  const MemberBadgesFamily();

  /// Admin üye detay ekranındaki rozet bölümü — [BadgesController]'dan farklı
  /// olarak oturum açan kullanıcı değil, `memberId` ile belirtilen ÜYENİN
  /// rozetleri okunur. `earnedBadgeIds`/`buildBadges` zaten `uid` parametreli
  /// olduğu için ek bir servis/rule değişikliği gerekmiyor — firestore.rules
  /// admin'in kendi salonundaki her üyenin `users/{uid}` dokümanını zaten
  /// okuyabilmesine izin veriyor.
  ///
  /// Copied from [memberBadges].
  MemberBadgesProvider call(String memberId) {
    return MemberBadgesProvider(memberId);
  }

  @override
  MemberBadgesProvider getProviderOverride(
    covariant MemberBadgesProvider provider,
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
  String? get name => r'memberBadgesProvider';
}

/// Admin üye detay ekranındaki rozet bölümü — [BadgesController]'dan farklı
/// olarak oturum açan kullanıcı değil, `memberId` ile belirtilen ÜYENİN
/// rozetleri okunur. `earnedBadgeIds`/`buildBadges` zaten `uid` parametreli
/// olduğu için ek bir servis/rule değişikliği gerekmiyor — firestore.rules
/// admin'in kendi salonundaki her üyenin `users/{uid}` dokümanını zaten
/// okuyabilmesine izin veriyor.
///
/// Copied from [memberBadges].
class MemberBadgesProvider extends AutoDisposeStreamProvider<List<BadgeItem>> {
  /// Admin üye detay ekranındaki rozet bölümü — [BadgesController]'dan farklı
  /// olarak oturum açan kullanıcı değil, `memberId` ile belirtilen ÜYENİN
  /// rozetleri okunur. `earnedBadgeIds`/`buildBadges` zaten `uid` parametreli
  /// olduğu için ek bir servis/rule değişikliği gerekmiyor — firestore.rules
  /// admin'in kendi salonundaki her üyenin `users/{uid}` dokümanını zaten
  /// okuyabilmesine izin veriyor.
  ///
  /// Copied from [memberBadges].
  MemberBadgesProvider(String memberId)
    : this._internal(
        (ref) => memberBadges(ref as MemberBadgesRef, memberId),
        from: memberBadgesProvider,
        name: r'memberBadgesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$memberBadgesHash,
        dependencies: MemberBadgesFamily._dependencies,
        allTransitiveDependencies:
            MemberBadgesFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  MemberBadgesProvider._internal(
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
    Stream<List<BadgeItem>> Function(MemberBadgesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MemberBadgesProvider._internal(
        (ref) => create(ref as MemberBadgesRef),
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
  AutoDisposeStreamProviderElement<List<BadgeItem>> createElement() {
    return _MemberBadgesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberBadgesProvider && other.memberId == memberId;
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
mixin MemberBadgesRef on AutoDisposeStreamProviderRef<List<BadgeItem>> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _MemberBadgesProviderElement
    extends AutoDisposeStreamProviderElement<List<BadgeItem>>
    with MemberBadgesRef {
  _MemberBadgesProviderElement(super.provider);

  @override
  String get memberId => (origin as MemberBadgesProvider).memberId;
}

String _$badgesControllerHash() => r'8266fc71e3bca37ffb7f5c80dc9a2fa2e45c434f';

/// See also [BadgesController].
@ProviderFor(BadgesController)
final badgesControllerProvider =
    AutoDisposeNotifierProvider<BadgesController, List<BadgeItem>>.internal(
      BadgesController.new,
      name: r'badgesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$badgesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BadgesController = AutoDisposeNotifier<List<BadgeItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
