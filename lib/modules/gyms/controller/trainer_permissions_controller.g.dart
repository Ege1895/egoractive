// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_permissions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trainerPermissionsControllerHash() =>
    r'274b3d8c4ffa5ed4feff40656e6b29f3203e90fd';

/// [AdminPermissionsPanel]'in antrenör seçim adımından sonra açılan
/// [TrainerPermissionsEditPanel]'in state'i — gym-wide `AdminPermissionsController`'dan
/// farklı olarak `gyms/{gymId}.trainerPermissions.{trainerId}` altında,
/// seçilen bir ya da birden fazla antrenöre özel saklanır. Her toggle
/// seçilen antrenörlerin hepsine aynı anda yazılır (toplu düzenleme).
///
/// Copied from [TrainerPermissionsController].
@ProviderFor(TrainerPermissionsController)
final trainerPermissionsControllerProvider =
    AutoDisposeNotifierProvider<
      TrainerPermissionsController,
      AdminPermissions
    >.internal(
      TrainerPermissionsController.new,
      name: r'trainerPermissionsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trainerPermissionsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TrainerPermissionsController = AutoDisposeNotifier<AdminPermissions>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
