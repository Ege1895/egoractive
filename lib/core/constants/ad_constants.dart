import 'dart:io';

import 'package:flutter/foundation.dart';

/// F6-2 — debug build'lerde her zaman Google'ın TEST ad unit ID'lerini
/// kullanır; sadece release/profile build'de gerçek (AdMob konsolundaki)
/// ID'lere geçer. Geliştirirken gerçek ID'lerle kendi reklamına bakmak
/// AdMob'un "geçersiz trafik" tespitiyle hesabı askıya alabildiği için bu
/// ayrım önemli — `debugTestDeviceIds` doldurulmuş olsa bile ekstra bir
/// güvenlik katmanı.
String get bannerAdUnitId {
  if (kDebugMode) {
    return Platform.isIOS ? _iosTestBannerAdUnitId : _androidTestBannerAdUnitId;
  }
  return Platform.isIOS ? _iosBannerAdUnitId : _androidBannerAdUnitId;
}

const _androidTestBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const _iosTestBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';

/// AdMob konsolunda `com.egoragames.egoractive` için oluşturulan gerçek
/// banner reklam birimleri (Uygulamalar > [app] > Reklam birimleri).
const _androidBannerAdUnitId = 'ca-app-pub-7842412614783450/8018778123';
const _iosBannerAdUnitId = 'ca-app-pub-7842412614783450/9570749122';

/// F6-2 — Gerçek App ID'lerle test ederken kendi cihazının reklam
/// isteklerini AdMob'a "test isteği" olarak işaretlemek için buraya
/// cihaz ID'sini ekle. Değer, uygulamayı ilk kez gerçek App ID'yle
/// çalıştırdığında konsola şu formatta yazdırılır: "Use
/// RequestConfiguration.Builder.setTestDeviceIds(Arrays.asList("XXXX"))"
/// — o ID'yi buraya kopyala. Boş bırakılırsa hiçbir etkisi olmaz.
/// Bunu işaretlemeden gerçek cihazda kendi reklamına çok kez tıklamak/
/// bakmak, AdMob'un "geçersiz trafik" tespitiyle hesabı askıya alabilir.
const debugTestDeviceIds = <String>[];
