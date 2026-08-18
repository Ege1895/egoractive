import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../service/member_registration_service.dart';
import 'new_member_controller.dart';

part 'member_registration_controller.g.dart';

class MemberRegistrationState {
  const MemberRegistrationState({
    this.isSubmitting = false,
    this.errorMessage,
    this.nameError,
    this.phoneError,
    this.trainerError,
    this.createdMemberId,
  });

  final bool isSubmitting;

  /// Alana bağlanamayan hatalar (aktif salon bulunamadı, network) için —
  /// field-seviyeli hatalar aşağıdaki ayrı alanlarda tutulur.
  final String? errorMessage;
  final String? nameError;
  final String? phoneError;
  final String? trainerError;

  /// F3-2 — paket satış akışı `memberPackages` dokümanını bu üyeye
  /// bağlamak için kullanır.
  final String? createdMemberId;

  MemberRegistrationState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    String? createdMemberId,
    bool clearError = false,
  }) {
    return MemberRegistrationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdMemberId: createdMemberId ?? this.createdMemberId,
    );
  }
}

/// F2-2 — [MemberInfoPanel]'in (yeni üye akışı) ilk adımdaki gerçek kayıt
/// aksiyonu. Form alanları [NewMemberController]'da tutuluyor; bu controller
/// sadece validasyon + gönderim durumunu tutar.
@riverpod
class MemberRegistrationController extends _$MemberRegistrationController {
  @override
  MemberRegistrationState build() => const MemberRegistrationState();

  /// Başarılıysa `true` döner (çağıran taraf sonraki adıma geçer). Önceki
  /// sürüm "zaten kayıtlı"/boş alan/antrenör seçilmedi hatalarının hepsini
  /// tek bir genel banner'da gösteriyordu — artık her biri ilgili alanın
  /// altında.
  Future<bool> submit() async {
    if (state.isSubmitting) return false;

    final form = ref.read(newMemberControllerProvider);
    final name = '${form.firstName.trim()} ${form.lastName.trim()}'.trim();
    final phoneDigits = form.phoneDigits.trim();

    final nameError = name.isEmpty ? 'Ad ve soyad gerekli.' : null;
    final phoneError = phoneDigits.length != 10
        ? 'Geçerli bir telefon numarası gir.'
        : null;
    final trainerError = form.trainerId == null || form.trainerName == null
        ? 'Bir antrenör seç.'
        : null;
    if (nameError != null || phoneError != null || trainerError != null) {
      state = MemberRegistrationState(
        nameError: nameError,
        phoneError: phoneError,
        trainerError: trainerError,
      );
      return false;
    }

    final gymId = await ref.read(activeGymIdProvider.future);
    if (gymId == null) {
      state = state.copyWith(errorMessage: 'Aktif bir salon bulunamadı.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    final phoneNumber = '+90$phoneDigits';
    final service = ref.read(memberRegistrationServiceProvider);
    try {
      if (await service.phoneNumberIsTaken(phoneNumber)) {
        state = MemberRegistrationState(
          phoneError: 'Bu telefon numarası zaten kayıtlı.',
        );
        return false;
      }
      final memberId = await service.registerMember(
        name: name,
        phoneNumber: phoneNumber,
        gymId: gymId,
        trainerId: form.trainerId!,
        trainerName: form.trainerName!,
        gender: form.gender,
      );
      state = state.copyWith(isSubmitting: false, createdMemberId: memberId);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Üye eklenemedi. Bağlantını kontrol edip tekrar dene.',
      );
      return false;
    }
  }
}
