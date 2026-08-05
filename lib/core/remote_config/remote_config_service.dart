import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_config_service.g.dart';

/// Remote Config parametre anahtarları (CLAUDE.md §2.5 — runtime'da
/// değişebilecek iş kuralı değerleri buradan okunur). `screenTexts*` anahtarları
/// panellerdeki static UI metinlerini (admin/antrenör/üye girdisi hariç) tutar —
/// kullanıcının kendi girdiği veri asla burada değil.
abstract final class RemoteConfigKeys {
  static const sessionReminderMinutesBefore = 'sessionReminderMinutesBefore';
  static const defaultGroupSessionCapacity = 'defaultGroupSessionCapacity';
  static const feedbackReminderDayOfMonth = 'feedbackReminderDayOfMonth';
  static const freeVersionAdsEnabled = 'freeVersionAdsEnabled';
  static const featureFlags = 'featureFlags';
  static const screenTextsCommon = 'screenTextsCommon';
  static const screenTextsShell = 'screenTextsShell';
  static const screenTextsAuth = 'screenTextsAuth';
  static const screenTextsBadges = 'screenTextsBadges';
  static const screenTextsEvents = 'screenTextsEvents';
  static const screenTextsExpenses = 'screenTextsExpenses';
  static const screenTextsFeedback = 'screenTextsFeedback';
  static const screenTextsGroupSessions = 'screenTextsGroupSessions';
  static const screenTextsGyms = 'screenTextsGyms';
  static const screenTextsMeasurements = 'screenTextsMeasurements';
  static const screenTextsMembers = 'screenTextsMembers';
  static const screenTextsNotifications = 'screenTextsNotifications';
  static const screenTextsPackages = 'screenTextsPackages';
  static const screenTextsSessions = 'screenTextsSessions';
  static const screenTextsTrainers = 'screenTextsTrainers';
}

/// Firebase Remote Config'e tip güvenli erişim katmanı. `FirebaseRemoteConfig.instance`
/// bu dosya dışında hiçbir yerde çağrılmaz (CLAUDE.md §2.5).
class RemoteConfigService {
  const RemoteConfigService();

