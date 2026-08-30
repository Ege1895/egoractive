// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$otpControllerHash() => r'caff7403766bc7c5cb39ae856f0c97e4c17d6924';

/// Egoractive Authentication Sistemi §7 — OTP ekranının purpose'tan bağımsız
/// (login/activation/emailChange) ortak state'i: kod input'u, 60sn
/// TAMAMEN client-side geri sayım, doğrulama/tekrar-gönderme durumları.
/// Hangi callable'ın çağrılacağını bilmez — [verify]/[resend] çağıran
/// panelden bir closure alır, böylece Controller diğer modüllerden/UI'dan
/// habersiz kalır (CLAUDE.md §2.2).
///
/// Copied from [OtpController].
@ProviderFor(OtpController)
final otpControllerProvider =
    AutoDisposeNotifierProvider<OtpController, OtpState>.internal(
      OtpController.new,
      name: r'otpControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$otpControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OtpController = AutoDisposeNotifier<OtpState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
