// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_gate.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shouldShowAdsHash() => r'c8f9e99c3dcfa8923d673e9157af4f90b5522223';

/// F6-2 — bir üyeye banner reklam gösterilip gösterilmeyeceğine karar
/// verir: salonun aboneliği `active` DEĞİLSE VE `cfg_free_version_ads_enabled`
/// RC flag'i açıksa reklam gösterilir. Flag kapatılırsa hiç kimseye
/// (abone olsun olmasın) reklam gösterilmez — global kill-switch.
///
/// Copied from [shouldShowAds].
@ProviderFor(shouldShowAds)
final shouldShowAdsProvider = AutoDisposeProvider<bool>.internal(
  shouldShowAds,
  name: r'shouldShowAdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shouldShowAdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShouldShowAdsRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
