import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/partner_gym.dart';

part 'partner_gym_service.g.dart';

/// Girişten önce (henüz auth yok) çağrılan `listPartnerGyms` callable'ı —
/// auth gerektirmez, bkz. `functions/src/callable/list-partner-gyms.ts`.
class PartnerGymService {
  const PartnerGymService();

  Future<List<PartnerGym>> fetchAll() async {
    // Varsayılan 60s timeout girişten önceki bu ekranda kullanıcıyı süresiz
    // bir spinner'da bırakabiliyordu (kullanıcı raporu: uygulamayı zorla
    // kapatmak zorunda kaldı) — 15s'e indirilip `PartnerGymsPanel`'e bir
    // "tekrar dene" aksiyonu eklendi, en azından takılma süresiz olmuyor.
    final callable = FirebaseFunctions.instance.httpsCallable(
      'listPartnerGyms',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
    );
    final result = await callable.call<Map<String, dynamic>>();
    final rawGyms = (result.data['gyms'] as List<dynamic>?) ?? const [];
    return rawGyms
        .map((raw) => _fromMap(Map<String, dynamic>.from(raw as Map)))
        .toList();
  }

  PartnerGym _fromMap(Map<String, dynamic> data) {
    return PartnerGym(
      id: (data['id'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      address: (data['address'] as String?) ?? '',
      logoUrl: (data['logoUrl'] as String?) ?? '',
    );
  }
}

@riverpod
PartnerGymService partnerGymService(PartnerGymServiceRef ref) =>
    const PartnerGymService();
