// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeControllerHash() => r'9f4a85624779e7dea8169318c17a3da96ee09cbe';

/// Salon bazlı dinamik tema (CLAUDE.md §2.4) — aktif salonun tema rengini
/// tutar. Faz 2+'da `gyms/{gymId}.themeColors`'tan yüklenecek; şimdilik
/// `modules/gyms` içindeki GymThemeController mock seçimle burayı günceller.
///
/// Copied from [ThemeController].
@ProviderFor(ThemeController)
final themeControllerProvider =
    NotifierProvider<ThemeController, AppColorScheme>.internal(
      ThemeController.new,
      name: r'themeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeController = Notifier<AppColorScheme>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
