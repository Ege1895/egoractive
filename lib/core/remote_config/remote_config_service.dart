import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../locale/locale_controller.dart';

part 'remote_config_service.g.dart';

/// Remote Config parametre anahtarları (CLAUDE.md §2.5).
///
/// - `cfg*` sabitleri: sayısal/boolean/JSON iş kuralı parametreleri, RC'de
///   olduğu gibi tek parametre.
/// - `lbl*` sabitleri: panellerdeki static UI metinleri (admin/antrenör/üye
///   girdisi HARİÇ). RC'de HER metin için `<key>_tr` ve `<key>_en` olmak üzere
///   iki AYRI parametre var — bu sabitler locale eksiz taban adı tutar, `_tr`/`_en`
///   eki [RemoteConfigService.getText] tarafından otomatik eklenir. Kod içinde
///   asla `_tr`/`_en` yazılmaz.
abstract final class RemoteConfigKeys {
  static const sessionReminderMinutesBefore =
      'cfg_session_reminder_minutes_before';
  static const defaultGroupSessionCapacity =
      'cfg_default_group_session_capacity';

  /// Grup dersi oluşturma ekranındaki kontenjan stepper'ının üst sınırı.
  static const groupSessionCapacityMax = 'cfg_group_session_capacity_max';

  /// Üye anasayfasındaki taksit listesinde bir taksitin son ödeme tarihine
  /// kaç gün kala (veya geçmişse) "Ödeme yaklaşıyor" olarak kırmızı
  /// gösterileceği.
  static const installmentDueSoonDays = 'cfg_installment_due_soon_days';

  /// Admin Üyeler listesinde bir üyenin "Bitiyor" filtresine/rozetine
  /// düşmesi için kalan ders sayısının (planlanmış + henüz planlanmamış
  /// toplamı) kaç veya altında olması gerektiği. 0 her zaman "Paketi yok".
  static const memberEndingSoonSessionsThreshold =
      'cfg_member_ending_soon_sessions_threshold';

  /// F4-2/F4-3 — grup dersi/etkinlikte katılım her zaman açık (bkz.
  /// discover_item.dart canLeave), ama bir kez katılınca "Katılmaktan
  /// Vazgeç" başlangıca kaç saat kalana kadar aktif — sonrasında sadece
  /// "Katılıyorsun" gösterilir, ayrılma seçeneği kalkar. İki kategori
  /// ayrı anahtardan besleniyor ki farklı varsayılan saatlerle (ör.
  /// etkinlik 24, grup dersi 8) ayrı ayrı ayarlanabilsin.
  static const eventLeaveLockHoursBefore = 'cfg_event_leave_lock_hours_before';
  static const groupSessionLeaveLockHoursBefore =
      'cfg_group_session_leave_lock_hours_before';
  static const feedbackReminderDayOfMonth =
      'cfg_feedback_reminder_day_of_month';
  static const freeVersionAdsEnabled = 'cfg_free_version_ads_enabled';
  static const featureFlags = 'cfg_feature_flags';

  /// Test amaçlı — `true` iken seans/grup dersi/etkinlik oluşturma
  /// ekranları geçmiş bir tarih/saat seçilmesine izin verir (QA'nın geçmiş
  /// veriyle test senaryosu kurabilmesi için). Prod'da her zaman `false`
  /// kalmalı — kapalıyken üçü de şu andan eski bir tarih/saate
  /// oluşturulamaz.
  static const allowPastDatetimeCreation = 'cfg_allow_past_datetime_creation';

  /// F6-3 — yeni bir salon oluşturulduğunda `trialStartedAt`'ten itibaren
  /// kaç gün ücretsiz deneme süresi tanınır.
  static const trialDurationDays = 'cfg_trial_duration_days';

  /// F7-x — salon kuralları editöründe (Quill zengin metin) izin verilen
  /// azami düz metin karakter sayısı. Sınır olmadan bir admin teorik olarak
  /// Firestore'un 1 MB doküman sınırına yaklaşan bir içerik yazabilirdi —
  /// bu hem doküman boyutunu hem her açılışta okunan veri miktarını
  /// gereksiz büyütür.
  static const gymRulesMaxChars = 'cfg_gym_rules_max_chars';

  /// Grup dersi oluşturma ekranındaki "Açıklama" alanının azami karakter
  /// sayısı — `gymRulesMaxChars` ile aynı desen (bkz. `gymsRulesEditorPanel`).
  static const groupSessionDescriptionMaxChars =
      'cfg_group_session_description_max_chars';

  /// `true` iken yeni oluşturulan bir salonun admin'i, girişten hemen sonra
  /// zorunlu [SubscriptionOnboardingPanel]'e (geri butonu yok, pakete abone
  /// olmadan atlanamaz) yönlendirilir. Mağaza ürünleri (App Store Connect/
  /// Play Console) henüz canlıya alınmadıysa `SubscriptionPurchaseService`
  /// mock veriyle açar (bkz. `mockSubscriptionProducts`) — ekran boş
  /// kalmaz, tasarım/test amaçlı görüntülenip gezilebilir; gerçek satın alma
  /// denemesi güvenle başarısız olur. Gerekirse test amaçlı Console'dan
  /// `false` yapılabilir (`allowPastDatetimeCreation` ile aynı desen).
  static const requireSubscriptionOnboarding =
      'cfg_require_subscription_onboarding';

  /// Onboarding — zorunlu abonelik başlatma ekranı ([SubscriptionOnboardingPanel]).
  static const subscriptionOnboardingTitle =
      'lbl_subscription_onboarding_title';
  static const subscriptionOnboardingSubtitle =
      'lbl_subscription_onboarding_subtitle';
  static const subscriptionOnboardingCta = 'lbl_subscription_onboarding_cta';
  static const subscriptionOnboardingCaption =
      'lbl_subscription_onboarding_caption';
  static const subscriptionOnboardingNoProducts =
      'lbl_subscription_onboarding_no_products';

  /// Salon Abonelik ve Erişim Akışı — salon daha önce trial kullandıysa
  /// (`trialUsed == true`) bu ekranda "X gün ücretsiz" yerine sadece ücretli
  /// plan kopyası gösterilir (Bölüm 11).
  static const subscriptionOnboardingSubtitlePaidOnly =
      'lbl_subscription_onboarding_subtitle_paid_only';
  static const subscriptionOnboardingCtaPaidOnly =
      'lbl_subscription_onboarding_cta_paid_only';
  static const subscriptionOnboardingCaptionPaidOnly =
      'lbl_subscription_onboarding_caption_paid_only';

  /// F4-4 — rozet kriterleri: `[{id, title, note, type, threshold}]`.
  /// `type`: sessionsCompleted | groupSessionJoins | eventJoins |
  /// membershipMonths. Yeni bir rozet eklemek/eşiği değiştirmek için store
  /// güncellemesi gerekmiyor — `badgeCheck` scheduled function'ı da aynı
  /// şablonu okuyor.
  static const badgeCriteria = 'cfg_badge_criteria';

  /// F5-3 — gider kategorileri: `[{id, label_tr, label_en}]`. Firestore'a
  /// `id` yazılır, ekranda cihaz diline göre `label_tr`/`label_en` gösterilir
  /// — Firestore'da dilden bağımsız, ekranda doğru dilde. Yeni bir kategori
  /// eklemek için kod değişikliği/store güncellemesi gerekmiyor.
  static const expenseCategories = 'cfg_expense_categories';

  /// F3-3 — üye/antrenör için seans iptali son kaç saate kadar açık.
  /// Gerçek zorlama `firestore.rules`'ta (Security Rules Remote Config'e
  /// erişemediği için orada sabit 24 olarak tutuluyor) — bu değer sadece
  /// client-side gösterim/erken uyarı için kullanılır, ikisi değiştirilirse
  /// birlikte güncellenmeli.
  static const cancellationDeadlineHours = 'cfg_cancellation_deadline_hours';

  /// F3-6 — Yetki Ayarları'nın global varsayılanı. Bir salon
  /// `gyms/{gymId}.trainerPermissions.{trainerId}` altında override
  /// yazmadıysa buradan okunur.
  static const defaultTrainerReminderDelayMinutes =
      'cfg_default_trainer_reminder_delay_minutes';

  /// Antrenörün üye seanslarını iptal/erteleyebilme yetkisi hiç
  /// ayarlanmamışsa (yeni antrenör) düşülecek varsayılan — `firestore.rules`
  /// tarafında da (Security Rules RC'ye erişemediği için) ayrıca `true`
  /// sabit olarak tutuluyor, ikisi senkron kalmalı.
  static const defaultCanCancelMemberSessions =
      'cfg_default_can_cancel_member_sessions';
  static const defaultCanRescheduleMemberSessions =
      'cfg_default_can_reschedule_member_sessions';

  /// F3-4 — sessionReminderCheck Cloud Function'ının gönderdiği push metni.
  /// Admin SDK'dan (Cloud Functions) da okunabildiği için diğer `lbl_*`
  /// metinlerinden farklı olarak isimlendirmede `notif` öneki kullanılıyor.
  /// `{time}` ve `{trainerName}` yer tutucuları fonksiyon tarafında gerçek
  /// değerlerle değiştiriliyor (kişiselleştirilmiş bildirim metni).
  static const notifSessionReminderTitle = 'lbl_notif_session_reminder_title';
  static const notifSessionReminderBody = 'lbl_notif_session_reminder_body';

  /// F3-5 — sessionCompletionCheck Cloud Function'ının antrenöre gönderdiği
  /// push metni. `{memberName}` yer tutucusu fonksiyon tarafında değişir.
  static const notifSessionCompletionTitle =
      'lbl_notif_session_completion_title';
  static const notifSessionCompletionBody = 'lbl_notif_session_completion_body';

  /// Üyenin kalan ders toplamı (remainingSessions+plannedSessionsCount)
  /// admin Üyeler listesindeki "Bitiyor"/"Paketi yok" eşiğini aşağı doğru
  /// geçtiğinde `onMemberPackageQuotaChanged` Cloud Function'ının üyeye
  /// gönderdiği push metinleri. `{remaining}` yer tutucusu (sadece
  /// endingSoon metninde) fonksiyon tarafında değişir.
  static const notifPackageEndingSoonTitle =
      'lbl_notif_package_ending_soon_title';
  static const notifPackageEndingSoonBody =
      'lbl_notif_package_ending_soon_body';
  static const notifPackageNoneTitle = 'lbl_notif_package_none_title';
  static const notifPackageNoneBody = 'lbl_notif_package_none_body';

  /// F5-4 — feedbackReminderCheck Cloud Function'ının üyelere gönderdiği
  /// push metni.
  static const notifFeedbackReminderTitle = 'lbl_notif_feedback_reminder_title';
  static const notifFeedbackReminderBody = 'lbl_notif_feedback_reminder_body';

  static const commonVazgec = 'lbl_common_vazgec';
  static const commonKaydet = 'lbl_common_kaydet';
  static const commonDuzenle = 'lbl_common_duzenle';
  static const commonKapat = 'lbl_common_kapat';
  static const commonDegistir = 'lbl_common_degistir';
  static const commonCikisYap = 'lbl_common_cikis_yap';
  static const commonHesabimiSil = 'lbl_common_hesabimi_sil';
  static const commonStudyoKurallariNav = 'lbl_common_studyo_kurallari_nav';
  static const commonSeansiErtele = 'lbl_common_seansi_ertele';

  /// Seans/grup dersi/etkinlik oluşturma ekranlarının üçünde de aynı
  /// mesajla kullanılan — geçmiş bir tarih/saat seçildiğinde gösterilir
  /// (bkz. [RemoteConfigKeys.allowPastDatetimeCreation]).
  static const commonPastDatetimeError = 'lbl_common_past_datetime_error';
  static const commonGelicem = 'lbl_common_gelicem';
  static const commonGelmeyecegim = 'lbl_common_gelmeyecegim';
  static const commonAnaSayfaTab = 'lbl_common_ana_sayfa_tab';
  static const commonProfilTab = 'lbl_common_profil_tab';
  static const commonTelefonLabel = 'lbl_common_telefon_label';
  /// F8-5 sonrası bulundu — `AppPhoneField`'ın ülke seçici sheet'indeki arama
  /// kutusu, `flutter_country_selector` paketinin kendi varsayılan metnini
  /// ("Aramak"/"Search") gösteriyordu; bu, kullanıcıya default/placeholder
  /// gibi görünen, doğal olmayan bir ifadeydi.
  static const commonPhoneCountrySearchHint =
      'lbl_common_phone_country_search_hint';
  static const commonTumuFilter = 'lbl_common_tumu_filter';
  static const commonTamamlandi = 'lbl_common_tamamlandi';
  static const commonIptalLabel = 'lbl_common_iptal_label';
  static const commonKalanDersLabel = 'lbl_common_kalan_ders_label';
  static const commonPaketiYokFilter = 'lbl_common_paketi_yok_filter';
  static const commonSeansSayisiLabel = 'lbl_common_seans_sayisi_label';
  static const commonAddSeansButton = 'lbl_common_add_seans_button';
  static const commonOlcum6AySectionHeader =
      'lbl_common_olcum_6_ay_section_header';
  static const commonDersGecmisiSectionHeader =
      'lbl_common_ders_gecmisi_section_header';
  static const commonUyeDetayiTitle = 'lbl_common_uye_detayi_title';
  static const commonBuGundeSeansYok = 'lbl_common_bu_gunde_seans_yok';
  static const commonBitisLabel = 'lbl_common_bitis_label';
  static const commonLanguageNavLabel = 'lbl_common_language_nav_label';
  static const commonTamamButton = 'lbl_common_tamam_button';
  static const commonHenuzVeriYok = 'lbl_common_henuz_veri_yok';
  static const languageSelectTitle = 'lbl_language_select_title';
  static const languageSelectTurkishOption =
      'lbl_language_select_turkish_option';
  static const languageSelectEnglishOption =
      'lbl_language_select_english_option';
  static const shellMemberTabDerslerim = 'lbl_shell_member_tab_derslerim';
  static const shellMemberTabOlcumlerim = 'lbl_shell_member_tab_olcumlerim';
  static const shellMemberTabKesfet = 'lbl_shell_member_tab_kesfet';
  static const shellTrainerTabTakvimim = 'lbl_shell_trainer_tab_takvimim';
  static const shellTrainerTabUyelerim = 'lbl_shell_trainer_tab_uyelerim';
  static const shellTrainerTabRaporum = 'lbl_shell_trainer_tab_raporum';
  static const shellAdminTabUyeler = 'lbl_shell_admin_tab_uyeler';
  static const shellAdminTabSeanslar = 'lbl_shell_admin_tab_seanslar';
  static const shellAdminTabFinans = 'lbl_shell_admin_tab_finans';
  static const shellAdminTabAyarlar = 'lbl_shell_admin_tab_ayarlar';
  static const shellRolePickerMemberButton =
      'lbl_shell_role_picker_member_button';
  static const shellRolePickerTrainerButton =
      'lbl_shell_role_picker_trainer_button';
  static const shellRolePickerAdminButton =
      'lbl_shell_role_picker_admin_button';
  static const shellRolePickerGymSetupButton =
      'lbl_shell_role_picker_gym_setup_button';
  static const authProfileTitle = 'lbl_auth_profile_title';
  static const authPhoneNumberLabel = 'lbl_auth_phone_number_label';
  static const authLoginButton = 'lbl_auth_login_button';
  static const authSelectAvatarLabel = 'lbl_auth_select_avatar_label';
  static const authBadgesNavLabel = 'lbl_auth_badges_nav_label';
  static const authGiveFeedbackNavLabel = 'lbl_auth_give_feedback_nav_label';
  static const authSessionRemindersToggleTitle =
      'lbl_auth_session_reminders_toggle_title';
  static const authSessionRemindersToggleDescription =
      'lbl_auth_session_reminders_toggle_description';
  static const authDeleteAccountConfirmTitle =
      'lbl_auth_delete_account_confirm_title';
  static const authLoginErrorNotFound = 'lbl_auth_login_error_not_found';
  static const authLoginErrorRateLimited = 'lbl_auth_login_error_rate_limited';
  static const authLoginErrorGeneric = 'lbl_auth_login_error_generic';
  static const authLoginErrorSubscriptionInactive =
      'lbl_auth_login_error_subscription_inactive';
  static const authRetryButton = 'lbl_auth_retry_button';
  static const authDeleteAccountErrorGeneric =
      'lbl_auth_delete_account_error_generic';

  /// F1 auth modülü UI migrasyonu — silme onayı ekranındaki liste
  /// maddeleri, başlık/gövde metinleri ve buton durumları.
  static const authDeleteAccountItemRemainingSessions =
      'lbl_auth_delete_account_item_remaining_sessions';
  static const authDeleteAccountItemMeasurementsBadges =
      'lbl_auth_delete_account_item_measurements_badges';
  static const authDeleteAccountItemFeedback =
      'lbl_auth_delete_account_item_feedback';
  static const authDeleteAccountConfirmHeading =
      'lbl_auth_delete_account_confirm_heading';
  static const authDeleteAccountConfirmBody =
      'lbl_auth_delete_account_confirm_body';
  static const authDeleteAccountAcknowledgeLabel =
      'lbl_auth_delete_account_acknowledge_label';
  static const authDeleteAccountInProgressButton =
      'lbl_auth_delete_account_in_progress_button';

  /// Giriş bekleniyor ekranı.
  static const authLoginWaitingHeading = 'lbl_auth_login_waiting_heading';
  static const authLoginWaitingBody = 'lbl_auth_login_waiting_body';
  static const authLoginWaitingHint = 'lbl_auth_login_waiting_hint';
  static const authLoginWaitingCancelButton =
      'lbl_auth_login_waiting_cancel_button';

  /// Onboarding — rol seçimi ekranı.
  static const authOnboardingRoleBrandLabel =
      'lbl_auth_onboarding_role_brand_label';
  static const authOnboardingRoleTitle = 'lbl_auth_onboarding_role_title';
  static const authOnboardingRoleSubtitle = 'lbl_auth_onboarding_role_subtitle';
  static const authOnboardingRoleTrainerTitle =
      'lbl_auth_onboarding_role_trainer_title';
  static const authOnboardingRoleTrainerNote =
      'lbl_auth_onboarding_role_trainer_note';
  static const authOnboardingRoleMemberTitle =
      'lbl_auth_onboarding_role_member_title';
  static const authOnboardingRoleMemberNote =
      'lbl_auth_onboarding_role_member_note';
  static const authOnboardingRoleHintTrainer =
      'lbl_auth_onboarding_role_hint_trainer';
  static const authOnboardingRoleHintMember =
      'lbl_auth_onboarding_role_hint_member';
  static const authOnboardingRoleContinueButton =
      'lbl_auth_onboarding_role_continue_button';
  static const authOnboardingRoleGoToLoginButton =
      'lbl_auth_onboarding_role_go_to_login_button';
  static const authOnboardingRolePartnerGymsButton =
      'lbl_auth_onboarding_role_partner_gyms_button';

  /// Onboarding — anlaşmalı salonlar listesi.
  static const partnerGymsTitle = 'lbl_partner_gyms_title';
  static const partnerGymsEmpty = 'lbl_partner_gyms_empty';
  static const partnerGymsError = 'lbl_partner_gyms_error';

  /// Onboarding — antrenör alt seçimi ekranı.
  static const authTrainerPathTitle = 'lbl_auth_trainer_path_title';
  static const authTrainerPathSubtitle = 'lbl_auth_trainer_path_subtitle';
  static const authTrainerPathLinkedTitle =
      'lbl_auth_trainer_path_linked_title';
  static const authTrainerPathLinkedNote = 'lbl_auth_trainer_path_linked_note';
  static const authTrainerPathNewGymTitle =
      'lbl_auth_trainer_path_new_gym_title';
  static const authTrainerPathNewGymNote = 'lbl_auth_trainer_path_new_gym_note';
  static const authTrainerPathHintLinked = 'lbl_auth_trainer_path_hint_linked';
  static const authTrainerPathHintNewGym = 'lbl_auth_trainer_path_hint_new_gym';
  static const authTrainerPathCreateGymButton =
      'lbl_auth_trainer_path_create_gym_button';

  /// Telefonla giriş ekranı.
  static const authPhoneLoginTitle = 'lbl_auth_phone_login_title';
  static const authPhoneLoginSubtitle = 'lbl_auth_phone_login_subtitle';
  static const authPhoneLoginHint = 'lbl_auth_phone_login_hint';
  static const authSwitchToEmailLink = 'lbl_auth_switch_to_email_link';

  /// Egoractive Authentication Sistemi — email ile giriş ekranı.
  static const authEmailLoginTitle = 'lbl_auth_email_login_title';
  static const authEmailLoginSubtitle = 'lbl_auth_email_login_subtitle';
  static const authSwitchToPhoneLink = 'lbl_auth_switch_to_phone_link';
  static const authEmailAddressLabel = 'lbl_auth_email_address_label';

  /// Egoractive Authentication Sistemi — OTP doğrulama ekranı (§7/§8).
  static const authOtpTitle = 'lbl_auth_otp_title';
  static const authOtpSubtitle = 'lbl_auth_otp_subtitle';
  static const authOtpVerifyButton = 'lbl_auth_otp_verify_button';
  static const authOtpResendButton = 'lbl_auth_otp_resend_button';
  static const authOtpResendCountdownTemplate =
      'lbl_auth_otp_resend_countdown_template';
  static const authOtpInvalidCodeError = 'lbl_auth_otp_invalid_code_error';
  static const authOtpExpiredError = 'lbl_auth_otp_expired_error';
  static const authOtpTooManyAttemptsError =
      'lbl_auth_otp_too_many_attempts_error';
  static const authOtpGenericError = 'lbl_auth_otp_generic_error';

  /// Egoractive Authentication Sistemi §5/§6 — email eksik hesap aktivasyonu.
  static const authEmailSetupTitle = 'lbl_auth_email_setup_title';
  static const authEmailSetupSubtitle = 'lbl_auth_email_setup_subtitle';
  static const authEmailSetupSendButton = 'lbl_auth_email_setup_send_button';
  static const authEmailSetupInvalidEmailError =
      'lbl_auth_email_setup_invalid_email_error';
  static const authEmailSetupEmailTakenError =
      'lbl_auth_email_setup_email_taken_error';

  /// Profil ekranı — kalan (henüz migrate edilmemiş) metinler.
  static const authProfileMemberCaption = 'lbl_auth_profile_member_caption';
  static const authProfileSessionReminderDescription =
      'lbl_auth_profile_session_reminder_description';

  /// Splash ekranı.
  static const authSplashTitle = 'lbl_auth_splash_title';
  static const authSplashTagline = 'lbl_auth_splash_tagline';
  static const authSplashPublisher = 'lbl_auth_splash_publisher';

  static const badgesTitle = 'lbl_badges_title';
  static const badgesLoadError = 'lbl_badges_load_error';

  /// `{count}` yer tutucusu kazanılan rozet sayısıyla değiştirilir.
  static const badgesEarnedCountLabel = 'lbl_badges_earned_count_label';

  /// `{note}` yer tutucusu sıradaki rozetin açıklamasıyla değiştirilir.
  static const badgesNextLockedLabel = 'lbl_badges_next_locked_label';
  static const badgesDetailEarnedStatus = 'lbl_badges_detail_earned_status';
  static const badgesDetailLockedStatus = 'lbl_badges_detail_locked_status';
  static const membersDetailBadgesSectionHeader =
      'lbl_members_detail_badges_section_header';
  static const eventsAdminListTitle = 'lbl_events_admin_list_title';
  static const eventsAddEventButton = 'lbl_events_add_event_button';
  static const eventsAttendingLabel = 'lbl_events_attending_label';
  static const eventsCapacityLabel = 'lbl_events_capacity_label';
  static const eventsCreateTitle = 'lbl_events_create_title';
  static const eventsCapacityEmptyMeansUnlimitedHelper =
      'lbl_events_capacity_empty_means_unlimited_helper';
  static const eventsNameFieldLabel = 'lbl_events_name_field_label';
  static const eventsLocationFieldLabel = 'lbl_events_location_field_label';
  static const eventsDateFieldLabel = 'lbl_events_date_field_label';
  static const eventsTimeFieldLabel = 'lbl_events_time_field_label';
  static const eventsDescriptionFieldLabel =
      'lbl_events_description_field_label';
  static const eventsCreateSubmitButton = 'lbl_events_create_submit_button';

  /// Admin düzenleme ekranı (bkz. `create_event_panel.dart` edit modu,
  /// `admin_events_panel.dart`'ta karta dokununca açılır).
  static const eventsEditTitle = 'lbl_events_edit_title';
  static const eventsEditSubmitButton = 'lbl_events_edit_submit_button';
  static const eventsDateFieldHint = 'lbl_events_date_field_hint';
  static const eventsTimeFieldHint = 'lbl_events_time_field_hint';
  static const eventsNameRequiredError = 'lbl_events_name_required_error';
  static const eventsDateFormatError = 'lbl_events_date_format_error';
  static const eventsCreateFailedError = 'lbl_events_create_failed_error';
  static const expensesListTitle = 'lbl_expenses_list_title';
  static const expensesAddExpenseButton = 'lbl_expenses_add_expense_button';
  static const expensesCategoriesSectionHeader =
      'lbl_expenses_categories_section_header';
  static const expensesRecentEntriesSectionHeader =
      'lbl_expenses_recent_entries_section_header';
  static const expensesAddTitle = 'lbl_expenses_add_title';
  static const expensesCategoryFieldLabel = 'lbl_expenses_category_field_label';
  static const expensesRecurringToggleLabel =
      'lbl_expenses_recurring_toggle_label';
  static const expensesRecurringToggleDescription =
      'lbl_expenses_recurring_toggle_description';
  static const expensesAmountFieldLabel = 'lbl_expenses_amount_field_label';
  static const expensesDescriptionFieldLabel =
      'lbl_expenses_description_field_label';
  static const expensesDateFieldLabel = 'lbl_expenses_date_field_label';
  static const expensesSubmitButton = 'lbl_expenses_submit_button';
  static const expensesAmountFieldHint = 'lbl_expenses_amount_field_hint';
  static const expensesCategoryPickerTitle =
      'lbl_expenses_category_picker_title';
  static const expensesDescriptionFieldHint =
      'lbl_expenses_description_field_hint';
  static const expensesTrainerCommissionNote =
      'lbl_expenses_trainer_commission_note';
  static const expensesAmountInvalidError = 'lbl_expenses_amount_invalid_error';
  static const expensesDescriptionRequiredError =
      'lbl_expenses_description_required_error';
  static const expensesSaveFailedError = 'lbl_expenses_save_failed_error';

  /// `{month}` yer tutucusu ay adıyla değiştirilir.
  static const expensesMonthlyTotalLabel = 'lbl_expenses_monthly_total_label';

  /// `{ratio}` yer tutucusu ciro oranıyla değiştirilir.
  static const expensesRevenueRatioLabel = 'lbl_expenses_revenue_ratio_label';
  static const feedbackAdminListTitle = 'lbl_feedback_admin_list_title';
  static const feedbackMemberFormTitle = 'lbl_feedback_member_form_title';
  static const feedbackCommentSectionHeader =
      'lbl_feedback_comment_section_header';

  /// `{count}` yer tutucusu toplam değerlendirme sayısıyla değiştirilir.
  static const feedbackTotalReviewsCaption =
      'lbl_feedback_total_reviews_caption';
  static const feedbackHowWasSessionTitle =
      'lbl_feedback_how_was_session_title';

  /// `{trainer}` yer tutucusu antrenör adıyla değiştirilir.
  static const feedbackPrivacyNoteWithTrainer =
      'lbl_feedback_privacy_note_with_trainer';
  static const feedbackPrivacyNote = 'lbl_feedback_privacy_note';
  static const feedbackCommentFieldHint = 'lbl_feedback_comment_field_hint';
  static const feedbackSubmitButton = 'lbl_feedback_submit_button';
  static const feedbackGiveStarToSubmitHint =
      'lbl_feedback_give_star_to_submit_hint';
  static const feedbackSentAnonymouslyHint =
      'lbl_feedback_sent_anonymously_hint';
  static const feedbackRatingLabel0 = 'lbl_feedback_rating_label_0';
  static const feedbackRatingLabel1 = 'lbl_feedback_rating_label_1';
  static const feedbackRatingLabel2 = 'lbl_feedback_rating_label_2';
  static const feedbackRatingLabel3 = 'lbl_feedback_rating_label_3';
  static const feedbackRatingLabel4 = 'lbl_feedback_rating_label_4';
  static const feedbackRatingLabel5 = 'lbl_feedback_rating_label_5';
  static const groupSessionsAdminListTitle =
      'lbl_group_sessions_admin_list_title';
  static const groupSessionsAddGroupSessionButton =
      'lbl_group_sessions_add_group_session_button';
  static const groupSessionsCapacitySuffixLabel =
      'lbl_group_sessions_capacity_suffix_label';
  static const groupSessionsCapacityFullNote =
      'lbl_group_sessions_capacity_full_note';

