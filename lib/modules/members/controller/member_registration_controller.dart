import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../service/member_registration_service.dart';
import 'new_member_controller.dart';
import '../../../core/remote_config/remote_config_service.dart';

part 'member_registration_controller.g.dart';

class MemberRegistrationState {
  const MemberRegistrationState({
    this.isSubmitting = false,
    this.errorMessage,
    this.nameError,
    this.phoneError,
    this.trainerError,
    this.createdMemberId,
    this.isRenewal = false,
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

  /// F5-17 — [AdminMemberDetailPanel]'deki "Paketi Yenile" butonundan
  /// mevcut bir üye için başlatıldıysa `true`. `NewMembershipPackagePanel`/
  /// `NewMembershipPaymentPanel` bu bayrağa göre "Vazgeç"/kaydetme sonrası
  /// tüm sihirbazı (`popToRoot`) değil, sadece kendi üstüne eklenen adımları
  /// (`pop`) kapatıp üye detayına döner.
  final bool isRenewal;

  MemberRegistrationState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    String? createdMemberId,
    bool clearError = false,
    bool? isRenewal,
  }) {
    return MemberRegistrationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdMemberId: createdMemberId ?? this.createdMemberId,
      isRenewal: isRenewal ?? this.isRenewal,
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

    final nameError = name.isEmpty ? 'Ad ve soyad gerekli.' : null;
    final phoneError = form.isPhoneValid
        ? null
        : ref.read(rcTextProvider(RemoteConfigKeys.commonInvalidPhoneError));
    final trainerError = form.trainerId == null || form.trainerName == null
        ? ref.read(
            rcTextProvider(
              RemoteConfigKeys.membersRegistrationTrainerRequiredError,
            ),
          )
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
      state = state.copyWith(
        errorMessage: ref.read(
          rcTextProvider(RemoteConfigKeys.commonNoActiveGymError),
        ),
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    final phoneNumber = form.phoneE164;
    final service = ref.read(memberRegistrationServiceProvider);
    try {
      if (await service.phoneNumberIsTaken(phoneNumber)) {
        state = MemberRegistrationState(
          phoneError: ref.read(
            rcTextProvider(RemoteConfigKeys.membersRegistrationPhoneTakenError),
          ),
        );
        return false;
      }
      final memberId = await service.registerMember(
        name: name,
        phoneNumber: phoneNumber,
        gymId: gymId,
        trainerId: form.trainerId!,
        trainerName: form.trainerName!,
        registeredAt: form.registeredAt,
        gender: form.gender,
        canConfirmAttendance: form.canConfirmAttendance,
      );
      state = state.copyWith(
        isSubmitting: false,
        createdMemberId: memberId,
        isRenewal: false,
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: ref.read(
          rcTextProvider(RemoteConfigKeys.membersRegistrationCreateError),
        ),
      );
      return false;
    }
  }

  /// [MemberInfoPanel]'in mevcut üye düzenleme modu — daha önce sadece
  /// paneli kapatıp hiçbir şey yazmıyordu (false-success).
  Future<bool> submitEdit({required String memberId}) async {
    if (state.isSubmitting) return false;

    final form = ref.read(newMemberControllerProvider);
    final name = '${form.firstName.trim()} ${form.lastName.trim()}'.trim();

    final nameError = name.isEmpty ? 'Ad ve soyad gerekli.' : null;
    final phoneError = form.isPhoneValid
        ? null
        : ref.read(rcTextProvider(RemoteConfigKeys.commonInvalidPhoneError));
    if (nameError != null || phoneError != null) {
      state = MemberRegistrationState(
        nameError: nameError,
        phoneError: phoneError,
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref
          .read(memberRegistrationServiceProvider)
          .updateMember(
            memberId: memberId,
            name: name,
            phoneNumber: form.phoneE164,
            trainerId: form.trainerId,
            trainerName: form.trainerName,
            gender: form.gender,
            canConfirmAttendance: form.canConfirmAttendance,
          );
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: ref.read(
          rcTextProvider(RemoteConfigKeys.membersRegistrationUpdateError),
        ),
      );
      return false;
    }
  }

  /// [AdminMemberDetailPanel]'deki "Paketi Yenile" butonu — 1. adımı (üye
  /// bilgileri) atlayıp doğrudan `NewMembershipPackagePanel`'e (2. adım)
  /// geçmeden önce bu üyeyi paket akışının yazma hedefi olarak işaretler.
  void beginRenewal(String memberId) {
    state = MemberRegistrationState(createdMemberId: memberId, isRenewal: true);
  }

  void reset() => state = const MemberRegistrationState();
}
