// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_registration_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memberRegistrationControllerHash() =>
    r'ce310d0ecf959fe6124fe5f1c3bcb56010d0d09d';

/// F2-2 — [MemberInfoPanel]'in (yeni üye akışı) ilk adımdaki gerçek kayıt
/// aksiyonu. Form alanları [NewMemberController]'da tutuluyor; bu controller
/// sadece validasyon + gönderim durumunu tutar.
///
/// Copied from [MemberRegistrationController].
@ProviderFor(MemberRegistrationController)
final memberRegistrationControllerProvider =
    AutoDisposeNotifierProvider<
      MemberRegistrationController,
      MemberRegistrationState
    >.internal(
      MemberRegistrationController.new,
      name: r'memberRegistrationControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$memberRegistrationControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MemberRegistrationController =
    AutoDisposeNotifier<MemberRegistrationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
