// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_gyms_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceCountryCodeHash() => r'0595608751aa5252982ff1b97b48b39049c9dbde';

/// Cihazın sistem bölgesi — ayrı bir provider olarak sarılması BİLEREK:
/// `PlatformDispatcher.instance` doğrudan `dart:ui`'nin gerçek global
/// singleton'ı, Flutter'ın widget test altyapısındaki
/// `tester.platformDispatcher.localeTestValue` override'ı BUNU etkilemiyor
/// (sadece `WidgetsBinding` üzerinden erişilen değeri değiştiriyor) — bu
/// yüzden [partnerGyms] içine gömülseydi test edilemezdi. Bu ince provider
/// sayesinde testler Riverpod'un kendi `overrideWithValue`'uyla sahte bir
/// bölge enjekte edebiliyor.
///
/// Copied from [deviceCountryCode].
@ProviderFor(deviceCountryCode)
final deviceCountryCodeProvider = AutoDisposeProvider<String?>.internal(
  deviceCountryCode,
  name: r'deviceCountryCodeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceCountryCodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeviceCountryCodeRef = AutoDisposeProviderRef<String?>;
String _$partnerGymsHash() => r'7db4716acba493404d077eeaaf7326e724465dae';

/// Cihazın sistem bölgesindeki (ör. TR, US) salonlarla eşleşmeyenleri eler —
/// Amerika'daki bir kullanıcının Türkiye'deki anlaşmalı salonları görmesinin
/// bir anlamı yok. Salonun ülkesi kendi E.164 telefon numarasından (`+90...`
/// → TR) çözülür; ayrı bir "ülke" alanı tutmaya gerek yok, numara zaten
/// F8'den beri tam E.164. Cihazın bölgesi bilinmiyorsa (bazı emülatör/cihaz
/// konfigürasyonlarında `countryCode` null gelebilir) filtre uygulanmaz —
/// hiç göstermemektense tümünü göstermek tercih edilir.
///
/// Copied from [partnerGyms].
@ProviderFor(partnerGyms)
final partnerGymsProvider =
    AutoDisposeFutureProvider<List<PartnerGym>>.internal(
      partnerGyms,
      name: r'partnerGymsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$partnerGymsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PartnerGymsRef = AutoDisposeFutureProviderRef<List<PartnerGym>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
