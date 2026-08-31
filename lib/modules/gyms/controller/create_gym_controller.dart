import 'dart:io';
import 'dart:ui' show Color;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/painting.dart' show FileImage;
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/currency_constants.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/utils/gym_logo_image.dart';
import '../domain/gym_profile.dart';
import '../service/create_gym_service.dart';
import 'gym_profile_controller.dart';
import 'gym_theme_controller.dart';

part 'create_gym_controller.g.dart';

class CreateGymState {
  const CreateGymState({
    this.logoFile,
    this.currency = defaultCurrencyCode,
    this.isSubmitting = false,
    this.errorMessage,
    this.nameError,
    this.cityError,
    this.addressError,
    this.phoneError,
    this.emailError,
    this.isExtractingPalette = false,
    this.logoPalette = const [],
    this.selectedPaletteColor,
  });

  final XFile? logoFile;

  /// F9-2 — sadece salon kuruluşunda seçilir, sonradan değiştirilemez
  /// (dönüşüm/kur mantığı yok, bilinçli kısıtlama — bkz. FAZ 9 notu).
  final String currency;
  final bool isSubmitting;

  /// Alana bağlanamayan hatalar (network, sunucu) için — field-seviyeli
  /// hatalar aşağıdaki ayrı alanlarda tutulur.
  final String? errorMessage;
  final String? nameError;
  final String? cityError;
  final String? addressError;
  final String? phoneError;
  final String? emailError;

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
    String? currency,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? nameError,
    String? cityError,
    String? addressError,
    String? phoneError,
    String? emailError,
    bool clearFieldErrors = false,
    bool? isExtractingPalette,
    List<Color>? logoPalette,
    Color? selectedPaletteColor,
    bool clearSelectedPaletteColor = false,
  }) {
    return CreateGymState(
      logoFile: logoFile ?? this.logoFile,
      currency: currency ?? this.currency,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      nameError: clearFieldErrors ? null : (nameError ?? this.nameError),
      cityError: clearFieldErrors ? null : (cityError ?? this.cityError),
      addressError: clearFieldErrors
          ? null
          : (addressError ?? this.addressError),
      phoneError: clearFieldErrors ? null : (phoneError ?? this.phoneError),
      emailError: clearFieldErrors ? null : (emailError ?? this.emailError),
      isExtractingPalette: isExtractingPalette ?? this.isExtractingPalette,
      logoPalette: logoPalette ?? this.logoPalette,
      selectedPaletteColor: clearSelectedPaletteColor
          ? null
          : (selectedPaletteColor ?? this.selectedPaletteColor),
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

  /// [GymSetupPanel] her açıldığında çağırır — bkz. [GymProfileController.reset].
  /// Global tema önizlemesini de varsayılana döndürür: önceki bir denemede
  /// palet rengi seçilip salon kaydı başarısız olduysa (ya da kullanıcı
  /// vazgeçtiyse), bu ekrana her dönüşte yanlış/geçici bir vurgu rengi asılı
  /// kalmasın.
  void reset() {
    state = const CreateGymState();
    ref.read(themeControllerProvider.notifier).resetToDefault();
  }

  /// F9-2 — sadece bu ekranda (salon kuruluşu) çağrılır; [GymInfoPanel]'de
  /// bu alana dokunacak hiçbir UI yok, bilerek.
  void selectCurrency(String code) => state = state.copyWith(currency: code);

  Future<void> pickLogo() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
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

  /// Seçimi hem yerel state'e hem de global [ThemeController]'a yazar ki
  /// buton/vurgu renkleri ekranda anında (canlı önizleme) değişsin — aynı
  /// [GymThemeController.selectTheme] hazır tema seçiminde yaptığı gibi.
  void selectPaletteColor(Color color) {
    state = state.copyWith(selectedPaletteColor: color);
    ref.read(themeControllerProvider.notifier).setAccentColor(color);
  }

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
      final palette = extractGymPaletteColors(generator);
      state = state.copyWith(
        isExtractingPalette: false,
        logoPalette: palette,
        selectedPaletteColor: palette.isEmpty ? null : palette.first,
      );
    } catch (_) {
      state = state.copyWith(isExtractingPalette: false, logoPalette: const []);
    }
  }

  /// Zorunlu alan eksikse ilgili alanın hatasını doldurup `null` döner —
  /// önceki sürüm tüm hataları ("zaten kayıtlı" dahil) tek bir genel
  /// banner'da gösteriyordu, kullanıcı hangi alanın sorunlu olduğunu
  /// görmeden alanlara tek tek bakmak zorunda kalıyordu. Başarılıysa
  /// oluşturulan `gymId`'yi döner. [email] — Egoractive Authentication
  /// Sistemi §9: "Login ve rapor e-postası", zorunlu; hem admin OTP
  /// girişinde hem salon raporlarında kullanılır. Logo opsiyoneldir.
  Future<String?> submit({required String email}) async {
    if (state.isSubmitting) return null;

    final profile = ref.read(gymProfileControllerProvider);
    if (!_validate(profile, email)) return null;

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearFieldErrors: true,
    );
    try {
      final themeColor =
          state.selectedPaletteColor ??
          ref.read(gymThemeControllerProvider.notifier).activeTheme.primary;
      final gymId = await ref
          .read(createGymServiceProvider)
          .createGym(
            profile: profile,
            themeColor: themeColor,
            email: email.trim(),
            logoFile: state.logoFile,
            currency: state.currency,
          );
      state = state.copyWith(isSubmitting: false);
      return gymId;
    } on FirebaseFunctionsException catch (e) {
      final isEmailConflict =
          e.code == 'already-exists' && (e.message ?? '').contains('email');
      state = state.copyWith(
        isSubmitting: false,
        phoneError: e.code == 'already-exists' && !isEmailConflict
            ? 'Bu numarayla kayıtlı bir hesap zaten var. Giriş yapmayı dene.'
            : null,
        emailError: isEmailConflict
            ? 'Bu email adresiyle kayıtlı bir hesap zaten var. Giriş yapmayı dene.'
            : null,
        errorMessage: e.code == 'already-exists'
            ? null
            : 'Salon oluşturulamadı. Bağlantını kontrol edip tekrar dene.',
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage:
            'Salon oluşturulamadı. Bağlantını kontrol edip tekrar dene.',
      );
      return null;
    }
  }

  /// Her boş/geçersiz alan için ayrı bir hata mesajı yazar, geçerliyse
  /// `true` döner.
  bool _validate(GymProfile profile, String email) {
    final nameError = profile.name.trim().isEmpty ? 'Salon adı gerekli.' : null;
    final cityError = profile.city.trim().isEmpty ? 'Şehir gerekli.' : null;
    final addressError = profile.address.trim().isEmpty
        ? 'Adres gerekli.'
        : null;
    // F8-4 — bu numarayla admin girişi yapılacağı için geçerli olmalı
    // (AppPhoneField'ın phone_numbers_parser tabanlı doğrulaması).
    final phoneError = profile.isPhoneValid
        ? null
        : 'Geçerli bir cep telefonu numarası gir.';
    // Egoractive Authentication Sistemi §9 — "Login ve rapor e-postası"
    // zorunlu, admin bununla OTP alıp giriş yapacak.
    final emailError = !email.contains('@') || email.trim().length < 4
        ? 'Geçerli bir email adresi gir.'
        : null;

    if (nameError == null &&
        cityError == null &&
        addressError == null &&
        phoneError == null &&
        emailError == null) {
      return true;
    }
    // copyWith'in `x ?? this.x` deseni "null geç" ile "hiç geçme"yi ayırt
    // edemediği için (biri geçersizken diğeri artık geçerli olan alanın
    // eski hatası temizlenemez), burada state doğrudan kuruluyor.
    state = CreateGymState(
      logoFile: state.logoFile,
      isExtractingPalette: state.isExtractingPalette,
      logoPalette: state.logoPalette,
      selectedPaletteColor: state.selectedPaletteColor,
      nameError: nameError,
      cityError: cityError,
      addressError: addressError,
      phoneError: phoneError,
      emailError: emailError,
    );
    return false;
  }
}
