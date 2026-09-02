// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_member_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newMemberControllerHash() =>
    r'9543d53e104a233d13b4fa36dd5604fd21003c75';

/// Yeni üye kayıt akışının (P4-5 → P4-6 → P4-7) formu — geri tuşuyla önceki
/// adıma dönüldüğünde veri kaybolmasın diye tek bir kalıcı state'te tutulur.
///
/// Copied from [NewMemberController].
@ProviderFor(NewMemberController)
final newMemberControllerProvider =
    AutoDisposeNotifierProvider<NewMemberController, NewMemberForm>.internal(
      NewMemberController.new,
      name: r'newMemberControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$newMemberControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NewMemberController = AutoDisposeNotifier<NewMemberForm>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
