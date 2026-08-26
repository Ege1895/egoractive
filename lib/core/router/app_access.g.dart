// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_access.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appAccessHash() => r'e833bba760d22269369af488ccd6584991b5a871';

/// Salon Abonelik ve Erişim Akışı — tek reaktif erişim kararı kaynağı.
/// Önceki tek seferlik (Future tabanlı) rol kontrolünün yerini alır: rol
/// DEĞİŞTİĞİNDE olduğu kadar, salonun `subscriptionStatus`'u CANLI olarak
/// değiştiğinde de (uygulama açıkken trial biterse/abone olunursa) tepki
/// verir — `subscriptionStatus` bir custom claim değil canlı bir Firestore
/// alanı olduğu için token'ın yenilenmesini beklemeye gerek yok.
///
/// Salonun abonelik durumu `subscriptionStateForGymProvider` üzerinden
/// izlenir — `SubscriptionController` da AYNI provider'ı izliyor (bkz. o
/// dosyadaki yorum), aynı `gyms/{gymId}` dokümanı için iki ayrı Firestore
/// listener'ı açılmasın diye. Buradaki `ref.listen(..., fireImmediately: true)`
/// köprüsü BİLEREK kullanılıyor (`ref.watch` + "veri gelene kadar hiç yield
/// etme" yaklaşımı yerine): `ref.listen`'in geri çağırması provider'ın HER
/// durum geçişinde (loading→data, data→data, data→error) kesin olarak
/// tetiklenir — ilk sürümde "hâlâ loading'ken hiç yield etmeden dön"
/// deseni, veri geldiğinde üst provider'ın yeniden tetiklenmesine
/// güveniyordu ve gerçek bir cihazda kalıcı bir giriş kilitlenmesine yol
/// açtı (bkz. "Çmt Saloon" salonu, 2026-08-26) — kesin kaynağı doğrulanamadı
/// ama bu köprü, aynı belirsizliğe bağlı kalmadan sorunu ortadan kaldırıyor.
///
/// Copied from [appAccess].
@ProviderFor(appAccess)
final appAccessProvider = AutoDisposeStreamProvider<AppAccess>.internal(
  appAccess,
  name: r'appAccessProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appAccessHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppAccessRef = AutoDisposeStreamProviderRef<AppAccess>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
