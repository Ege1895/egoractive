// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'baf32c03854278f1e773e0d3f2cb50d9b6270837';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;
String _$authIdTokenResultHash() => r'aa07c19d76190c859ee3d4261828211399e8b674';

/// `role` (bu dosyada) ve `gymId` (`theme_controller.dart`'taki
/// `activeGymIdProvider`) aynı custom claim map'inin iki farklı alanı —
/// ikisi de `getIdTokenResult()`'a bağımlı. Önceden her biri KENDİ
/// `getIdTokenResult()` çağrısını yapıyordu; `appAccessProvider` da bunları
/// ardışık `await`ediyordu (role bitmeden gymId isteği hiç başlamıyordu) —
/// yani her uygulama açılışında aynı token için iki ayrı round-trip.
/// Riverpod aynı provider'ı izleyen tüm taraflar arasında sonucu
/// memoize ettiği için burada TEK bir çağrıya indirgemek, `currentRole` ve
/// `activeGymId`'nin ikisinin de aynı (tek) fetch'i paylaşmasını sağlıyor.
///
/// Copied from [authIdTokenResult].
@ProviderFor(authIdTokenResult)
final authIdTokenResultProvider =
    AutoDisposeFutureProvider<IdTokenResult?>.internal(
      authIdTokenResult,
      name: r'authIdTokenResultProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authIdTokenResultHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthIdTokenResultRef = AutoDisposeFutureProviderRef<IdTokenResult?>;
String _$currentRoleHash() => r'aa6a1c097936d95b1b7cc3be4a0b4a22c04360a9';

/// Oturum yoksa `null`. Oturum varsa ID token'ı okuyup rolü çözer — token
/// custom claim taşımıyorsa/claim geçersizse de `null` döner.
///
/// Copied from [currentRole].
@ProviderFor(currentRole)
final currentRoleProvider = AutoDisposeFutureProvider<AppRole?>.internal(
  currentRole,
  name: r'currentRoleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentRoleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentRoleRef = AutoDisposeFutureProviderRef<AppRole?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
