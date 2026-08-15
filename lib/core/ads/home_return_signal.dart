import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_return_signal.g.dart';

/// F6-2 — kullanıcı üye shell'inin ana ekranına "döndüğünde" (Ana Sayfa
/// sekmesine dokunarak ya da geri navigasyonuyla shell'e geri gelerek)
/// artan bir sayaç. AdMob politikası gereği interstitial reklamlar rastgele
/// bir zamanlayıcıyla değil, doğal bir geçiş anında gösterilmeli — bu sinyal
/// [AdInterstitialGate]'e "şimdi doğal bir geçiş anı" bilgisini taşır.
@riverpod
class HomeReturnSignal extends _$HomeReturnSignal {
  @override
  int build() => 0;

  void notify() => state++;
}
