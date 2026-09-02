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
  /// [GymSetupPanel]'in (henüz `gymId` yokken) yazdığı form buffer'ının asıl
  /// kaynağı — `state` DEĞİL, bu alan. Sebep: `build()`, izlediği
  /// `activeGymIdProvider`/`_profileForGymProvider` her yeniden çözüldüğünde
  /// (ör. token/auth stream'i `loading`'den `data(null)`'a geçince) YENİDEN
  /// çalışır ve dönen değer `state`'in yerini alır — `gymId == null` iken
  /// bu her seferinde sabit `_emptyProfile` dönseydi, kullanıcının o ana
  /// kadar `updateName`/`updateCity`/... ile yazdığı HER ŞEY, arka planda
  /// tamamen ilgisiz bir provider yeniden çözüldüğü anda sessizce silinirdi
  /// (gerçek rapor edilen hata: alanlar dolu göründüğü halde submit "gerekli"
  /// hatası veriyordu). `_buffer` bu Notifier örneği YAŞADIĞI sürece
  /// `build()`'ın kaç kez tekrar çalıştığından bağımsız kalıcıdır.
  GymProfile _buffer = _emptyProfile;

  @override
  GymProfile build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    // Aktif salon yoksa (F2-9 salon oluşturma akışı, henüz gymId atanmadan
    // önce) buffer'ı olduğu gibi döner. Aktif salon varsa (GymInfoPanel, üye
    // sayısı vb.) `gyms/{gymId}` dokümanı gerçek zamanlı izlenir.
    if (gymId == null) return _buffer;
    _buffer =
        ref.watch(_profileForGymProvider(gymId)).valueOrNull ?? _emptyProfile;
    return _buffer;
  }

  /// [GymSetupPanel] (yeni salon oluşturma) her açıldığında çağırır — bu
  /// provider [GymInfoPanel] (mevcut salonu düzenleme) ile paylaşıldığı ve
  /// panel stack eski panelleri `maintainState` ile canlı tuttuğu için,
  /// `build()`'ın autoDispose ile kendiliğinden sıfırlanacağı garanti değil.
  void reset() {
    _buffer = _emptyProfile;
    state = _buffer;
  }

  void updateName(String name) => _set(_buffer.copyWith(name: name));

  void updateCity(String city) => _set(_buffer.copyWith(city: city));

  /// F8-4 — [GymSetupPanel]'de salonu oluşturan kişi bu numarayla giriş
  /// yapacağı için (F2-9), [GymInfoPanel]'de ise sadece salonun iletişim
  /// numarası olarak kullanılır — ikisinde de artık tam E.164.
  void updatePhone(String e164, {required bool isValid}) =>
      _set(_buffer.copyWith(phone: e164, isPhoneValid: isValid));

  void updateAddress(String address) =>
      _set(_buffer.copyWith(address: address));

  void _set(GymProfile profile) {
    _buffer = profile;
    state = profile;
  }

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
