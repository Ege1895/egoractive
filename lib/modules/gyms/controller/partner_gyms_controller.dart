import 'dart:ui' show PlatformDispatcher;

import 'package:phone_form_field/phone_form_field.dart' show PhoneNumber;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/partner_gym.dart';
import '../service/partner_gym_service.dart';

part 'partner_gyms_controller.g.dart';

/// Cihazın sistem bölgesi — ayrı bir provider olarak sarılması BİLEREK:
/// `PlatformDispatcher.instance` doğrudan `dart:ui`'nin gerçek global
/// singleton'ı, Flutter'ın widget test altyapısındaki
/// `tester.platformDispatcher.localeTestValue` override'ı BUNU etkilemiyor
/// (sadece `WidgetsBinding` üzerinden erişilen değeri değiştiriyor) — bu
/// yüzden [partnerGyms] içine gömülseydi test edilemezdi. Bu ince provider
/// sayesinde testler Riverpod'un kendi `overrideWithValue`'uyla sahte bir
/// bölge enjekte edebiliyor.
@riverpod
String? deviceCountryCode(DeviceCountryCodeRef ref) =>
    PlatformDispatcher.instance.locale.countryCode;

/// Cihazın sistem bölgesindeki (ör. TR, US) salonlarla eşleşmeyenleri eler —
/// Amerika'daki bir kullanıcının Türkiye'deki anlaşmalı salonları görmesinin
/// bir anlamı yok. Salonun ülkesi kendi E.164 telefon numarasından (`+90...`
/// → TR) çözülür; ayrı bir "ülke" alanı tutmaya gerek yok, numara zaten
/// F8'den beri tam E.164. Cihazın bölgesi bilinmiyorsa (bazı emülatör/cihaz
/// konfigürasyonlarında `countryCode` null gelebilir) filtre uygulanmaz —
/// hiç göstermemektense tümünü göstermek tercih edilir.
@riverpod
Future<List<PartnerGym>> partnerGyms(PartnerGymsRef ref) async {
  final all = await ref.watch(partnerGymServiceProvider).fetchAll();
  final deviceCountry = ref.watch(deviceCountryCodeProvider);
  if (deviceCountry == null) return all;
  return all.where((gym) => _countryOf(gym.phone) == deviceCountry).toList();
}

String? _countryOf(String phone) {
  if (phone.isEmpty) return null;
  try {
    return PhoneNumber.parse(phone).isoCode.name;
  } catch (_) {
    return null;
  }
}
