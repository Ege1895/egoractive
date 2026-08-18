// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badges_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$badgesHash() => r'c6c8d5e9ac92c52175133c16d17f49d5fec0270c';

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