  /// `{remaining}` yer tutucusu kalan kontenjan sayısıyla değiştirilir.
  static const groupSessionsCapacityLowNote =
      'lbl_group_sessions_capacity_low_note';
  static const groupSessionsCapacityAvailableNote =
      'lbl_group_sessions_capacity_available_note';
  static const groupSessionsViewParticipantsLink =
      'lbl_group_sessions_view_participants_link';
  static const groupSessionsDiscoverTitle = 'lbl_group_sessions_discover_title';
  static const groupSessionsDiscoverTabGroupSessions =
      'lbl_group_sessions_discover_tab_group_sessions';
  static const groupSessionsDiscoverTabEvents =
      'lbl_group_sessions_discover_tab_events';
  static const groupSessionsCreateTitle = 'lbl_group_sessions_create_title';
  static const groupSessionsCapacityFieldLabel =
      'lbl_group_sessions_capacity_field_label';
  static const groupSessionsOnlineBookingToggleLabel =
      'lbl_group_sessions_online_booking_toggle_label';
  static const groupSessionsOnlineBookingToggleDescription =
      'lbl_group_sessions_online_booking_toggle_description';
  static const groupSessionsDefaultLocationLabel =
      'lbl_group_sessions_default_location_label';
  static const groupSessionsNameFieldLabel =
      'lbl_group_sessions_name_field_label';
  static const groupSessionsStartTimeFieldLabel =
      'lbl_group_sessions_start_time_field_label';
  static const groupSessionsDurationFieldLabel =
      'lbl_group_sessions_duration_field_label';
  static const groupSessionsCreateSubmitButton =
      'lbl_group_sessions_create_submit_button';

  /// Admin düzenleme ekranı (bkz. `create_group_session_panel.dart` edit
  /// modu, `admin_group_sessions_panel.dart`'ta karta dokununca açılır).
  static const groupSessionsEditTitle = 'lbl_group_sessions_edit_title';
  static const groupSessionsEditSubmitButton =
      'lbl_group_sessions_edit_submit_button';
  static const groupSessionsCancelButton = 'lbl_group_sessions_cancel_button';
  static const groupSessionsCancelledBadge =
      'lbl_group_sessions_cancelled_badge';

  /// `{minutes}` yer tutucusu ders süresiyle değiştirilir.
  static const groupSessionsDurationSuffix =
      'lbl_group_sessions_duration_suffix';

  /// `{max}` yer tutucusu kontenjan üst sınırıyla değiştirilir.
  static const groupSessionsCapacityMaxNote =
      'lbl_group_sessions_capacity_max_note';

  /// `{studio}` ve `{max}` yer tutucuları stüdyo adı ve kontenjan üst
  /// sınırıyla değiştirilir.
  static const groupSessionsCapacityMaxNoteWithStudio =
      'lbl_group_sessions_capacity_max_note_with_studio';
  static const groupSessionsLocationFieldHint =
      'lbl_group_sessions_location_field_hint';
  static const groupSessionsLocationFieldHelper =
      'lbl_group_sessions_location_field_helper';
  static const groupSessionsDurationPickerTitle =
      'lbl_group_sessions_duration_picker_title';
  static const groupSessionsDescriptionFieldLabel =
      'lbl_group_sessions_description_field_label';
  static const groupSessionsDescriptionCharCountTemplate =
      'lbl_group_sessions_description_char_count_template';
  static const groupSessionsTrainerFieldLabel =
      'lbl_group_sessions_trainer_field_label';
  static const groupSessionsTrainerFieldPlaceholder =
      'lbl_group_sessions_trainer_field_placeholder';
  static const groupSessionsTrainerCountSelected =
      'lbl_group_sessions_trainer_count_selected';
  static const groupSessionsTrainerPickerTitle =
      'lbl_group_sessions_trainer_picker_title';
  static const groupSessionsDiscoverEmptyState =
      'lbl_group_sessions_discover_empty_state';
  static const groupSessionsJoinFullErrorSnackbar =
      'lbl_group_sessions_join_full_error_snackbar';
  static const groupSessionsJoinFailedSnackbar =
      'lbl_group_sessions_join_failed_snackbar';
  static const groupSessionsJoinedLeaveButton =
      'lbl_group_sessions_joined_leave_button';

  /// Grup dersi / etkinlik detay sayfaları (bkz.
  /// `group_session_detail_panel.dart`/`event_detail_panel.dart`) —
  /// [DiscoverPanel] kartlarındaki katıl/vazgeç düğmesi kaldırılıp detay
  /// sayfasına taşındı.
  static const groupSessionsDetailTitle = 'lbl_group_sessions_detail_title';
  static const eventsDetailTitle = 'lbl_events_detail_title';
  static const eventsJoinButton = 'lbl_events_join_button';
  static const eventsJoinedLeaveButton = 'lbl_events_joined_leave_button';
  static const groupSessionsJoinButton = 'lbl_group_sessions_join_button';

  /// `{taken}` yer tutucusu katılımcı sayısıyla değiştirilir.
  static const groupSessionsAttendingCountNoCapacity =
      'lbl_group_sessions_attending_count_no_capacity';

  /// `{taken}` ve `{capacity}` yer tutucuları katılımcı sayısı ve
  /// kontenjanla değiştirilir.
  static const groupSessionsAttendingCountWithCapacity =
      'lbl_group_sessions_attending_count_with_capacity';
  static const gymsAdminHomeCompletedWord =
      'lbl_gyms_admin_home_completed_word';
  static const gymsAdminHomeTrainerPerformanceSection =
      'lbl_gyms_admin_home_trainer_performance_section';
  static const gymsAdminHomeUpcomingPaymentsSection =
      'lbl_gyms_admin_home_upcoming_payments_section';
  static const gymsAdminHomePendingFeedbackLabel =
      'lbl_gyms_admin_home_pending_feedback_label';
  static const gymsAdminHomeTotalSessionsLabel =
      'lbl_gyms_admin_home_total_sessions_label';
  static const gymsAdminHomeCompletedLabel =
      'lbl_gyms_admin_home_completed_label';
  static const gymsAdminHomeEstimatedRevenueLabel =
      'lbl_gyms_admin_home_estimated_revenue_label';
  static const gymsAdminHomeExpenseLabel = 'lbl_gyms_admin_home_expense_label';
  static const gymsPermissionsTitle = 'lbl_gyms_permissions_title';
  static const gymsPermissionsReminderDropdownLabel =
      'lbl_gyms_permissions_reminder_dropdown_label';
  static const gymsPermissionsReminderDescription =
      'lbl_gyms_permissions_reminder_description';
  static const gymsSettingsTitle = 'lbl_gyms_settings_title';
  static const gymsSettingsNavGymInfo = 'lbl_gyms_settings_nav_gym_info';
  static const gymsSettingsNavTrainerManagement =
      'lbl_gyms_settings_nav_trainer_management';
  static const gymsSettingsNavStudioPackages =
      'lbl_gyms_settings_nav_studio_packages';
  static const gymsSettingsNavSessionManagement =
      'lbl_gyms_settings_nav_session_management';
  static const gymsSettingsNavGroupSessions =
      'lbl_gyms_settings_nav_group_sessions';
  static const gymsSettingsNavEvents = 'lbl_gyms_settings_nav_events';
  static const gymsSettingsNavPermissions = 'lbl_gyms_settings_nav_permissions';
  static const gymsSettingsNavFeedback = 'lbl_gyms_settings_nav_feedback';
  static const gymsSettingsNavSendNotification =
      'lbl_gyms_settings_nav_send_notification';
  static const gymsGymInfoTitle = 'lbl_gyms_gym_info_title';
  static const gymsGymInfoLogoSection = 'lbl_gyms_gym_info_logo_section';
  static const gymsGymInfoLogoHelper = 'lbl_gyms_gym_info_logo_helper';
  static const gymsGymInfoChangeLogoButton =
      'lbl_gyms_gym_info_change_logo_button';
  static const gymsGymInfoThemeColorSection =
      'lbl_gyms_gym_info_theme_color_section';
  static const gymsGymInfoPreviewLabel = 'lbl_gyms_gym_info_preview_label';
  static const gymsGymInfoPrimaryButtonLabel =
      'lbl_gyms_gym_info_primary_button_label';
  static const gymsGymInfoSeeAllThemesLink =
      'lbl_gyms_gym_info_see_all_themes_link';
  static const gymsGymInfoNameFieldLabel = 'lbl_gyms_gym_info_name_field_label';
  static const gymsGymInfoAddressFieldLabel =
      'lbl_gyms_gym_info_address_field_label';
  static const gymsGymSetupStepHeader = 'lbl_gyms_gym_setup_step_header';
  static const gymsGymSetupTitle = 'lbl_gyms_gym_setup_title';
  static const gymsGymSetupLogoLabel = 'lbl_gyms_gym_setup_logo_label';
  static const gymsGymSetupChooseLogoButton =
      'lbl_gyms_gym_setup_choose_logo_button';
  static const gymsGymSetupThemeColorLabel =
      'lbl_gyms_gym_setup_theme_color_label';
  static const gymsGymSetupCityFieldLabel =
      'lbl_gyms_gym_setup_city_field_label';
  static const gymsGymSetupSubmitButton = 'lbl_gyms_gym_setup_submit_button';
  static const gymsThemesTitle = 'lbl_gyms_themes_title';
  static const gymsThemesMemberPreviewSection =
      'lbl_gyms_themes_member_preview_section';
  static const gymsThemesShowLogoSilhouetteToggleLabel =
      'lbl_gyms_themes_show_logo_silhouette_toggle_label';
  static const gymsThemesShowLogoSilhouetteToggleDescription =
      'lbl_gyms_themes_show_logo_silhouette_toggle_description';
  static const gymsThemesApplyToAllButton =
      'lbl_gyms_themes_apply_to_all_button';
  static const gymsAddThemeTitle = 'lbl_gyms_add_theme_title';
  static const gymsAddThemePaletteLabel = 'lbl_gyms_add_theme_palette_label';
  static const gymsAddThemeColorCodeLabel =
      'lbl_gyms_add_theme_color_code_label';
  static const gymsAddThemeColorHelper = 'lbl_gyms_add_theme_color_helper';
  static const gymsAddThemeUseLogoQuestion =
      'lbl_gyms_add_theme_use_logo_question';
  static const gymsAddThemePreviewSection =
      'lbl_gyms_add_theme_preview_section';
  static const gymsAddThemeUseLogoOption = 'lbl_gyms_add_theme_use_logo_option';
  static const gymsAddThemeFlatBackgroundOption =
      'lbl_gyms_add_theme_flat_background_option';
  static const gymsAddThemeSubmitButton = 'lbl_gyms_add_theme_submit_button';
  static const gymsAddThemeNameFieldLabel =
      'lbl_gyms_add_theme_name_field_label';
  static const gymsStudioRulesTitle = 'lbl_gyms_studio_rules_title';
  static const gymsEditStudioRulesTitle = 'lbl_gyms_edit_studio_rules_title';
  static const gymsSettingsNavSubscription =
      'lbl_gyms_settings_nav_subscription';
  static const gymsSettingsNavReports = 'lbl_gyms_settings_nav_reports';
  static const gymsAdminHomeThisMonthNote =
      'lbl_gyms_admin_home_this_month_note';
  static const gymsAdminHomeNoTrainersMessage =
      'lbl_gyms_admin_home_no_trainers_message';
  static const gymsAdminHomeAddTrainerButton =
      'lbl_gyms_admin_home_add_trainer_button';
  static const gymsAdminHomeNoPendingPaymentsMessage =
      'lbl_gyms_admin_home_no_pending_payments_message';
  static const gymsAdminHomeDuePaymentMembersTemplate =
      'lbl_gyms_admin_home_due_payment_members_template';
  static const gymsAdminHomeTotalFeedbackTemplate =
      'lbl_gyms_admin_home_total_feedback_template';
  static const gymsPermissionsTrainerQuestion =
      'lbl_gyms_permissions_trainer_question';
  static const gymsPermissionsTrainerHelper =
      'lbl_gyms_permissions_trainer_helper';
  static const gymsPermissionsAuthorizeButton =
      'lbl_gyms_permissions_authorize_button';
  static const gymsPermissionsDoneButton = 'lbl_gyms_permissions_done_button';
  static const gymsGymInfoUploadingLabel = 'lbl_gyms_gym_info_uploading_label';
  static const gymsGymInfoPaletteExtractingLabel =
      'lbl_gyms_gym_info_palette_extracting_label';
  static const gymsGymInfoThemeColorNote = 'lbl_gyms_gym_info_theme_color_note';
  static const gymsGymInfoGymReportEmailLabel =
      'lbl_gyms_gym_info_gym_report_email_label';
  static const gymsGymInfoGymReportEmailHint =
      'lbl_gyms_gym_info_gym_report_email_hint';

  /// Egoractive Authentication Sistemi §9/§10 — "Login ve rapor e-postası",
  /// eski opsiyonel rapor e-postası alanının yerine geçen zorunlu tek alan.
  static const gymsGymInfoLoginReportEmailLabel =
      'lbl_gyms_gym_info_login_report_email_label';
  static const gymsGymInfoSavingLabel = 'lbl_gyms_gym_info_saving_label';
  static const gymsGymInfoLogoUploadFailedError =
      'lbl_gyms_gym_info_logo_upload_failed_error';
  static const gymsGymInfoNameRequiredError =
      'lbl_gyms_gym_info_name_required_error';
  static const gymsGymInfoAddressRequiredError =
      'lbl_gyms_gym_info_address_required_error';
  static const gymsGymInfoPhoneRequiredError =
      'lbl_gyms_gym_info_phone_required_error';
  static const gymsGymInfoSaveFailedError =
      'lbl_gyms_gym_info_save_failed_error';
  static const gymsGymInfoLogoColorThemeName =
      'lbl_gyms_gym_info_logo_color_theme_name';
  static const gymsGymInfoLogoColorThemeNote =
      'lbl_gyms_gym_info_logo_color_theme_note';
  static const gymsGymSetupHeadline = 'lbl_gyms_gym_setup_headline';
  static const gymsGymSetupPhoneFieldLabel =
      'lbl_gyms_gym_setup_phone_field_label';
  static const gymsGymSetupPhoneHint = 'lbl_gyms_gym_setup_phone_hint';
  static const gymsGymSetupPhoneHelperNote =
      'lbl_gyms_gym_setup_phone_helper_note';
  static const gymsGymSetupCurrencyFieldLabel =
      'lbl_gyms_gym_setup_currency_field_label';
  static const gymsGymSetupCurrencyHelperNote =
      'lbl_gyms_gym_setup_currency_helper_note';
  static const gymsGymInfoCurrencyFieldLabel =
      'lbl_gyms_gym_info_currency_field_label';
  static const gymsGymSetupLogoOptionalLabel =
      'lbl_gyms_gym_setup_logo_optional_label';
  static const gymsGymSetupLogoDescription =
      'lbl_gyms_gym_setup_logo_description';
  static const gymsGymSetupLogoColorHintNote =
      'lbl_gyms_gym_setup_logo_color_hint_note';
  static const gymsGymSetupSuggestedColorsLabel =
      'lbl_gyms_gym_setup_suggested_colors_label';
  static const gymsGymSetupChangeLaterNote =
      'lbl_gyms_gym_setup_change_later_note';
  static const gymsGymSetupSubmittingLabel =
      'lbl_gyms_gym_setup_submitting_label';
  static const gymsGymSetupSuccessBanner = 'lbl_gyms_gym_setup_success_banner';
  static const gymsAddThemeNameFieldHint = 'lbl_gyms_add_theme_name_field_hint';
  static const gymsAddThemeInvalidHexError =
      'lbl_gyms_add_theme_invalid_hex_error';
  static const gymsThemePreviewRemainingSessionsLabel =
      'lbl_gyms_theme_preview_remaining_sessions_label';
  static const gymsThemePreviewNextSessionLabel =
      'lbl_gyms_theme_preview_next_session_label';
  static const gymsAddThemeDefaultName = 'lbl_gyms_add_theme_default_name';
  static const gymsAddThemeCustomColorNote =
      'lbl_gyms_add_theme_custom_color_note';
  static const gymsRulesEditorToolbarHint =
      'lbl_gyms_rules_editor_toolbar_hint';
  static const gymsRulesEditorSaveFailedError =
      'lbl_gyms_rules_editor_save_failed_error';
  static const gymsRulesViewLastUpdatedTemplate =
      'lbl_gyms_rules_view_last_updated_template';
  static const gymsRulesEditorCharCountTemplate =
      'lbl_gyms_rules_editor_char_count_template';
  static const gymsRulesEditorMaxLengthError =
      'lbl_gyms_rules_editor_max_length_error';
  static const gymsThemesDescription = 'lbl_gyms_themes_description';
  static const gymsThemesAddThemeButton = 'lbl_gyms_themes_add_theme_button';
  static const gymsTrainerPermissionsReminderQuestion =
      'lbl_gyms_trainer_permissions_reminder_question';
  static const gymsTrainerPermissionsReminderNote =
      'lbl_gyms_trainer_permissions_reminder_note';
  static const gymsTrainerPermissionsCancelTitle =
      'lbl_gyms_trainer_permissions_cancel_title';
  static const gymsTrainerPermissionsCancelNote =
      'lbl_gyms_trainer_permissions_cancel_note';
  static const gymsTrainerPermissionsRescheduleTitle =
      'lbl_gyms_trainer_permissions_reschedule_title';
  static const gymsTrainerPermissionsRescheduleNote =
      'lbl_gyms_trainer_permissions_reschedule_note';
  static const gymsTrainerPermissionsAutoSaveNote =
      'lbl_gyms_trainer_permissions_auto_save_note';
  static const gymsTrainerPermissionsSaveFailedError =
      'lbl_gyms_trainer_permissions_save_failed_error';
  static const measurementsAddTitle = 'lbl_measurements_add_title';
  static const measurementsMeasurementDateLabel =
      'lbl_measurements_measurement_date_label';
  static const measurementsMeasurementsSection =
      'lbl_measurements_measurements_section';
  static const measurementsUnitCm = 'lbl_measurements_unit_cm';
  // F7-x — vücut noktası etiketleri ("Bel"/"Göğüs" vb.) önceden
  // `MeasurementMetric.label`'da hardcoded Türkçe idi, app İngilizce iken
  // de Türkçe kalıyordu. Artık RC'den okunuyor (bkz. measurement_metric.dart).
  static const measurementsMetricBel = 'lbl_measurements_metric_bel';
  static const measurementsMetricGogus = 'lbl_measurements_metric_gogus';
  static const measurementsMetricKalca = 'lbl_measurements_metric_kalca';
  static const measurementsMetricKol = 'lbl_measurements_metric_kol';
  static const measurementsMetricBacak = 'lbl_measurements_metric_bacak';
  static const measurementsMetricKilo = 'lbl_measurements_metric_kilo';
  static const measurementsMetricYagOrani = 'lbl_measurements_metric_yag_orani';
  // F7-x — antrenör/admin'in üye kartındaki basit 3'lü metrik seçici
  // (`TrainerMetric`) kilo/yağ oranı için yukarıdaki aynı RC anahtarlarını
  // paylaşır; sadece "Bel çevresi" bu ekrana özel, o yüzden ayrı bir key.
  static const trainersMetricBelCevresi = 'lbl_trainers_metric_bel_cevresi';
  static const measurementsTitle = 'lbl_measurements_title';
  static const measurementsSelectedPointLabel =
      'lbl_measurements_selected_point_label';
  static const measurementsHistorySection = 'lbl_measurements_history_section';

  /// `{name}` yer tutucusu üye adıyla değiştirilir.
  static const measurementsMemberTitle = 'lbl_measurements_member_title';
  static const measurementsAvatarHint = 'lbl_measurements_avatar_hint';
  static const measurementsChartHint = 'lbl_measurements_chart_hint';
  static const measurementsChartToggleLabel =
      'lbl_measurements_chart_toggle_label';
  static const measurementsAvatarToggleLabel =
      'lbl_measurements_avatar_toggle_label';
  static const measurementsDatePickerTitle =
      'lbl_measurements_date_picker_title';
  static const measurementsLatestRecordOption =
      'lbl_measurements_latest_record_option';
  static const measurementsShowingLatestLabel =
      'lbl_measurements_showing_latest_label';

  /// `{date}` yer tutucusu seçili tarihle değiştirilir.
  static const measurementsShowingDateLabel =
      'lbl_measurements_showing_date_label';
  static const measurementsChangeDateLabel =
      'lbl_measurements_change_date_label';
  static const measurementsValueFieldHint = 'lbl_measurements_value_field_hint';
  static const measurementsEmptyPointHint = 'lbl_measurements_empty_point_hint';
  static const measurementsSaveFailedError =
      'lbl_measurements_save_failed_error';

  /// `{metric}` yer tutucusu ölçüm metriği adıyla değiştirilir.
  static const measurementsNoDataForMetric =
      'lbl_measurements_no_data_for_metric';

  /// `{metric}` yer tutucusu ölçüm metriği adıyla değiştirilir.
  static const measurementsMetricLatestLabel =
      'lbl_measurements_metric_latest_label';
  static const measurementsNoChangeLabel = 'lbl_measurements_no_change_label';

  /// `{delta}` yer tutucusu 6 aylık değişim değeriyle değiştirilir.
  static const measurementsSixMonthDeltaLabel =
      'lbl_measurements_six_month_delta_label';
  static const measurementsLatestMeasurementLabel =
      'lbl_measurements_latest_measurement_label';
  static const measurementsSwitchToAvatarCta =
      'lbl_measurements_switch_to_avatar_cta';

  /// `{metric}` yer tutucusu ölçüm metriği adıyla değiştirilir.
  static const measurementsAddMetricLabel = 'lbl_measurements_add_metric_label';
  static const membersDetailPaymentStatusLabel =
      'lbl_members_detail_payment_status_label';
  static const membersDetailRemainingSessionsLabel =
      'lbl_members_detail_remaining_sessions_label';
  static const membersDetailMakeupLabel = 'lbl_members_detail_makeup_label';
  static const membersDetailTotalLabel = 'lbl_members_detail_total_label';
  static const membersDetailPaidLabel = 'lbl_members_detail_paid_label';
  static const membersDetailRemainingAmountLabel =
      'lbl_members_detail_remaining_amount_label';
  static const membersListTitle = 'lbl_members_list_title';
  static const membersAddMemberButton = 'lbl_members_add_member_button';
  static const membersListEmptyState = 'lbl_members_list_empty_state';
  static const membersFilterActive = 'lbl_members_filter_active';
  static const membersFilterExpiring = 'lbl_members_filter_expiring';
  static const membersInfoStepIndicator1 = 'lbl_members_info_step_indicator_1';
  static const membersInfoLoginHelper = 'lbl_members_info_login_helper';
  static const membersGenderFieldLabel = 'lbl_members_gender_field_label';
  static const membersTrainerFieldLabel = 'lbl_members_trainer_field_label';
  static const membersRegistrationDateFieldLabel =
      'lbl_members_registration_date_field_label';
  static const membersSelectTrainerButton = 'lbl_members_select_trainer_button';
  static const membersFirstNameFieldLabel =
      'lbl_members_first_name_field_label';
  static const membersLastNameFieldLabel = 'lbl_members_last_name_field_label';
  static const membersBirthYearFieldLabel =
      'lbl_members_birth_year_field_label';
  static const membersHeightFieldLabel = 'lbl_members_height_field_label';
  static const membersNoteFieldLabel = 'lbl_members_note_field_label';
  static const membersPaymentTitle = 'lbl_members_payment_title';
  static const membersPaymentStepIndicator3 =
      'lbl_members_payment_step_indicator_3';
  static const membersPaymentTotalLabel = 'lbl_members_payment_total_label';
  static const membersPaymentPaidLabel = 'lbl_members_payment_paid_label';
  static const membersPaymentRemainingLabel =
      'lbl_members_payment_remaining_label';
  static const membersPaymentAutoCalculatedHelper =
      'lbl_members_payment_auto_calculated_helper';
  static const membersPaymentDueDateFieldLabel =
      'lbl_members_payment_due_date_field_label';
  static const membersPaymentEnterAmountHelper =
      'lbl_members_payment_enter_amount_helper';
  static const membersPaymentFullOption = 'lbl_members_payment_full_option';
  static const membersPaymentHalfOption = 'lbl_members_payment_half_option';
  static const membersPaymentOtherOption = 'lbl_members_payment_other_option';
  static const membersNewMembershipTitle = 'lbl_members_new_membership_title';
  static const membersNewMembershipStepIndicator2 =
      'lbl_members_new_membership_step_indicator_2';
  static const membersPackageSelectSection =
      'lbl_members_package_select_section';
  static const membersMakeupSessionCountLabel =
      'lbl_members_makeup_session_count_label';
  static const membersMakeupSessionHelper = 'lbl_members_makeup_session_helper';
  static const membersStartDateFieldLabel =
      'lbl_members_start_date_field_label';
  static const membersEndDateFieldLabel = 'lbl_members_end_date_field_label';
  static const membersGoToPaymentButton = 'lbl_members_go_to_payment_button';
  static const membersDetailNotFound = 'lbl_members_detail_not_found';
  static const membersDetailLastPaymentLabel =
      'lbl_members_detail_last_payment_label';
  static const membersDetailViewMeasurementsButton =
      'lbl_members_detail_view_measurements_button';
  static const membersDetailRenewPackageButton =
      'lbl_members_detail_renew_package_button';
  static const membersDetailRenewPackageBlockedNote =
      'lbl_members_detail_renew_package_blocked_note';
  static const membersDetailPhoneTrainerLine =
      'lbl_members_detail_phone_trainer_line';
  static const membersListSearchHint = 'lbl_members_list_search_hint';
  static const membersListLoadError = 'lbl_members_list_load_error';
  static const membersEditPaymentTitle = 'lbl_members_edit_payment_title';
  static const membersPaymentInstallmentCountLabel =
      'lbl_members_payment_installment_count_label';
  static const membersEditPaymentSaveError =
      'lbl_members_edit_payment_save_error';
  static const membersPaymentInstallmentNote =
      'lbl_members_payment_installment_note';
  static const membersSavingLabel = 'lbl_members_saving_label';
  static const membersSelfInfoTitle = 'lbl_members_self_info_title';
  static const membersSelfInfoNameRequiredError =
      'lbl_members_self_info_name_required_error';
  static const membersSelfInfoPhoneInvalidError =
      'lbl_members_self_info_phone_invalid_error';
  static const membersSelfInfoPhoneTakenError =
      'lbl_members_self_info_phone_taken_error';
  static const membersSelfInfoSaveError = 'lbl_members_self_info_save_error';
  static const membersSelfInfoEmailFieldLabel =
      'lbl_members_self_info_email_field_label';
  static const membersInfoNewTitle = 'lbl_members_info_new_title';
  static const membersInfoEditTitle = 'lbl_members_info_edit_title';
  static const membersInfoPhoneHint = 'lbl_members_info_phone_hint';
  static const membersInfoAgeSuffix = 'lbl_members_info_age_suffix';

  /// `{type}`/`{days}` yer tutucuları paket seçim kartında seans türü ve
  /// geçerlilik süresiyle değiştirilir.
  static const membersPackagePickTypeValidityCaption =
      'lbl_members_package_pick_type_validity_caption';
  static const membersInfoHeightPickerTitle =
      'lbl_members_info_height_picker_title';
  static const membersInfoGenderLabel = 'lbl_members_info_gender_label';
  static const membersInfoGenderHelper = 'lbl_members_info_gender_helper';
  static const membersInfoGenderErkekOption =
      'lbl_members_info_gender_erkek_option';
  static const membersInfoGenderKadinOption =
      'lbl_members_info_gender_kadin_option';

  /// Antrenör uzmanlık seçenekleri (`trainerSpecialtyOptions`) — sabit,
  /// kod-tanımlı liste; her biri için ayrı anahtar.
  static const trainersSpecialtyFonksiyonelOption =
      'lbl_trainers_specialty_fonksiyonel_option';
  static const trainersSpecialtyPilatesOption =
      'lbl_trainers_specialty_pilates_option';
  static const trainersSpecialtyYogaOption =
      'lbl_trainers_specialty_yoga_option';
  static const trainersSpecialtyKickboxOption =
      'lbl_trainers_specialty_kickbox_option';

  /// Salon oluşturulurken önerilen varsayılan tema paletindeki isim/not
  /// çiftleri (`GymThemeService`/`GymThemeController`'daki sabit presetler).
  static const gymsThemePresetDefaultName =
      'lbl_gyms_theme_preset_default_name';
  static const gymsThemePresetDefaultNote =
      'lbl_gyms_theme_preset_default_note';
  static const gymsThemePresetOrangeName = 'lbl_gyms_theme_preset_orange_name';
  static const gymsThemePresetOrangeNote = 'lbl_gyms_theme_preset_orange_note';
  static const gymsThemePresetGreenName = 'lbl_gyms_theme_preset_green_name';
  static const gymsThemePresetGreenNote = 'lbl_gyms_theme_preset_green_note';

  /// `{value}` yer tutucusuz, virgülle ayrılmış 12 ay / 7 gün adı listesi —
  /// `.split(',')` ile kullanılır. Bu projede birden çok dosyada aynı ay/gün
  /// isim map'leri tekrarlanıyordu; bu anahtarlar en görünür tekrarı
  /// (Seanslar ekranı tarih başlığı) gidermek için eklendi.
  static const commonMonthNamesLong = 'lbl_common_month_names_long';
  static const commonWeekdayNamesLong = 'lbl_common_weekday_names_long';
  static const membersInfoConfirmAttendanceLabel =
      'lbl_members_info_confirm_attendance_label';
  static const membersInfoConfirmAttendanceHelper =
      'lbl_members_info_confirm_attendance_helper';
  static const membersInfoGoToPackageButton =
      'lbl_members_info_go_to_package_button';
  static const membersInfoNoTrainersMessage =
      'lbl_members_info_no_trainers_message';
  static const membersInfoPickerConfirmButton =
      'lbl_members_info_picker_confirm_button';
  static const membersNewMembershipTrainerLabel =
      'lbl_members_new_membership_trainer_label';
  static const membersNewMembershipAutofillNote =
      'lbl_members_new_membership_autofill_note';
  static const membersInstallmentAmountFieldLabel =
      'lbl_members_installment_amount_field_label';
  static const membersInstallmentPaidToggleLabel =
      'lbl_members_installment_paid_toggle_label';
  static const notificationsTitle = 'lbl_notifications_title';
  static const notificationsTargetQuestionLabel =
      'lbl_notifications_target_question_label';
  static const notificationsTargetSingleMemberOption =
      'lbl_notifications_target_single_member_option';
  static const notificationsTargetWholeGymOption =
      'lbl_notifications_target_whole_gym_option';
  static const notificationsPreviewLabel = 'lbl_notifications_preview_label';
  static const notificationsSelectMemberButton =
      'lbl_notifications_select_member_button';
  static const notificationsTitleFieldLabel =
      'lbl_notifications_title_field_label';
  static const notificationsMessageFieldLabel =
      'lbl_notifications_message_field_label';
  static const notificationsTargetSelectedMembersOption =
      'lbl_notifications_target_selected_members_option';

