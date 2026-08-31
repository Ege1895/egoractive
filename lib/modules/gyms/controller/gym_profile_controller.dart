import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/gym_profile.dart';
import '../repository/gym_profile_repository.dart';

part 'gym_profile_controller.g.dart';

const _emptyProfile = GymProfile(name: '', city: '', phone: '', address: '');

@riverpod
Stream<GymProfile> _profileForGym(_ProfileForGymRef ref, String gymId) {
  return ref.watch(gymProfileRepositoryProvider).watchProfile(gymId);
}

@riverpod
class GymProfileController extends _$GymProfileController {
  @override
  GymProfile build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    // Aktif salon yoksa (F2-9 salon oluşturma akışı, henüz gymId atanmadan
    // önce) boş bir profil döner — GymSetupPanel bu state'i kendi form
    // buffer'ı olarak kullanır. Aktif salon varsa (GymInfoPanel, üye
    // sayısı vb.) `gyms/{gymId}` dokümanı gerçek zamanlı izlenir.
    if (gymId == null) return _emptyProfile;
    return ref.watch(_profileForGymProvider(gymId)).valueOrNull ??
        _emptyProfile;
  }

  /// [GymSetupPanel] (yeni salon oluşturma) her açıldığında çağırır — bu
  /// provider [GymInfoPanel] (mevcut salonu düzenleme) ile paylaşıldığı ve
  /// panel stack eski panelleri `maintainState` ile canlı tuttuğu için,
  /// `build()`'ın autoDispose ile kendiliğinden sıfırlanacağı garanti değil.
  void reset() => state = _emptyProfile;

  void updateName(String name) => state = state.copyWith(name: name);

  void updateCity(String city) => state = state.copyWith(city: city);

  /// F8-4 — [GymSetupPanel]'de salonu oluşturan kişi bu numarayla giriş
  /// yapacağı için (F2-9), [GymInfoPanel]'de ise sadece salonun iletişim
  /// numarası olarak kullanılır — ikisinde de artık tam E.164.
  void updatePhone(String e164, {required bool isValid}) =>
      state = state.copyWith(phone: e164, isPhoneValid: isValid);

  void updateAddress(String address) =>
      state = state.copyWith(address: address);

  /// [GymInfoPanel]'in "Kaydet" butonu tarafından çağrılır — mevcut state'i
  /// `gyms/{gymId}` dokümanına yazar. Aktif salon yoksa (beklenmeyen durum,
  /// bu panel her zaman girişli bir admin için açılır) hata fırlatır ki
  /// panel bunu kullanıcıya gösterebilsin.
  Future<void> save() async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) {
      throw StateError('Aktif salon bulunamadı.');
    }
    await ref.read(gymProfileRepositoryProvider).saveProfile(gymId, state);
  }
}
