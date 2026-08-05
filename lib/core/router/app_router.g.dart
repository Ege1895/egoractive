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
String _$currentRoleHash() => r'ab66cd5591d230ef16d51c2b11bbe2734fcd5735';

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