  /// `{gym}` yer tutucusu salon adıyla değiştirilir.
  static const notificationsWholeGymSummaryLabel =
      'lbl_notifications_whole_gym_summary_label';

  /// `{current}`/`{max}` yer tutucuları mesaj karakter sayacıyla değiştirilir.
  static const notificationsMessageCounterLabel =
      'lbl_notifications_message_counter_label';

  /// `{title}`/`{message}` yer tutucuları önizleme başlığı/metniyle
  /// değiştirilir.
  static const notificationsPreviewTemplate =
      'lbl_notifications_preview_template';
  static const notificationsPreviewMessagePlaceholder =
      'lbl_notifications_preview_message_placeholder';
  static const notificationsSendButtonLabel =
      'lbl_notifications_send_button_label';
  static const notificationsSendingButtonLabel =
      'lbl_notifications_sending_button_label';
  static const notificationsSentButtonLabel =
      'lbl_notifications_sent_button_label';
  static const notificationsMemberPickerSubtitle =
      'lbl_notifications_member_picker_subtitle';
  static const notificationsNoMembersEmptyState =
      'lbl_notifications_no_members_empty_state';
  static const packagesListTitle = 'lbl_packages_list_title';
  static const packagesAddPackageButton = 'lbl_packages_add_package_button';
  static const packagesEditSessionTypeFieldLabel =
      'lbl_packages_edit_session_type_field_label';
  static const packagesEditOnSaleToggleLabel =
      'lbl_packages_edit_on_sale_toggle_label';
  static const packagesEditOnSaleToggleDescription =
      'lbl_packages_edit_on_sale_toggle_description';
  static const packagesDeletePackageButton =
      'lbl_packages_delete_package_button';
  static const packagesEditNameFieldLabel =
      'lbl_packages_edit_name_field_label';
  static const packagesEditValidityDaysFieldLabel =
      'lbl_packages_edit_validity_days_field_label';
  static const packagesEditPriceFieldLabel =
      'lbl_packages_edit_price_field_label';
  static const packagesMemberPackageTitle = 'lbl_packages_member_package_title';
  static const packagesRemainingWord = 'lbl_packages_remaining_word';
  static const packagesTrainerOwnerLabel = 'lbl_packages_trainer_owner_label';
  static const packagesStartLabel = 'lbl_packages_start_label';
  static const packagesAddTitle = 'lbl_packages_add_title';
  static const packagesEditTitle = 'lbl_packages_edit_title';
  static const packagesNameFieldHint = 'lbl_packages_name_field_hint';
  static const packagesSessionCountFieldHint =
      'lbl_packages_session_count_field_hint';
  static const packagesValidityFieldHint = 'lbl_packages_validity_field_hint';

  /// `{price}` yer tutucusu seans başı fiyatla değiştirilir.
  static const packagesPerSessionPriceCaption =
      'lbl_packages_per_session_price_caption';
  static const packagesDeleteFailedError = 'lbl_packages_delete_failed_error';
  static const packagesNameRequiredError = 'lbl_packages_name_required_error';
  static const packagesSessionCountInvalidError =
      'lbl_packages_session_count_invalid_error';
  static const packagesValidityInvalidError =
      'lbl_packages_validity_invalid_error';
  static const packagesSaveFailedError = 'lbl_packages_save_failed_error';

  /// `{remaining}` ve `{makeup}` yer tutucuları kalan ders ve telafi hakkı
  /// sayısıyla değiştirilir.
  static const packagesRemainingWithMakeupCaption =
      'lbl_packages_remaining_with_makeup_caption';

  /// `{remaining}` yer tutucusu kalan ders sayısıyla değiştirilir.
  static const packagesLowSessionsWarningTitle =
      'lbl_packages_low_sessions_warning_title';

  /// `{trainer}` yer tutucusu antrenör adıyla değiştirilir.
  static const packagesRenewWithTrainerCaption =
      'lbl_packages_renew_with_trainer_caption';

  /// `{count}` ve `{days}` yer tutucuları seans sayısı ve geçerlilik
  /// gün sayısıyla değiştirilir.
  static const packagesSessionCountValidityCaption =
      'lbl_packages_session_count_validity_caption';
  static const packagesOffSaleLabel = 'lbl_packages_off_sale_label';

  static const reportsSummaryLoadError = 'lbl_reports_summary_load_error';
  static const reportsTotalSessionsLabel = 'lbl_reports_total_sessions_label';
  static const reportsNetLabel = 'lbl_reports_net_label';
  static const reportsTrainerPerformanceLoadError =
      'lbl_reports_trainer_performance_load_error';
  static const reportsTrainerPerformanceEmptyState =
      'lbl_reports_trainer_performance_empty_state';
  static const reportsPastReportsSectionTitle =
      'lbl_reports_past_reports_section_title';
  static const reportsPeriodWeeklyLabel = 'lbl_reports_period_weekly_label';
  static const reportsPeriodMonthlyLabel = 'lbl_reports_period_monthly_label';
  static const reportsSnapshotListLoadError =
      'lbl_reports_snapshot_list_load_error';
  static const reportsSnapshotListEmptyState =
      'lbl_reports_snapshot_list_empty_state';
  static const reportsSnapshotDetailTitle = 'lbl_reports_snapshot_detail_title';
  static const reportsExportPdfButtonLabel =
      'lbl_reports_export_pdf_button_label';
  static const reportsPdfDocumentTitle = 'lbl_reports_pdf_document_title';
  static const reportsPdfExportError = 'lbl_reports_pdf_export_error';
  static const reportsPdfSessionsTitle = 'lbl_reports_pdf_sessions_title';
  // F7-x — "Ders Özeti" bölümünün birebir/düet kırılımı ve antrenör
  // satırındaki tür rozetleri (mail template'iyle birebir aynı).
  static const reportsPdfIndividualSessionsLabel =
      'lbl_reports_pdf_individual_sessions_label';
  static const reportsPdfDuetSessionsLabel =
      'lbl_reports_pdf_duet_sessions_label';
  static const reportsPdfSoloPillLabel = 'lbl_reports_pdf_solo_pill_label';
  static const reportsPdfDuetPillLabel = 'lbl_reports_pdf_duet_pill_label';
  static const reportsPdfGroupPillLabel = 'lbl_reports_pdf_group_pill_label';
  // F5-21 — mail template'iyle (report-email-template.ts) birebir aynı
  // yapı/metinler için PDF'e özel RC key'leri.
  static const reportsPdfHeroPositiveTemplate =
      'lbl_reports_pdf_hero_positive_template';
  static const reportsPdfHeroNegativeTemplate =
      'lbl_reports_pdf_hero_negative_template';
  static const reportsPdfHeroSubPositive = 'lbl_reports_pdf_hero_sub_positive';
  static const reportsPdfHeroSubNegative = 'lbl_reports_pdf_hero_sub_negative';
  static const reportsPdfGroupEventsTitle =
      'lbl_reports_pdf_group_events_title';
  static const reportsPdfGroupSessionsLabel =
      'lbl_reports_pdf_group_sessions_label';
  static const reportsPdfEventsLabel = 'lbl_reports_pdf_events_label';
  static const reportsPdfSessionsUnit = 'lbl_reports_pdf_sessions_unit';
  static const reportsPdfEventsUnit = 'lbl_reports_pdf_events_unit';
  static const reportsPdfAttendanceTemplate =
      'lbl_reports_pdf_attendance_template';
  static const reportsPdfPackagesTitle = 'lbl_reports_pdf_packages_title';
  static const reportsPdfPackagesEmpty = 'lbl_reports_pdf_packages_empty';
  static const reportsPdfSalesUnit = 'lbl_reports_pdf_sales_unit';
  static const reportsPdfFinanceTitle = 'lbl_reports_pdf_finance_title';
  static const reportsPdfNetProfitLabel = 'lbl_reports_pdf_net_profit_label';
  static const reportsPdfNetLossLabel = 'lbl_reports_pdf_net_loss_label';
  static const reportsPdfCompletedShortLabel =
      'lbl_reports_pdf_completed_short_label';
  static const reportsPdfCancelledShortLabel =
      'lbl_reports_pdf_cancelled_short_label';
  static const reportsPdfTotalShortLabel = 'lbl_reports_pdf_total_short_label';
  static const reportsPdfCompletionRateTemplate =
      'lbl_reports_pdf_completion_rate_template';
  static const reportsPdfOtherLabel = 'lbl_reports_pdf_other_label';
  static const reportsPdfFooter = 'lbl_reports_pdf_footer';

  static const sessionsCalendarTitle = 'lbl_sessions_calendar_title';
  static const sessionsCalendarSlotTimeLabel =
      'lbl_sessions_calendar_slot_time_label';
  static const sessionsCalendarSlotStatusLabel =
      'lbl_sessions_calendar_slot_status_label';
  // F7-x — takvim gündem satırı/detayında antrenör adının yanına eklenen
  // kısa tür etiketi ve düet dersin katılan üyeler listesi başlığı.
  static const sessionsCalendarTypeIndividual =
      'lbl_sessions_calendar_type_individual';
  static const sessionsCalendarTypeDuet = 'lbl_sessions_calendar_type_duet';
  static const sessionsCalendarDuetMembersLabel =
      'lbl_sessions_calendar_duet_members_label';
  static const sessionsAttendanceAnswerLabel =
      'lbl_sessions_attendance_answer_label';
  static const sessionsAttendanceAnswerTimeLabel =
      'lbl_sessions_attendance_answer_time_label';
  static const sessionsAttendanceMemberNoteLabel =
      'lbl_sessions_attendance_member_note_label';
  static const sessionsAttendanceBackToCalendarButton =
      'lbl_sessions_attendance_back_to_calendar_button';
  static const sessionsManagementTitle = 'lbl_sessions_management_title';
  static const sessionsManagementEmptyState =
      'lbl_sessions_management_empty_state';
  static const sessionsFilterScheduled = 'lbl_sessions_filter_scheduled';
  static const sessionsChangeTrainerAction =
      'lbl_sessions_change_trainer_action';
  static const sessionsCancelSessionAction =
      'lbl_sessions_cancel_session_action';
  static const sessionsConfirmTitle = 'lbl_sessions_confirm_title';
  static const sessionsConfirmAttendingAnswerText =
      'lbl_sessions_confirm_attending_answer_text';
  static const sessionsConfirmNotAttendingAnswerText =
      'lbl_sessions_confirm_not_attending_answer_text';
  static const sessionsConfirmChangeAnswerButton =
      'lbl_sessions_confirm_change_answer_button';
  static const sessionsMemberHomeThisWeekSection =
      'lbl_sessions_member_home_this_week_section';
  static const sessionsMemberHomeSeePackageButton =
      'lbl_sessions_member_home_see_package_button';
  static const sessionsTrainerNotificationsTitle =
      'lbl_sessions_trainer_notifications_title';
  static const sessionsCompletionMemberNoShowOption =
      'lbl_sessions_completion_member_no_show_option';
  static const sessionsListTitle = 'lbl_sessions_list_title';
  static const sessionsListViewToggle = 'lbl_sessions_list_view_toggle';
  static const sessionsCalendarViewToggle = 'lbl_sessions_calendar_view_toggle';
  static const sessionsUpcomingSection = 'lbl_sessions_upcoming_section';
  static const sessionsPastSection = 'lbl_sessions_past_section';
  static const sessionsCalendarNoExpensesState =
      'lbl_sessions_calendar_no_expenses_state';
  static const sessionsStatusNow = 'lbl_sessions_status_now';
  static const sessionsManagementCancellingLabel =
      'lbl_sessions_management_cancelling_label';
  static const sessionsManagementAdminCancelNote =
      'lbl_sessions_management_admin_cancel_note';
  static const sessionsManagementCancelError =
      'lbl_sessions_management_cancel_error';
  static const sessionsConfirmQuestion = 'lbl_sessions_confirm_question';
  static const sessionsConfirmChangeHint = 'lbl_sessions_confirm_change_hint';
  static const sessionsConfirmWaitingHint = 'lbl_sessions_confirm_waiting_hint';
  static const sessionsConfirmSessionSummary =
      'lbl_sessions_confirm_session_summary';
  static const sessionsConfirmNoPermission =
      'lbl_sessions_confirm_no_permission';
  static const sessionsConfirmComingNote = 'lbl_sessions_confirm_coming_note';
  static const sessionsConfirmComingNoteWithMeta =
      'lbl_sessions_confirm_coming_note_with_meta';
  static const sessionsConfirmNotComingNote =
      'lbl_sessions_confirm_not_coming_note';
  static const sessionsMemberHomeGreeting = 'lbl_sessions_member_home_greeting';
  static const sessionsMemberHomeRemainingSessionsLabel =
      'lbl_sessions_member_home_remaining_sessions_label';
  static const sessionsMemberHomePackageValidUntil =
      'lbl_sessions_member_home_package_valid_until';
  static const sessionsMemberHomeNextSessionSection =
      'lbl_sessions_member_home_next_session_section';
  static const sessionsMemberHomeInstallmentsSection =
      'lbl_sessions_member_home_installments_section';
  static const sessionsMemberHomeInstallmentIndexLabel =
      'lbl_sessions_member_home_installment_index_label';
  static const sessionsMemberHomeInstallmentDueDateLabel =
      'lbl_sessions_member_home_installment_due_date_label';
  static const sessionsMemberHomeInstallmentDueSoonLabel =
      'lbl_sessions_member_home_installment_due_soon_label';
  static const sessionsMemberHomeInstallmentUnpaidLabel =
      'lbl_sessions_member_home_installment_unpaid_label';
  static const sessionsCompletionConfirmError =
      'lbl_sessions_completion_confirm_error';
  static const sessionsManagementMarkCompletedAction =
      'lbl_sessions_management_mark_completed_action';
  static const sessionsManagementMarkAbsentAction =
      'lbl_sessions_management_mark_absent_action';
  static const sessionsManagementAttendanceCurrentStatus =
      'lbl_sessions_management_attendance_current_status';
  static const sessionsManagementAttendanceError =
      'lbl_sessions_management_attendance_error';
  static const sessionsCompletionQuestion = 'lbl_sessions_completion_question';
  static const sessionsCompletionTimeLimitNote =
      'lbl_sessions_completion_time_limit_note';

  /// Seans başlangıcının üzerinden 24 saatten fazla geçmiş, hâlâ
  /// `planned` durumundaki bir seansın "Dersi onayla" sheet'inde
  /// gösterilir — butonlar devre dışı bırakılır (bkz.
  /// `trainer_calendar_panel.dart`, `firestore.rules`'taki
  /// `withinCompletionWindow()`).
  static const sessionsCompletionExpiredNote =
      'lbl_sessions_completion_expired_note';
  static const sessionsListEmptyState = 'lbl_sessions_list_empty_state';
  static const sessionsListCalendarEmptyDay =
      'lbl_sessions_list_calendar_empty_day';
  static const sessionsTrainerNotificationsEmptyState =
      'lbl_sessions_trainer_notifications_empty_state';
  static const sessionsCreateTrainerBusyError =
      'lbl_sessions_create_trainer_busy_error';

  /// Antrenör çakışması/hak yetersizliği/geçmiş tarih DIŞINDA, beklenmeyen
  /// bir hatayla (ör. izin reddi) karşılaşıldığında — önceden bu durum da
  /// yanlışlıkla "antrenör dolu" mesajıyla gösteriliyordu, gerçek sebebi
  /// gizliyordu.
  static const sessionsCreateGenericError = 'lbl_sessions_create_generic_error';
  static const sessionsCreateRescheduleError =
      'lbl_sessions_create_reschedule_error';
  static const sessionsCreateNoActiveGymError =
      'lbl_sessions_create_no_active_gym_error';
  static const sessionsCreateSkippedDaysSnackbar =
      'lbl_sessions_create_skipped_days_snackbar';

  /// Atlanan her günün yanında parantez içinde gösterilen kısa sebep etiketi
  /// (bkz. `create_session_sheet.dart`'taki `_skippedDayEntry`) — hepsi tek
  /// bir "antrenör dolu" mesajına indirgenmesin diye günün GERÇEK sebebi
  /// ayrı ayrı gösteriliyor.
  static const sessionsSkipReasonTrainerBusy =
      'lbl_sessions_skip_reason_trainer_busy';
  static const sessionsSkipReasonPastDatetime =
      'lbl_sessions_skip_reason_past_datetime';
  static const sessionsSkipReasonInsufficientSessions =
      'lbl_sessions_skip_reason_insufficient_sessions';
  static const sessionsSkipReasonUnknownError =
      'lbl_sessions_skip_reason_unknown_error';
  static const sessionsCreateTitle = 'lbl_sessions_create_title';
  static const sessionsCreateSelectPlaceholder =
      'lbl_sessions_create_select_placeholder';
  static const sessionsCreateMemberSummary =
      'lbl_sessions_create_member_summary';
  static const sessionsCreatePickMemberTitle =
      'lbl_sessions_create_pick_member_title';
  static const sessionsCreateMemberSessionsSuffix =
      'lbl_sessions_create_member_sessions_suffix';
  static const sessionsCreatePickTrainerTitle =
      'lbl_sessions_create_pick_trainer_title';

  /// Seans oluşturma sheet'inin en üstündeki "Birebir Seans"/"Düet Ders"
  /// toggle'ı — düet seçilince üye alanı çoklu seçime döner.
  static const sessionsCreateKindLabel = 'lbl_sessions_create_kind_label';
  static const sessionsCreateKindIndividual =
      'lbl_sessions_create_kind_individual';
  static const sessionsCreateKindDuet = 'lbl_sessions_create_kind_duet';
  static const sessionsCreateMembersFieldLabel =
      'lbl_sessions_create_members_field_label';
  static const sessionsCreatePickMembersTitle =
      'lbl_sessions_create_pick_members_title';
  static const sessionsCreateDuetMembersSummary =
      'lbl_sessions_create_duet_members_summary';
  static const sessionsCreateDuetMinMembersError =
      'lbl_sessions_create_duet_min_members_error';
  static const sessionsCreateRepeatLabel = 'lbl_sessions_create_repeat_label';
  static const sessionsCreateRepeatDaysSelected =
      'lbl_sessions_create_repeat_days_selected';
  static const sessionsCreateSubmitButton = 'lbl_sessions_create_submit_button';
  static const sessionsRepeatCalendarExhaustedError =
      'lbl_sessions_repeat_calendar_exhausted_error';
  static const sessionsRepeatCalendarSubtitle =
      'lbl_sessions_repeat_calendar_subtitle';
  static const sessionsRepeatCalendarRemainingLabel =
      'lbl_sessions_repeat_calendar_remaining_label';
  static const trainersManagementTitle = 'lbl_trainers_management_title';
  static const trainersAddTrainerButton = 'lbl_trainers_add_trainer_button';
  static const trainersSpecialtyFieldLabel =
      'lbl_trainers_specialty_field_label';
  static const trainersAddTrainerFormTitle =
      'lbl_trainers_add_trainer_form_title';
  static const trainersFullNameFieldLabel =
      'lbl_trainers_full_name_field_label';
  static const trainersAddTrainerSubmitButton =
      'lbl_trainers_add_trainer_submit_button';
  static const trainersHomeAwaitingApprovalSection =
      'lbl_trainers_home_awaiting_approval_section';
  static const trainersHomeTodayScheduleSection =
      'lbl_trainers_home_today_schedule_section';
  static const trainersHomeNoShowLabel = 'lbl_trainers_home_no_show_label';
  static const trainersHomeTodaySessionsLabel =
      'lbl_trainers_home_today_sessions_label';
  static const trainersHomeCompletedLabel = 'lbl_trainers_home_completed_label';
  static const trainersHomeFreeSlotLabel = 'lbl_trainers_home_free_slot_label';
  static const trainersMemberDetailCreateSessionButton =
      'lbl_trainers_member_detail_create_session_button';
  static const trainersMemberDetailAddMeasurementButton =
      'lbl_trainers_member_detail_add_measurement_button';
  static const trainersMemberDetailRemainingSessionsLabel =
      'lbl_trainers_member_detail_remaining_sessions_label';
  static const trainersMemberDetailPackageEndLabel =
      'lbl_trainers_member_detail_package_end_label';
  static const trainersCalendarTitle = 'lbl_trainers_calendar_title';
  static const trainersCalendarMarkCompletedAction =
      'lbl_trainers_calendar_mark_completed_action';
  static const trainersMembersListTitle = 'lbl_trainers_members_list_title';
  static const trainersMembersFilterExpiring =
      'lbl_trainers_members_filter_expiring';
  static const trainersMembersRemainingSessionsSuffix =
      'lbl_trainers_members_remaining_sessions_suffix';
  static const trainersReportTitle = 'lbl_trainers_report_title';
  static const trainersReportStartDateFieldLabel =
      'lbl_trainers_report_start_date_field_label';
  static const trainersReportEndDateFieldLabel =
      'lbl_trainers_report_end_date_field_label';
  static const trainersReportOneOnOneToggle =
      'lbl_trainers_report_one_on_one_toggle';
  static const trainersReportGroupToggle = 'lbl_trainers_report_group_toggle';
  static const trainersReportDuetToggle = 'lbl_trainers_report_duet_toggle';
  static const trainersReportPeriodWeekly = 'lbl_trainers_report_period_weekly';
  static const trainersReportPeriodMonthly =
      'lbl_trainers_report_period_monthly';
  static const trainersReportPeriodAllTime =
      'lbl_trainers_report_period_all_time';
  static const trainersReportPeriodCustom = 'lbl_trainers_report_period_custom';
  static const trainersProfileFooterText = 'lbl_trainers_profile_footer_text';
  static const trainersInfoTitle = 'lbl_trainers_info_title';
  static const trainersDetailTitle = 'lbl_trainers_detail_title';
  static const trainersMemberCountSuffix = 'lbl_trainers_member_count_suffix';
  static const trainersDetailAllTimeSection =
      'lbl_trainers_detail_all_time_section';
  static const trainersDetailPlannedLabel = 'lbl_trainers_detail_planned_label';
  static const trainersDetailThisMonthSection =
      'lbl_trainers_detail_this_month_section';
  static const trainersDetailThisWeekSection =
      'lbl_trainers_detail_this_week_section';
  static const trainersDetailMonthLoadError =
      'lbl_trainers_detail_month_load_error';
  static const trainersAddTrainerNameRequiredError =
      'lbl_trainers_add_trainer_name_required_error';
  static const trainersAddTrainerError = 'lbl_trainers_add_trainer_error';
  static const trainersPhoneTakenError = 'lbl_trainers_phone_taken_error';
  static const trainersAddTrainerNameHint =
      'lbl_trainers_add_trainer_name_hint';
  static const trainersManagementTrainerCountSuffix =
      'lbl_trainers_management_trainer_count_suffix';
  static const trainersAddTrainerSavingLabel =
      'lbl_trainers_add_trainer_saving_label';
  static const trainersEditTrainerFormTitle =
      'lbl_trainers_edit_trainer_form_title';
  static const trainersEditTrainerError = 'lbl_trainers_edit_trainer_error';
  static const trainersHomeGreeting = 'lbl_trainers_home_greeting';
  static const trainersHomeGreetingWithName =
      'lbl_trainers_home_greeting_with_name';
  static const trainersHomeConfirmationSaveError =
      'lbl_trainers_home_confirmation_save_error';
  static const trainersMembersSearchHint = 'lbl_trainers_members_search_hint';
  static const trainersProfileSpecialtyRole =
      'lbl_trainers_profile_specialty_role';
  // F6-1 abonelik ekranı yeniden tasarımı — 4 durum (deneme/aktif/süresi
  // dolmuş/mağazaya yönlendirildi). `{days}`/`{date}`/`{total}`/`{current}`/
  // `{period}`/`{plan}` yer tutucuları panel tarafında dolduruluyor;
  // `{store}`/`{storeAccount}` ("App Store"/"Apple" ya da "Google Play"/
  // "Google") platforma göre kod içinde sabit — marka adı, iş kuralı değil.
  static const subscriptionTrialBannerTitle =
      'lbl_subscription_trial_banner_title';
  static const subscriptionTrialBannerBody =
      'lbl_subscription_trial_banner_body';
  static const subscriptionTrialProgress = 'lbl_subscription_trial_progress';
  static const subscriptionExpiredBannerTitle =
      'lbl_subscription_expired_banner_title';
  static const subscriptionExpiredBannerBody =
      'lbl_subscription_expired_banner_body';
  static const subscriptionRestrictedTitle =
      'lbl_subscription_restricted_title';
  static const subscriptionRestrictedNote = 'lbl_subscription_restricted_note';
  static const subscriptionActivePlanLabel =
      'lbl_subscription_active_plan_label';
  static const subscriptionActiveBadge = 'lbl_subscription_active_badge';
  static const subscriptionRenewalLabel = 'lbl_subscription_renewal_label';
  static const subscriptionStartedLabel = 'lbl_subscription_started_label';
  static const subscriptionActiveNote = 'lbl_subscription_active_note';
  static const subscriptionStoreRowTitle = 'lbl_subscription_store_row_title';
  static const subscriptionStoreRowSubtitle =
      'lbl_subscription_store_row_subtitle';
  static const subscriptionManageCta = 'lbl_subscription_manage_cta';
  static const subscriptionManageCaption = 'lbl_subscription_manage_caption';

  /// Aylık abone olan kullanıcıya "Aktif abone" ekranında gösterilen
  /// yıllığa geçiş kartının üstündeki başlık.
  static const subscriptionUpgradeToYearlyTitle =
      'lbl_subscription_upgrade_to_yearly_title';
  static const subscriptionStoreNote = 'lbl_subscription_store_note';
  static const subscriptionStoreNoteExpired =
      'lbl_subscription_store_note_expired';
  static const subscriptionPurchaseCta = 'lbl_subscription_purchase_cta';
  static const subscriptionPurchaseCtaExpired =
      'lbl_subscription_purchase_cta_expired';
  static const subscriptionPurchaseCaption =
      'lbl_subscription_purchase_caption';
  static const subscriptionPendingBannerTitle =
      'lbl_subscription_pending_banner_title';
  static const subscriptionPendingBannerBody =
      'lbl_subscription_pending_banner_body';
  static const subscriptionPendingPill = 'lbl_subscription_pending_pill';
  static const subscriptionPendingCta = 'lbl_subscription_pending_cta';
  static const subscriptionPendingCaption = 'lbl_subscription_pending_caption';
  static const subscriptionPendingNote = 'lbl_subscription_pending_note';
  static const subscriptionYearlyBadge = 'lbl_subscription_yearly_badge';
  static const subscriptionYearlySub = 'lbl_subscription_yearly_sub';
  static const subscriptionMonthlySub = 'lbl_subscription_monthly_sub';

  /// `{days}` yer tutucusu, mağazadan okunan gerçek ücretsiz deneme
  /// süresiyle (bkz. `SubscriptionProduct.trialDays`) değiştirilir — sadece
  /// mağaza bu bilgiyi döndürdüğünde kullanılır, aksi halde
  /// [subscriptionYearlySub]/[subscriptionMonthlySub]'a düşülür.
  static const subscriptionTrialSubLabel = 'lbl_subscription_trial_sub_label';
  static const subscriptionNoProducts = 'lbl_subscription_no_products';
  static const subscriptionYearlyPlanFallback =
      'lbl_subscription_yearly_plan_fallback';
  static const subscriptionMonthlyPlanFallback =
      'lbl_subscription_monthly_plan_fallback';
  static const subscriptionYearlyPeriodWord =
      'lbl_subscription_yearly_period_word';
  static const subscriptionMonthlyPeriodWord =
      'lbl_subscription_monthly_period_word';
  static const subscriptionStoreBadgeLabel =
      'lbl_subscription_store_badge_label';
  static const subscriptionManagementOpenError =
      'lbl_subscription_management_open_error';
  static const subscriptionExemptNote = 'lbl_subscription_exempt_note';

  /// `[{label_tr, label_en}]` — abonelikte dahil olan özellik listesi.
  static const subscriptionIncludedFeatures =
      'cfg_subscription_included_features';

  /// `[{label_tr, label_en}]` — süresi dolduğunda kısıtlanan işlemler.
  static const subscriptionRestrictedOperations =
      'cfg_subscription_restricted_operations';
}

/// Firebase Remote Config'e tip güvenli erişim katmanı. `FirebaseRemoteConfig.instance`
/// bu dosya dışında hiçbir yerde çağrılmaz (CLAUDE.md §2.5).
class RemoteConfigService {
  const RemoteConfigService();

