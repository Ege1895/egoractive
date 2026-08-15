import 'dart:io';

/// F6-2 — Google'ın herkese açık TEST banner ad unit ID'leri. Gerçek AdMob
/// hesabındaki ad unit ID'leri store'a yüklemeden önce buraya girilmeli —
/// aksi halde reklamlar hep test reklamı olarak kalır (gerçek gelir üretmez).
String get bannerAdUnitId => Platform.isIOS ? _iosTestBannerAdUnitId : _androidTestBannerAdUnitId;

const _androidTestBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const _iosTestBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
