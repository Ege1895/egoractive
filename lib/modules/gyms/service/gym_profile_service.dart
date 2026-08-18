import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_profile.dart';

part 'gym_profile_service.g.dart';

/// Mock servis — F2'de gerçek `gyms/{gymId}` dokümanına bağlanacak.
class GymProfileService {
  const GymProfileService();

  GymProfile loadProfile() {
    // F2-9 — bu ekran kimliksiz yeni kullanıcının salon oluşturma (signup)
    // akışı; hiçbir alan gerçek bir kayda karşılık gelmediği için tamamı
    // boş başlamalı (telefon zaten admin bununla giriş yapacağı için boştu,
    // aynı kural diğer alanlar için de geçerli).
    return const GymProfile(name: '', city: '', phone: '', address: '');
  }
}

@riverpod
GymProfileService gymProfileService(GymProfileServiceRef ref) =>
    const GymProfileService();