  static const _defaultBadgeCriteriaJson = '''
[
  {"id": "first_session", "title_tr": "İlk dersin", "title_en": "Your first session", "note_tr": "İlk dersini tamamla", "note_en": "Complete your first session", "type": "sessionsCompleted", "threshold": 1},
  {"id": "sessions_5", "title_tr": "5 ders tamam", "title_en": "5 sessions done", "note_tr": "5 ders tamamla", "note_en": "Complete 5 sessions", "type": "sessionsCompleted", "threshold": 5},
  {"id": "sessions_20", "title_tr": "20 ders tamam", "title_en": "20 sessions done", "note_tr": "20 ders tamamla", "note_en": "Complete 20 sessions", "type": "sessionsCompleted", "threshold": 20},
  {"id": "group_session_join", "title_tr": "Grup dersi", "title_en": "Group class", "note_tr": "Bir grup dersine katıl", "note_en": "Join a group class", "type": "groupSessionJoins", "threshold": 1},
  {"id": "event_join", "title_tr": "Etkinlik", "title_en": "Event", "note_tr": "Bir etkinliğe katıl", "note_en": "Join an event", "type": "eventJoins", "threshold": 1},
  {"id": "membership_6_months", "title_tr": "6 ay üyelik", "title_en": "6-month membership", "note_tr": "6 ay üyeliğini sürdür", "note_en": "Keep your membership for 6 months", "type": "membershipMonths", "threshold": 6},
  {"id": "sessions_50", "title_tr": "50 ders tamam", "title_en": "50 sessions done", "note_tr": "50 ders tamamla", "note_en": "Complete 50 sessions", "type": "sessionsCompleted", "threshold": 50},
  {"id": "membership_12_months", "title_tr": "1 yıl üyelik", "title_en": "1-year membership", "note_tr": "12 ay üyeliğini sürdür", "note_en": "Keep your membership for 12 months", "type": "membershipMonths", "threshold": 12},
  {"id": "feedback_given", "title_tr": "Geri bildirim", "title_en": "Feedback", "note_tr": "İlk geri bildirimini gönder", "note_en": "Send your first feedback", "type": "feedbackCount", "threshold": 1},
  {"id": "measurement_logged", "title_tr": "Ölçüm takibi", "title_en": "Measurement tracking", "note_tr": "İlk ölçümünü kaydet", "note_en": "Log your first measurement", "type": "measurementEntries", "threshold": 1}
]
''';

  static const _defaultExpenseCategoriesJson = '''
[
  {"id": "rent", "label_tr": "Kira", "label_en": "Rent"},
  {"id": "utility", "label_tr": "Fatura", "label_en": "Utility"},
  {"id": "equipment", "label_tr": "Ekipman", "label_en": "Equipment"},
  {"id": "commission", "label_tr": "Prim", "label_en": "Commission"},
  {"id": "marketing", "label_tr": "Pazarlama", "label_en": "Marketing"},
  {"id": "other", "label_tr": "Diğer", "label_en": "Other"}
]
''';

  static const _defaultSubscriptionIncludedFeaturesJson = '''
[
  {"label_tr": "Sınırsız üye ve antrenör hesabı", "label_en": "Unlimited member and trainer accounts"},
  {"label_tr": "Seans takvimi, onay ve telafi takibi", "label_en": "Session calendar, confirmation and makeup tracking"},
  {"label_tr": "Ölçüm takibi ve üye raporları", "label_en": "Measurement tracking and member reports"},
  {"label_tr": "Salon teması, kurallar ve bildirimler", "label_en": "Gym theme, rules and notifications"}
]
''';

  static const _defaultSubscriptionRestrictedOperationsJson = '''
[
  {"label_tr": "Yeni üye ve üyelik ekleme", "label_en": "Adding new members and memberships"},
  {"label_tr": "Seans ve grup dersi oluşturma", "label_en": "Creating sessions and group classes"},
  {"label_tr": "Üyelere bildirim gönderme", "label_en": "Sending notifications to members"}
]
''';