  static const Map<String, Object> _defaults = {
    RemoteConfigKeys.sessionReminderMinutesBefore: 60,
    RemoteConfigKeys.defaultGroupSessionCapacity: 6,
    RemoteConfigKeys.feedbackReminderDayOfMonth: -1,
    RemoteConfigKeys.freeVersionAdsEnabled: true,
    RemoteConfigKeys.featureFlags: '{}',
    RemoteConfigKeys.screenTextsCommon: '{"vazgec":"Vazgeç","kaydet":"Kaydet","duzenle":"Düzenle","kapat":"Kapat","degistir":"Değiştir","cikisYap":"Çıkış yap","hesabimiSil":"Hesabımı sil","studyoKurallariNav":"Stüdyo kuralları","seansiErtele":"Seansı ertele","gelicem":"Gelicem","gelmeyecegim":"Gelmeyeceğim","anaSayfaTab":"Ana Sayfa","profilTab":"Profil","telefonLabel":"Telefon","tumuFilter":"Tümü","tamamlandi":"Tamamlandı","iptalLabel":"İptal","kalanDersLabel":"Kalan ders","paketiYokFilter":"Paketi yok","seansSayisiLabel":"Seans sayısı","addSeansButton":"+ Seans","olcum6AySectionHeader":"ÖLÇÜM · 6 AY","dersGecmisiSectionHeader":"DERS GEÇMİŞİ","uyeDetayiTitle":"Üye detayı","buGundeSeansYok":"Bu günde seans yok.","bitisLabel":"Bitiş"}',
    RemoteConfigKeys.screenTextsShell: '{"memberTabDerslerim":"Derslerim","memberTabOlcumlerim":"Ölçümlerim","memberTabKesfet":"Keşfet","trainerTabTakvimim":"Takvimim","trainerTabUyelerim":"Üyelerim","trainerTabRaporum":"Raporum","adminTabUyeler":"Üyeler","adminTabSeanslar":"Seanslar","adminTabFinans":"Finans","adminTabAyarlar":"Ayarlar","rolePickerMemberButton":"Üye","rolePickerTrainerButton":"Antrenör","rolePickerAdminButton":"Admin","rolePickerGymSetupButton":"Admin · Salon Kurulumu (ilk kurulum)"}',
    RemoteConfigKeys.screenTextsAuth: '{"profileTitle":"Profilim","phoneNumberLabel":"Telefon numarası","loginButton":"Giriş yap","devMenuButton":"Geliştirici menüsü","selectAvatarLabel":"Avatarını seç","badgesNavLabel":"Rozetlerim","giveFeedbackNavLabel":"Geri bildirim ver","sessionRemindersToggleTitle":"Ders hatırlatmaları","sessionRemindersToggleDescription":"Dersinden 2 saat önce bildirim","deleteAccountConfirmTitle":"Profilim"}',
    RemoteConfigKeys.screenTextsBadges: '{"title":"Rozetlerim"}',
    RemoteConfigKeys.screenTextsEvents: '{"adminListTitle":"Etkinlikler","addEventButton":"+ Etkinlik","attendingLabel":"Katılan","capacityLabel":"Kontenjan","createTitle":"Etkinlik oluştur","capacityEmptyMeansUnlimitedHelper":"Boş bırakırsanız sınırsız olur","nameFieldLabel":"Etkinlik adı","locationFieldLabel":"Lokasyon","dateFieldLabel":"Tarih","timeFieldLabel":"Saat","descriptionFieldLabel":"Açıklama","createSubmitButton":"Etkinliği oluştur"}',
    RemoteConfigKeys.screenTextsExpenses: '{"listTitle":"Giderler","addExpenseButton":"+ Gider","categoriesSectionHeader":"KATEGORİLER","recentEntriesSectionHeader":"SON KAYITLAR","addTitle":"Gider ekle","categoryFieldLabel":"Kategori","recurringToggleLabel":"Her ay tekrar et","recurringToggleDescription":"Kira ve fatura gibi sabit giderler için","amountFieldLabel":"Tutar (₺)","descriptionFieldLabel":"Açıklama","dateFieldLabel":"Tarih","submitButton":"Gideri kaydet"}',
    RemoteConfigKeys.screenTextsFeedback: '{"adminListTitle":"Geri bildirimler","memberFormTitle":"Geri bildirim","commentSectionHeader":"YORUMUN (İSTEĞE BAĞLI)"}',
    RemoteConfigKeys.screenTextsGroupSessions: '{"adminListTitle":"Grup dersleri","addGroupSessionButton":"+ Grup dersi","capacitySuffixLabel":"kontenjan","viewParticipantsLink":"Katılımcıları gör","discoverTitle":"Keşfet","discoverTabGroupSessions":"Grup dersleri","discoverTabEvents":"Etkinlikler","createTitle":"Grup dersi oluştur","daysFieldLabel":"Günler","capacityFieldLabel":"Kontenjan","onlineBookingToggleLabel":"Online rezervasyona açık","onlineBookingToggleDescription":"Üyeler Keşfet\'ten katılabilir","defaultLocationLabel":"Stüdyo","nameFieldLabel":"Ders adı","startTimeFieldLabel":"Başlangıç saati","durationFieldLabel":"Süre","createSubmitButton":"Grup dersini oluştur"}',
    RemoteConfigKeys.screenTextsGyms: '{"adminHomeCompletedWord":"tamamlanan","adminHomeTrainerPerformanceSection":"ANTRENÖR PERFORMANSI","adminHomeUpcomingPaymentsSection":"ÖDEME VAKTİ YAKLAŞAN","adminHomePendingFeedbackLabel":"Bekleyen geri bildirim","adminHomeTotalSessionsLabel":"Toplam seans","adminHomeCompletedLabel":"Tamamlanan","adminHomeEstimatedRevenueLabel":"Tahmini ciro","adminHomeExpenseLabel":"Gider","permissionsTitle":"Yetki ayarları","permissionsReminderDropdownLabel":"Seans bitimi eğitmene ne zaman hatırlatılsın?","permissionsReminderDescription":"Bildirim seans bitiminden sonra gider","settingsTitle":"Ayarlar","settingsNavGymInfo":"Salon bilgileri","settingsNavTrainerManagement":"Antrenör yönetimi","settingsNavStudioPackages":"Stüdyo paketleri","settingsNavSessionManagement":"Ders / seans yönetimi","settingsNavGroupSessions":"Grup dersleri","settingsNavEvents":"Etkinlikler","settingsNavPermissions":"Yetki ayarları","settingsNavFeedback":"Geri bildirimler","settingsNavSendNotification":"Bildirim gönder","gymInfoTitle":"Salon bilgileri","gymInfoLogoSection":"LOGO","gymInfoLogoHelper":"Kare, en az 512×512 px PNG yükleyin.","gymInfoChangeLogoButton":"Logoyu değiştir","gymInfoThemeColorSection":"TEMA RENGİ","gymInfoPreviewLabel":"Önizleme","gymInfoPrimaryButtonLabel":"Birincil buton","gymInfoSeeAllThemesLink":"Tüm temaları gör ›","gymInfoNameFieldLabel":"Salon adı","gymInfoAddressFieldLabel":"Adres","gymSetupStepHeader":"KURULUM 1 / 1","gymSetupTitle":"Salonunu tanımla","gymSetupLogoLabel":"Salon logosu","gymSetupChooseLogoButton":"Logo seç","gymSetupThemeColorLabel":"Tema rengi","gymSetupCityFieldLabel":"Şehir","gymSetupSubmitButton":"Salonu oluştur ve girişi tamamla","themesTitle":"Temalar","themesMemberPreviewSection":"ÜYE EKRANI ÖNİZLEMESİ","themesShowLogoSilhouetteToggleLabel":"Logo silüetini arka planda göster","themesShowLogoSilhouetteToggleDescription":"Üye ve antrenör ekranlarında %25 opaklıkla","themesApplyToAllButton":"Temayı tüm üyelere uygula","addThemeTitle":"Tema ekle","addThemePaletteLabel":"Palet","addThemeColorCodeLabel":"Renk kodu","addThemeColorHelper":"Paletten seçin ya da kendi HEX kodunuzu yazın.","addThemeUseLogoQuestion":"Salon logosu kullanılsın mı?","addThemePreviewSection":"ÖNİZLEME","addThemeUseLogoOption":"Evet, logoyu kullan","addThemeFlatBackgroundOption":"Hayır, düz zemin","addThemeSubmitButton":"Temayı kaydet ve uygula","addThemeNameFieldLabel":"Tema adı","studioRulesTitle":"Stüdyo kuralları","editStudioRulesTitle":"Kuralları düzenle"}',
    RemoteConfigKeys.screenTextsMeasurements: '{"addTitle":"Yeni ölçüm","measurementDateLabel":"Ölçüm tarihi","measurementsSection":"ÖLÇÜLER","unitCm":"cm","title":"Ölçümlerim","selectedPointLabel":"Seçili nokta","historySection":"ÖLÇÜM GEÇMİŞİ"}',
    RemoteConfigKeys.screenTextsMembers: '{"detailPaymentStatusLabel":"Ödeme durumu","detailRemainingSessionsLabel":"Kalan ders","detailMakeupLabel":"Telafi","detailTotalLabel":"Toplam","detailPaidLabel":"Ödendi","detailRemainingAmountLabel":"Kalan","listTitle":"Üyeler","addMemberButton":"+ Üye ekle","listEmptyState":"Bu filtreye uyan üye yok.","filterActive":"Aktif","filterExpiring":"Bitiyor","infoStepIndicator1":"1 / 3","infoLoginHelper":"Üye bu numarayla giriş yapar, şifre yok.","genderFieldLabel":"Cinsiyet","trainerFieldLabel":"Antrenör","registrationDateFieldLabel":"Kayıt tarihi","selectTrainerButton":"Antrenör seç","firstNameFieldLabel":"Ad","lastNameFieldLabel":"Soyad","birthYearFieldLabel":"Doğum yılı","heightFieldLabel":"Boy","noteFieldLabel":"Not (isteğe bağlı)","paymentTitle":"Ödeme bilgisi","paymentStepIndicator3":"3 / 3","paymentTotalLabel":"Toplam tutar","paymentPaidLabel":"Ödendi","paymentRemainingLabel":"Kalan ödeme","paymentAutoCalculatedHelper":"Otomatik hesaplanır","paymentDueDateFieldLabel":"Son ödeme tarihi","paymentEnterAmountHelper":"Ödenen tutarı gir","paymentFullOption":"Tam ödendi","paymentHalfOption":"Yarısı","paymentOtherOption":"Diğer","newMembershipTitle":"Yeni üyelik","newMembershipStepIndicator2":"2 / 3","packageSelectSection":"PAKET SEÇ","makeupSessionCountLabel":"Telafi seans sayısı","makeupSessionHelper":"Paket bitince kullanılabilir","startDateFieldLabel":"Başlangıç tarihi","endDateFieldLabel":"Bitiş tarihi","goToPaymentButton":"Ödeme bilgisine geç"}',
    RemoteConfigKeys.screenTextsNotifications: '{"title":"Bildirim gönder","targetQuestionLabel":"Kime gidecek?","targetSingleMemberOption":"Tek üye","targetWholeGymOption":"Tüm salon","previewLabel":"Önizleme","selectMemberButton":"Üye seç","titleFieldLabel":"Başlık","messageFieldLabel":"Mesaj"}',
    RemoteConfigKeys.screenTextsPackages: '{"listTitle":"Paketler","addPackageButton":"+ Paket ekle","editSessionTypeFieldLabel":"Ders tipi","editOnSaleToggleLabel":"Satışta","editOnSaleToggleDescription":"Kapalıysa yeni üyeliklerde görünmez","deletePackageButton":"Paketi sil","editNameFieldLabel":"Paket adı","editValidityDaysFieldLabel":"Geçerlilik (gün)","editPriceFieldLabel":"Fiyat (₺)","memberPackageTitle":"Paketim","remainingWord":"kalan","trainerOwnerLabel":"Antrenörün","startLabel":"Başlangıç"}',
    RemoteConfigKeys.screenTextsSessions: '{"calendarTitle":"Takvim","calendarSlotTimeLabel":"Saat","calendarSlotStatusLabel":"Durum","attendanceAnswerLabel":"Cevabı","attendanceAnswerTimeLabel":"Cevap saati","attendanceMemberNoteLabel":"Üyenin notu","attendanceBackToCalendarButton":"Takvime dön","managementTitle":"Seanslar","managementEmptyState":"Bu güne uyan seans yok.","filterScheduled":"Planlandı","changeTrainerAction":"Antrenörü değiştir","cancelSessionAction":"Seansı iptal et","confirmTitle":"Ders onayı","confirmAttendingAnswerText":"Geleceğini bildirdin","confirmNotAttendingAnswerText":"Gelmeyeceğini bildirdin","confirmChangeAnswerButton":"Cevabımı değiştir","memberHomeThisWeekSection":"BU HAFTA","memberHomeSeePackageButton":"Paketimi gör","trainerNotificationsTitle":"Bildirimler","completionTitle":"Seans onayı","completionMemberNoShowOption":"Üye gelmedi","completionUndoButton":"Geri al","listTitle":"Derslerim","listViewToggle":"Liste","calendarViewToggle":"Takvim","upcomingSection":"YAKLAŞAN","pastSection":"GEÇMİŞ"}',
    RemoteConfigKeys.screenTextsTrainers: '{"managementTitle":"Antrenörler","addTrainerButton":"+ Antrenör ekle","specialtyFieldLabel":"Uzmanlık","addTrainerFormTitle":"Antrenör ekle","fullNameFieldLabel":"Ad soyad","addTrainerSubmitButton":"Antrenörü ekle","homeAwaitingApprovalSection":"ONAYINIZI BEKLİYOR","homeTodayScheduleSection":"BUGÜNKÜ PROGRAMINIZ","homeNoShowLabel":"Gelmedi","homeTodaySessionsLabel":"Bugünkü seans","homeCompletedLabel":"Tamamlanan","homeFreeSlotLabel":"Boş saat","memberDetailCreateSessionButton":"Seans oluştur","memberDetailAddMeasurementButton":"Ölçüm ekle","memberDetailRemainingSessionsLabel":"Kalan ders","memberDetailPackageEndLabel":"Paket bitişi","calendarTitle":"Takvimim","calendarWeekToggle":"Hafta","calendarMonthToggle":"Ay","calendarMarkCompletedAction":"Tamamlandı işaretle","membersListTitle":"Üyelerim","membersFilterExpiring":"Paketi bitiyor","membersRemainingSessionsSuffix":"kalan ders","reportTitle":"Seans raporum","reportEarnedCommissionLabel":"Kazanılan prim","reportDetailLink":"Detay","reportStartDateFieldLabel":"Başlangıç t.","reportEndDateFieldLabel":"Bitiş t.","reportOneOnOneToggle":"Birebir","reportGroupToggle":"Grup","profileFooterText":"Egoractive · Egora Games · Sürüm 1.0"}',
  };

