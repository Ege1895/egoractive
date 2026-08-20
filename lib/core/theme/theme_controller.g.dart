// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeGymIdHash() => r'84143af14ba99f24c2a4f3e8cf87ecbde240c9fe';

/// Oturum açan kullanıcının custom claim'indeki `gymId`. Gerçek claim
/// ataması F2-5'te (Custom Claims atama Cloud Function) yapılacağı için
/// şimdilik çoğunlukla `null` döner — bu durumda [ThemeController]
/// varsayılan temada kalır (F1-6 kabul kriteri: "salon yokken varsayılan
/// tema düzgün render ediliyor").
///
/// Copied from [activeGymId].
@ProviderFor(activeGymId)
final activeGymIdProvider = AutoDisposeFutureProvider<String?>.internal(
  activeGymId,
  name: r'activeGymIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeGymIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveGymIdRef = AutoDisposeFutureProviderRef<String?>;
String _$themeControllerHash() => r'13b5647efae87b1bf549a926bd83fde667e7f951';

/// Salon bazlı dinamik tema (CLAUDE.md §2.4). Aktif salon biliniyorsa
/// `gyms/{gymId}` dokümanındaki `themeColors.primary` alanını canlı dinler
/// (F1-6); salon yoksa varsayılan temada kalır.
///
/// `setAccentColor`, admin Salon Bilgileri/Temalar panelinde seçim
/// yaparken anlık önizleme için state'i optimistik olarak günceller — bir
/// sonraki Firestore emisyonu (gerçek kayıt F2'de) bunu teyit eder/geçersiz
/// kılar.
///
/// Copied from [ThemeController].
@ProviderFor(ThemeController)
final themeControllerProvider =
    StreamNotifierProvider<ThemeController, AppColorScheme>.internal(
      ThemeController.new,
      name: r'themeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeController = StreamNotifier<AppColorScheme>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