  static const Map<String, Object> _defaults = {
    RemoteConfigKeys.sessionReminderMinutesBefore: 120,
    RemoteConfigKeys.defaultGroupSessionCapacity: 6,
    RemoteConfigKeys.groupSessionCapacityMax: 20,
    RemoteConfigKeys.installmentDueSoonDays: 3,
    RemoteConfigKeys.memberEndingSoonSessionsThreshold: 3,
    RemoteConfigKeys.eventLeaveLockHoursBefore: 24,
    RemoteConfigKeys.groupSessionLeaveLockHoursBefore: 8,
    RemoteConfigKeys.cancellationDeadlineHours: 24,
    RemoteConfigKeys.defaultTrainerReminderDelayMinutes: 30,
    RemoteConfigKeys.defaultCanCancelMemberSessions: true,
    RemoteConfigKeys.defaultCanRescheduleMemberSessions: true,
    RemoteConfigKeys.allowPastDatetimeCreation: false,
    RemoteConfigKeys.feedbackReminderDayOfMonth: -1,
    RemoteConfigKeys.freeVersionAdsEnabled: true,
    RemoteConfigKeys.trialDurationDays: 14,
    RemoteConfigKeys.gymRulesMaxChars: 6000,
    RemoteConfigKeys.groupSessionDescriptionMaxChars: 500,
    RemoteConfigKeys.requireSubscriptionOnboarding: true,
    RemoteConfigKeys.featureFlags: '{"group_sessions_enabled": true}',
    RemoteConfigKeys.badgeCriteria: _defaultBadgeCriteriaJson,
    RemoteConfigKeys.expenseCategories: _defaultExpenseCategoriesJson,
    'lbl_notif_session_reminder_title_tr': '⏰ Bugün {time}\'de dersin var!',
    'lbl_notif_session_reminder_body_tr':
        '{trainerName} seni bekliyor. Gelip gelmeyeceğini onaylamak için dokun 👇',
    'lbl_notif_session_completion_title_tr': '✅ Dersini onaylar mısın?',
    'lbl_notif_session_completion_body_tr':
        '{memberName} ile dersin bitti. Tamamlandı mı, yoksa üye gelmedi mi?',
    'lbl_notif_package_ending_soon_title_tr': '⏳ Paketin bitmek üzere',
    'lbl_notif_package_ending_soon_body_tr':
        '{remaining} ders hakkın kaldı. Yeni paket için salonunla iletişime geç.',
    'lbl_notif_package_none_title_tr': '📦 Paketin bitti',
    'lbl_notif_package_none_body_tr':
        'Ders hakkın kalmadı. Devam edebilmek için yeni bir paket almalısın.',
    'lbl_notif_feedback_reminder_title_tr': '💬 Bu ay nasıl geçti?',
    'lbl_notif_feedback_reminder_body_tr':
        'Deneyimini bizimle paylaşır mısın? 1 dakikanı alır.',
    'lbl_common_vazgec_tr': 'Vazgeç',
    'lbl_common_kaydet_tr': 'Kaydet',
    'lbl_common_duzenle_tr': 'Düzenle',
    'lbl_common_kapat_tr': 'Kapat',
    'lbl_common_degistir_tr': 'Değiştir',
    'lbl_common_cikis_yap_tr': 'Çıkış yap',
    'lbl_common_hesabimi_sil_tr': 'Hesabımı sil',
    'lbl_common_studyo_kurallari_nav_tr': 'Salon kuralları',
    'lbl_common_seansi_ertele_tr': 'Seansı ertele',
    'lbl_common_gelicem_tr': 'Gelicem',
    'lbl_common_gelmeyecegim_tr': 'Gelmeyeceğim',
    'lbl_common_ana_sayfa_tab_tr': 'Ana Sayfa',
    'lbl_common_profil_tab_tr': 'Profil',
    'lbl_common_telefon_label_tr': 'Telefon',
    'lbl_common_phone_country_search_hint_tr': 'Ülke ara',
    'lbl_common_tumu_filter_tr': 'Tümü',
    'lbl_common_tamamlandi_tr': 'Tamamlandı',
    'lbl_common_iptal_label_tr': 'İptal',
    'lbl_common_kalan_ders_label_tr': 'Kalan ders',
    'lbl_common_paketi_yok_filter_tr': 'Paketi yok',
    'lbl_common_seans_sayisi_label_tr': 'Seans sayısı',
    'lbl_common_add_seans_button_tr': '+ Seans',
    'lbl_common_olcum_6_ay_section_header_tr': 'ÖLÇÜM · 6 AY',
    'lbl_common_ders_gecmisi_section_header_tr': 'DERS GEÇMİŞİ',
    'lbl_common_uye_detayi_title_tr': 'Üye detayı',
    'lbl_common_bu_gunde_seans_yok_tr': 'Bu günde seans yok.',
    'lbl_common_bitis_label_tr': 'Bitiş',
    'lbl_common_language_nav_label_tr': 'Dil',
    'lbl_common_tamam_button_tr': 'Tamam',
    'lbl_common_henuz_veri_yok_tr': 'Henüz veri yok',
    'lbl_language_select_title_tr': 'Dil seç',
    'lbl_language_select_turkish_option_tr': 'Türkçe',
    'lbl_language_select_english_option_tr': 'English',
    'lbl_shell_member_tab_derslerim_tr': 'Derslerim',
    'lbl_shell_member_tab_olcumlerim_tr': 'Ölçümlerim',
    'lbl_shell_member_tab_kesfet_tr': 'Keşfet',
    'lbl_shell_trainer_tab_takvimim_tr': 'Takvimim',
    'lbl_shell_trainer_tab_uyelerim_tr': 'Üyelerim',
    'lbl_shell_trainer_tab_raporum_tr': 'Raporum',
    'lbl_shell_admin_tab_uyeler_tr': 'Üyeler',
    'lbl_shell_admin_tab_seanslar_tr': 'Seanslar',
    'lbl_shell_admin_tab_finans_tr': 'Finans',
    'lbl_shell_admin_tab_ayarlar_tr': 'Ayarlar',
    'lbl_shell_role_picker_member_button_tr': 'Üye',
    'lbl_shell_role_picker_trainer_button_tr': 'Antrenör',
    'lbl_shell_role_picker_admin_button_tr': 'Admin',
    'lbl_shell_role_picker_gym_setup_button_tr':
        'Admin · Salon Kurulumu (ilk kurulum)',
    'lbl_auth_profile_title_tr': 'Profilim',
    'lbl_auth_phone_number_label_tr': 'Telefon numarası',
    'lbl_auth_login_button_tr': 'Giriş yap',
    'lbl_auth_select_avatar_label_tr': 'Avatarını seç',
    'lbl_auth_badges_nav_label_tr': 'Rozetlerim',
    'lbl_auth_give_feedback_nav_label_tr': 'Geri bildirim ver',
    'lbl_auth_session_reminders_toggle_title_tr': 'Ders hatırlatmaları',
    'lbl_auth_session_reminders_toggle_description_tr':
        'Dersinden 2 saat önce bildirim',
    'lbl_auth_delete_account_confirm_title_tr': 'Profilim',
    'lbl_auth_login_error_not_found_tr':
        'Bu numarayla kayıtlı bir hesap bulunamadı. Salon yönetimi seni eklemeli.',
    'lbl_auth_login_error_rate_limited_tr':
        'Çok fazla deneme yapıldı. Bir dakika sonra tekrar dene.',
    'lbl_auth_login_error_generic_tr':
        'Giriş yapılamadı. Bağlantını kontrol edip tekrar dene.',
    'lbl_auth_login_error_subscription_inactive_tr':
        'Hesabınız şu anda aktif değil. Lütfen salonunuzla iletişime geçin.',
    'lbl_auth_retry_button_tr': 'Tekrar dene',
    'lbl_auth_delete_account_error_generic_tr':
        'Hesap silinemedi. Bağlantını kontrol edip tekrar dene.',
    'lbl_auth_delete_account_item_remaining_sessions_tr':
        'Kalan {count} dersin ve telafi hakkın',
    'lbl_auth_delete_account_item_measurements_badges_tr':
        'Ölçüm geçmişin ve rozetlerin',
    'lbl_auth_delete_account_item_feedback_tr':
        'Salonuna bıraktığın geri bildirimler',
    'lbl_auth_delete_account_confirm_heading_tr':
        'Hesabını silmek geri alınamaz',
    'lbl_auth_delete_account_confirm_body_tr':
        'Silme işlemi 24 saat içinde tamamlanır ve iptal edilemez. '
        'Kalan {count} dersin ve ölçüm geçmişin de silinir.',
    'lbl_auth_delete_account_acknowledge_label_tr':
        'Anladım, hesabım ve tüm verilerim silinsin.',
    'lbl_auth_delete_account_in_progress_button_tr': 'Siliniyor…',
    'lbl_auth_login_waiting_heading_tr': 'Seni tanıyoruz…',
    'lbl_auth_login_waiting_body_tr': '+90 {phone} numarası salonda aranıyor.',
    'lbl_auth_login_waiting_hint_tr':
        '30 saniyeden uzun sürerse bağlantını kontrol edip tekrar dene.',
    'lbl_auth_login_waiting_cancel_button_tr': 'İptal',
    'lbl_auth_onboarding_role_brand_label_tr': 'EGORACTIVE',
    'lbl_auth_onboarding_role_title_tr': 'Hoş geldin',
    'lbl_auth_onboarding_role_subtitle_tr': 'Devam etmek için rolünü seç.',
    'lbl_auth_onboarding_role_trainer_title_tr': 'Antrenörüm',
    'lbl_auth_onboarding_role_trainer_note_tr': 'Antrenörlük belgem var',
    'lbl_auth_onboarding_role_member_title_tr': 'Üyeyim',
    'lbl_auth_onboarding_role_member_note_tr': 'Bir salona kayıtlıyım',
    'lbl_auth_onboarding_role_hint_trainer_tr':
        'Sonraki adımda bir salona bağlı mı olduğunu soracağız.',
    'lbl_auth_onboarding_role_hint_member_tr':
        'Salonuna kayıtlı telefon numaranla giriş yapacaksın.',
    'lbl_auth_onboarding_role_continue_button_tr': 'Devam et',
    'lbl_auth_onboarding_role_go_to_login_button_tr': 'Girişe geç',
    'lbl_auth_onboarding_role_partner_gyms_button_tr': 'Anlaşmalı Salonlar',
    'lbl_partner_gyms_title_tr': 'Anlaşmalı Salonlar',
    'lbl_partner_gyms_empty_tr': 'Henüz listelenen bir salon yok.',
    'lbl_partner_gyms_error_tr': 'Salonlar yüklenemedi, tekrar dene.',
    'lbl_auth_trainer_path_title_tr': 'Bir salona bağlı mısın?',
    'lbl_auth_trainer_path_subtitle_tr':
        'Zaten çalıştığın bir salon varsa oraya bağlan; yoksa kendi salonunu sen oluştur.',
    'lbl_auth_trainer_path_linked_title_tr': 'Bir salona bağlı çalışıyorum',
    'lbl_auth_trainer_path_linked_note_tr':
        'Salon yönetimi beni zaten sisteme eklemiş olmalı',
    'lbl_auth_trainer_path_new_gym_title_tr': 'Yeni bir salon açmak istiyorum',
    'lbl_auth_trainer_path_new_gym_note_tr':
        'Kendi salonumu ilk kez kaydediyorum',
    'lbl_auth_trainer_path_hint_linked_tr':
        'Numaran sistemde yoksa salon yönetiminden seni eklemesini isteyebilirsin.',
    'lbl_auth_trainer_path_hint_new_gym_tr':
        'Salon bilgilerini girdikten sonra yönetici olarak giriş yapacaksın.',
    'lbl_auth_trainer_path_create_gym_button_tr': 'Salon oluşturmaya geç',
    'lbl_auth_phone_login_title_tr': 'Telefonunla giriş yap',
    'lbl_auth_phone_login_subtitle_tr':
        'Salonuna kayıtlı numaranı gir; şifre yok, tek dokunuşla girersin.',
    'lbl_auth_phone_login_hint_tr':
        'Numaran kayıtlı değilse salon yönetimi seni eklemeli.',
    'lbl_auth_email_login_title_tr': 'E-posta ile giriş yap',
    'lbl_auth_email_login_subtitle_tr':
        'Salonuna kayıtlı e-posta adresini gir, sana bir doğrulama kodu '
        'gönderelim. Şifre yok, kod ile tek dokunuşta girersin.',
    'lbl_auth_email_address_label_tr': 'E-posta adresi',
    'lbl_auth_switch_to_phone_link_tr': 'Telefon numarası ile giriş yap',
    'lbl_auth_switch_to_email_link_tr': 'E-posta ile giriş yap',
    'lbl_auth_otp_title_tr': 'Kodu gir',
    'lbl_auth_otp_subtitle_tr':
        '{email} adresine 6 haneli bir doğrulama kodu gönderdik. Kodu '
        'aşağıya gir.',
    'lbl_auth_otp_verify_button_tr': 'Doğrula ve devam et',
    'lbl_auth_otp_resend_button_tr': 'Kodu tekrar gönder',
    'lbl_auth_otp_resend_countdown_template_tr':
        '{seconds} saniye sonra tekrar gönderebilirsin',
    'lbl_auth_otp_generic_error_tr':
        'Bir şeyler ters gitti. İnternet bağlantını kontrol edip tekrar '
        'dene.',
    'lbl_auth_otp_invalid_code_error_tr':
        'Girdiğin kod yanlış. Kontrol edip tekrar dene.',
    'lbl_auth_otp_expired_error_tr':
        'Bu kodun süresi doldu. "Kodu tekrar gönder" ile yeni bir kod iste.',
    'lbl_auth_otp_too_many_attempts_error_tr':
        'Çok fazla yanlış deneme yaptın. "Kodu tekrar gönder" ile yeni bir '
        'kod iste.',
    'lbl_auth_email_setup_title_tr': 'E-posta adresini ekle',
    'lbl_auth_email_setup_subtitle_tr':
        'Girişlerinde kullanacağın e-posta adresini gir; sana 6 haneli bir '
        'doğrulama kodu göndereceğiz.',
    'lbl_auth_email_setup_send_button_tr': 'Doğrulama kodu gönder',
    'lbl_auth_email_setup_invalid_email_error_tr':
        'Bu geçerli bir e-posta adresi değil. Lütfen kontrol edip tekrar '
        'dene (örn. isim@ornek.com).',
    'lbl_auth_email_setup_email_taken_error_tr':
        'Bu e-posta adresi başka bir hesapta kullanılıyor. Farklı bir '
        'adres dene.',
    'lbl_gyms_gym_info_login_report_email_label_tr':
        'Login ve rapor e-postası *',
    'lbl_members_self_info_email_field_label_tr': 'E-posta adresi',
    'lbl_trainers_info_title_tr': 'Bilgilerim',
    'lbl_auth_profile_member_caption_tr': '+90 {phone} · Üye',
    'lbl_auth_profile_session_reminder_description_tr':
        'Dersinden {minutes} dakika önce bildirim',
    'lbl_auth_splash_title_tr': 'Egoractive',
    'lbl_auth_splash_tagline_tr': 'Spor salonu yönetimi',
    'lbl_auth_splash_publisher_tr': 'Egora Games',
    'lbl_badges_title_tr': 'Rozetlerim',
    'lbl_badges_load_error_tr': 'Rozetler yüklenemedi.',
    'lbl_badges_earned_count_label_tr': '{count} rozet kazandın',
    'lbl_badges_next_locked_label_tr': 'Sıradaki: {note}',
    'lbl_badges_detail_earned_status_tr': 'Kazanıldı',
    'lbl_badges_detail_locked_status_tr': 'Henüz kazanılmadı',
    'lbl_members_detail_badges_section_header_tr': 'ROZETLER',
    'lbl_events_admin_list_title_tr': 'Etkinlikler',
    'lbl_events_add_event_button_tr': '+ Etkinlik',
    'lbl_events_attending_label_tr': 'Katılan',
    'lbl_events_capacity_label_tr': 'Kontenjan',
    'lbl_events_create_title_tr': 'Etkinlik oluştur',
    'lbl_events_capacity_empty_means_unlimited_helper_tr':
        'Boş bırakırsanız sınırsız olur',
    'lbl_events_name_field_label_tr': 'Etkinlik adı',
    'lbl_events_location_field_label_tr': 'Lokasyon',
    'lbl_events_date_field_label_tr': 'Tarih',
    'lbl_events_time_field_label_tr': 'Saat',
    'lbl_events_description_field_label_tr': 'Açıklama',
    'lbl_events_create_submit_button_tr': 'Etkinliği oluştur',
    'lbl_events_date_field_hint_tr': '16 Ağu 2026',
    'lbl_events_time_field_hint_tr': '08:00',
    'lbl_events_name_required_error_tr': 'Etkinlik adı boş bırakılamaz.',
    'lbl_events_date_format_error_tr':
        'Tarihi "gün ay yıl" formatında gir (örn. 16 Ağu 2026).',
    'lbl_events_create_failed_error_tr':
        'Etkinlik oluşturulamadı, tekrar dene.',
    'lbl_expenses_list_title_tr': 'Giderler',
    'lbl_expenses_add_expense_button_tr': '+ Gider',
    'lbl_expenses_categories_section_header_tr': 'KATEGORİLER',
    'lbl_expenses_recent_entries_section_header_tr': 'SON KAYITLAR',
    'lbl_expenses_add_title_tr': 'Gider ekle',
    'lbl_expenses_category_field_label_tr': 'Kategori',
    'lbl_expenses_recurring_toggle_label_tr': 'Her ay tekrar et',
    'lbl_expenses_recurring_toggle_description_tr':
        'Kira ve fatura gibi sabit giderler için',
    'lbl_expenses_amount_field_label_tr': 'Tutar ({currency})',
    'lbl_expenses_description_field_label_tr': 'Açıklama',
    'lbl_expenses_date_field_label_tr': 'Tarih',
    'lbl_expenses_submit_button_tr': 'Gideri kaydet',
    'lbl_expenses_amount_field_hint_tr': '8.400',
    'lbl_expenses_category_picker_title_tr': 'Kategori seç',
    'lbl_expenses_description_field_hint_tr': 'Reformer yay değişimi',
    'lbl_expenses_trainer_commission_note_tr':
        'Antrenör primleri seans onaylarından otomatik hesaplanır; buraya elle girilmez.',
    'lbl_expenses_amount_invalid_error_tr': 'Geçerli bir tutar gir.',
    'lbl_expenses_description_required_error_tr': 'Açıklama boş bırakılamaz.',
    'lbl_expenses_save_failed_error_tr': 'Gider kaydedilemedi, tekrar dene.',
    'lbl_expenses_monthly_total_label_tr': '{month} toplam gider',
    'lbl_expenses_revenue_ratio_label_tr': 'Ciroya oranı {ratio}',
    'lbl_feedback_admin_list_title_tr': 'Geri bildirimler',
    'lbl_feedback_member_form_title_tr': 'Geri bildirim',
    'lbl_feedback_comment_section_header_tr': 'YORUMUN (İSTEĞE BAĞLI)',
    'lbl_feedback_total_reviews_caption_tr': '{count} değerlendirme',
    'lbl_feedback_how_was_session_title_tr': 'Dersin nasıl geçti?',
    'lbl_feedback_privacy_note_with_trainer_tr':
        '{trainer} ile birebir · Yalnızca salon yönetimi görür, antrenörüne isimsiz iletilir.',
    'lbl_feedback_privacy_note_tr':
        'Yalnızca salon yönetimi görür, antrenörüne isimsiz iletilir.',
    'lbl_feedback_comment_field_hint_tr':
        'Isınma bölümü bu hafta çok iyiydi, esneme için 5 dakika daha olsa harika olur.',
    'lbl_feedback_submit_button_tr': 'Gönder',
    'lbl_feedback_give_star_to_submit_hint_tr': 'Göndermek için yıldız ver',
    'lbl_feedback_sent_anonymously_hint_tr': 'Antrenörüne isimsiz iletilir',
    'lbl_feedback_rating_label_0_tr': 'Puan vermek için dokun',
    'lbl_feedback_rating_label_1_tr': 'Hiç iyi geçmedi',
    'lbl_feedback_rating_label_2_tr': 'Beklediğim gibi değildi',
    'lbl_feedback_rating_label_3_tr': 'Fena değildi',
    'lbl_feedback_rating_label_4_tr': 'İyiydi',
    'lbl_feedback_rating_label_5_tr': 'Harikaydı',
    'lbl_group_sessions_admin_list_title_tr': 'Grup dersleri',
    'lbl_group_sessions_add_group_session_button_tr': '+ Grup dersi',
    'lbl_group_sessions_capacity_suffix_label_tr': 'kontenjan',
    'lbl_group_sessions_capacity_full_note_tr': 'Kontenjan doldu',
    'lbl_group_sessions_capacity_low_note_tr': 'Son {remaining} yer',
    'lbl_group_sessions_capacity_available_note_tr': 'Yer var',
    'lbl_group_sessions_view_participants_link_tr': 'Katılımcıları gör',
    'lbl_group_sessions_discover_title_tr': 'Keşfet',
    'lbl_group_sessions_discover_tab_group_sessions_tr': 'Grup dersleri',
    'lbl_group_sessions_discover_tab_events_tr': 'Etkinlikler',
    'lbl_group_sessions_create_title_tr': 'Grup dersi oluştur',
    'lbl_group_sessions_capacity_field_label_tr': 'Kontenjan',
    'lbl_group_sessions_online_booking_toggle_label_tr':
        'Online rezervasyona açık',
    'lbl_group_sessions_online_booking_toggle_description_tr':
        'Üyeler Keşfet\'ten katılabilir',
    'lbl_group_sessions_default_location_label_tr': 'Ders yeri (opsiyonel)',
    'lbl_group_sessions_name_field_label_tr': 'Ders adı',
    'lbl_group_sessions_start_time_field_label_tr': 'Başlangıç saati',
    'lbl_group_sessions_duration_field_label_tr': 'Süre',
    'lbl_group_sessions_create_submit_button_tr': 'Grup dersini oluştur',
    'lbl_group_sessions_duration_suffix_tr': '{minutes} dk',
    'lbl_group_sessions_capacity_max_note_tr': 'Üst sınır {max} kişi',
    'lbl_group_sessions_capacity_max_note_with_studio_tr':
        '{studio} için üst sınır {max} kişi',
    'lbl_group_sessions_location_field_hint_tr': 'Örn. Stüdyo 1, Ana salon',
    'lbl_group_sessions_location_field_helper_tr':
        'Dersin nerede yapılacağını üyelere gösterir.',
    'lbl_group_sessions_duration_picker_title_tr': 'Süre seç',
    'lbl_group_sessions_discover_empty_state_tr':
        'Şu anda açık kayıt yok — yeni bir tarih eklendiğinde burada görünecek.',
    'lbl_group_sessions_join_full_error_snackbar_tr': 'Bu ders az önce doldu.',
    'lbl_group_sessions_join_failed_snackbar_tr':
        'Katılım kaydedilemedi, tekrar dene.',
    'lbl_group_sessions_waitlist_join_button_tr': 'Yedek listesine yaz',
    'lbl_group_sessions_joined_leave_button_tr': 'Katılmaktan Vazgeç',
    'lbl_group_sessions_joined_locked_button_tr': 'Katılıyorsun',
    'lbl_group_sessions_join_button_tr': 'Katılıyorum',
    'lbl_group_sessions_attending_count_no_capacity_tr':
        '{taken} kişi katılıyor',
    'lbl_group_sessions_attending_count_with_capacity_tr':
        '{taken} / {capacity} kişi',
    'lbl_gyms_admin_home_completed_word_tr': 'tamamlanan',
    'lbl_gyms_admin_home_trainer_performance_section_tr':
        'ANTRENÖR PERFORMANSI',
    'lbl_gyms_admin_home_upcoming_payments_section_tr': 'ÖDEME VAKTİ YAKLAŞAN',
    'lbl_gyms_admin_home_pending_feedback_label_tr': 'Bekleyen geri bildirim',
    'lbl_gyms_admin_home_total_sessions_label_tr': 'Toplam seans',
    'lbl_gyms_admin_home_completed_label_tr': 'Tamamlanan',
    'lbl_gyms_admin_home_estimated_revenue_label_tr': 'Tahmini ciro',
    'lbl_gyms_admin_home_expense_label_tr': 'Gider',
    'lbl_gyms_permissions_title_tr': 'Yetki ayarları',
    'lbl_gyms_permissions_reminder_dropdown_label_tr':
        'Seans bitimi eğitmene ne zaman hatırlatılsın?',
    'lbl_gyms_permissions_reminder_description_tr':
        'Bildirim seans bitiminden sonra gider',
    'lbl_gyms_settings_title_tr': 'Ayarlar',
    'lbl_gyms_settings_nav_gym_info_tr': 'Salon bilgileri',
    'lbl_gyms_settings_nav_trainer_management_tr': 'Antrenör yönetimi',
    'lbl_gyms_settings_nav_studio_packages_tr': 'Salon paketleri',
    'lbl_gyms_settings_nav_session_management_tr': 'Ders / seans yönetimi',
    'lbl_gyms_settings_nav_group_sessions_tr': 'Grup dersleri',
    'lbl_gyms_settings_nav_events_tr': 'Etkinlikler',
    'lbl_gyms_settings_nav_permissions_tr': 'Yetki ayarları',
    'lbl_gyms_settings_nav_feedback_tr': 'Geri bildirimler',
    'lbl_gyms_settings_nav_send_notification_tr': 'Bildirim gönder',
    'lbl_gyms_gym_info_title_tr': 'Salon bilgileri',
    'lbl_gyms_gym_info_logo_section_tr': 'LOGO',
    'lbl_gyms_gym_info_logo_helper_tr': 'Kare, en az 512×512 px PNG yükleyin.',
    'lbl_gyms_gym_info_change_logo_button_tr': 'Logoyu değiştir',
    'lbl_gyms_gym_info_theme_color_section_tr': 'TEMA RENGİ',
    'lbl_gyms_gym_info_preview_label_tr': 'Önizleme',
    'lbl_gyms_gym_info_primary_button_label_tr': 'Birincil buton',
    'lbl_gyms_gym_info_see_all_themes_link_tr': 'Tüm temaları gör ›',
    'lbl_gyms_gym_info_name_field_label_tr': 'Salon adı',
    'lbl_gyms_gym_info_address_field_label_tr': 'Adres',
    'lbl_gyms_gym_setup_step_header_tr': 'KURULUM 1 / 1',
    'lbl_gyms_gym_setup_title_tr': 'Salonunu tanımla',
    'lbl_gyms_gym_setup_logo_label_tr': 'Salon logosu',
    'lbl_gyms_gym_setup_choose_logo_button_tr': 'Logo seç',
    'lbl_gyms_gym_setup_theme_color_label_tr': 'Tema rengi',
    'lbl_gyms_gym_setup_city_field_label_tr': 'Şehir',
    'lbl_gyms_gym_setup_submit_button_tr': 'Salonu oluştur ve girişi tamamla',
    'lbl_gyms_themes_title_tr': 'Temalar',
    'lbl_gyms_themes_member_preview_section_tr': 'ÜYE EKRANI ÖNİZLEMESİ',
    'lbl_gyms_themes_show_logo_silhouette_toggle_label_tr':
        'Logo silüetini arka planda göster',
    'lbl_gyms_themes_show_logo_silhouette_toggle_description_tr':
        'Üye ve antrenör ekranlarında %25 opaklıkla',
    'lbl_gyms_themes_apply_to_all_button_tr': 'Temayı tüm üyelere uygula',
    'lbl_gyms_add_theme_title_tr': 'Tema ekle',
    'lbl_gyms_add_theme_palette_label_tr': 'Palet',
    'lbl_gyms_add_theme_color_code_label_tr': 'Renk kodu',
    'lbl_gyms_add_theme_color_helper_tr':
        'Paletten seçin ya da kendi HEX kodunuzu yazın.',
    'lbl_gyms_add_theme_use_logo_question_tr': 'Salon logosu kullanılsın mı?',
    'lbl_gyms_add_theme_preview_section_tr': 'ÖNİZLEME',
    'lbl_gyms_add_theme_use_logo_option_tr': 'Evet, logoyu kullan',
    'lbl_gyms_add_theme_flat_background_option_tr': 'Hayır, düz zemin',
    'lbl_gyms_add_theme_submit_button_tr': 'Temayı kaydet ve uygula',
    'lbl_gyms_add_theme_name_field_label_tr': 'Tema adı',
    'lbl_gyms_studio_rules_title_tr': 'Salon kuralları',
    'lbl_gyms_edit_studio_rules_title_tr': 'Kuralları düzenle',
    'lbl_gyms_settings_nav_subscription_tr': 'Abonelik',
    'lbl_gyms_settings_nav_reports_tr': 'Raporlar',
    'lbl_gyms_admin_home_this_month_note_tr': 'Bu ay',
    'lbl_gyms_admin_home_no_trainers_message_tr': 'Henüz antrenör yok.',
    'lbl_gyms_admin_home_add_trainer_button_tr': '+ Antrenör ekle',
    'lbl_gyms_admin_home_no_pending_payments_message_tr': 'Bekleyen ödeme yok.',
    'lbl_gyms_admin_home_due_payment_members_template_tr':
        '{count} üyenin ödemesi bekleniyor',
    'lbl_gyms_admin_home_total_feedback_template_tr':
        'Toplam {count} değerlendirme',
    'lbl_gyms_permissions_trainer_question_tr':
        'Hangi antrenöre yetkilendirme yapmak istiyorsun?',
    'lbl_gyms_permissions_trainer_helper_tr':
        'Bir ya da birden fazla antrenör seçebilirsin; aynı ayarlar hepsine uygulanır.',
    'lbl_gyms_permissions_authorize_button_tr': 'Yetkilendir',
    'lbl_gyms_permissions_done_button_tr': 'Bitti',
    'lbl_gyms_gym_info_uploading_label_tr': 'Yükleniyor…',
    'lbl_gyms_gym_info_palette_extracting_label_tr':
        'Logodan renkler çıkarılıyor…',
    'lbl_gyms_gym_info_theme_color_note_tr':
        'Seçtiğiniz renk üyelerin uygulamasında da birincil renk olur; koyu zemin ve durum renkleri değişmez.',
    'lbl_gyms_gym_info_report_emails_section_tr': 'RAPOR E-POSTASI',
    'lbl_gyms_gym_info_report_emails_description_tr':
        'Haftalık ve aylık salon özeti (ciro/gider dahil) bu adrese e-posta ile gönderilir.',
    'lbl_gyms_gym_info_gym_report_email_label_tr': 'Rapor e-postası',
    'lbl_gyms_gym_info_gym_report_email_hint_tr': 'admin@salon.com',
    'lbl_gyms_gym_info_saving_label_tr': 'Kaydediliyor…',
    'lbl_gyms_gym_info_logo_upload_failed_error_tr':
        'Logo yüklenemedi, tekrar dene.',
    'lbl_gyms_gym_info_name_required_error_tr': 'Salon adı boş olamaz.',
    'lbl_gyms_gym_info_address_required_error_tr': 'Adres boş olamaz.',
    'lbl_gyms_gym_info_phone_required_error_tr': 'Telefon boş olamaz.',
    'lbl_gyms_gym_info_save_failed_error_tr':
        'Salon bilgileri kaydedilemedi, tekrar dene.',
    'lbl_gyms_gym_info_logo_color_theme_name_tr': 'Logo rengi',
    'lbl_gyms_gym_info_logo_color_theme_note_tr': 'Logonuzdan çıkarıldı',
    'lbl_gyms_gym_setup_headline_tr':
        'Bu adımı tamamlayınca yönetici hesabınız aktifleşir ve uygulamaya girersiniz.',
    'lbl_gyms_gym_setup_phone_field_label_tr': 'Telefon numaran (giriş için)',
    'lbl_gyms_gym_setup_phone_hint_tr': '5XX XXX XX XX',
    'lbl_gyms_gym_setup_phone_helper_note_tr':
        'Salon kaydı tamamlanınca bu numarayla admin olarak giriş yapacaksın.',
    'lbl_gyms_gym_setup_currency_field_label_tr': 'Para birimi',
    'lbl_gyms_gym_setup_currency_helper_note_tr':
        'Salonun tüm paket/ödeme/gider tutarları bu para biriminde tutulur — sonradan değiştirilemez.',
    'lbl_gyms_gym_info_currency_field_label_tr': 'Para birimi',
    'lbl_gyms_gym_setup_logo_optional_label_tr': 'Salon logosu (opsiyonel)',
    'lbl_gyms_gym_setup_logo_description_tr':
        'Kare PNG, en az 512×512. Eklersen üyelerin ve antrenörlerin her ekranında arka planda %25 opaklıkla silüet olarak görünür — sonradan Salon Bilgileri panelinden de ekleyebilirsin.',
    'lbl_gyms_gym_setup_logo_color_hint_note_tr':
        'Logo eklersen aşağıdaki tema rengi seçeneklerini logona göre öneririz.',
    'lbl_gyms_gym_setup_suggested_colors_label_tr':
        'Logona göre önerilen renkler',
    'lbl_gyms_gym_setup_change_later_note_tr':
        'Sonradan Temalar panelinden değiştirebilirsiniz.',
    'lbl_gyms_gym_setup_submitting_label_tr': 'Oluşturuluyor…',
    'lbl_gyms_gym_setup_success_banner_tr':
        'Salonun oluşturuldu! Şimdi az önce girdiğin numarayla giriş yap.',
    'lbl_gyms_add_theme_name_field_hint_tr': 'Vira İmza',
    'lbl_gyms_add_theme_invalid_hex_error_tr':
        'Geçerli bir HEX kod gir (ör. 05A6FA).',
    'lbl_gyms_theme_preview_remaining_sessions_label_tr': 'Kalan dersin: 6',
    'lbl_gyms_theme_preview_next_session_label_tr':
        'Sıradaki ders 3 Ağustos 18:30',
    'lbl_gyms_add_theme_default_name_tr': 'Yeni Tema',
    'lbl_gyms_add_theme_custom_color_note_tr': 'Özel renk',
    'lbl_gyms_rules_editor_toolbar_hint_tr':
        'Kalın/italik gibi biçimlendirme için araç çubuğunu, emoji için klavyenizin emoji tuşunu kullanabilirsiniz.',
    'lbl_gyms_rules_editor_save_failed_error_tr':
        'Kurallar kaydedilemedi, bağlantını kontrol edip tekrar dene.',
    'lbl_gyms_rules_view_last_updated_template_tr': 'Son güncelleme {date}',
    'lbl_gyms_rules_editor_char_count_template_tr': '{count} / {max}',
    'lbl_gyms_rules_editor_max_length_error_tr':
        'Kurallar metni çok uzun — en fazla {max} karakter olabilir.',
    'lbl_gyms_themes_description_tr':
        'Seçtiğiniz tema salonunuzdaki tüm üye ve antrenörlerin uygulamasında görünür. Koyu zemin ve durum renkleri sabit kalır, değişen tek şey vurgu rengi.',
    'lbl_gyms_themes_add_theme_button_tr': '+ Tema ekle',
    'lbl_gyms_trainer_permissions_reminder_question_tr':
        'Seans bitimi eğitmene ne zaman hatırlatılsın?',
    'lbl_gyms_trainer_permissions_reminder_note_tr':
        'Bildirim seans bitiminden sonra gider',
    'lbl_gyms_trainer_permissions_cancel_title_tr':
        'Üye seanslarını iptal edebilir',
    'lbl_gyms_trainer_permissions_cancel_note_tr':
        'Kapalıysa bu antrenör kendi üyelerinin seansını iptal edemez',
    'lbl_gyms_trainer_permissions_reschedule_title_tr':
        'Üye seanslarını erteleyebilir',
    'lbl_gyms_trainer_permissions_reschedule_note_tr':
        'Kapalıysa bu antrenör kendi üyelerinin seansını erteleyemez',
    'lbl_gyms_trainer_permissions_auto_save_note_tr':
        'Her değişiklik anında kaydedilir.',
    'lbl_gyms_trainer_permissions_save_failed_error_tr':
        'Ayar kaydedilemedi, bağlantını kontrol edip tekrar dene.',
    'lbl_measurements_add_title_tr': 'Yeni ölçüm',
    'lbl_measurements_measurement_date_label_tr': 'Ölçüm tarihi',
    'lbl_measurements_measurements_section_tr': 'ÖLÇÜLER',
    'lbl_measurements_unit_cm_tr': 'cm',
    'lbl_measurements_metric_bel_tr': 'Bel',
    'lbl_measurements_metric_gogus_tr': 'Göğüs',
    'lbl_measurements_metric_kalca_tr': 'Kalça',
    'lbl_measurements_metric_kol_tr': 'Kol',
    'lbl_measurements_metric_bacak_tr': 'Bacak',
    'lbl_measurements_metric_kilo_tr': 'Kilo',
    'lbl_measurements_metric_yag_orani_tr': 'Yağ oranı',
    'lbl_trainers_metric_bel_cevresi_tr': 'Bel çevresi',
    'lbl_measurements_title_tr': 'Ölçümlerim',
    'lbl_measurements_selected_point_label_tr': 'Seçili nokta',
    'lbl_measurements_history_section_tr': 'ÖLÇÜM GEÇMİŞİ',
    'lbl_measurements_member_title_tr': '{name} · Ölçümleri',
    'lbl_measurements_avatar_hint_tr': 'Noktalara dokunarak değerleri gör',
    'lbl_measurements_chart_hint_tr': 'metrik çiplerine dokun',
    'lbl_measurements_chart_toggle_label_tr': 'Grafik',
    'lbl_measurements_avatar_toggle_label_tr': 'Avatar',
    'lbl_measurements_date_picker_title_tr': 'Tarih seç',
    'lbl_measurements_latest_record_option_tr': 'Son kayıt',
    'lbl_measurements_showing_latest_label_tr': 'Son kayıt gösteriliyor',
    'lbl_measurements_showing_date_label_tr': '{date} gösteriliyor',
    'lbl_measurements_change_date_label_tr': 'Tarih değiştir',
    'lbl_measurements_value_field_hint_tr': 'Değer gir',
    'lbl_measurements_empty_point_hint_tr':
        'Henüz ölçüm eklenmedi — yukarıdan bir değer gir.',
    'lbl_measurements_save_failed_error_tr':
        'Ölçüm kaydedilemedi, tekrar dene.',
    'lbl_measurements_no_data_for_metric_tr': '{metric} için henüz ölçüm yok.',
    'lbl_measurements_metric_latest_label_tr': '{metric} · son ölçüm',
    'lbl_measurements_no_change_label_tr': 'değişim yok',
    'lbl_measurements_six_month_delta_label_tr': '6 ayda {delta}',
    'lbl_measurements_latest_measurement_label_tr': 'Son ölçüm',
    'lbl_measurements_switch_to_avatar_cta_tr':
        'Ölçüm eklemek için Avatar\'a geç',
    'lbl_measurements_add_metric_label_tr': '{metric} ekle',
    'lbl_members_detail_payment_status_label_tr': 'Ödeme durumu',
    'lbl_members_detail_remaining_sessions_label_tr': 'Kalan ders',
    'lbl_members_detail_makeup_label_tr': 'Telafi',
    'lbl_members_detail_total_label_tr': 'Toplam',
    'lbl_members_detail_paid_label_tr': 'Ödendi',
    'lbl_members_detail_remaining_amount_label_tr': 'Kalan',
    'lbl_members_list_title_tr': 'Üyeler',
    'lbl_members_add_member_button_tr': '+ Üye ekle',
    'lbl_members_list_empty_state_tr': 'Bu filtreye uyan üye yok.',
    'lbl_members_filter_active_tr': 'Aktif',
    'lbl_members_filter_expiring_tr': 'Bitiyor',
    'lbl_members_info_step_indicator_1_tr': '1 / 3',
    'lbl_members_info_login_helper_tr':
        'Üye bu numarayla giriş yapar, şifre yok.',
    'lbl_members_gender_field_label_tr': 'Cinsiyet',
    'lbl_members_trainer_field_label_tr': 'Antrenör',
    'lbl_members_registration_date_field_label_tr': 'Kayıt tarihi',
    'lbl_members_select_trainer_button_tr': 'Antrenör seç',
    'lbl_members_first_name_field_label_tr': 'Ad',
    'lbl_members_last_name_field_label_tr': 'Soyad',
    'lbl_members_birth_year_field_label_tr': 'Doğum yılı',
    'lbl_members_height_field_label_tr': 'Boy',
    'lbl_members_note_field_label_tr': 'Not (isteğe bağlı)',
    'lbl_members_payment_title_tr': 'Ödeme bilgisi',
    'lbl_members_payment_step_indicator_3_tr': '3 / 3',
    'lbl_members_payment_total_label_tr': 'Toplam tutar',
    'lbl_members_payment_paid_label_tr': 'Ödendi',
    'lbl_members_payment_remaining_label_tr': 'Kalan ödeme',
    'lbl_members_payment_auto_calculated_helper_tr': 'Otomatik hesaplanır',
    'lbl_members_payment_due_date_field_label_tr': 'Son ödeme tarihi',
    'lbl_members_payment_enter_amount_helper_tr': 'Ödenen tutarı gir',
    'lbl_members_payment_full_option_tr': 'Tam ödendi',
    'lbl_members_payment_half_option_tr': 'Yarısı',
    'lbl_members_payment_other_option_tr': 'Diğer',
    'lbl_members_new_membership_title_tr': 'Yeni üyelik',
    'lbl_members_new_membership_step_indicator_2_tr': '2 / 3',
    'lbl_members_package_select_section_tr': 'PAKET SEÇ',
    'lbl_members_makeup_session_count_label_tr': 'Telafi seans sayısı',
    'lbl_members_makeup_session_helper_tr': 'Paket bitince kullanılabilir',
    'lbl_members_start_date_field_label_tr': 'Başlangıç tarihi',
    'lbl_members_end_date_field_label_tr': 'Bitiş tarihi',
    'lbl_members_go_to_payment_button_tr': 'Ödeme bilgisine geç',
    'lbl_members_detail_not_found_tr': 'Üye bulunamadı.',
    'lbl_members_detail_last_payment_label_tr': 'Son ödeme {date}',
    'lbl_members_detail_view_measurements_button_tr': 'Ölçüm ekranını gör',
    'lbl_members_detail_renew_package_button_tr': 'Paketi Yenile',
    'lbl_members_detail_renew_package_blocked_note_tr':
        'Yeni paket tanımlamadan önce mevcut paketin borcu kapatılmalı.',
    'lbl_members_detail_phone_trainer_line_tr':
        '{phone} · Antrenör: {trainerName}',
    'lbl_members_list_search_hint_tr': 'İsim ara',
    'lbl_members_list_load_error_tr': 'Liste yüklenemedi.',
    'lbl_members_edit_payment_title_tr': 'Ödeme bilgileri',
    'lbl_members_payment_installment_count_label_tr': 'Taksit sayısı',
    'lbl_members_edit_payment_save_error_tr':
        'Kaydedilemedi, bağlantını kontrol edip tekrar dene.',
    'lbl_members_payment_installment_note_tr':
        'Üye kendi ekranında yalnızca taksitlerin ödenip ödenmediğini görür; '
        'tutarlar üyeye gösterilmez.',
    'lbl_members_saving_label_tr': 'Kaydediliyor…',
    'lbl_members_self_info_title_tr': 'Bilgilerim',
    'lbl_members_self_info_name_required_error_tr': 'Ad ve soyad gerekli.',
    'lbl_members_self_info_phone_invalid_error_tr':
        'Geçerli bir telefon numarası gir.',
    'lbl_members_self_info_phone_taken_error_tr':
        'Bu telefon numarası zaten kayıtlı.',
    'lbl_members_self_info_save_error_tr':
        'Kaydedilemedi, bağlantını kontrol edip tekrar dene.',
    'lbl_members_info_new_title_tr': 'Yeni üye',
    'lbl_members_info_edit_title_tr': 'Üye bilgileri',
    'lbl_members_info_phone_hint_tr': '5XX XXX XX XX',
    'lbl_members_info_age_suffix_tr': '{age} yaş',
    'lbl_members_package_pick_type_validity_caption_tr': '{type} · {days} gün',
    'lbl_members_info_height_picker_title_tr': 'Boy (cm)',
    'lbl_members_info_gender_label_tr': 'Cinsiyet (opsiyonel)',
    'lbl_members_info_gender_helper_tr':
        'Ölçüm avatarı bu bilgiye göre gösterilir; üye ekranında ayrıca '
        'seçim yapılmaz.',
    'lbl_members_info_gender_erkek_option_tr': 'Erkek',
    'lbl_members_info_gender_kadin_option_tr': 'Kadın',
    'lbl_trainers_specialty_fonksiyonel_option_tr': 'Fonksiyonel',
    'lbl_trainers_specialty_pilates_option_tr': 'Pilates',
    'lbl_trainers_specialty_yoga_option_tr': 'Yoga',
    'lbl_trainers_specialty_kickbox_option_tr': 'Kickbox',
    'lbl_gyms_theme_preset_default_name_tr': 'Egora Mavisi',
    'lbl_gyms_theme_preset_default_note_tr': 'Varsayılan tema',
    'lbl_gyms_theme_preset_orange_name_tr': 'Turuncu Enerji',
    'lbl_gyms_theme_preset_orange_note_tr': 'Sıcak, enerjik vurgu',
    'lbl_gyms_theme_preset_green_name_tr': 'Yeşil Doğa',
    'lbl_gyms_theme_preset_green_note_tr': 'Sakin, doğal vurgu',
    'lbl_common_month_names_long_tr':
        'Ocak,Şubat,Mart,Nisan,Mayıs,Haziran,Temmuz,Ağustos,Eylül,Ekim,Kasım,Aralık',
    'lbl_common_weekday_names_long_tr':
        'Pazartesi,Salı,Çarşamba,Perşembe,Cuma,Cumartesi,Pazar',
    'lbl_members_info_confirm_attendance_label_tr': 'Ders onayı gönderebilsin',
    'lbl_members_info_confirm_attendance_helper_tr':
        'Üye ana ekranından sıradaki dersi için "Gelicem"/"Gelmeyeceğim" '
        'bildirebilir.',
    'lbl_members_info_go_to_package_button_tr': 'Paket seçimine geç',
    'lbl_members_info_no_trainers_message_tr': 'Henüz antrenör yok.',
    'lbl_members_info_picker_confirm_button_tr': 'Seç',
    'lbl_members_new_membership_trainer_label_tr': 'Antrenör: {trainerName}',
    'lbl_members_new_membership_autofill_note_tr':
        'Bitiş tarihi ve seans sayısı seçtiğiniz pakete göre dolar; '
        'isterseniz elle değiştirebilirsiniz.',
    'lbl_members_installment_amount_field_label_tr': 'Tutar',
    'lbl_members_installment_paid_toggle_label_tr': 'Ödendi mi?',
    'lbl_notifications_title_tr': 'Bildirim gönder',
    'lbl_notifications_target_question_label_tr': 'Kime gidecek?',
    'lbl_notifications_target_single_member_option_tr': 'Tek üye',
    'lbl_notifications_target_whole_gym_option_tr': 'Tüm salon',
    'lbl_notifications_preview_label_tr': 'Önizleme',
    'lbl_notifications_select_member_button_tr': 'Üye seç',
    'lbl_notifications_title_field_label_tr': 'Başlık',
    'lbl_notifications_message_field_label_tr': 'Mesaj',
    'lbl_notifications_target_selected_members_option_tr': 'Seçili üyeler',
    'lbl_notifications_whole_gym_summary_label_tr': '{gym} · tüm üyeler',
    'lbl_notifications_message_counter_label_tr': '{current} / {max}',
    'lbl_notifications_preview_template_tr': 'Egoractive · {title} — {message}',
    'lbl_notifications_preview_message_placeholder_tr': 'Mesaj metni…',
    'lbl_notifications_send_button_label_tr': 'Gönder',
    'lbl_notifications_sending_button_label_tr': 'Gönderiliyor…',
    'lbl_notifications_sent_button_label_tr': 'Gönderildi',
    'lbl_notifications_member_picker_subtitle_tr':
        'Bir ya da birden fazla üye seçebilirsin.',
    'lbl_notifications_no_members_empty_state_tr': 'Henüz üye yok.',
    'lbl_packages_list_title_tr': 'Paketler',
    'lbl_packages_add_package_button_tr': '+ Paket ekle',
    'lbl_packages_edit_session_type_field_label_tr': 'Ders tipi',
    'lbl_packages_edit_on_sale_toggle_label_tr': 'Satışta',
    'lbl_packages_edit_on_sale_toggle_description_tr':
        'Kapalıysa yeni üyeliklerde görünmez',
    'lbl_packages_delete_package_button_tr': 'Paketi sil',
    'lbl_packages_edit_name_field_label_tr': 'Paket adı',
    'lbl_packages_edit_validity_days_field_label_tr': 'Geçerlilik (gün)',
    'lbl_packages_edit_price_field_label_tr': 'Fiyat ({currency})',
    'lbl_packages_member_package_title_tr': 'Paketim',
    'lbl_packages_remaining_word_tr': 'kalan',
    'lbl_packages_trainer_owner_label_tr': 'Antrenörün',
    'lbl_packages_start_label_tr': 'Başlangıç',
    'lbl_packages_add_title_tr': 'Paket ekle',
    'lbl_packages_edit_title_tr': 'Paketi düzenle',
    'lbl_packages_name_field_hint_tr': 'Birebir 12 Seans',
    'lbl_packages_session_count_field_hint_tr': 'Örn. 12',
    'lbl_packages_validity_field_hint_tr': 'Örn. 90',
    'lbl_packages_per_session_price_caption_tr': 'seans başı {price}',
    'lbl_packages_delete_failed_error_tr': 'Paket silinemedi, tekrar dene.',
    'lbl_packages_name_required_error_tr': 'Paket adı boş bırakılamaz.',
    'lbl_packages_session_count_invalid_error_tr':
        'Geçerli bir seans sayısı gir.',
    'lbl_packages_validity_invalid_error_tr': 'Geçerli bir gün sayısı gir.',
    'lbl_packages_save_failed_error_tr': 'Paket kaydedilemedi, tekrar dene.',
    'lbl_packages_remaining_with_makeup_caption_tr':
        '{remaining} dersin kaldı. Telafi hakkın: {makeup} seans.',
    'lbl_packages_low_sessions_warning_title_tr':
        'Son {remaining} dersin kaldı',
    'lbl_packages_renew_with_trainer_caption_tr':
        'Paket bitmeden yenilemek istersen antrenörün {trainer} ile konuşabilirsin.',
    'lbl_packages_session_count_validity_caption_tr':
        '{count} seans · {days} gün',
    'lbl_packages_off_sale_label_tr': 'Kapalı',
    'lbl_reports_summary_load_error_tr':
        'Rapor verileri şu an yüklenemedi, lütfen daha sonra tekrar deneyin.',
    'lbl_reports_total_sessions_label_tr': 'Toplam ders',
    'lbl_reports_net_label_tr': 'Net',
    'lbl_reports_trainer_performance_load_error_tr':
        'Antrenör verileri yüklenemedi.',
    'lbl_reports_trainer_performance_empty_state_tr':
        'Bu ay için antrenör verisi yok.',
    'lbl_reports_past_reports_section_title_tr': 'GEÇMİŞ RAPORLAR',
    'lbl_reports_period_weekly_label_tr': 'Haftalık',
    'lbl_reports_period_monthly_label_tr': 'Aylık',
    'lbl_reports_snapshot_list_load_error_tr':
        'Geçmiş raporlar yüklenemedi, lütfen daha sonra tekrar deneyin.',
    'lbl_reports_snapshot_list_empty_state_tr':
        'Bu periyot için henüz oluşturulmuş bir rapor yok.',
    'lbl_reports_snapshot_detail_title_tr': 'Rapor Detayı',
    'lbl_reports_export_pdf_button_label_tr': 'PDF olarak dışa aktar',
    'lbl_reports_pdf_document_title_tr': 'Egoractive · Rapor',
    'lbl_reports_pdf_export_error_tr':
        'PDF oluşturulamadı, lütfen tekrar deneyin.',
    'lbl_reports_pdf_hero_positive_template_tr': 'Bu dönem net {net} kâr ettin',
    'lbl_reports_pdf_hero_negative_template_tr':
        'Bu dönem net {net} gider fazlası oluştu',
    'lbl_reports_pdf_hero_sub_positive_tr':
        'Detaylar aşağıda — antrenör performansı ve en çok satan paketleri incelemeyi unutma.',
    'lbl_reports_pdf_hero_sub_negative_tr':
        'Aşağıdaki gider ve paket satış dökümü, nereden tasarruf edebileceğini görmene yardımcı olabilir.',
    'lbl_reports_pdf_group_events_title_tr': 'Grup Dersleri & Etkinlikler',
    'lbl_reports_pdf_group_sessions_label_tr': 'Grup Dersleri',
    'lbl_reports_pdf_events_label_tr': 'Etkinlikler',
    'lbl_reports_pdf_sessions_unit_tr': 'ders',
    'lbl_reports_pdf_events_unit_tr': 'etkinlik',
    'lbl_reports_pdf_attendance_template_tr':
        '{attendance} / {capacity} kişi katıldı · %{pct} doluluk',
    'lbl_reports_pdf_packages_title_tr': 'Satın Alınan Paketler',
    'lbl_reports_pdf_packages_empty_tr': 'Bu dönemde paket satışı olmadı.',
    'lbl_reports_pdf_sales_unit_tr': 'satış',
    'lbl_reports_pdf_finance_title_tr': 'Mali Özet',
    'lbl_reports_pdf_net_profit_label_tr': 'Net Kâr',
    'lbl_reports_pdf_net_loss_label_tr': 'Net Zarar',
    'lbl_reports_pdf_completed_short_label_tr': 'tamamlandı',
    'lbl_reports_pdf_cancelled_short_label_tr': 'iptal',
    'lbl_reports_pdf_total_short_label_tr': 'toplam',
    'lbl_reports_pdf_completion_rate_template_tr':
        '%{completed} tamamlanma · %{cancelled} iptal oranı',
    'lbl_reports_pdf_sessions_title_tr': 'Ders Özeti',
    'lbl_reports_pdf_individual_sessions_label_tr': 'Birebir Seans',
    'lbl_reports_pdf_duet_sessions_label_tr': 'Düet Dersi',
    'lbl_reports_pdf_solo_pill_label_tr': 'Seans',
    'lbl_reports_pdf_duet_pill_label_tr': 'Düet',
    'lbl_reports_pdf_group_pill_label_tr': 'Grup',
    'lbl_reports_pdf_other_label_tr': 'Diğer',
    'lbl_reports_pdf_footer_tr':
        'Bu rapor Egoractive tarafından otomatik oluşturuldu.',
    'lbl_sessions_calendar_title_tr': 'Takvim',
    'lbl_sessions_calendar_slot_time_label_tr': 'Saat',
    'lbl_sessions_calendar_slot_status_label_tr': 'Durum',
    'lbl_sessions_calendar_type_individual_tr': 'Birebir',
    'lbl_sessions_calendar_type_duet_tr': 'Düet',
    'lbl_sessions_calendar_duet_members_label_tr': 'Katılan Üyeler',
    'lbl_sessions_attendance_answer_label_tr': 'Cevabı',
    'lbl_sessions_attendance_answer_time_label_tr': 'Cevap saati',
    'lbl_sessions_attendance_member_note_label_tr': 'Üyenin notu',
    'lbl_sessions_attendance_back_to_calendar_button_tr': 'Takvime dön',
    'lbl_sessions_management_title_tr': 'Seanslar',
    'lbl_sessions_management_empty_state_tr': 'Bu güne uyan seans yok.',
    'lbl_sessions_filter_scheduled_tr': 'Planlandı',
    'lbl_sessions_change_trainer_action_tr': 'Antrenörü değiştir',
    'lbl_sessions_cancel_session_action_tr': 'Seansı iptal et',
    'lbl_sessions_confirm_title_tr': 'Ders onayı',
    'lbl_sessions_confirm_attending_answer_text_tr': 'Geleceğini bildirdin',
    'lbl_sessions_confirm_not_attending_answer_text_tr':
        'Gelmeyeceğini bildirdin',
    'lbl_sessions_confirm_change_answer_button_tr': 'Cevabımı değiştir',
    'lbl_sessions_member_home_this_week_section_tr': 'BU HAFTA',
    'lbl_sessions_member_home_see_package_button_tr': 'Paketimi gör',
    'lbl_sessions_trainer_notifications_title_tr': 'Bildirimler',
    'lbl_sessions_completion_member_no_show_option_tr': 'Üye gelmedi',
    'lbl_sessions_list_title_tr': 'Derslerim',
    'lbl_sessions_list_view_toggle_tr': 'Liste',
    'lbl_sessions_calendar_view_toggle_tr': 'Takvim',
    'lbl_sessions_upcoming_section_tr': 'YAKLAŞAN',
    'lbl_sessions_past_section_tr': 'GEÇMİŞ',
    'lbl_sessions_calendar_no_expenses_state_tr': 'Bu günde gider yok.',
    'lbl_sessions_status_now_tr': 'Şimdi',
    'lbl_sessions_management_cancelling_label_tr': 'İptal ediliyor…',
    'lbl_sessions_management_admin_cancel_note_tr':
        'Yönetici olarak tarih kısıtı olmadan iptal ve erteleme yapabilirsiniz.',
    'lbl_sessions_management_cancel_error_tr':
        'Seans iptal edilemedi, tekrar dene.',
    'lbl_sessions_confirm_question_tr':
        "Yarın {hour}'daki dersine gelecek misin?",
    'lbl_sessions_confirm_change_hint_tr':
        'Cevabını dersten 2 saat öncesine kadar değiştirebilirsin.',
    'lbl_sessions_confirm_waiting_hint_tr':
        '{meta} seni bekliyor. Cevabını dersten 2 saat öncesine kadar değiştirebilirsin.',
    'lbl_sessions_confirm_session_summary_tr':
        '{meta} · Kalan dersinden 1 düşer',
    'lbl_sessions_confirm_no_permission_tr':
        'Bu ders için geleceğini/gelmeyeceğini bildirme yetkin yok. Antrenörünle iletişime geç.',
    'lbl_sessions_confirm_coming_note_tr':
        'Programda yerin ayrıldı. Dersten 2 saat öncesine kadar değiştirebilirsin.',
    'lbl_sessions_confirm_coming_note_with_meta_tr':
        "{meta}'ın programında yerin ayrıldı. Dersten 2 saat öncesine kadar değiştirebilirsin.",
    'lbl_sessions_confirm_not_coming_note_tr':
        'Ders kalan dersinden düşmedi, antrenörüne iletildi. Dersten 2 saat öncesine kadar değiştirebilirsin.',
    'lbl_sessions_member_home_greeting_tr': 'Merhaba{name}',
    'lbl_sessions_member_home_remaining_sessions_label_tr':
        'Kalan dersin: {count}',
    'lbl_sessions_member_home_package_valid_until_tr':
        "{name} paketi · {date}'e kadar geçerli",
    'lbl_sessions_member_home_next_session_section_tr': 'SIRADAKİ DERSİN',
    'lbl_sessions_member_home_installments_section_tr': 'TAKSİTLER',
    'lbl_sessions_member_home_installment_index_label_tr': '{index}. Taksit',
    'lbl_sessions_member_home_installment_due_date_label_tr':
        'Son ödeme {date}',
    'lbl_sessions_member_home_installment_due_soon_label_tr':
        'Ödeme yaklaşıyor',
    'lbl_sessions_member_home_installment_unpaid_label_tr': 'Ödenmedi',
    'lbl_sessions_completion_confirm_error_tr':
        'Onay kaydedilemedi, bağlantını kontrol edip tekrar dene.',
    'lbl_sessions_management_mark_completed_action_tr':
        'Tamamlandı olarak işaretle',
    'lbl_sessions_management_mark_absent_action_tr': 'Gelmedi olarak işaretle',
    'lbl_sessions_management_attendance_current_status_tr': 'Şu an: {status}',
    'lbl_sessions_management_attendance_error_tr':
        'Kaydedilemedi, bağlantını kontrol edip tekrar dene.',
    'lbl_sessions_completion_question_tr':
        '{time} {name} seansını tamamladınız mı?',
    'lbl_sessions_completion_time_limit_note_tr':
        'Onayı 24 saat içinde verebilirsiniz, sonrasında yönetici onayı gerekir.',
    'lbl_sessions_completion_expired_note_tr':
        'Bu seansı onaylama süresi geçti. Yönetici ile iletişime geçmelisin.',
    'lbl_sessions_list_empty_state_tr':
        'Henüz dersin yok — antrenörün seninle bir ders planladığında burada görünecek.',
    'lbl_sessions_list_calendar_empty_day_tr': 'Bu günde dersin yok.',
    'lbl_sessions_trainer_notifications_empty_state_tr': 'Henüz bildirim yok.',
    'lbl_sessions_create_trainer_busy_error_tr':
        '{name} bu saatte dolu, başka bir saat seç.',
    'lbl_sessions_create_reschedule_error_tr':
        'Seans ertelenemedi, tekrar dene.',
    'lbl_sessions_create_no_active_gym_error_tr': 'Aktif salon bulunamadı.',
    'lbl_sessions_create_skipped_days_snackbar_tr':
        'Şu günler için antrenör dolu, atlandı: {days}.',
    'lbl_sessions_create_title_tr': 'Yeni seans',
    'lbl_sessions_create_select_placeholder_tr': 'Seç',
    'lbl_sessions_create_member_summary_tr': '{name} · {count} seans',
    'lbl_sessions_create_pick_member_title_tr': 'Üye seç',
    'lbl_sessions_create_member_sessions_suffix_tr': '{count} seans',
    'lbl_sessions_create_pick_trainer_title_tr': 'Antrenör seç',
    'lbl_sessions_create_kind_label_tr': 'Seans türü',
    'lbl_sessions_create_kind_individual_tr': 'Birebir Seans',
    'lbl_sessions_create_kind_duet_tr': 'Düet Ders',
    'lbl_sessions_create_members_field_label_tr': 'Üyeler',
    'lbl_sessions_create_pick_members_title_tr': 'Üyeleri seç',
    'lbl_sessions_create_duet_members_summary_tr': '{count} üye seçildi',
    'lbl_sessions_create_duet_min_members_error_tr':
        'Düet ders için en az 2 üye seçmelisin.',
    'lbl_sessions_create_repeat_label_tr': 'Tekrarla',
    'lbl_sessions_create_repeat_days_selected_tr': '{count} gün seçildi',
    'lbl_sessions_create_submit_button_tr': 'Oluştur',
    'lbl_sessions_repeat_calendar_exhausted_error_tr': 'Kalan seans tükendi.',
    'lbl_sessions_repeat_calendar_subtitle_tr':
        'Lütfen tekrarlanacak günleri seçiniz.',
    'lbl_sessions_repeat_calendar_remaining_label_tr': 'Kalan seans',
    'lbl_trainers_management_title_tr': 'Antrenörler',
    'lbl_trainers_add_trainer_button_tr': '+ Antrenör ekle',
    'lbl_trainers_specialty_field_label_tr': 'Uzmanlık',
    'lbl_trainers_add_trainer_form_title_tr': 'Antrenör ekle',
    'lbl_trainers_full_name_field_label_tr': 'Ad soyad',
    'lbl_trainers_add_trainer_submit_button_tr': 'Antrenörü ekle',
    'lbl_trainers_home_awaiting_approval_section_tr': 'ONAYINIZI BEKLİYOR',
    'lbl_trainers_home_today_schedule_section_tr': 'BUGÜNKÜ PROGRAMINIZ',
    'lbl_trainers_home_no_show_label_tr': 'Gelmedi',
    'lbl_trainers_home_today_sessions_label_tr': 'Bugünkü seans',
    'lbl_trainers_home_completed_label_tr': 'Tamamlanan',
    'lbl_trainers_home_free_slot_label_tr': 'Boş saat',
    'lbl_trainers_member_detail_create_session_button_tr': 'Seans oluştur',
    'lbl_trainers_member_detail_add_measurement_button_tr': 'Ölçüm ekle',
    'lbl_trainers_member_detail_remaining_sessions_label_tr': 'Kalan ders',
    'lbl_trainers_member_detail_package_end_label_tr': 'Paket bitişi',
    'lbl_trainers_calendar_title_tr': 'Takvimim',
    'lbl_trainers_calendar_mark_completed_action_tr': 'Ders tamamlandı',
    'lbl_trainers_members_list_title_tr': 'Üyelerim',
    'lbl_trainers_members_filter_expiring_tr': 'Paketi bitiyor',
    'lbl_trainers_members_remaining_sessions_suffix_tr': 'kalan ders',
    'lbl_trainers_report_title_tr': 'Seans raporum',
    'lbl_trainers_report_start_date_field_label_tr': 'Başlangıç t.',
    'lbl_trainers_report_end_date_field_label_tr': 'Bitiş t.',
    'lbl_trainers_report_one_on_one_toggle_tr': 'Birebir',
    'lbl_trainers_report_group_toggle_tr': 'Grup',
    'lbl_trainers_report_duet_toggle_tr': 'Düet',
    'lbl_trainers_report_period_weekly_tr': 'Haftalık',
    'lbl_trainers_report_period_monthly_tr': 'Aylık',
    'lbl_trainers_report_period_all_time_tr': 'Tüm zamanlar',
    'lbl_trainers_report_period_custom_tr': 'Özel',
    'lbl_trainers_profile_footer_text_tr':
        'Egoractive · Egora Games · Sürüm 1.0',
    'lbl_trainers_detail_title_tr': 'Antrenör detayı',
    'lbl_trainers_member_count_suffix_tr': '{count} üye',
    'lbl_trainers_detail_all_time_section_tr': 'TÜM ZAMANLAR',
    'lbl_trainers_detail_planned_label_tr': 'Planlanan',
    'lbl_trainers_detail_this_month_section_tr': 'BU AY',
    'lbl_trainers_detail_this_week_section_tr': 'BU HAFTA',
    'lbl_trainers_detail_month_load_error_tr': 'Bu ayın verileri yüklenemedi.',
    'lbl_trainers_add_trainer_name_required_error_tr': 'Ad soyad boş olamaz.',
    'lbl_trainers_add_trainer_error_tr': 'Antrenör eklenemedi, tekrar dene.',
    'lbl_trainers_phone_taken_error_tr': 'Bu telefon numarası zaten kayıtlı.',
    'lbl_trainers_add_trainer_name_hint_tr': 'Emre Kaya',
    'lbl_trainers_management_trainer_count_suffix_tr': '{count} kişi',
    'lbl_trainers_add_trainer_saving_label_tr': 'Ekleniyor…',
    'lbl_trainers_edit_trainer_form_title_tr': 'Antrenörü düzenle',
    'lbl_trainers_edit_trainer_error_tr':
        'Antrenör güncellenemedi, tekrar dene.',
    'lbl_trainers_home_greeting_tr': 'İyi çalışmalar',
    'lbl_trainers_home_greeting_with_name_tr': 'İyi çalışmalar {name}',
    'lbl_trainers_home_confirmation_save_error_tr':
        'Onay kaydedilemedi, bağlantını kontrol edip tekrar dene.',
    'lbl_trainers_members_search_hint_tr': 'Üye ara',
    'lbl_trainers_profile_specialty_role_tr': '{specialty} · Antrenör',
    'lbl_notif_session_reminder_title_en': '⏰ Your session is at {time} today!',
    'lbl_notif_session_reminder_body_en':
        '{trainerName} is waiting for you. Tap to confirm you\'re coming 👇',
    'lbl_notif_session_completion_title_en': '✅ Can you confirm your session?',
    'lbl_notif_session_completion_body_en':
        'Your session with {memberName} has ended. Was it completed, or did they not show up?',
    'lbl_notif_package_ending_soon_title_en': '⏳ Your package is running low',
    'lbl_notif_package_ending_soon_body_en':
        'You have {remaining} sessions left. Contact your gym to get a new package.',
    'lbl_notif_package_none_title_en': '📦 Your package has ended',
    'lbl_notif_package_none_body_en':
        'You have no sessions left. Get a new package to keep training.',
    'lbl_notif_feedback_reminder_title_en': '💬 How was your month?',
    'lbl_notif_feedback_reminder_body_en':
        'Would you share your experience with us? It only takes a minute.',
    'lbl_common_vazgec_en': 'Cancel',
    'lbl_common_kaydet_en': 'Save',
    'lbl_common_duzenle_en': 'Edit',
    'lbl_common_kapat_en': 'Close',
    'lbl_common_degistir_en': 'Change',
    'lbl_common_cikis_yap_en': 'Sign out',
    'lbl_common_hesabimi_sil_en': 'Delete my account',
    'lbl_common_studyo_kurallari_nav_en': 'Studio rules',
    'lbl_common_seansi_ertele_en': 'Postpone session',
    'lbl_common_gelicem_en': 'I\'m coming',
    'lbl_common_gelmeyecegim_en': 'I\'m not coming',
    'lbl_common_ana_sayfa_tab_en': 'Home',
    'lbl_common_profil_tab_en': 'Profile',
    'lbl_common_telefon_label_en': 'Phone',
    'lbl_common_phone_country_search_hint_en': 'Search country',
    'lbl_common_tumu_filter_en': 'All',
    'lbl_common_tamamlandi_en': 'Completed',
    'lbl_common_iptal_label_en': 'Canceled',
    'lbl_common_kalan_ders_label_en': 'Remaining sessions',
    'lbl_common_paketi_yok_filter_en': 'No package',
    'lbl_common_seans_sayisi_label_en': 'Session count',
    'lbl_common_add_seans_button_en': '+ Session',
    'lbl_common_olcum_6_ay_section_header_en': 'MEASUREMENT · 6 MO',
    'lbl_common_ders_gecmisi_section_header_en': 'SESSION HISTORY',
    'lbl_common_uye_detayi_title_en': 'Member detail',
    'lbl_common_bu_gunde_seans_yok_en': 'No sessions on this day.',
    'lbl_common_bitis_label_en': 'End',
    'lbl_common_language_nav_label_en': 'Language',
    'lbl_common_tamam_button_en': 'Done',
    'lbl_common_henuz_veri_yok_en': 'No data yet',
    'lbl_language_select_title_en': 'Select language',
    'lbl_language_select_turkish_option_en': 'Türkçe',
    'lbl_language_select_english_option_en': 'English',
    'lbl_shell_member_tab_derslerim_en': 'My Sessions',
    'lbl_shell_member_tab_olcumlerim_en': 'My Measurements',
    'lbl_shell_member_tab_kesfet_en': 'Discover',
    'lbl_shell_trainer_tab_takvimim_en': 'My Calendar',
    'lbl_shell_trainer_tab_uyelerim_en': 'My Members',
    'lbl_shell_trainer_tab_raporum_en': 'My Report',
    'lbl_shell_admin_tab_uyeler_en': 'Members',
    'lbl_shell_admin_tab_seanslar_en': 'Sessions',
    'lbl_shell_admin_tab_finans_en': 'Finance',
    'lbl_shell_admin_tab_ayarlar_en': 'Settings',
    'lbl_shell_role_picker_member_button_en': 'Member',
    'lbl_shell_role_picker_trainer_button_en': 'Trainer',
    'lbl_shell_role_picker_admin_button_en': 'Admin',
    'lbl_shell_role_picker_gym_setup_button_en':
        'Admin · Gym Setup (first-time setup)',
    'lbl_auth_profile_title_en': 'My Profile',
    'lbl_auth_phone_number_label_en': 'Phone number',
    'lbl_auth_login_button_en': 'Log in',
    'lbl_auth_select_avatar_label_en': 'Choose your avatar',
    'lbl_auth_badges_nav_label_en': 'My Badges',
    'lbl_auth_give_feedback_nav_label_en': 'Give feedback',
    'lbl_auth_session_reminders_toggle_title_en': 'Session reminders',
    'lbl_auth_session_reminders_toggle_description_en':
        'Notification 2 hours before your session',
    'lbl_auth_delete_account_confirm_title_en': 'My Profile',
    'lbl_auth_login_error_not_found_en':
        'No account found with this number. The gym staff needs to add you first.',
    'lbl_auth_login_error_rate_limited_en':
        'Too many attempts. Try again in a minute.',
    'lbl_auth_login_error_generic_en':
        'Could not log in. Check your connection and try again.',
    'lbl_auth_login_error_subscription_inactive_en':
        'Your account is not active right now. Please contact your gym.',
    'lbl_auth_retry_button_en': 'Try again',
    'lbl_auth_delete_account_error_generic_en':
        'Could not delete account. Check your connection and try again.',
    'lbl_auth_delete_account_item_remaining_sessions_en':
        'Your {count} remaining sessions and makeup credit',
    'lbl_auth_delete_account_item_measurements_badges_en':
        'Your measurement history and badges',
    'lbl_auth_delete_account_item_feedback_en':
        'The feedback you left for your studio',
    'lbl_auth_delete_account_confirm_heading_en':
        'Deleting your account cannot be undone',
    'lbl_auth_delete_account_confirm_body_en':
        'The deletion is completed within 24 hours and cannot be cancelled. '
        'Your {count} remaining sessions and measurement history will also be deleted.',
    'lbl_auth_delete_account_acknowledge_label_en':
        'I understand, delete my account and all my data.',
    'lbl_auth_delete_account_in_progress_button_en': 'Deleting…',
    'lbl_auth_login_waiting_heading_en': 'Getting to know you…',
    'lbl_auth_login_waiting_body_en': 'Looking up +90 {phone} at the studio.',
    'lbl_auth_login_waiting_hint_en':
        'If it takes longer than 30 seconds, check your connection and try again.',
    'lbl_auth_login_waiting_cancel_button_en': 'Cancel',
    'lbl_auth_onboarding_role_brand_label_en': 'EGORACTIVE',
    'lbl_auth_onboarding_role_title_en': 'Welcome',
    'lbl_auth_onboarding_role_subtitle_en': 'Choose your role to continue.',
    'lbl_auth_onboarding_role_trainer_title_en': "I'm a trainer",
    'lbl_auth_onboarding_role_trainer_note_en':
        'I have a trainer certification',
    'lbl_auth_onboarding_role_member_title_en': "I'm a member",
    'lbl_auth_onboarding_role_member_note_en': "I'm registered at a gym/studio",
    'lbl_auth_onboarding_role_hint_trainer_en':
        "In the next step we'll ask if you're linked to a gym.",
    'lbl_auth_onboarding_role_hint_member_en':
        "You'll log in with the phone number registered at your studio.",
    'lbl_auth_onboarding_role_continue_button_en': 'Continue',
    'lbl_auth_onboarding_role_go_to_login_button_en': 'Go to login',
    'lbl_auth_onboarding_role_partner_gyms_button_en': 'Partner Gyms',
    'lbl_partner_gyms_title_en': 'Partner Gyms',
    'lbl_partner_gyms_empty_en': 'No gyms listed yet.',
    'lbl_partner_gyms_error_en': 'Couldn\'t load gyms, please try again.',
    'lbl_auth_trainer_path_title_en': 'Are you linked to a gym?',
    'lbl_auth_trainer_path_subtitle_en':
        'If you already work at a studio, link to it; otherwise create your own gym.',
    'lbl_auth_trainer_path_linked_title_en': 'I work at a linked gym',
    'lbl_auth_trainer_path_linked_note_en':
        'The gym management should have already added me to the system',
    'lbl_auth_trainer_path_new_gym_title_en': 'I want to open a new gym',
    'lbl_auth_trainer_path_new_gym_note_en':
        "I'm registering my own studio/gym for the first time",
    'lbl_auth_trainer_path_hint_linked_en':
        "If your number isn't in the system, you can ask the gym management to add you.",
    'lbl_auth_trainer_path_hint_new_gym_en':
        "After entering your gym details, you'll log in as an admin.",
    'lbl_auth_trainer_path_create_gym_button_en': 'Continue to create gym',
    'lbl_auth_phone_login_title_en': 'Log in with your phone',
    'lbl_auth_phone_login_subtitle_en':
        "Enter the number registered at your studio; no password, one tap and you're in.",
    'lbl_auth_phone_login_hint_en':
        "If your number isn't registered, the studio management needs to add you.",
    'lbl_auth_email_login_title_en': 'Log in with email',
    'lbl_auth_email_login_subtitle_en':
        "Enter the email registered at your studio and we'll send you a "
        "verification code. No password — one code and you're in.",
    'lbl_auth_email_address_label_en': 'Email address',
    'lbl_auth_switch_to_phone_link_en': 'Log in with phone number',
    'lbl_auth_switch_to_email_link_en': 'Log in with email',
    'lbl_auth_otp_title_en': 'Enter the code',
    'lbl_auth_otp_subtitle_en':
        "We sent a 6-digit verification code to {email}. Enter it below.",
    'lbl_auth_otp_verify_button_en': 'Verify and continue',
    'lbl_auth_otp_resend_button_en': 'Resend code',
    'lbl_auth_otp_resend_countdown_template_en': 'You can resend in {seconds}s',
    'lbl_auth_otp_generic_error_en':
        'Something went wrong. Check your connection and try again.',
    'lbl_auth_otp_invalid_code_error_en':
        "That code isn't right. Check it and try again.",
    'lbl_auth_otp_expired_error_en':
        'This code has expired. Tap "Resend code" to get a new one.',
    'lbl_auth_otp_too_many_attempts_error_en':
        'Too many wrong attempts. Tap "Resend code" to get a new one.',
    'lbl_auth_email_setup_title_en': 'Add your email',
    'lbl_auth_email_setup_subtitle_en':
        "Enter the email you'll use to log in — we'll send a 6-digit "
        'verification code to it.',
    'lbl_auth_email_setup_send_button_en': 'Send verification code',
    'lbl_auth_email_setup_invalid_email_error_en':
        "That doesn't look like a valid email address. Check it and try "
        'again (e.g. name@example.com).',
    'lbl_auth_email_setup_email_taken_error_en':
        'This email is already used by another account. Try a different '
        'one.',
    'lbl_gyms_gym_info_login_report_email_label_en': 'Login & report email *',
    'lbl_members_self_info_email_field_label_en': 'Email address',
    'lbl_trainers_info_title_en': 'My Info',
    'lbl_auth_profile_member_caption_en': '+90 {phone} · Member',
    'lbl_auth_profile_session_reminder_description_en':
        'Notification {minutes} minutes before your session',
    'lbl_auth_splash_title_en': 'Egoractive',
    'lbl_auth_splash_tagline_en': 'Gym management',
    'lbl_auth_splash_publisher_en': 'Egora Games',
    'lbl_badges_title_en': 'My Badges',
    'lbl_badges_load_error_en': 'Failed to load badges.',
    'lbl_badges_earned_count_label_en': 'You earned {count} badges',
    'lbl_badges_next_locked_label_en': 'Next: {note}',
    'lbl_badges_detail_earned_status_en': 'Earned',
    'lbl_badges_detail_locked_status_en': 'Not earned yet',
    'lbl_members_detail_badges_section_header_en': 'BADGES',
    'lbl_events_admin_list_title_en': 'Events',
    'lbl_events_add_event_button_en': '+ Event',
    'lbl_events_attending_label_en': 'Attending',
    'lbl_events_capacity_label_en': 'Capacity',
    'lbl_events_create_title_en': 'Create event',
    'lbl_events_capacity_empty_means_unlimited_helper_en':
        'Leave empty for unlimited',
    'lbl_events_name_field_label_en': 'Event name',
    'lbl_events_location_field_label_en': 'Location',
    'lbl_events_date_field_label_en': 'Date',
    'lbl_events_time_field_label_en': 'Time',
    'lbl_events_description_field_label_en': 'Description',
    'lbl_events_create_submit_button_en': 'Create event',
    'lbl_events_date_field_hint_en': 'Aug 16 2026',
    'lbl_events_time_field_hint_en': '08:00',
    'lbl_events_name_required_error_en': 'Event name cannot be empty.',
    'lbl_events_date_format_error_en':
        'Enter the date as "day month year" (e.g. 16 Ağu 2026).',
    'lbl_events_create_failed_error_en': 'Could not create event, try again.',
    'lbl_expenses_list_title_en': 'Expenses',
    'lbl_expenses_add_expense_button_en': '+ Expense',
    'lbl_expenses_categories_section_header_en': 'CATEGORIES',
    'lbl_expenses_recent_entries_section_header_en': 'RECENT ENTRIES',
    'lbl_expenses_add_title_en': 'Add expense',
    'lbl_expenses_category_field_label_en': 'Category',
    'lbl_expenses_recurring_toggle_label_en': 'Repeat every month',
    'lbl_expenses_recurring_toggle_description_en':
        'For fixed expenses like rent and bills',
    'lbl_expenses_amount_field_label_en': 'Amount ({currency})',
    'lbl_expenses_description_field_label_en': 'Description',
    'lbl_expenses_date_field_label_en': 'Date',
    'lbl_expenses_submit_button_en': 'Save expense',
    'lbl_expenses_amount_field_hint_en': '8,400',
    'lbl_expenses_category_picker_title_en': 'Select category',
    'lbl_expenses_description_field_hint_en': 'Reformer spring replacement',
    'lbl_expenses_trainer_commission_note_en':
        'Trainer commissions are calculated automatically from session approvals; they are not entered manually here.',
    'lbl_expenses_amount_invalid_error_en': 'Enter a valid amount.',
    'lbl_expenses_description_required_error_en':
        'Description cannot be empty.',
    'lbl_expenses_save_failed_error_en': 'Could not save expense, try again.',
    'lbl_expenses_monthly_total_label_en': 'Total expenses in {month}',
    'lbl_expenses_revenue_ratio_label_en': 'Ratio to revenue {ratio}',
    'lbl_feedback_admin_list_title_en': 'Feedback',
    'lbl_feedback_member_form_title_en': 'Feedback',
    'lbl_feedback_comment_section_header_en': 'YOUR COMMENT (OPTIONAL)',
    'lbl_feedback_total_reviews_caption_en': '{count} reviews',
    'lbl_feedback_how_was_session_title_en': 'How was your session?',
    'lbl_feedback_privacy_note_with_trainer_en':
        'One-on-one with {trainer} · Only studio management sees this, it is shared with your trainer anonymously.',
    'lbl_feedback_privacy_note_en':
        'Only studio management sees this, it is shared with your trainer anonymously.',
    'lbl_feedback_comment_field_hint_en':
        'The warm-up was really good this week, five more minutes of stretching would be great.',
    'lbl_feedback_submit_button_en': 'Submit',
    'lbl_feedback_give_star_to_submit_hint_en': 'Give a rating to submit',
    'lbl_feedback_sent_anonymously_hint_en': 'Sent to your trainer anonymously',
    'lbl_feedback_rating_label_0_en': 'Tap to rate',
    'lbl_feedback_rating_label_1_en': 'Not good at all',
    'lbl_feedback_rating_label_2_en': 'Not what I expected',
    'lbl_feedback_rating_label_3_en': 'Not bad',
    'lbl_feedback_rating_label_4_en': 'Good',
    'lbl_feedback_rating_label_5_en': 'Great',
    'lbl_group_sessions_admin_list_title_en': 'Group Sessions',
    'lbl_group_sessions_add_group_session_button_en': '+ Group Session',
    'lbl_group_sessions_capacity_suffix_label_en': 'capacity',
    'lbl_group_sessions_capacity_full_note_en': 'Fully booked',
    'lbl_group_sessions_capacity_low_note_en': '{remaining} spots left',
    'lbl_group_sessions_capacity_available_note_en': 'Spots available',
    'lbl_group_sessions_view_participants_link_en': 'View participants',
    'lbl_group_sessions_discover_title_en': 'Discover',
    'lbl_group_sessions_discover_tab_group_sessions_en': 'Group Sessions',
    'lbl_group_sessions_discover_tab_events_en': 'Events',
    'lbl_group_sessions_create_title_en': 'Create group session',
    'lbl_group_sessions_capacity_field_label_en': 'Capacity',
    'lbl_group_sessions_online_booking_toggle_label_en':
        'Open for online booking',
    'lbl_group_sessions_online_booking_toggle_description_en':
        'Members can join from Discover',
    'lbl_group_sessions_default_location_label_en':
        'Session location (optional)',
    'lbl_group_sessions_name_field_label_en': 'Session name',
    'lbl_group_sessions_start_time_field_label_en': 'Start time',
    'lbl_group_sessions_duration_field_label_en': 'Duration',
    'lbl_group_sessions_create_submit_button_en': 'Create group session',
    'lbl_group_sessions_duration_suffix_en': '{minutes} min',
    'lbl_group_sessions_capacity_max_note_en': 'Limit is {max} people',
    'lbl_group_sessions_capacity_max_note_with_studio_en':
        'Limit for {studio} is {max} people',
    'lbl_group_sessions_location_field_hint_en': 'E.g. Studio 1, Main hall',
    'lbl_group_sessions_location_field_helper_en':
        'Shows members where the session takes place.',
    'lbl_group_sessions_duration_picker_title_en': 'Select duration',
    'lbl_group_sessions_discover_empty_state_en':
        'No open sign-ups right now — new dates will show up here.',
    'lbl_group_sessions_join_full_error_snackbar_en':
        'This session just filled up.',
    'lbl_group_sessions_join_failed_snackbar_en':
        'Could not save your response, try again.',
    'lbl_group_sessions_waitlist_join_button_en': 'Join waitlist',
    'lbl_group_sessions_joined_leave_button_en': 'Cancel attendance',
    'lbl_group_sessions_joined_locked_button_en': 'Attending',
    'lbl_group_sessions_join_button_en': 'Join',
    'lbl_group_sessions_attending_count_no_capacity_en': '{taken} attending',
    'lbl_group_sessions_attending_count_with_capacity_en':
        '{taken} / {capacity}',
    'lbl_gyms_admin_home_completed_word_en': 'completed',
    'lbl_gyms_admin_home_trainer_performance_section_en': 'TRAINER PERFORMANCE',
    'lbl_gyms_admin_home_upcoming_payments_section_en': 'PAYMENT DUE SOON',
    'lbl_gyms_admin_home_pending_feedback_label_en': 'Pending feedback',
    'lbl_gyms_admin_home_total_sessions_label_en': 'Total sessions',
    'lbl_gyms_admin_home_completed_label_en': 'Completed',
    'lbl_gyms_admin_home_estimated_revenue_label_en': 'Estimated revenue',
    'lbl_gyms_admin_home_expense_label_en': 'Expense',
    'lbl_gyms_permissions_title_en': 'Permission settings',
    'lbl_gyms_permissions_reminder_dropdown_label_en':
        'When should the trainer be reminded after a session ends?',
    'lbl_gyms_permissions_reminder_description_en':
        'Notification is sent after the session ends',
    'lbl_gyms_settings_title_en': 'Settings',
    'lbl_gyms_settings_nav_gym_info_en': 'Gym information',
    'lbl_gyms_settings_nav_trainer_management_en': 'Trainer management',
    'lbl_gyms_settings_nav_studio_packages_en': 'Studio packages',
    'lbl_gyms_settings_nav_session_management_en': 'Session management',
    'lbl_gyms_settings_nav_group_sessions_en': 'Group sessions',
    'lbl_gyms_settings_nav_events_en': 'Events',
    'lbl_gyms_settings_nav_permissions_en': 'Permission settings',
    'lbl_gyms_settings_nav_feedback_en': 'Feedback',
    'lbl_gyms_settings_nav_send_notification_en': 'Send notification',
    'lbl_gyms_gym_info_title_en': 'Gym information',
    'lbl_gyms_gym_info_logo_section_en': 'LOGO',
    'lbl_gyms_gym_info_logo_helper_en':
        'Upload a square PNG, at least 512×512 px.',
    'lbl_gyms_gym_info_change_logo_button_en': 'Change logo',
    'lbl_gyms_gym_info_theme_color_section_en': 'THEME COLOR',
    'lbl_gyms_gym_info_preview_label_en': 'Preview',
    'lbl_gyms_gym_info_primary_button_label_en': 'Primary button',
    'lbl_gyms_gym_info_see_all_themes_link_en': 'See all themes ›',
    'lbl_gyms_gym_info_name_field_label_en': 'Gym name',
    'lbl_gyms_gym_info_address_field_label_en': 'Address',
    'lbl_gyms_gym_setup_step_header_en': 'SETUP 1 / 1',
    'lbl_gyms_gym_setup_title_en': 'Define your gym',
    'lbl_gyms_gym_setup_logo_label_en': 'Gym logo',
    'lbl_gyms_gym_setup_choose_logo_button_en': 'Choose logo',
    'lbl_gyms_gym_setup_theme_color_label_en': 'Theme color',
    'lbl_gyms_gym_setup_city_field_label_en': 'City',
    'lbl_gyms_gym_setup_submit_button_en': 'Create gym and finish setup',
    'lbl_gyms_themes_title_en': 'Themes',
    'lbl_gyms_themes_member_preview_section_en': 'MEMBER SCREEN PREVIEW',
    'lbl_gyms_themes_show_logo_silhouette_toggle_label_en':
        'Show logo silhouette in background',
    'lbl_gyms_themes_show_logo_silhouette_toggle_description_en':
        'At 25% opacity on member and trainer screens',
    'lbl_gyms_themes_apply_to_all_button_en': 'Apply theme to all members',
    'lbl_gyms_add_theme_title_en': 'Add theme',
    'lbl_gyms_add_theme_palette_label_en': 'Palette',
    'lbl_gyms_add_theme_color_code_label_en': 'Color code',
    'lbl_gyms_add_theme_color_helper_en':
        'Choose from the palette or enter your own HEX code.',
    'lbl_gyms_add_theme_use_logo_question_en': 'Use gym logo?',
    'lbl_gyms_add_theme_preview_section_en': 'PREVIEW',
    'lbl_gyms_add_theme_use_logo_option_en': 'Yes, use the logo',
    'lbl_gyms_add_theme_flat_background_option_en': 'No, flat background',
    'lbl_gyms_add_theme_submit_button_en': 'Save and apply theme',
    'lbl_gyms_add_theme_name_field_label_en': 'Theme name',
    'lbl_gyms_studio_rules_title_en': 'Studio rules',
    'lbl_gyms_edit_studio_rules_title_en': 'Edit rules',
    'lbl_gyms_settings_nav_subscription_en': 'Subscription',
    'lbl_gyms_settings_nav_reports_en': 'Reports',
    'lbl_gyms_admin_home_this_month_note_en': 'This month',
    'lbl_gyms_admin_home_no_trainers_message_en': 'No trainers yet.',
    'lbl_gyms_admin_home_add_trainer_button_en': '+ Add trainer',
    'lbl_gyms_admin_home_no_pending_payments_message_en':
        'No pending payments.',
    'lbl_gyms_admin_home_due_payment_members_template_en':
        '{count} members have pending payments',
    'lbl_gyms_admin_home_total_feedback_template_en': '{count} reviews total',
    'lbl_gyms_permissions_trainer_question_en':
        'Which trainer do you want to authorize?',
    'lbl_gyms_permissions_trainer_helper_en':
        'You can select one or more trainers; the same settings apply to all of them.',
    'lbl_gyms_permissions_authorize_button_en': 'Authorize',
    'lbl_gyms_permissions_done_button_en': 'Done',
    'lbl_gyms_gym_info_uploading_label_en': 'Uploading…',
    'lbl_gyms_gym_info_palette_extracting_label_en':
        'Extracting colors from logo…',
    'lbl_gyms_gym_info_theme_color_note_en':
        "The color you choose also becomes the primary color in members' app; the dark background and status colors stay unchanged.",
    'lbl_gyms_gym_info_report_emails_section_en': 'REPORT EMAIL',
    'lbl_gyms_gym_info_report_emails_description_en':
        'The weekly and monthly gym summary (including revenue/expenses) is emailed to this address.',
    'lbl_gyms_gym_info_gym_report_email_label_en': 'Report email',
    'lbl_gyms_gym_info_gym_report_email_hint_en': 'admin@studio.com',
    'lbl_gyms_gym_info_saving_label_en': 'Saving…',
    'lbl_gyms_gym_info_logo_upload_failed_error_en':
        'Logo could not be uploaded, try again.',
    'lbl_gyms_gym_info_name_required_error_en': 'Gym name cannot be empty.',
    'lbl_gyms_gym_info_address_required_error_en': 'Address cannot be empty.',
    'lbl_gyms_gym_info_phone_required_error_en': 'Phone cannot be empty.',
    'lbl_gyms_gym_info_save_failed_error_en':
        'Gym information could not be saved, try again.',
    'lbl_gyms_gym_info_logo_color_theme_name_en': 'Logo color',
    'lbl_gyms_gym_info_logo_color_theme_note_en': 'Extracted from your logo',
    'lbl_gyms_gym_setup_headline_en':
        'Once you complete this step, your admin account activates and you enter the app.',
    'lbl_gyms_gym_setup_phone_field_label_en': 'Your phone number (for login)',
    'lbl_gyms_gym_setup_phone_hint_en': '5XX XXX XX XX',
    'lbl_gyms_gym_setup_phone_helper_note_en':
        'Once gym registration is complete, you will log in as admin with this number.',
    'lbl_gyms_gym_setup_currency_field_label_en': 'Currency',
    'lbl_gyms_gym_setup_currency_helper_note_en':
        'All package/payment/expense amounts for this gym are kept in this currency — it cannot be changed later.',
    'lbl_gyms_gym_info_currency_field_label_en': 'Currency',
    'lbl_gyms_gym_setup_logo_optional_label_en': 'Gym logo (optional)',
    'lbl_gyms_gym_setup_logo_description_en':
        'Square PNG, at least 512×512. If you add one, it appears as a 25%-opacity silhouette in the background on every screen for members and trainers — you can also add it later from the Gym Info panel.',
    'lbl_gyms_gym_setup_logo_color_hint_note_en':
        'If you add a logo, we will suggest the theme color options below based on it.',
    'lbl_gyms_gym_setup_suggested_colors_label_en':
        'Suggested colors based on your logo',
    'lbl_gyms_gym_setup_change_later_note_en':
        'You can change this later from the Themes panel.',
    'lbl_gyms_gym_setup_submitting_label_en': 'Creating…',
    'lbl_gyms_gym_setup_success_banner_en':
        'Your gym has been created! Now log in with the number you just entered.',
    'lbl_gyms_add_theme_name_field_hint_en': 'Vira Signature',
    'lbl_gyms_add_theme_invalid_hex_error_en':
        'Enter a valid HEX code (e.g. 05A6FA).',
    'lbl_gyms_theme_preview_remaining_sessions_label_en': 'Sessions left: 6',
    'lbl_gyms_theme_preview_next_session_label_en':
        'Next session Aug 3, 6:30 PM',
    'lbl_gyms_add_theme_default_name_en': 'New Theme',
    'lbl_gyms_add_theme_custom_color_note_en': 'Custom color',
    'lbl_gyms_rules_editor_toolbar_hint_en':
        "Use the toolbar for formatting like bold/italic, and your keyboard's emoji key for emoji.",
    'lbl_gyms_rules_editor_save_failed_error_en':
        'Rules could not be saved, check your connection and try again.',
    'lbl_gyms_rules_view_last_updated_template_en': 'Last updated {date}',
    'lbl_gyms_rules_editor_char_count_template_en': '{count} / {max}',
    'lbl_gyms_rules_editor_max_length_error_en':
        'Rules text is too long — the limit is {max} characters.',
    'lbl_gyms_themes_description_en':
        "The theme you choose appears in the app for all your gym's members and trainers. The dark background and status colors stay fixed — only the accent color changes.",
    'lbl_gyms_themes_add_theme_button_en': '+ Add theme',
    'lbl_gyms_trainer_permissions_reminder_question_en':
        'When should the trainer be reminded after the session ends?',
    'lbl_gyms_trainer_permissions_reminder_note_en':
        'The notification is sent after the session ends',
    'lbl_gyms_trainer_permissions_cancel_title_en':
        'Can cancel member sessions',
    'lbl_gyms_trainer_permissions_cancel_note_en':
        'When off, this trainer cannot cancel their members\' sessions',
    'lbl_gyms_trainer_permissions_reschedule_title_en':
        'Can reschedule member sessions',
    'lbl_gyms_trainer_permissions_reschedule_note_en':
        'When off, this trainer cannot reschedule their members\' sessions',
    'lbl_gyms_trainer_permissions_auto_save_note_en':
        'Every change is saved instantly.',
    'lbl_gyms_trainer_permissions_save_failed_error_en':
        'Setting could not be saved, check your connection and try again.',
    'lbl_measurements_add_title_en': 'New measurement',
    'lbl_measurements_measurement_date_label_en': 'Measurement date',
    'lbl_measurements_measurements_section_en': 'MEASUREMENTS',
    'lbl_measurements_unit_cm_en': 'cm',
    'lbl_measurements_metric_bel_en': 'Waist',
    'lbl_measurements_metric_gogus_en': 'Chest',
    'lbl_measurements_metric_kalca_en': 'Hip',
    'lbl_measurements_metric_kol_en': 'Arm',
    'lbl_measurements_metric_bacak_en': 'Leg',
    'lbl_measurements_metric_kilo_en': 'Weight',
    'lbl_measurements_metric_yag_orani_en': 'Body fat',
    'lbl_trainers_metric_bel_cevresi_en': 'Waist circumference',
    'lbl_measurements_title_en': 'My Measurements',
    'lbl_measurements_selected_point_label_en': 'Selected point',
    'lbl_measurements_history_section_en': 'MEASUREMENT HISTORY',
    'lbl_measurements_member_title_en': '{name} · Measurements',
    'lbl_measurements_avatar_hint_en': 'Tap points to see values',
    'lbl_measurements_chart_hint_en': 'tap metric chips',
    'lbl_measurements_chart_toggle_label_en': 'Chart',
    'lbl_measurements_avatar_toggle_label_en': 'Avatar',
    'lbl_measurements_date_picker_title_en': 'Select date',
    'lbl_measurements_latest_record_option_en': 'Latest record',
    'lbl_measurements_showing_latest_label_en': 'Showing latest record',
    'lbl_measurements_showing_date_label_en': 'Showing {date}',
    'lbl_measurements_change_date_label_en': 'Change date',
    'lbl_measurements_value_field_hint_en': 'Enter value',
    'lbl_measurements_empty_point_hint_en':
        'No measurement yet — enter a value above.',
    'lbl_measurements_save_failed_error_en':
        'Could not save measurement, try again.',
    'lbl_measurements_no_data_for_metric_en':
        'No measurements yet for {metric}.',
    'lbl_measurements_metric_latest_label_en': '{metric} · latest measurement',
    'lbl_measurements_no_change_label_en': 'no change',
    'lbl_measurements_six_month_delta_label_en': 'over 6 months {delta}',
    'lbl_measurements_latest_measurement_label_en': 'Latest measurement',
    'lbl_measurements_switch_to_avatar_cta_en':
        'Switch to Avatar to add a measurement',
    'lbl_measurements_add_metric_label_en': 'Add {metric}',
    'lbl_members_detail_payment_status_label_en': 'Payment status',
    'lbl_members_detail_remaining_sessions_label_en': 'Remaining sessions',
    'lbl_members_detail_makeup_label_en': 'Makeup',
    'lbl_members_detail_total_label_en': 'Total',
    'lbl_members_detail_paid_label_en': 'Paid',
    'lbl_members_detail_remaining_amount_label_en': 'Remaining',
    'lbl_members_list_title_en': 'Members',
    'lbl_members_add_member_button_en': '+ Add member',
    'lbl_members_list_empty_state_en': 'No members match this filter.',
    'lbl_members_filter_active_en': 'Active',
    'lbl_members_filter_expiring_en': 'Expiring',
    'lbl_members_info_step_indicator_1_en': '1 / 3',
    'lbl_members_info_login_helper_en':
        'The member logs in with this number, no password needed.',
    'lbl_members_gender_field_label_en': 'Gender',
    'lbl_members_trainer_field_label_en': 'Trainer',
    'lbl_members_registration_date_field_label_en': 'Registration date',
    'lbl_members_select_trainer_button_en': 'Select trainer',
    'lbl_members_first_name_field_label_en': 'First name',
    'lbl_members_last_name_field_label_en': 'Last name',
    'lbl_members_birth_year_field_label_en': 'Birth year',
    'lbl_members_height_field_label_en': 'Height',
    'lbl_members_note_field_label_en': 'Note (optional)',
    'lbl_members_payment_title_en': 'Payment information',
    'lbl_members_payment_step_indicator_3_en': '3 / 3',
    'lbl_members_payment_total_label_en': 'Total amount',
    'lbl_members_payment_paid_label_en': 'Paid',
    'lbl_members_payment_remaining_label_en': 'Remaining payment',
    'lbl_members_payment_auto_calculated_helper_en': 'Calculated automatically',
    'lbl_members_payment_due_date_field_label_en': 'Due date',
    'lbl_members_payment_enter_amount_helper_en': 'Enter amount paid',
    'lbl_members_payment_full_option_en': 'Paid in full',
    'lbl_members_payment_half_option_en': 'Half',
    'lbl_members_payment_other_option_en': 'Other',
    'lbl_members_new_membership_title_en': 'New membership',
    'lbl_members_new_membership_step_indicator_2_en': '2 / 3',
    'lbl_members_package_select_section_en': 'SELECT PACKAGE',
    'lbl_members_makeup_session_count_label_en': 'Makeup session count',
    'lbl_members_makeup_session_helper_en': 'Usable after the package ends',
    'lbl_members_start_date_field_label_en': 'Start date',
    'lbl_members_end_date_field_label_en': 'End date',
    'lbl_members_go_to_payment_button_en': 'Continue to payment',
    'lbl_members_detail_not_found_en': 'Member not found.',
    'lbl_members_detail_last_payment_label_en': 'Last payment {date}',
    'lbl_members_detail_view_measurements_button_en':
        'View measurements screen',
    'lbl_members_detail_renew_package_button_en': 'Renew Package',
    'lbl_members_detail_renew_package_blocked_note_en':
        'Settle the current package\'s balance before defining a new one.',
    'lbl_members_detail_phone_trainer_line_en':
        '{phone} · Trainer: {trainerName}',
    'lbl_members_list_search_hint_en': 'Search by name',
    'lbl_members_list_load_error_en': 'Could not load the list.',
    'lbl_members_edit_payment_title_en': 'Payment details',
    'lbl_members_payment_installment_count_label_en': 'Installment count',
    'lbl_members_edit_payment_save_error_en':
        'Could not save, check your connection and try again.',
    'lbl_members_payment_installment_note_en':
        'The member only sees whether installments are paid on their own '
        'screen; amounts are not shown to them.',
    'lbl_members_saving_label_en': 'Saving…',
    'lbl_members_self_info_title_en': 'My Info',
    'lbl_members_self_info_name_required_error_en':
        'Name and surname are required.',
    'lbl_members_self_info_phone_invalid_error_en':
        'Enter a valid phone number.',
    'lbl_members_self_info_phone_taken_error_en':
        'This phone number is already registered.',
    'lbl_members_self_info_save_error_en':
        'Could not save, check your connection and try again.',
    'lbl_members_info_new_title_en': 'New member',
    'lbl_members_info_edit_title_en': 'Member details',
    'lbl_members_info_phone_hint_en': '5XX XXX XX XX',
    'lbl_members_info_age_suffix_en': '{age} yo',
    'lbl_members_package_pick_type_validity_caption_en': '{type} · {days} days',
    'lbl_members_info_height_picker_title_en': 'Height (cm)',
    'lbl_members_info_gender_label_en': 'Gender (optional)',
    'lbl_members_info_gender_helper_en':
        'The measurement avatar is shown based on this; no separate '
        'selection is made on the member screen.',
    'lbl_members_info_gender_erkek_option_en': 'Male',
    'lbl_members_info_gender_kadin_option_en': 'Female',
    'lbl_trainers_specialty_fonksiyonel_option_en': 'Functional',
    'lbl_trainers_specialty_pilates_option_en': 'Pilates',
    'lbl_trainers_specialty_yoga_option_en': 'Yoga',
    'lbl_trainers_specialty_kickbox_option_en': 'Kickboxing',
    'lbl_gyms_theme_preset_default_name_en': 'Egora Blue',
    'lbl_gyms_theme_preset_default_note_en': 'Default theme',
    'lbl_gyms_theme_preset_orange_name_en': 'Orange Energy',
    'lbl_gyms_theme_preset_orange_note_en': 'Warm, energetic accent',
    'lbl_gyms_theme_preset_green_name_en': 'Green Nature',
    'lbl_gyms_theme_preset_green_note_en': 'Calm, natural accent',
    'lbl_common_month_names_long_en':
        'January,February,March,April,May,June,July,August,September,October,November,December',
    'lbl_common_weekday_names_long_en':
        'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
    'lbl_members_info_confirm_attendance_label_en':
        'Can send session confirmations',
    'lbl_members_info_confirm_attendance_helper_en':
        'The member can report "I\'ll be there"/"I won\'t make it" for '
        'their next session from the home screen.',
    'lbl_members_info_go_to_package_button_en': 'Continue to package',
    'lbl_members_info_no_trainers_message_en': 'No trainers yet.',
    'lbl_members_info_picker_confirm_button_en': 'Select',
    'lbl_members_new_membership_trainer_label_en': 'Trainer: {trainerName}',
    'lbl_members_new_membership_autofill_note_en':
        'End date and session count fill in based on the selected package; '
        'you can edit them manually if you want.',
    'lbl_members_installment_amount_field_label_en': 'Amount',
    'lbl_members_installment_paid_toggle_label_en': 'Paid?',
    'lbl_notifications_title_en': 'Send notification',
    'lbl_notifications_target_question_label_en': 'Who should receive it?',
    'lbl_notifications_target_single_member_option_en': 'Single member',
    'lbl_notifications_target_whole_gym_option_en': 'Whole gym',
    'lbl_notifications_preview_label_en': 'Preview',
    'lbl_notifications_select_member_button_en': 'Select member',
    'lbl_notifications_title_field_label_en': 'Title',
    'lbl_notifications_message_field_label_en': 'Message',
    'lbl_notifications_target_selected_members_option_en': 'Selected members',
    'lbl_notifications_whole_gym_summary_label_en': '{gym} · all members',
    'lbl_notifications_message_counter_label_en': '{current} / {max}',
    'lbl_notifications_preview_template_en': 'Egoractive · {title} — {message}',
    'lbl_notifications_preview_message_placeholder_en': 'Message text…',
    'lbl_notifications_send_button_label_en': 'Send',
    'lbl_notifications_sending_button_label_en': 'Sending…',
    'lbl_notifications_sent_button_label_en': 'Sent',
    'lbl_notifications_member_picker_subtitle_en':
        'You can select one or more members.',
    'lbl_notifications_no_members_empty_state_en': 'No members yet.',
    'lbl_packages_list_title_en': 'Packages',
    'lbl_packages_add_package_button_en': '+ Add package',
    'lbl_packages_edit_session_type_field_label_en': 'Session type',
    'lbl_packages_edit_on_sale_toggle_label_en': 'On sale',
    'lbl_packages_edit_on_sale_toggle_description_en':
        'Hidden from new memberships when off',
    'lbl_packages_delete_package_button_en': 'Delete package',
    'lbl_packages_edit_name_field_label_en': 'Package name',
    'lbl_packages_edit_validity_days_field_label_en': 'Validity (days)',
    'lbl_packages_edit_price_field_label_en': 'Price ({currency})',
    'lbl_packages_member_package_title_en': 'My Package',
    'lbl_packages_remaining_word_en': 'remaining',
    'lbl_packages_trainer_owner_label_en': 'Your trainer',
    'lbl_packages_start_label_en': 'Start',
    'lbl_packages_add_title_en': 'Add package',
    'lbl_packages_edit_title_en': 'Edit package',
    'lbl_packages_name_field_hint_en': 'One-on-one 12 Sessions',
    'lbl_packages_session_count_field_hint_en': 'E.g. 12',
    'lbl_packages_validity_field_hint_en': 'E.g. 90',
    'lbl_packages_per_session_price_caption_en': '{price} per session',
    'lbl_packages_delete_failed_error_en':
        'Could not delete package, try again.',
    'lbl_packages_name_required_error_en': 'Package name cannot be empty.',
    'lbl_packages_session_count_invalid_error_en':
        'Enter a valid session count.',
    'lbl_packages_validity_invalid_error_en': 'Enter a valid number of days.',
    'lbl_packages_save_failed_error_en': 'Could not save package, try again.',
    'lbl_packages_remaining_with_makeup_caption_en':
        '{remaining} sessions left. Make-up sessions available: {makeup}.',
    'lbl_packages_low_sessions_warning_title_en': '{remaining} sessions left',
    'lbl_packages_renew_with_trainer_caption_en':
        'If you want to renew before your package ends, you can talk to your trainer {trainer}.',
    'lbl_packages_session_count_validity_caption_en':
        '{count} sessions · {days} days',
    'lbl_packages_off_sale_label_en': 'Off',
    'lbl_reports_summary_load_error_en':
        'Report data could not be loaded right now, please try again later.',
    'lbl_reports_total_sessions_label_en': 'Total sessions',
    'lbl_reports_net_label_en': 'Net',
    'lbl_reports_trainer_performance_load_error_en':
        'Trainer data failed to load.',
    'lbl_reports_trainer_performance_empty_state_en':
        'No trainer data for this month.',
    'lbl_reports_past_reports_section_title_en': 'PAST REPORTS',
    'lbl_reports_period_weekly_label_en': 'Weekly',
    'lbl_reports_period_monthly_label_en': 'Monthly',
    'lbl_reports_snapshot_list_load_error_en':
        'Past reports could not be loaded, please try again later.',
    'lbl_reports_snapshot_list_empty_state_en':
        'No reports generated yet for this period.',
    'lbl_reports_snapshot_detail_title_en': 'Report Detail',
    'lbl_reports_export_pdf_button_label_en': 'Export as PDF',
    'lbl_reports_pdf_document_title_en': 'Egoractive · Report',
    'lbl_reports_pdf_hero_positive_template_en':
        'You made {net} net profit this period',
    'lbl_reports_pdf_hero_negative_template_en':
        'This period ended with a {net} net loss',
    'lbl_reports_pdf_hero_sub_positive_en':
        'See the details below — check trainer performance and your best-selling packages.',
    'lbl_reports_pdf_hero_sub_negative_en':
        'The expense and package breakdown below can help you spot where to save.',
    'lbl_reports_pdf_group_events_title_en': 'Group Classes & Events',
    'lbl_reports_pdf_group_sessions_label_en': 'Group Classes',
    'lbl_reports_pdf_events_label_en': 'Events',
    'lbl_reports_pdf_sessions_unit_en': 'classes',
    'lbl_reports_pdf_events_unit_en': 'events',
    'lbl_reports_pdf_attendance_template_en':
        '{attendance} / {capacity} attended · %{pct} full',
    'lbl_reports_pdf_packages_title_en': 'Packages Sold',
    'lbl_reports_pdf_packages_empty_en': 'No packages were sold this period.',
    'lbl_reports_pdf_sales_unit_en': 'sold',
    'lbl_reports_pdf_finance_title_en': 'Financial Summary',
    'lbl_reports_pdf_net_profit_label_en': 'Net Profit',
    'lbl_reports_pdf_net_loss_label_en': 'Net Loss',
    'lbl_reports_pdf_completed_short_label_en': 'completed',
    'lbl_reports_pdf_cancelled_short_label_en': 'cancelled',
    'lbl_reports_pdf_total_short_label_en': 'total',
    'lbl_reports_pdf_completion_rate_template_en':
        '%{completed} completion · %{cancelled} cancellation rate',
    'lbl_reports_pdf_sessions_title_en': 'Session Overview',
    'lbl_reports_pdf_individual_sessions_label_en': 'Individual Sessions',
    'lbl_reports_pdf_duet_sessions_label_en': 'Duet Classes',
    'lbl_reports_pdf_solo_pill_label_en': 'Solo',
    'lbl_reports_pdf_duet_pill_label_en': 'Duet',
    'lbl_reports_pdf_group_pill_label_en': 'Group',
    'lbl_reports_pdf_other_label_en': 'Other',
    'lbl_reports_pdf_footer_en':
        'This report was generated automatically by Egoractive.',
    'lbl_reports_pdf_export_error_en':
        'Could not generate PDF, please try again.',
    'lbl_sessions_calendar_title_en': 'Calendar',
    'lbl_sessions_calendar_slot_time_label_en': 'Time',
    'lbl_sessions_calendar_slot_status_label_en': 'Status',
    'lbl_sessions_calendar_type_individual_en': 'Individual',
    'lbl_sessions_calendar_type_duet_en': 'Duet',
    'lbl_sessions_calendar_duet_members_label_en': 'Participating Members',
    'lbl_sessions_attendance_answer_label_en': 'Answer',
    'lbl_sessions_attendance_answer_time_label_en': 'Answer time',
    'lbl_sessions_attendance_member_note_label_en': 'Member\'s note',
    'lbl_sessions_attendance_back_to_calendar_button_en': 'Back to calendar',
    'lbl_sessions_management_title_en': 'Sessions',
    'lbl_sessions_management_empty_state_en': 'No sessions match this day.',
    'lbl_sessions_filter_scheduled_en': 'Scheduled',
    'lbl_sessions_change_trainer_action_en': 'Change trainer',
    'lbl_sessions_cancel_session_action_en': 'Cancel session',
    'lbl_sessions_confirm_title_en': 'Session confirmation',
    'lbl_sessions_confirm_attending_answer_text_en':
        'You confirmed you\'re coming',
    'lbl_sessions_confirm_not_attending_answer_text_en':
        'You confirmed you\'re not coming',
    'lbl_sessions_confirm_change_answer_button_en': 'Change my answer',
    'lbl_sessions_member_home_this_week_section_en': 'THIS WEEK',
    'lbl_sessions_member_home_see_package_button_en': 'View my package',
    'lbl_sessions_trainer_notifications_title_en': 'Notifications',
    'lbl_sessions_completion_member_no_show_option_en': 'Member didn\'t show',
    'lbl_sessions_list_title_en': 'My Sessions',
    'lbl_sessions_list_view_toggle_en': 'List',
    'lbl_sessions_calendar_view_toggle_en': 'Calendar',
    'lbl_sessions_upcoming_section_en': 'UPCOMING',
    'lbl_sessions_past_section_en': 'PAST',
    'lbl_sessions_calendar_no_expenses_state_en': 'No expenses on this day.',
    'lbl_sessions_status_now_en': 'Now',
    'lbl_sessions_management_cancelling_label_en': 'Cancelling…',
    'lbl_sessions_management_admin_cancel_note_en':
        'As an admin you can cancel or reschedule without a time restriction.',
    'lbl_sessions_management_cancel_error_en':
        'Could not cancel the session, please try again.',
    'lbl_sessions_confirm_question_en':
        'Will you attend your class tomorrow at {hour}?',
    'lbl_sessions_confirm_change_hint_en':
        'You can change your answer up to 2 hours before the class.',
    'lbl_sessions_confirm_waiting_hint_en':
        '{meta} is waiting for you. You can change your answer up to 2 hours before the class.',
    'lbl_sessions_confirm_session_summary_en':
        '{meta} · Deducts 1 from your remaining sessions',
    'lbl_sessions_confirm_no_permission_en':
        "You don't have permission to confirm attendance for this class. Contact your trainer.",
    'lbl_sessions_confirm_coming_note_en':
        'Your spot has been reserved. You can change your answer up to 2 hours before the class.',
    'lbl_sessions_confirm_coming_note_with_meta_en':
        "Your spot in {meta}'s schedule has been reserved. You can change your answer up to 2 hours before the class.",
    'lbl_sessions_confirm_not_coming_note_en':
        'Your remaining sessions were not deducted, your trainer has been notified. You can change your answer up to 2 hours before the class.',
    'lbl_sessions_member_home_greeting_en': 'Hi{name}',
    'lbl_sessions_member_home_remaining_sessions_label_en':
        'Remaining sessions: {count}',
    'lbl_sessions_member_home_package_valid_until_en':
        '{name} package · valid until {date}',
    'lbl_sessions_member_home_next_session_section_en': 'NEXT CLASS',
    'lbl_sessions_member_home_installments_section_en': 'INSTALLMENTS',
    'lbl_sessions_member_home_installment_index_label_en':
        'Installment {index}',
    'lbl_sessions_member_home_installment_due_date_label_en': 'Due {date}',
    'lbl_sessions_member_home_installment_due_soon_label_en': 'Due soon',
    'lbl_sessions_member_home_installment_unpaid_label_en': 'Unpaid',
    'lbl_sessions_completion_confirm_error_en':
        'Could not save the confirmation, check your connection and try again.',
    'lbl_sessions_management_mark_completed_action_en': 'Mark as completed',
    'lbl_sessions_management_mark_absent_action_en': 'Mark as no-show',
    'lbl_sessions_management_attendance_current_status_en':
        'Currently: {status}',
    'lbl_sessions_management_attendance_error_en':
        'Could not save, check your connection and try again.',
    'lbl_sessions_completion_question_en':
        'Did you complete {name}\'s {time} class?',
    'lbl_sessions_completion_time_limit_note_en':
        'You can confirm within 24 hours, after that admin approval is required.',
    'lbl_sessions_completion_expired_note_en':
        'The window to confirm this session has passed. Please contact your admin.',
    'lbl_sessions_list_empty_state_en':
        "You don't have any classes yet — they'll show up here once your trainer schedules one with you.",
    'lbl_sessions_list_calendar_empty_day_en': 'No classes on this day.',
    'lbl_sessions_trainer_notifications_empty_state_en':
        'No notifications yet.',
    'lbl_sessions_create_trainer_busy_error_en':
        '{name} is busy at this time, pick another time.',
    'lbl_sessions_create_reschedule_error_en':
        'Could not reschedule the session, please try again.',
    'lbl_sessions_create_no_active_gym_error_en': 'No active gym found.',
    'lbl_sessions_create_skipped_days_snackbar_en':
        'Skipped, trainer busy on: {days}.',
    'lbl_sessions_create_title_en': 'New session',
    'lbl_sessions_create_select_placeholder_en': 'Select',
    'lbl_sessions_create_member_summary_en': '{name} · {count} sessions',
    'lbl_sessions_create_pick_member_title_en': 'Select member',
    'lbl_sessions_create_member_sessions_suffix_en': '{count} sessions',
    'lbl_sessions_create_pick_trainer_title_en': 'Select trainer',
    'lbl_sessions_create_kind_label_en': 'Session type',
    'lbl_sessions_create_kind_individual_en': '1-on-1 Session',
    'lbl_sessions_create_kind_duet_en': 'Duet Class',
    'lbl_sessions_create_members_field_label_en': 'Members',
    'lbl_sessions_create_pick_members_title_en': 'Select members',
    'lbl_sessions_create_duet_members_summary_en': '{count} members selected',
    'lbl_sessions_create_duet_min_members_error_en':
        'Select at least 2 members for a duet class.',
    'lbl_sessions_create_repeat_label_en': 'Repeat',
    'lbl_sessions_create_repeat_days_selected_en': '{count} days selected',
    'lbl_sessions_create_submit_button_en': 'Create',
    'lbl_sessions_repeat_calendar_exhausted_error_en':
        'No remaining sessions left.',
    'lbl_sessions_repeat_calendar_subtitle_en':
        'Please select the days to repeat.',
    'lbl_sessions_repeat_calendar_remaining_label_en': 'Remaining sessions',
    'lbl_trainers_management_title_en': 'Trainers',
    'lbl_trainers_add_trainer_button_en': '+ Add trainer',
    'lbl_trainers_specialty_field_label_en': 'Specialty',
    'lbl_trainers_add_trainer_form_title_en': 'Add trainer',
    'lbl_trainers_full_name_field_label_en': 'Full name',
    'lbl_trainers_add_trainer_submit_button_en': 'Add trainer',
    'lbl_trainers_home_awaiting_approval_section_en': 'AWAITING YOUR APPROVAL',
    'lbl_trainers_home_today_schedule_section_en': 'TODAY\'S SCHEDULE',
    'lbl_trainers_home_no_show_label_en': 'No-show',
    'lbl_trainers_home_today_sessions_label_en': 'Today\'s sessions',
    'lbl_trainers_home_completed_label_en': 'Completed',
    'lbl_trainers_home_free_slot_label_en': 'Free slot',
    'lbl_trainers_member_detail_create_session_button_en': 'Create session',
    'lbl_trainers_member_detail_add_measurement_button_en': 'Add measurement',
    'lbl_trainers_member_detail_remaining_sessions_label_en':
        'Remaining sessions',
    'lbl_trainers_member_detail_package_end_label_en': 'Package end date',
    'lbl_trainers_calendar_title_en': 'My Calendar',
    'lbl_trainers_calendar_mark_completed_action_en': 'Session completed',
    'lbl_trainers_members_list_title_en': 'My Members',
    'lbl_trainers_members_filter_expiring_en': 'Package expiring',
    'lbl_trainers_members_remaining_sessions_suffix_en': 'remaining sessions',
    'lbl_trainers_report_title_en': 'My session report',
    'lbl_trainers_report_start_date_field_label_en': 'Start',
    'lbl_trainers_report_end_date_field_label_en': 'End',
    'lbl_trainers_report_one_on_one_toggle_en': 'One-on-one',
    'lbl_trainers_report_group_toggle_en': 'Group',
    'lbl_trainers_report_duet_toggle_en': 'Duet',
    'lbl_trainers_report_period_weekly_en': 'Weekly',
    'lbl_trainers_report_period_monthly_en': 'Monthly',
    'lbl_trainers_report_period_all_time_en': 'All time',
    'lbl_trainers_report_period_custom_en': 'Custom',
    'lbl_trainers_profile_footer_text_en':
        'Egoractive · Egora Games · Version 1.0',
    'lbl_trainers_detail_title_en': 'Trainer detail',
    'lbl_trainers_member_count_suffix_en': '{count} members',
    'lbl_trainers_detail_all_time_section_en': 'ALL TIME',
    'lbl_trainers_detail_planned_label_en': 'Planned',
    'lbl_trainers_detail_this_month_section_en': 'THIS MONTH',
    'lbl_trainers_detail_this_week_section_en': 'THIS WEEK',
    'lbl_trainers_detail_month_load_error_en':
        'This month\'s data could not be loaded.',
    'lbl_trainers_add_trainer_name_required_error_en':
        'Full name cannot be empty.',
    'lbl_trainers_add_trainer_error_en':
        'Trainer could not be added, try again.',
    'lbl_trainers_phone_taken_error_en': 'This phone number is already registered.',
    'lbl_trainers_add_trainer_name_hint_en': 'John Smith',
    'lbl_trainers_management_trainer_count_suffix_en': '{count} people',
    'lbl_trainers_add_trainer_saving_label_en': 'Adding…',
    'lbl_trainers_edit_trainer_form_title_en': 'Edit trainer',
    'lbl_trainers_edit_trainer_error_en':
        'Could not update trainer, try again.',
    'lbl_trainers_home_greeting_en': 'Have a great day',
    'lbl_trainers_home_greeting_with_name_en': 'Have a great day, {name}',
    'lbl_trainers_home_confirmation_save_error_en':
        'Confirmation could not be saved, check your connection and try again.',
    'lbl_trainers_members_search_hint_en': 'Search members',
    'lbl_trainers_profile_specialty_role_en': '{specialty} · Trainer',

    RemoteConfigKeys.subscriptionIncludedFeatures:
        _defaultSubscriptionIncludedFeaturesJson,
    RemoteConfigKeys.subscriptionRestrictedOperations:
        _defaultSubscriptionRestrictedOperationsJson,
    'lbl_subscription_trial_banner_title_tr':
        'Deneme süreniz {days} gün sonra doluyor',
    'lbl_subscription_trial_banner_title_en': 'Your trial ends in {days} days',
    'lbl_subscription_trial_banner_body_tr':
        '{date} tarihine kadar tüm özellikler açık. Bir plan seçerseniz salonunuz kesintisiz çalışmaya devam eder.',
    'lbl_subscription_trial_banner_body_en':
        'All features are open until {date}. If you choose a plan, your studio keeps running without interruption.',
    'lbl_subscription_trial_progress_tr':
        '{total} günlük denemenin {current}. günündesiniz',
    'lbl_subscription_trial_progress_en':
        "You're on day {current} of your {total}-day trial",
    'lbl_subscription_expired_banner_title_tr':
        'Aboneliğiniz {date} tarihinde sona erdi',
    'lbl_subscription_expired_banner_title_en':
        'Your subscription ended on {date}',
    'lbl_subscription_expired_banner_body_tr':
        'Verileriniz güvende ve eksiksiz duruyor. Bir plan seçtiğiniz anda her şey kaldığı yerden devam eder.',
    'lbl_subscription_expired_banner_body_en':
        'Your data is safe and complete. As soon as you choose a plan, everything continues where it left off.',
    'lbl_subscription_restricted_title_tr': 'Şu an kısıtlı',
    'lbl_subscription_restricted_title_en': 'Currently restricted',
    'lbl_subscription_restricted_note_tr':
        'Takvim, üye listesi ve raporları görüntülemeye devam edebilirsiniz.',
    'lbl_subscription_restricted_note_en':
        'You can still view the calendar, member list and reports.',
    'lbl_subscription_active_plan_label_tr': 'Mevcut planınız',
    'lbl_subscription_active_plan_label_en': 'Your current plan',
    'lbl_subscription_active_badge_tr': 'Aktif',
    'lbl_subscription_active_badge_en': 'Active',
    'lbl_subscription_renewal_label_tr': 'Yenilenme',
    'lbl_subscription_renewal_label_en': 'Renews',
    'lbl_subscription_started_label_tr': 'Başlangıç',
    'lbl_subscription_started_label_en': 'Started',
    'lbl_subscription_active_note_tr':
        'Aboneliğiniz {period} kendini yeniler. Plan değişikliği, duraklatma ve iptal uygulama içinde değil, {store} abonelik ayarlarında yapılır.',
    'lbl_subscription_active_note_en':
        'Your subscription renews {period}. Plan changes, pausing and cancellation are done in {store} subscription settings, not in the app.',
    'lbl_subscription_exempt_note_tr':
        'Salonunuz için abonelik ücreti alınmıyor — tüm özellikler sınırsız kullanımınıza açık.',
    'lbl_subscription_exempt_note_en':
        'Your gym is not billed for a subscription — every feature is available to you without limits.',
    'lbl_subscription_store_row_title_tr': '{store} üzerinden',
    'lbl_subscription_store_row_title_en': 'Via {store}',
    'lbl_subscription_store_row_subtitle_tr':
        'Ödeme ve faturalar {storeAccount} hesabınızda',
    'lbl_subscription_store_row_subtitle_en':
        'Payments and invoices are on your {storeAccount} account',
    'lbl_subscription_manage_cta_tr': 'Aboneliği yönet',
    'lbl_subscription_manage_cta_en': 'Manage subscription',
    'lbl_subscription_manage_caption_tr': '{store} abonelik ayarları açılır',
    'lbl_subscription_manage_caption_en':
        '{store} subscription settings will open',
    'lbl_subscription_upgrade_to_yearly_title_tr': 'Yıllığa geç',
    'lbl_subscription_upgrade_to_yearly_title_en': 'Switch to yearly',
    'lbl_subscription_store_note_tr':
        "Satın alma uygulama içinde yapılmaz. Devam ettiğinizde {store} açılır; ödeme, iptal ve faturalar {storeAccount} hesabınız üzerinden yürür. Dönem bitiminden 24 saat önce iptal edilmezse abonelik kendini yeniler.",
    'lbl_subscription_store_note_en':
        'Purchases are not made in the app. When you continue, {store} opens; payment, cancellation and invoices are handled through your {storeAccount} account. Unless cancelled 24 hours before the period ends, the subscription renews automatically.',
    'lbl_subscription_store_note_expired_tr':
        'Satın alma uygulama içinde yapılmaz. Devam ettiğinizde {store} açılır; ödeme, iptal ve faturalar {storeAccount} hesabınız üzerinden yürür.',
    'lbl_subscription_store_note_expired_en':
        'Purchases are not made in the app. When you continue, {store} opens; payment, cancellation and invoices are handled through your {storeAccount} account.',
    'lbl_subscription_purchase_cta_tr': "{plan} planla {store}'a git",
    'lbl_subscription_purchase_cta_en': 'Go to {store} with the {plan} plan',
    'lbl_subscription_purchase_cta_expired_tr':
        "{plan} planı {store}'da başlat",
    'lbl_subscription_purchase_cta_expired_en':
        'Start the {plan} plan on {store}',
    'lbl_subscription_purchase_caption_tr':
        "{store}'da açılır · Satın almayı geri yükle",
    'lbl_subscription_purchase_caption_en':
        'Opens in {store} · Restore purchase',
    'lbl_subscription_pending_banner_title_tr': "{store}'a yönlendirildiniz",
    'lbl_subscription_pending_banner_title_en':
        "You've been redirected to {store}",
    'lbl_subscription_pending_banner_body_tr':
        'Satın almayı mağaza penceresinde tamamlayın; sonucu bu ekrana biz yansıtacağız.',
    'lbl_subscription_pending_banner_body_en':
        'Complete the purchase in the store window; we will reflect the result on this screen.',
    'lbl_subscription_pending_pill_tr': "{store}'da açıldı",
    'lbl_subscription_pending_pill_en': 'Opened in {store}',
    'lbl_subscription_pending_cta_tr': '{store} bekleniyor…',
    'lbl_subscription_pending_cta_en': 'Waiting for {store}…',
    'lbl_subscription_pending_caption_tr':
        'Mağaza penceresi kapanınca güncellenir',
    'lbl_subscription_pending_caption_en':
        'Updates once the store window closes',
    'lbl_subscription_pending_note_tr':
        'Mağaza penceresini kapatır ya da iptal ederseniz bu ekrana geri dönersiniz; plan seçiminiz korunur.',
    'lbl_subscription_pending_note_en':
        'If you close the store window or cancel, you will return to this screen; your plan selection is kept.',
    'lbl_subscription_yearly_badge_tr': 'En avantajlı',
    'lbl_subscription_yearly_badge_en': 'Best value',
    'lbl_subscription_yearly_sub_tr': '2 ay bedava',
    'lbl_subscription_yearly_sub_en': '2 months free',
    'lbl_subscription_monthly_sub_tr': 'aylık',
    'lbl_subscription_monthly_sub_en': 'monthly',
    'lbl_subscription_trial_sub_label_tr': '{days} gün ücretsiz',
    'lbl_subscription_trial_sub_label_en': '{days}-day free trial',
    'lbl_subscription_no_products_tr':
        'Şu an satın alınabilir bir abonelik ürünü bulunamadı.',
    'lbl_subscription_no_products_en':
        'No purchasable subscription product is available right now.',
    'lbl_subscription_onboarding_title_tr': 'Aboneliğini başlat',
    'lbl_subscription_onboarding_title_en': 'Start your subscription',
    'lbl_subscription_onboarding_subtitle_tr':
        'Devam etmek için bir plan seç. {days} gün boyunca hiç ücret alınmaz, süre sonunda seçtiğin paket {store} üzerinden otomatik olarak devam eder.',
    'lbl_subscription_onboarding_subtitle_en':
        "Pick a plan to continue. You won't be charged for {days} days — after that, your selected plan renews automatically via {store}.",
    'lbl_subscription_onboarding_cta_tr':
        '{plan} ile {days} gün ücretsiz başlat',
    'lbl_subscription_onboarding_cta_en':
        'Start {days}-day free trial with {plan}',
    'lbl_subscription_onboarding_caption_tr':
        'Şimdi ücret alınmaz. İlk ödeme {days}. günde {store} hesabından çekilir.',
    'lbl_subscription_onboarding_caption_en':
        "You won't be charged today. Your first payment is taken on day {days} via {store}.",
    'lbl_subscription_onboarding_no_products_tr':
        'Planlar şu anda yüklenemiyor. Lütfen daha sonra tekrar dene.',
    'lbl_subscription_onboarding_no_products_en':
        'Plans can\'t be loaded right now. Please try again later.',
    'lbl_subscription_onboarding_subtitle_paid_only_tr':
        'Devam etmek için bir plan seç. Seçtiğin paket {store} üzerinden hemen başlar.',
    'lbl_subscription_onboarding_subtitle_paid_only_en':
        'Pick a plan to continue. Your selected plan starts right away via {store}.',
    'lbl_subscription_onboarding_cta_paid_only_tr': '{plan} ile abone ol',
    'lbl_subscription_onboarding_cta_paid_only_en': 'Subscribe with {plan}',
    'lbl_subscription_onboarding_caption_paid_only_tr':
        'İlk ödeme hemen {store} hesabından çekilir.',
    'lbl_subscription_onboarding_caption_paid_only_en':
        'Your first payment is taken right away via {store}.',
    'lbl_subscription_yearly_plan_fallback_tr': 'Yıllık',
    'lbl_subscription_yearly_plan_fallback_en': 'Yearly',
    'lbl_subscription_monthly_plan_fallback_tr': 'Aylık',
    'lbl_subscription_monthly_plan_fallback_en': 'Monthly',
    'lbl_subscription_yearly_period_word_tr': 'her yıl',
    'lbl_subscription_yearly_period_word_en': 'yearly',
    'lbl_subscription_monthly_period_word_tr': 'her ay',
    'lbl_subscription_monthly_period_word_en': 'monthly',
    'lbl_subscription_store_badge_label_tr': 'STORE',
    'lbl_subscription_store_badge_label_en': 'STORE',
    'lbl_subscription_management_open_error_tr': 'Abonelik yönetimi açılamadı.',
    'lbl_subscription_management_open_error_en':
        'Could not open subscription management.',
  };

