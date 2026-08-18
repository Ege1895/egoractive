// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_membership_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newMembershipControllerHash() =>
    r'5372fee4fbc8a88bb87977ec982583ae5b8c0288';

/// Yeni üyelik akışının (P4-6 → P4-7) paket + ödeme state'i — geri tuşuyla
/// paket adımına dönüldüğünde ödeme girişleri kaybolmasın diye tek state.
///
/// Copied from [NewMembershipController].
@ProviderFor(NewMembershipController)
final newMembershipControllerProvider =
    AutoDisposeNotifierProvider<
      NewMembershipController,
      NewMembershipState
    >.internal(
      NewMembershipController.new,
      name: r'newMembershipControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$newMembershipControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NewMembershipController = AutoDisposeNotifier<NewMembershipState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
