import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_profile.dart';

part 'gym_profile_service.g.dart';

/// Mock servis — F2'de gerçek `gyms/{gymId}` dokümanına bağlanacak.
class GymProfileService {
  const GymProfileService();

  GymProfile loadProfile() {
    // F2-9 — bu ekran artık kimliksiz yeni kullanıcının salon oluşturma
    // (signup) akışı; telefon alanı boş başlamalı çünkü admin bununla
    // giriş yapacak — örnek/sahte bir numarayla yanlışlıkla kaydolmasın.
    return const GymProfile(
      name: 'Vira Performans Stüdyo',
      city: 'İstanbul',
      phone: '',
      address: 'Bağdat Cad. No 214/3, Kadıköy',
    );
  }
}

@riverpod
GymProfileService gymProfileService(GymProfileServiceRef ref) => const GymProfileService();
