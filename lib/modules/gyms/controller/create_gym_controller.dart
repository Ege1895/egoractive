import 'dart:io';
import 'dart:ui' show Color;

import 'package:flutter/painting.dart' show FileImage;
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_profile.dart';
import '../service/create_gym_service.dart';
import 'gym_profile_controller.dart';
import 'gym_theme_controller.dart';

part 'create_gym_controller.g.dart';

class CreateGymState {
  const CreateGymState({
    this.logoFile,
    this.isSubmitting = false,
    this.errorMessage,
    this.isExtractingPalette = false,
    this.logoPalette = const [],
    this.selectedPaletteColor,
  });

  final XFile? logoFile;
  final bool isSubmitting;
  final String? errorMessage;

  /// Logo seçildikten sonra `palette_generator` ile renk çıkarımı sürüyor mu.
  final bool isExtractingPalette;

  /// Logodan çıkarılan öneri renkleri — boşsa (logo seçilmemiş/çıkarım
  /// başarısız olmuş) [GymSetupPanel] hazır tema listesini gösterir.
  final List<Color> logoPalette;

  /// Kullanıcının logo paletinden seçtiği renk — `null` ise hazır tema
  /// listesindeki seçim ([GymThemeController.activeTheme]) geçerlidir.
  final Color? selectedPaletteColor;

  CreateGymState copyWith({
    XFile? logoFile,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool? isExtractingPalette,
    List<Color>? logoPalette,
    Color? selectedPaletteColor,
    bool clearSelectedPaletteColor = false,
  }) {
    return CreateGymState(
      logoFile: logoFile ?? this.logoFile,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isExtractingPalette: isExtractingPalette ?? this.isExtractingPalette,
      logoPalette: logoPalette ?? this.logoPalette,
      selectedPaletteColor:
          clearSelectedPaletteColor ? null : (selectedPaletteColor ?? this.selectedPaletteColor),
    );
  }
}

/// F2-1 — [GymSetupPanel]'in "Salonu oluştur" aksiyonu. Metin alanları
/// hâlâ [GymProfileController]/[GymThemeController] üzerinden bağlı; bu
/// controller logo seçimini, logodan renk çıkarımını ve gönderim/validasyon
/// durumunu tutar.
@riverpod
class CreateGymController extends _$CreateGymController {
  @override
  CreateGymState build() => const CreateGymState();

  Future<void> pickLogo() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;
      state = state.copyWith(
        logoFile: file,
        clearError: true,
        logoPalette: const [],
        clearSelectedPaletteColor: true,
      );
      await _extractPalette(file);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Logo seçilemedi. Tekrar dene.');
    }
  }

  void selectPaletteColor(Color color) => state = state.copyWith(selectedPaletteColor: color);

  /// Logodaki baskın/canlı renkleri çıkarıp öneri listesine koyar. Çıkarım
  /// başarısız olursa (bozuk dosya, format desteklenmiyor vb.) sessizce
  /// vazgeçilir — kullanıcı hazır tema listesinden seçmeye devam edebilir,
  /// bu opsiyonel bir öneri özelliği, akışı asla engellememeli.
  Future<void> _extractPalette(XFile file) async {
    state = state.copyWith(isExtractingPalette: true);
    try {
      final generator = await PaletteGenerator.fromImageProvider(
        FileImage(File(file.path)),
        maximumColorCount: 12,
      );
      final candidates = <Color?>[
        generator.dominantColor?.color,
        generator.vibrantColor?.color,
        generator.lightVibrantColor?.color,
        generator.darkVibrantColor?.color,
        generator.mutedColor?.color,
      ].whereType<Color>().toList();

      final palette = _dedupeSimilarColors(candidates).take(5).toList();
      state = state.copyWith(
        isExtractingPalette: false,
        logoPalette: palette,
        selectedPaletteColor: palette.isEmpty ? null : palette.first,
      );
    } catch (_) {
      state = state.copyWith(isExtractingPalette: false, logoPalette: const []);
    }
  }

  /// Palette_generator'ın döndürdüğü roller (dominant/vibrant/muted vb.)
  /// çoğu logoda birbirine çok yakın renkler verir — göz zar zor ayırt
  /// edebileceği neredeyse aynı iki rengi ayrı seçenek olarak göstermemek
  /// için kaba bir RGB mesafe eşiğiyle eleniyor.
  List<Color> _dedupeSimilarColors(List<Color> colors) {
    const threshold = 24;
    final result = <Color>[];
    for (final color in colors) {
      final isSimilar = result.any((kept) {
        final dr = (kept.r - color.r).abs() * 255;
        final dg = (kept.g - color.g).abs() * 255;
        final db = (kept.b - color.b).abs() * 255;
        return dr < threshold && dg < threshold && db < threshold;
      });
      if (!isSimilar) result.add(color);
    }
    return result;
  }

  /// Zorunlu alan eksikse `null` döner ve [errorMessage]'ı doldurur;
  /// başarılıysa oluşturulan `gymId`'yi döner. Logo opsiyoneldir.
  Future<String?> submit() async {
    if (state.isSubmitting) return null;

    final profile = ref.read(gymProfileControllerProvider);
    final validationError = _validate(profile);
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final themeColor =
          state.selectedPaletteColor ?? ref.read(gymThemeControllerProvider.notifier).activeTheme.primary;
      final gymId = await ref.read(createGymServiceProvider).createGym(
            profile: profile,
            themeColor: themeColor,
            logoFile: state.logoFile,
          );
      state = state.copyWith(isSubmitting: false);
      return gymId;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Salon oluşturulamadı. Bağlantını kontrol edip tekrar dene.',
      );
      return null;
    }
  }

  String? _validate(GymProfile profile) {
    if (profile.name.trim().isEmpty || profile.city.trim().isEmpty || profile.address.trim().isEmpty) {
      return 'Lütfen tüm alanları doldur.';
    }
    // profile.phone GymProfileController.updatePhone'da zaten sadece rakam
    // tutuluyor — bu numarayla admin girişi yapılacağı için 10 haneli
    // geçerli bir TR cep telefonu olmalı (AuthState.isPhoneComplete ile
    // aynı kural).
    if (profile.phone.length != 10) {
      return 'Lütfen geçerli bir cep telefonu numarası gir.';
    }
    return null;
  }
}
