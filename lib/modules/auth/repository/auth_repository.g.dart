// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'2324eff64ae249ce4111d3ba182e65645cdfcd8e';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$currentUserEmailHash() => r'7246acea9e149c7334b54ae54700a9054a54b663';

/// Egoractive Authentication Sistemi §6 — app açılışında mevcut authenticated
/// hesabın email alanı boş mu diye tek seferlik kontrol. Email yalnızca
/// [OtpPurpose.activation]/[OtpPurpose.emailChange] doğrulaması sonrası
/// (Cloud Function tarafından) yazıldığı için canlı bir dinleyici yerine
/// tek seferlik `get()` yeterli — `EmailSetupPanel` doğrulama başarılı
/// olunca `ref.invalidate(appAccessProvider)` ile bu kontrolü elle tazeler.
///
/// Copied from [currentUserEmail].
@ProviderFor(currentUserEmail)
final currentUserEmailProvider = AutoDisposeFutureProvider<String?>.internal(
  currentUserEmail,
  name: r'currentUserEmailProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserEmailHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserEmailRef = AutoDisposeFutureProviderRef<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
