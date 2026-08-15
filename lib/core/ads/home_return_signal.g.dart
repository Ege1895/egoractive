// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_return_signal.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeReturnSignalHash() => r'e9c2111fdf919a9e515c1475c706eb627ee4a213';

/// F6-2 — kullanıcı üye shell'inin ana ekranına "döndüğünde" (Ana Sayfa
/// sekmesine dokunarak ya da geri navigasyonuyla shell'e geri gelerek)
/// artan bir sayaç. AdMob politikası gereği interstitial reklamlar rastgele
/// bir zamanlayıcıyla değil, doğal bir geçiş anında gösterilmeli — bu sinyal
/// [AdInterstitialGate]'e "şimdi doğal bir geçiş anı" bilgisini taşır.
///
/// Copied from [HomeReturnSignal].
@ProviderFor(HomeReturnSignal)
final homeReturnSignalProvider =
    AutoDisposeNotifierProvider<HomeReturnSignal, int>.internal(
      HomeReturnSignal.new,
      name: r'homeReturnSignalProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeReturnSignalHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeReturnSignal = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
