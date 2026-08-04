import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_profile.dart';

part 'gym_profile_service.g.dart';

/// Mock servis — F2'de gerçek `gyms/{gymId}` dokümanına bağlanacak.
class GymProfileService {
  const GymProfileService();

  GymProfile loadProfile() {
    return const GymProfile(
      name: 'Vira Performans Stüdyo',
      city: 'İstanbul',
      phone: '0216 384 12 90',
      address: 'Bağdat Cad. No 214/3, Kadıköy',
    );
  }
}

@riverpod
GymProfileService gymProfileService(GymProfileServiceRef ref) => const GymProfileService();