  /// Ders/seans onay bildiriminin kaç dakika önce gönderileceği.
  int get sessionReminderMinutesBefore =>
      getInt(RemoteConfigKeys.sessionReminderMinutesBefore);

  /// Grup dersi oluştururken varsayılan kontenjan.
  int get defaultGroupSessionCapacity =>
      getInt(RemoteConfigKeys.defaultGroupSessionCapacity);

  int get groupSessionCapacityMax =>
      getInt(RemoteConfigKeys.groupSessionCapacityMax);

  int get groupSessionDescriptionMaxChars =>
      getInt(RemoteConfigKeys.groupSessionDescriptionMaxChars);

  int get gymRulesMaxChars => getInt(RemoteConfigKeys.gymRulesMaxChars);

  int get installmentDueSoonDays =>
      getInt(RemoteConfigKeys.installmentDueSoonDays);

  int get memberEndingSoonSessionsThreshold =>
      getInt(RemoteConfigKeys.memberEndingSoonSessionsThreshold);

  /// Etkinlikte "Katılmaktan Vazgeç" başlangıca kaç saat kalana kadar aktif.
  int get eventLeaveLockHoursBefore =>
      getInt(RemoteConfigKeys.eventLeaveLockHoursBefore);

  /// Grup dersinde "Katılmaktan Vazgeç" başlangıca kaç saat kalana kadar
  /// aktif — etkinliklerden ayrı, kendi varsayılanıyla ayarlanabilir.
  int get groupSessionLeaveLockHoursBefore =>
      getInt(RemoteConfigKeys.groupSessionLeaveLockHoursBefore);

