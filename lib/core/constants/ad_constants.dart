import 'dart:io';

/// F6-2 — Google'ın herkese açık TEST banner ad unit ID'leri. Gerçek AdMob
/// hesabındaki ad unit ID'leri store'a yüklemeden önce buraya girilmeli —
/// aksi halde reklamlar hep test reklamı olarak kalır (gerçek gelir üretmez).
String get bannerAdUnitId => Platform.isIOS ? _iosTestBannerAdUnitId : _androidTestBannerAdUnitId;

const _androidTestBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const _iosTestBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';

/// F6-2 — Gerçek App ID'lerle test ederken kendi cihazının reklam
/// isteklerini AdMob'a "test isteği" olarak işaretlemek için buraya
/// cihaz ID'sini ekle. Değer, uygulamayı ilk kez gerçek App ID'yle
/// çalıştırdığında konsola şu formatta yazdırılır: "Use
/// RequestConfiguration.Builder.setTestDeviceIds(Arrays.asList("XXXX"))"
/// — o ID'yi buraya kopyala. Boş bırakılırsa hiçbir etkisi olmaz.
/// Bunu işaretlemeden gerçek cihazda kendi reklamına çok kez tıklamak/
/// bakmak, AdMob'un "geçersiz trafik" tespitiyle hesabı askıya alabilir.
const debugTestDeviceIds = <String>[];
