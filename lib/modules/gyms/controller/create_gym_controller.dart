import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_profile.dart';
import '../service/create_gym_service.dart';
import 'gym_profile_controller.dart';
import 'gym_theme_controller.dart';

part 'create_gym_controller.g.dart';

class CreateGymState {
  const CreateGymState({this.logoFile, this.isSubmitting = false, this.errorMessage});

  final XFile? logoFile;
  final bool isSubmitting;
  final String? errorMessage;

  CreateGymState copyWith({
    XFile? logoFile,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateGymState(
      logoFile: logoFile ?? this.logoFile,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// F2-1 — [GymSetupPanel]'in "Salonu oluştur" aksiyonu. Metin alanları
/// hâlâ [GymProfileController]/[GymThemeController] üzerinden bağlı; bu
/// controller sadece logo seçimini ve gönderim/validasyon durumunu tutar.
@riverpod
class CreateGymController extends _$CreateGymController {
  @override
  CreateGymState build() => const CreateGymState();

  Future<void> pickLogo() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;
      state = state.copyWith(logoFile: file, clearError: true);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Logo seçilemedi. Tekrar dene.');
    }
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
      final themeColor = ref.read(gymThemeControllerProvider.notifier).activeTheme.primary;
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