  /// Üye/antrenör seansı en fazla kaç saat öncesine kadar iptal edebilir.
  int get cancellationDeadlineHours =>
      getInt(RemoteConfigKeys.cancellationDeadlineHours);

  /// F3-6 — bir salon override yazmadıysa Yetki Ayarları'nın varsayılanları.
  int get defaultTrainerReminderDelayMinutes =>
      getInt(RemoteConfigKeys.defaultTrainerReminderDelayMinutes);

  bool get defaultCanCancelMemberSessions =>
      getBool(RemoteConfigKeys.defaultCanCancelMemberSessions);

  bool get defaultCanRescheduleMemberSessions =>
      getBool(RemoteConfigKeys.defaultCanRescheduleMemberSessions);

  /// Aylık geri bildirim hatırlatmasının gönderileceği gün. -1 = ayın son günü.
  int get feedbackReminderDayOfMonth =>
      getInt(RemoteConfigKeys.feedbackReminderDayOfMonth);

  /// Ücretsiz sürümde reklam gösterilsin mi.
  bool get freeVersionAdsEnabled =>
      getBool(RemoteConfigKeys.freeVersionAdsEnabled);

  /// Test amaçlı — açıkken seans/grup dersi/etkinlik geçmiş tarih/saate
  /// oluşturulabilir (bkz. [RemoteConfigKeys.allowPastDatetimeCreation]).
  bool get allowPastDatetimeCreation =>
      getBool(RemoteConfigKeys.allowPastDatetimeCreation);

