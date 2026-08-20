// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localeControllerHash() => r'022bf69f78f0f4a529b7321f7a7f24a00335b0b2';

/// Uygulamanın aktif dili (`'tr'`/`'en'`). Kullanıcı hiç seçim yapmadıysa
/// cihaz diline düşer (F1 kabul kriteri: ilk açılışta OS dili tr ise tr,
/// değilse en); kullanıcı [setLanguage] ile bir kez seçim yapınca
/// [LocalePrefs] üzerinden kalıcı olur. Bu provider'ı `watch` eden her widget
/// dil değişince otomatik yeniden çizilir (bkz. `rcTextProvider`).
///
/// Copied from [LocaleController].
@ProviderFor(LocaleController)
final localeControllerProvider =
    NotifierProvider<LocaleController, String>.internal(
      LocaleController.new,
      name: r'localeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocaleController = Notifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
