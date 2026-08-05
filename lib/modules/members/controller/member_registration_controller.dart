import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../service/member_registration_service.dart';
import 'new_member_controller.dart';

part 'member_registration_controller.g.dart';

class MemberRegistrationState {
  const MemberRegistrationState({this.isSubmitting = false, this.errorMessage});

  final bool isSubmitting;
  final String? errorMessage;

  MemberRegistrationState copyWith({bool? isSubmitting, String? errorMessage, bool clearError = false}) {
    return MemberRegistrationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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

  /// Başarılıysa `true` döner (çağıran taraf sonraki adıma geçer).
  Future<bool> submit() async {
    if (state.isSubmitting) return false;

    final form = ref.read(newMemberControllerProvider);
    final name = '${form.firstName.trim()} ${form.lastName.trim()}'.trim();
    final phoneDigits = form.phoneDigits.trim();

    if (name.isEmpty || phoneDigits.length != 10) {
      state = state.copyWith(errorMessage: 'Lütfen ad, soyad ve telefon numarasını gir.');
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
        state = state.copyWith(isSubmitting: false, errorMessage: 'Bu telefon numarası zaten kayıtlı.');
        return false;
      }
      await service.registerMember(name: name, phoneNumber: phoneNumber, gymId: gymId);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Üye eklenemedi. Bağlantını kontrol edip tekrar dene.');
      return false;
    }
  }
}
