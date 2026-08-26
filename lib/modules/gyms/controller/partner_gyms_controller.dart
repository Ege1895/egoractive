import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/partner_gym.dart';
import '../service/partner_gym_service.dart';

part 'partner_gyms_controller.g.dart';

@riverpod
Future<List<PartnerGym>> partnerGyms(PartnerGymsRef ref) {
  return ref.watch(partnerGymServiceProvider).fetchAll();
}