  int get sessionReminderMinutesBefore => getInt(RemoteConfigKeys.sessionReminderMinutesBefore);

  int get defaultGroupSessionCapacity => getInt(RemoteConfigKeys.defaultGroupSessionCapacity);

  /// Ayın son günü için -1 döner (ör. Şubat'ta 28/29'u sabit kodlamamak için).
  int get feedbackReminderDayOfMonth => getInt(RemoteConfigKeys.feedbackReminderDayOfMonth);

  bool get freeVersionAdsEnabled => getBool(RemoteConfigKeys.freeVersionAdsEnabled);

  /// Ham JSON'u map'e çevirir; parse hatasında veya boşsa boş obje döner —
  /// tek bir bozuk RC değeri yüzünden uygulama çökmez.
  Map<String, dynamic> get featureFlags => _getJsonMap(RemoteConfigKeys.featureFlags);

  /// Birden fazla panelde tekrar eden ortak static metinler (buton/label/section).
  Map<String, dynamic> get commonTexts => _getJsonMap(RemoteConfigKeys.screenTextsCommon);

  /// Rol bazlı tab bar ve rol seçici ekranındaki static metinler.
  Map<String, dynamic> get shellTexts => _getJsonMap(RemoteConfigKeys.screenTextsShell);

  /// auth modülü (Splash, Telefon Girişi, Profil, Hesap Silme) static metinleri.
  Map<String, dynamic> get authTexts => _getJsonMap(RemoteConfigKeys.screenTextsAuth);