  /// F6-3 — yeni salonlara tanınan ücretsiz deneme süresi (gün).
  int get trialDurationDays => getInt(RemoteConfigKeys.trialDurationDays);

  /// Bkz. [RemoteConfigKeys.requireSubscriptionOnboarding] — mağaza
  /// kurulumu tamamlanana kadar Console'dan `false` yapılabilir.
  bool get requireSubscriptionOnboarding =>
      getBool(RemoteConfigKeys.requireSubscriptionOnboarding);

  /// Feature flag'lerin tutulduğu JSON obje (esnek, sabit alanı yok).
  Map<String, dynamic> get featureFlags =>
      _getJsonMap(RemoteConfigKeys.featureFlags);

  /// F4-4 — rozet kriterleri listesi (kodda değil RC'de tanımlı).
  List<Map<String, dynamic>> get badgeCriteria =>
      _getJsonList(RemoteConfigKeys.badgeCriteria);

  /// F5-3 — gider kategorileri, ham liste (kodda değil RC'de tanımlı).
  /// Her öğe `{id, label_tr, label_en}` — dile göre çözümleme çağıran
  /// tarafta (`currentLocale` ile) yapılır.
  List<Map<String, dynamic>> get expenseCategories =>
      _getJsonList(RemoteConfigKeys.expenseCategories);

  /// F6-1 — abonelikte dahil olan özellikler, ham liste (`{label_tr, label_en}`).
  List<Map<String, dynamic>> get subscriptionIncludedFeatures =>
      _getJsonList(RemoteConfigKeys.subscriptionIncludedFeatures);

  /// F6-1 — süresi dolduğunda kısıtlanan işlemler, ham liste.
  List<Map<String, dynamic>> get subscriptionRestrictedOperations =>
      _getJsonList(RemoteConfigKeys.subscriptionRestrictedOperations);

  /// `lbl*` metinlerini okur: `<key>_<locale>` parametresini getirir. Kod
  /// içinde `_tr`/`_en` asla elle yazılmaz, bu metod ekler. Reaktif olmayan
  /// (controller içi, tek seferlik) kullanım için — `locale` çağıran tarafça
  /// `ref.read(localeControllerProvider)` ile verilir. Widget `build()`
  /// içinde reaktif okuma için bunun yerine `rcTextProvider` kullanılır.
  String getText(String baseKey, String locale) =>
      getString('${baseKey}_$locale');

  /// F10-2 — `runApp()` blokajını kaldırma. Eskiden tek bir `init()` vardı
  /// ve `main()` içinde `await` ediliyordu; içindeki `fetchAndActivate()`
  /// AĞA çıktığı için (255 KB'lık şablon, 10 sn timeout) uygulamanın ilk
  /// karesi ağ hızına bağımlı hale geliyordu — zayıf/tıkalı mobil bağlantıda
  /// kullanıcı 10 saniyeye kadar boş ekran görüyordu. Artık ikiye bölündü:
  /// [applyDefaults] ağa hiç çıkmaz ve `runApp()` öncesinde beklenir;
  /// [fetchInBackground] ise `runApp()` SONRASINDA, kimseyi bekletmeden
  /// çalışır.
  ///
  /// Bu güvenli çünkü [_defaults] (1496 anahtar) kodun içinde gömülü —
  /// ilk kare her zaman doğru metinlerle çizilir, fetch sadece Console'da
  /// yapılmış değişiklikleri getirir.
  Future<void> applyDefaults() async {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 24),
      ),
    );
    await rc.setDefaults(_defaults);
  }

  /// `runApp()`'ten SONRA, `unawaited` olarak çağrılır — hiçbir şeyi
  /// bekletmez. İnternet yoksa/başarısız olursa [applyDefaults]'taki
  /// değerler geçerliliğini korur, uygulama hiçbir zaman bu yüzden çökmez.
  ///
  /// Ayrıca `onConfigUpdated` (Remote Config Realtime) dinlenir — Console'da
  /// bir parametre değiştirildiğinde SDK bunu anlık bir stream event'i
  /// olarak alır (normal `minimumFetchInterval` kısıtlamasına tabi değil).
  ///
  /// ⚠️ BİLİNEN DAVRANIŞ: `activate()` sonrası ekranda ZATEN çizili olan
  /// metinler o oturumda tazelenmez — `rcTextProvider` yalnızca
  /// `remoteConfigServiceProvider` (const, hiç değişmez) ve
  /// `localeControllerProvider`'ı izliyor, bu ikisi de değişmediği için
  /// yeniden çizim tetiklenmez. Yeni değerler BİR SONRAKİ AÇILIŞTA görünür
  /// (Firebase RC aktive edilen değerleri cihazda kalıcı tutar). Karar
  /// anında okunan `cfg_*` bayrakları ise (ör. `ref.read(...)` ile) anında
  /// yeni değeri alır, yani iş mantığı etkilenmez. Bu davranış F10-2'de
  /// bilinçli olarak kabul edildi (bkz. FAZ 10 notları) — 889 widget'ı aynı
  /// anda yeniden çizmenin frame hitch riski, kazanca değmedi. **Sonucu:**
  /// `remoteconfig.template.json` ile buradaki [_defaults] haritasının
  /// senkron tutulması kritik.
  Future<void> fetchInBackground() async {
    final rc = FirebaseRemoteConfig.instance;
    try {
      await rc.fetchAndActivate();
    } on Exception {
      // Fetch başarısız oldu — setDefaults'taki değerler geçerliliğini korur.
    }
    rc.onConfigUpdated.listen((_) async {
      try {
        await rc.activate();
      } on Exception {
        // Aktivasyon başarısız olursa mevcut değerlerle devam edilir —
        // bir sonraki güncelleme sinyalinde tekrar denenir.
      }
    });
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

  List<Map<String, dynamic>> _getJsonList(String key) {
    final raw = getString(key);
    if (raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      return decoded is List
          ? decoded.whereType<Map<String, dynamic>>().toList()
          : const [];
    } on FormatException {
      return const [];
    }
  }
}

@Riverpod(keepAlive: true)
RemoteConfigService remoteConfigService(RemoteConfigServiceRef ref) =>
    const RemoteConfigService();

/// Bir `lbl*` taban anahtarını aktif dile göre reaktif olarak çözer — bu
/// provider'ı `watch` eden her widget, [localeControllerProvider] değişince
/// otomatik yeniden çizilir (bkz. CLAUDE.md §2.5, `lbl*` metinleri).
///
/// Firebase.initializeApp hiç çağrılmamış bir widget test ortamında
/// `FirebaseRemoteConfig.instance` erişimi fırlatabilir (bkz. aynı desen
/// `profile_panel.dart`'taki `sessionReminderMinutesBefore` try/catch'i) —
/// panel testte boş metinle render olsun diye burada da yutuluyor.
@riverpod
String rcText(RcTextRef ref, String baseKey) {
  final rc = ref.watch(remoteConfigServiceProvider);
  final locale = ref.watch(localeControllerProvider);
  try {
    return rc.getString('${baseKey}_$locale');
  } catch (_) {
    return '';
  }
}