  /// badges modülü static metinleri.
  Map<String, dynamic> get badgesTexts => _getJsonMap(RemoteConfigKeys.screenTextsBadges);

  /// events modülü static metinleri.
  Map<String, dynamic> get eventsTexts => _getJsonMap(RemoteConfigKeys.screenTextsEvents);

  /// expenses modülü static metinleri.
  Map<String, dynamic> get expensesTexts => _getJsonMap(RemoteConfigKeys.screenTextsExpenses);

  /// feedback modülü static metinleri.
  Map<String, dynamic> get feedbackTexts => _getJsonMap(RemoteConfigKeys.screenTextsFeedback);

  /// group_sessions modülü static metinleri.
  Map<String, dynamic> get groupSessionsTexts => _getJsonMap(RemoteConfigKeys.screenTextsGroupSessions);

  /// gyms modülü (Admin Ana Sayfa, Ayarlar, Salon Bilgileri/Kurulum/Temalar, Yetki Ayarları, Stüdyo Kuralları) static metinleri.
  Map<String, dynamic> get gymsTexts => _getJsonMap(RemoteConfigKeys.screenTextsGyms);

  /// measurements modülü static metinleri.
  Map<String, dynamic> get measurementsTexts => _getJsonMap(RemoteConfigKeys.screenTextsMeasurements);

  /// members modülü (Üye Listesi/Bilgileri/Detayı, Yeni Üyelik) static metinleri.
  Map<String, dynamic> get membersTexts => _getJsonMap(RemoteConfigKeys.screenTextsMembers);

  /// notifications modülü static metinleri.
  Map<String, dynamic> get notificationsTexts => _getJsonMap(RemoteConfigKeys.screenTextsNotifications);

  /// packages modülü static metinleri.
  Map<String, dynamic> get packagesTexts => _getJsonMap(RemoteConfigKeys.screenTextsPackages);

  /// sessions modülü (Takvim, Ders Yönetimi, Ders Onayı, Derslerim) static metinleri.
  Map<String, dynamic> get sessionsTexts => _getJsonMap(RemoteConfigKeys.screenTextsSessions);

  /// trainers modülü (Ana Sayfa, Üye Detayı, Takvimim, Üyelerim, Raporum, Profil) static metinleri.
  Map<String, dynamic> get trainersTexts => _getJsonMap(RemoteConfigKeys.screenTextsTrainers);

  /// Uygulama açılışında bir kez çağrılır: varsayılanları ayarlar, sonra
  /// fetch+activate dener. İnternet yoksa/başarısız olursa varsayılanlarla
  /// devam eder — uygulama hiçbir zaman bu yüzden çökmez.
  Future<void> init() async {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await rc.setDefaults(_defaults);
    try {
      await rc.fetchAndActivate();
    } on Exception {
      // Fetch başarısız oldu — setDefaults'taki değerler geçerliliğini korur.
    }
  }

  int getInt(String key) => FirebaseRemoteConfig.instance.getInt(key);

  bool getBool(String key) => FirebaseRemoteConfig.instance.getBool(key);

  String getString(String key) => FirebaseRemoteConfig.instance.getString(key);

  double getDouble(String key) => FirebaseRemoteConfig.instance.getDouble(key);

  Map<String, dynamic> _getJsonMap(String key) {
    final raw = getString(key);
    if (raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }
}

@Riverpod(keepAlive: true)
RemoteConfigService remoteConfigService(RemoteConfigServiceRef ref) => const RemoteConfigService();
