import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  /// F4-2 — grup dersine katılım/ayrılma başlangıca kaç saat kalana kadar
  /// açık (sonrasında UI'da kilitli görünür).
  static const groupSessionLockHoursBefore = 'cfg_group_session_lock_hours_before';
  static const feedbackReminderDayOfMonth =
      'cfg_feedback_reminder_day_of_month';
  static const freeVersionAdsEnabled = 'cfg_free_version_ads_enabled';
  static const featureFlags = 'cfg_feature_flags';
  /// F6-3 — yeni bir salon oluşturulduğunda `trialStartedAt`'ten itibaren
  /// kaç gün ücretsiz deneme süresi tanınır.
  static const trialDurationDays = 'cfg_trial_duration_days';
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
  /// F3-6 — Yetki Ayarları'nın global varsayılanları. Bir salon
  /// `gyms/{gymId}.permissions` altında override yazmadıysa buradan okunur.
  static const defaultTrainerReminderDelayMinutes =
      'cfg_default_trainer_reminder_delay_minutes';
  static const defaultOnlineBookingEnabled = 'cfg_default_online_booking_enabled';
  static const defaultAllowSessionsAfterPackageExpiry =
      'cfg_default_allow_sessions_after_package_expiry';
  static const defaultMemberCanCancelSession =
      'cfg_default_member_can_cancel_session';

  /// F3-4 — sessionReminderCheck Cloud Function'ının gönderdiği push metni.
  /// Admin SDK'dan (Cloud Functions) da okunabildiği için diğer `lbl_*`
  /// metinlerinden farklı olarak isimlendirmede `notif` öneki kullanılıyor.
  /// `{time}` ve `{trainerName}` yer tutucuları fonksiyon tarafında gerçek
  /// değerlerle değiştiriliyor (kişiselleştirilmiş bildirim metni).
  static const notifSessionReminderTitle = 'lbl_notif_session_reminder_title';
  static const notifSessionReminderBody = 'lbl_notif_session_reminder_body';
  /// F3-5 — sessionCompletionCheck Cloud Function'ının antrenöre gönderdiği
  /// push metni. `{memberName}` yer tutucusu fonksiyon tarafında değişir.
  static const notifSessionCompletionTitle = 'lbl_notif_session_completion_title';
  static const notifSessionCompletionBody = 'lbl_notif_session_completion_body';
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
  static const commonGelicem = 'lbl_common_gelicem';
  static const commonGelmeyecegim = 'lbl_common_gelmeyecegim';
  static const commonAnaSayfaTab = 'lbl_common_ana_sayfa_tab';
  static const commonProfilTab = 'lbl_common_profil_tab';
  static const commonTelefonLabel = 'lbl_common_telefon_label';
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
  static const authRetryButton = 'lbl_auth_retry_button';
  static const authDeleteAccountErrorGeneric = 'lbl_auth_delete_account_error_generic';
  static const badgesTitle = 'lbl_badges_title';
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
  static const feedbackAdminListTitle = 'lbl_feedback_admin_list_title';
  static const feedbackMemberFormTitle = 'lbl_feedback_member_form_title';
  static const feedbackCommentSectionHeader =
      'lbl_feedback_comment_section_header';
  static const groupSessionsAdminListTitle =
      'lbl_group_sessions_admin_list_title';
  static const groupSessionsAddGroupSessionButton =
      'lbl_group_sessions_add_group_session_button';
  static const groupSessionsCapacitySuffixLabel =
      'lbl_group_sessions_capacity_suffix_label';
  static const groupSessionsViewParticipantsLink =
      'lbl_group_sessions_view_participants_link';
  static const groupSessionsDiscoverTitle = 'lbl_group_sessions_discover_title';
  static const groupSessionsDiscoverTabGroupSessions =
      'lbl_group_sessions_discover_tab_group_sessions';
  static const groupSessionsDiscoverTabEvents =
      'lbl_group_sessions_discover_tab_events';
  static const groupSessionsCreateTitle = 'lbl_group_sessions_create_title';
  static const groupSessionsDaysFieldLabel =
      'lbl_group_sessions_days_field_label';
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
  static const measurementsAddTitle = 'lbl_measurements_add_title';
  static const measurementsMeasurementDateLabel =
      'lbl_measurements_measurement_date_label';
  static const measurementsMeasurementsSection =
      'lbl_measurements_measurements_section';
  static const measurementsUnitCm = 'lbl_measurements_unit_cm';
  static const measurementsTitle = 'lbl_measurements_title';
  static const measurementsSelectedPointLabel =
      'lbl_measurements_selected_point_label';
  static const measurementsHistorySection = 'lbl_measurements_history_section';
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
  static const sessionsCalendarTitle = 'lbl_sessions_calendar_title';
  static const sessionsCalendarSlotTimeLabel =
      'lbl_sessions_calendar_slot_time_label';
  static const sessionsCalendarSlotStatusLabel =
      'lbl_sessions_calendar_slot_status_label';
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
  static const sessionsCompletionTitle = 'lbl_sessions_completion_title';
  static const sessionsCompletionMemberNoShowOption =
      'lbl_sessions_completion_member_no_show_option';
  static const sessionsCompletionUndoButton =
      'lbl_sessions_completion_undo_button';
  static const sessionsListTitle = 'lbl_sessions_list_title';
  static const sessionsListViewToggle = 'lbl_sessions_list_view_toggle';
  static const sessionsCalendarViewToggle = 'lbl_sessions_calendar_view_toggle';
  static const sessionsUpcomingSection = 'lbl_sessions_upcoming_section';
  static const sessionsPastSection = 'lbl_sessions_past_section';
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
  static const trainersCalendarWeekToggle = 'lbl_trainers_calendar_week_toggle';
  static const trainersCalendarMonthToggle =
      'lbl_trainers_calendar_month_toggle';
  static const trainersCalendarMarkCompletedAction =
      'lbl_trainers_calendar_mark_completed_action';
  static const trainersMembersListTitle = 'lbl_trainers_members_list_title';
  static const trainersMembersFilterExpiring =
      'lbl_trainers_members_filter_expiring';
  static const trainersMembersRemainingSessionsSuffix =
      'lbl_trainers_members_remaining_sessions_suffix';
  static const trainersReportTitle = 'lbl_trainers_report_title';
  static const trainersReportEarnedCommissionLabel =
      'lbl_trainers_report_earned_commission_label';
  static const trainersReportDetailLink = 'lbl_trainers_report_detail_link';
  static const trainersReportStartDateFieldLabel =
      'lbl_trainers_report_start_date_field_label';
  static const trainersReportEndDateFieldLabel =
      'lbl_trainers_report_end_date_field_label';
  static const trainersReportOneOnOneToggle =
      'lbl_trainers_report_one_on_one_toggle';
  static const trainersReportGroupToggle = 'lbl_trainers_report_group_toggle';
  static const trainersProfileFooterText = 'lbl_trainers_profile_footer_text';

  // F6-1 abonelik ekranı yeniden tasarımı — 4 durum (deneme/aktif/süresi
  // dolmuş/mağazaya yönlendirildi). `{days}`/`{date}`/`{total}`/`{current}`/
  // `{period}`/`{plan}` yer tutucuları panel tarafında dolduruluyor;
  // `{store}`/`{storeAccount}` ("App Store"/"Apple" ya da "Google Play"/
  // "Google") platforma göre kod içinde sabit — marka adı, iş kuralı değil.
  static const subscriptionTrialBannerTitle = 'lbl_subscription_trial_banner_title';
  static const subscriptionTrialBannerBody = 'lbl_subscription_trial_banner_body';
  static const subscriptionTrialProgress = 'lbl_subscription_trial_progress';
  static const subscriptionExpiredBannerTitle = 'lbl_subscription_expired_banner_title';
  static const subscriptionExpiredBannerBody = 'lbl_subscription_expired_banner_body';
  static const subscriptionRestrictedTitle = 'lbl_subscription_restricted_title';
  static const subscriptionRestrictedNote = 'lbl_subscription_restricted_note';
  static const subscriptionActivePlanLabel = 'lbl_subscription_active_plan_label';
  static const subscriptionActiveBadge = 'lbl_subscription_active_badge';
  static const subscriptionRenewalLabel = 'lbl_subscription_renewal_label';
  static const subscriptionStartedLabel = 'lbl_subscription_started_label';
  static const subscriptionActiveNote = 'lbl_subscription_active_note';
  static const subscriptionStoreRowTitle = 'lbl_subscription_store_row_title';
  static const subscriptionStoreRowSubtitle = 'lbl_subscription_store_row_subtitle';
  static const subscriptionManageCta = 'lbl_subscription_manage_cta';
  static const subscriptionManageCaption = 'lbl_subscription_manage_caption';
  static const subscriptionStoreNote = 'lbl_subscription_store_note';
  static const subscriptionStoreNoteExpired = 'lbl_subscription_store_note_expired';
  static const subscriptionPurchaseCta = 'lbl_subscription_purchase_cta';
  static const subscriptionPurchaseCtaExpired = 'lbl_subscription_purchase_cta_expired';
  static const subscriptionPurchaseCaption = 'lbl_subscription_purchase_caption';
  static const subscriptionPendingBannerTitle = 'lbl_subscription_pending_banner_title';
  static const subscriptionPendingBannerBody = 'lbl_subscription_pending_banner_body';
  static const subscriptionPendingPill = 'lbl_subscription_pending_pill';
  static const subscriptionPendingCta = 'lbl_subscription_pending_cta';
  static const subscriptionPendingCaption = 'lbl_subscription_pending_caption';
  static const subscriptionPendingNote = 'lbl_subscription_pending_note';
  static const subscriptionYearlyBadge = 'lbl_subscription_yearly_badge';
  static const subscriptionYearlySub = 'lbl_subscription_yearly_sub';
  static const subscriptionMonthlySub = 'lbl_subscription_monthly_sub';
  static const subscriptionNoProducts = 'lbl_subscription_no_products';
  /// `[{label_tr, label_en}]` — abonelikte dahil olan özellik listesi.
  static const subscriptionIncludedFeatures = 'cfg_subscription_included_features';
  /// `[{label_tr, label_en}]` — süresi dolduğunda kısıtlanan işlemler.
  static const subscriptionRestrictedOperations = 'cfg_subscription_restricted_operations';
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
  {"id": "membership_6_months", "title_tr": "6 ay üyelik", "title_en": "6-month membership", "note_tr": "6 ay üyeliğini sürdür", "note_en": "Keep your membership for 6 months", "type": "membershipMonths", "threshold": 6}
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
    RemoteConfigKeys.sessionReminderMinutesBefore: 60,
    RemoteConfigKeys.defaultGroupSessionCapacity: 6,
    RemoteConfigKeys.groupSessionLockHoursBefore: 24,
    RemoteConfigKeys.cancellationDeadlineHours: 24,
    RemoteConfigKeys.defaultTrainerReminderDelayMinutes: 30,
    RemoteConfigKeys.defaultOnlineBookingEnabled: true,
    RemoteConfigKeys.defaultAllowSessionsAfterPackageExpiry: false,
    RemoteConfigKeys.defaultMemberCanCancelSession: true,
    RemoteConfigKeys.feedbackReminderDayOfMonth: -1,
    RemoteConfigKeys.freeVersionAdsEnabled: true,
    RemoteConfigKeys.trialDurationDays: 14,
    RemoteConfigKeys.featureFlags: '{"group_sessions_enabled": true}',
    RemoteConfigKeys.badgeCriteria: _defaultBadgeCriteriaJson,
    RemoteConfigKeys.expenseCategories: _defaultExpenseCategoriesJson,
    'lbl_notif_session_reminder_title_tr': '⏰ Bugün {time}\'de dersin var!',
    'lbl_notif_session_reminder_body_tr': '{trainerName} seni bekliyor. Gelip gelmeyeceğini onaylamak için dokun 👇',
    'lbl_notif_session_completion_title_tr': '✅ Dersini onaylar mısın?',
    'lbl_notif_session_completion_body_tr': '{memberName} ile dersin bitti. Tamamlandı mı, yoksa üye gelmedi mi?',
    'lbl_notif_feedback_reminder_title_tr': '💬 Bu ay nasıl geçti?',
    'lbl_notif_feedback_reminder_body_tr': 'Deneyimini bizimle paylaşır mısın? 1 dakikanı alır.',
    'lbl_common_vazgec_tr': 'Vazgeç',
    'lbl_common_kaydet_tr': 'Kaydet',
    'lbl_common_duzenle_tr': 'Düzenle',
    'lbl_common_kapat_tr': 'Kapat',
    'lbl_common_degistir_tr': 'Değiştir',
    'lbl_common_cikis_yap_tr': 'Çıkış yap',
    'lbl_common_hesabimi_sil_tr': 'Hesabımı sil',
    'lbl_common_studyo_kurallari_nav_tr': 'Stüdyo kuralları',
    'lbl_common_seansi_ertele_tr': 'Seansı ertele',
    'lbl_common_gelicem_tr': 'Gelicem',
    'lbl_common_gelmeyecegim_tr': 'Gelmeyeceğim',
    'lbl_common_ana_sayfa_tab_tr': 'Ana Sayfa',
    'lbl_common_profil_tab_tr': 'Profil',
    'lbl_common_telefon_label_tr': 'Telefon',
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
        'Bu numarayla kayıtlı bir hesap bulunamadı. Stüdyo yönetimi seni eklemeli.',
    'lbl_auth_login_error_rate_limited_tr':
        'Çok fazla deneme yapıldı. Bir dakika sonra tekrar dene.',
    'lbl_auth_login_error_generic_tr':
        'Giriş yapılamadı. Bağlantını kontrol edip tekrar dene.',
    'lbl_auth_retry_button_tr': 'Tekrar dene',
    'lbl_auth_delete_account_error_generic_tr':
        'Hesap silinemedi. Bağlantını kontrol edip tekrar dene.',
    'lbl_badges_title_tr': 'Rozetlerim',
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
    'lbl_expenses_list_title_tr': 'Giderler',
    'lbl_expenses_add_expense_button_tr': '+ Gider',
    'lbl_expenses_categories_section_header_tr': 'KATEGORİLER',
    'lbl_expenses_recent_entries_section_header_tr': 'SON KAYITLAR',
    'lbl_expenses_add_title_tr': 'Gider ekle',
    'lbl_expenses_category_field_label_tr': 'Kategori',
    'lbl_expenses_recurring_toggle_label_tr': 'Her ay tekrar et',
    'lbl_expenses_recurring_toggle_description_tr':
        'Kira ve fatura gibi sabit giderler için',
    'lbl_expenses_amount_field_label_tr': 'Tutar (₺)',
    'lbl_expenses_description_field_label_tr': 'Açıklama',
    'lbl_expenses_date_field_label_tr': 'Tarih',
    'lbl_expenses_submit_button_tr': 'Gideri kaydet',
    'lbl_feedback_admin_list_title_tr': 'Geri bildirimler',
    'lbl_feedback_member_form_title_tr': 'Geri bildirim',
    'lbl_feedback_comment_section_header_tr': 'YORUMUN (İSTEĞE BAĞLI)',
    'lbl_group_sessions_admin_list_title_tr': 'Grup dersleri',
    'lbl_group_sessions_add_group_session_button_tr': '+ Grup dersi',
    'lbl_group_sessions_capacity_suffix_label_tr': 'kontenjan',
    'lbl_group_sessions_view_participants_link_tr': 'Katılımcıları gör',
    'lbl_group_sessions_discover_title_tr': 'Keşfet',
    'lbl_group_sessions_discover_tab_group_sessions_tr': 'Grup dersleri',
    'lbl_group_sessions_discover_tab_events_tr': 'Etkinlikler',
    'lbl_group_sessions_create_title_tr': 'Grup dersi oluştur',
    'lbl_group_sessions_days_field_label_tr': 'Günler',
    'lbl_group_sessions_capacity_field_label_tr': 'Kontenjan',
    'lbl_group_sessions_online_booking_toggle_label_tr':
        'Online rezervasyona açık',
    'lbl_group_sessions_online_booking_toggle_description_tr':
        'Üyeler Keşfet\'ten katılabilir',
    'lbl_group_sessions_default_location_label_tr': 'Stüdyo',
    'lbl_group_sessions_name_field_label_tr': 'Ders adı',
    'lbl_group_sessions_start_time_field_label_tr': 'Başlangıç saati',
    'lbl_group_sessions_duration_field_label_tr': 'Süre',
    'lbl_group_sessions_create_submit_button_tr': 'Grup dersini oluştur',
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
    'lbl_gyms_settings_nav_studio_packages_tr': 'Stüdyo paketleri',
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
    'lbl_gyms_studio_rules_title_tr': 'Stüdyo kuralları',
    'lbl_gyms_edit_studio_rules_title_tr': 'Kuralları düzenle',
    'lbl_measurements_add_title_tr': 'Yeni ölçüm',
    'lbl_measurements_measurement_date_label_tr': 'Ölçüm tarihi',
    'lbl_measurements_measurements_section_tr': 'ÖLÇÜLER',
    'lbl_measurements_unit_cm_tr': 'cm',
    'lbl_measurements_title_tr': 'Ölçümlerim',
    'lbl_measurements_selected_point_label_tr': 'Seçili nokta',
    'lbl_measurements_history_section_tr': 'ÖLÇÜM GEÇMİŞİ',
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
    'lbl_notifications_title_tr': 'Bildirim gönder',
    'lbl_notifications_target_question_label_tr': 'Kime gidecek?',
    'lbl_notifications_target_single_member_option_tr': 'Tek üye',
    'lbl_notifications_target_whole_gym_option_tr': 'Tüm salon',
    'lbl_notifications_preview_label_tr': 'Önizleme',
    'lbl_notifications_select_member_button_tr': 'Üye seç',
    'lbl_notifications_title_field_label_tr': 'Başlık',
    'lbl_notifications_message_field_label_tr': 'Mesaj',
    'lbl_packages_list_title_tr': 'Paketler',
    'lbl_packages_add_package_button_tr': '+ Paket ekle',
    'lbl_packages_edit_session_type_field_label_tr': 'Ders tipi',
    'lbl_packages_edit_on_sale_toggle_label_tr': 'Satışta',
    'lbl_packages_edit_on_sale_toggle_description_tr':
        'Kapalıysa yeni üyeliklerde görünmez',
    'lbl_packages_delete_package_button_tr': 'Paketi sil',
    'lbl_packages_edit_name_field_label_tr': 'Paket adı',
    'lbl_packages_edit_validity_days_field_label_tr': 'Geçerlilik (gün)',
    'lbl_packages_edit_price_field_label_tr': 'Fiyat (₺)',
    'lbl_packages_member_package_title_tr': 'Paketim',
    'lbl_packages_remaining_word_tr': 'kalan',
    'lbl_packages_trainer_owner_label_tr': 'Antrenörün',
    'lbl_packages_start_label_tr': 'Başlangıç',
    'lbl_sessions_calendar_title_tr': 'Takvim',
    'lbl_sessions_calendar_slot_time_label_tr': 'Saat',
    'lbl_sessions_calendar_slot_status_label_tr': 'Durum',
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
    'lbl_sessions_completion_title_tr': 'Seans onayı',
    'lbl_sessions_completion_member_no_show_option_tr': 'Üye gelmedi',
    'lbl_sessions_completion_undo_button_tr': 'Geri al',
    'lbl_sessions_list_title_tr': 'Derslerim',
    'lbl_sessions_list_view_toggle_tr': 'Liste',
    'lbl_sessions_calendar_view_toggle_tr': 'Takvim',
    'lbl_sessions_upcoming_section_tr': 'YAKLAŞAN',
    'lbl_sessions_past_section_tr': 'GEÇMİŞ',
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
    'lbl_trainers_calendar_week_toggle_tr': 'Hafta',
    'lbl_trainers_calendar_month_toggle_tr': 'Ay',
    'lbl_trainers_calendar_mark_completed_action_tr': 'Tamamlandı işaretle',
    'lbl_trainers_members_list_title_tr': 'Üyelerim',
    'lbl_trainers_members_filter_expiring_tr': 'Paketi bitiyor',
    'lbl_trainers_members_remaining_sessions_suffix_tr': 'kalan ders',
    'lbl_trainers_report_title_tr': 'Seans raporum',
    'lbl_trainers_report_earned_commission_label_tr': 'Kazanılan prim',
    'lbl_trainers_report_detail_link_tr': 'Detay',
    'lbl_trainers_report_start_date_field_label_tr': 'Başlangıç t.',
    'lbl_trainers_report_end_date_field_label_tr': 'Bitiş t.',
    'lbl_trainers_report_one_on_one_toggle_tr': 'Birebir',
    'lbl_trainers_report_group_toggle_tr': 'Grup',
    'lbl_trainers_profile_footer_text_tr':
        'Egoractive · Egora Games · Sürüm 1.0',
    'lbl_notif_session_reminder_title_en': '⏰ Your session is at {time} today!',
    'lbl_notif_session_reminder_body_en': '{trainerName} is waiting for you. Tap to confirm you\'re coming 👇',
    'lbl_notif_session_completion_title_en': '✅ Can you confirm your session?',
    'lbl_notif_session_completion_body_en': 'Your session with {memberName} has ended. Was it completed, or did they not show up?',
    'lbl_notif_feedback_reminder_title_en': '💬 How was your month?',
    'lbl_notif_feedback_reminder_body_en': 'Would you share your experience with us? It only takes a minute.',
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
    'lbl_auth_login_error_rate_limited_en': 'Too many attempts. Try again in a minute.',
    'lbl_auth_login_error_generic_en': 'Could not log in. Check your connection and try again.',
    'lbl_auth_retry_button_en': 'Try again',
    'lbl_auth_delete_account_error_generic_en':
        'Could not delete account. Check your connection and try again.',
    'lbl_badges_title_en': 'My Badges',
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
    'lbl_expenses_list_title_en': 'Expenses',
    'lbl_expenses_add_expense_button_en': '+ Expense',
    'lbl_expenses_categories_section_header_en': 'CATEGORIES',
    'lbl_expenses_recent_entries_section_header_en': 'RECENT ENTRIES',
    'lbl_expenses_add_title_en': 'Add expense',
    'lbl_expenses_category_field_label_en': 'Category',
    'lbl_expenses_recurring_toggle_label_en': 'Repeat every month',
    'lbl_expenses_recurring_toggle_description_en':
        'For fixed expenses like rent and bills',
    'lbl_expenses_amount_field_label_en': 'Amount (₺)',
    'lbl_expenses_description_field_label_en': 'Description',
    'lbl_expenses_date_field_label_en': 'Date',
    'lbl_expenses_submit_button_en': 'Save expense',
    'lbl_feedback_admin_list_title_en': 'Feedback',
    'lbl_feedback_member_form_title_en': 'Feedback',
    'lbl_feedback_comment_section_header_en': 'YOUR COMMENT (OPTIONAL)',
    'lbl_group_sessions_admin_list_title_en': 'Group Sessions',
    'lbl_group_sessions_add_group_session_button_en': '+ Group Session',
    'lbl_group_sessions_capacity_suffix_label_en': 'capacity',
    'lbl_group_sessions_view_participants_link_en': 'View participants',
    'lbl_group_sessions_discover_title_en': 'Discover',
    'lbl_group_sessions_discover_tab_group_sessions_en': 'Group Sessions',
    'lbl_group_sessions_discover_tab_events_en': 'Events',
    'lbl_group_sessions_create_title_en': 'Create group session',
    'lbl_group_sessions_days_field_label_en': 'Days',
    'lbl_group_sessions_capacity_field_label_en': 'Capacity',
    'lbl_group_sessions_online_booking_toggle_label_en':
        'Open for online booking',
    'lbl_group_sessions_online_booking_toggle_description_en':
        'Members can join from Discover',
    'lbl_group_sessions_default_location_label_en': 'Studio',
    'lbl_group_sessions_name_field_label_en': 'Session name',
    'lbl_group_sessions_start_time_field_label_en': 'Start time',
    'lbl_group_sessions_duration_field_label_en': 'Duration',
    'lbl_group_sessions_create_submit_button_en': 'Create group session',
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
    'lbl_measurements_add_title_en': 'New measurement',
    'lbl_measurements_measurement_date_label_en': 'Measurement date',
    'lbl_measurements_measurements_section_en': 'MEASUREMENTS',
    'lbl_measurements_unit_cm_en': 'cm',
    'lbl_measurements_title_en': 'My Measurements',
    'lbl_measurements_selected_point_label_en': 'Selected point',
    'lbl_measurements_history_section_en': 'MEASUREMENT HISTORY',
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
    'lbl_notifications_title_en': 'Send notification',
    'lbl_notifications_target_question_label_en': 'Who should receive it?',
    'lbl_notifications_target_single_member_option_en': 'Single member',
    'lbl_notifications_target_whole_gym_option_en': 'Whole gym',
    'lbl_notifications_preview_label_en': 'Preview',
    'lbl_notifications_select_member_button_en': 'Select member',
    'lbl_notifications_title_field_label_en': 'Title',
    'lbl_notifications_message_field_label_en': 'Message',
    'lbl_packages_list_title_en': 'Packages',
    'lbl_packages_add_package_button_en': '+ Add package',
    'lbl_packages_edit_session_type_field_label_en': 'Session type',
    'lbl_packages_edit_on_sale_toggle_label_en': 'On sale',
    'lbl_packages_edit_on_sale_toggle_description_en':
        'Hidden from new memberships when off',
    'lbl_packages_delete_package_button_en': 'Delete package',
    'lbl_packages_edit_name_field_label_en': 'Package name',
    'lbl_packages_edit_validity_days_field_label_en': 'Validity (days)',
    'lbl_packages_edit_price_field_label_en': 'Price (₺)',
    'lbl_packages_member_package_title_en': 'My Package',
    'lbl_packages_remaining_word_en': 'remaining',
    'lbl_packages_trainer_owner_label_en': 'Your trainer',
    'lbl_packages_start_label_en': 'Start',
    'lbl_sessions_calendar_title_en': 'Calendar',
    'lbl_sessions_calendar_slot_time_label_en': 'Time',
    'lbl_sessions_calendar_slot_status_label_en': 'Status',
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
    'lbl_sessions_completion_title_en': 'Session confirmation',
    'lbl_sessions_completion_member_no_show_option_en': 'Member didn\'t show',
    'lbl_sessions_completion_undo_button_en': 'Undo',
    'lbl_sessions_list_title_en': 'My Sessions',
    'lbl_sessions_list_view_toggle_en': 'List',
    'lbl_sessions_calendar_view_toggle_en': 'Calendar',
    'lbl_sessions_upcoming_section_en': 'UPCOMING',
    'lbl_sessions_past_section_en': 'PAST',
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
    'lbl_trainers_calendar_week_toggle_en': 'Week',
    'lbl_trainers_calendar_month_toggle_en': 'Month',
    'lbl_trainers_calendar_mark_completed_action_en': 'Mark as completed',
    'lbl_trainers_members_list_title_en': 'My Members',
    'lbl_trainers_members_filter_expiring_en': 'Package expiring',
    'lbl_trainers_members_remaining_sessions_suffix_en': 'remaining sessions',
    'lbl_trainers_report_title_en': 'My session report',
    'lbl_trainers_report_earned_commission_label_en': 'Commission earned',
    'lbl_trainers_report_detail_link_en': 'Detail',
    'lbl_trainers_report_start_date_field_label_en': 'Start',
    'lbl_trainers_report_end_date_field_label_en': 'End',
    'lbl_trainers_report_one_on_one_toggle_en': 'One-on-one',
    'lbl_trainers_report_group_toggle_en': 'Group',
    'lbl_trainers_profile_footer_text_en':
        'Egoractive · Egora Games · Version 1.0',

    RemoteConfigKeys.subscriptionIncludedFeatures: _defaultSubscriptionIncludedFeaturesJson,
    RemoteConfigKeys.subscriptionRestrictedOperations: _defaultSubscriptionRestrictedOperationsJson,
    'lbl_subscription_trial_banner_title_tr': 'Deneme süreniz {days} gün sonra doluyor',
    'lbl_subscription_trial_banner_title_en': 'Your trial ends in {days} days',
    'lbl_subscription_trial_banner_body_tr':
        '{date} tarihine kadar tüm özellikler açık. Bir plan seçerseniz stüdyonuz kesintisiz çalışmaya devam eder.',
    'lbl_subscription_trial_banner_body_en':
        'All features are open until {date}. If you choose a plan, your studio keeps running without interruption.',
    'lbl_subscription_trial_progress_tr': '{total} günlük denemenin {current}. günündesiniz',
    'lbl_subscription_trial_progress_en': "You're on day {current} of your {total}-day trial",
    'lbl_subscription_expired_banner_title_tr': 'Aboneliğiniz {date} tarihinde sona erdi',
    'lbl_subscription_expired_banner_title_en': 'Your subscription ended on {date}',
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
    'lbl_subscription_store_row_title_tr': '{store} üzerinden',
    'lbl_subscription_store_row_title_en': 'Via {store}',
    'lbl_subscription_store_row_subtitle_tr': 'Ödeme ve faturalar {storeAccount} hesabınızda',
    'lbl_subscription_store_row_subtitle_en': 'Payments and invoices are on your {storeAccount} account',
    'lbl_subscription_manage_cta_tr': 'Aboneliği yönet',
    'lbl_subscription_manage_cta_en': 'Manage subscription',
    'lbl_subscription_manage_caption_tr': '{store} abonelik ayarları açılır',
    'lbl_subscription_manage_caption_en': '{store} subscription settings will open',
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
    'lbl_subscription_purchase_cta_expired_tr': "{plan} planı {store}'da başlat",
    'lbl_subscription_purchase_cta_expired_en': 'Start the {plan} plan on {store}',
    'lbl_subscription_purchase_caption_tr': "{store}'da açılır · Satın almayı geri yükle",
    'lbl_subscription_purchase_caption_en': 'Opens in {store} · Restore purchase',
    'lbl_subscription_pending_banner_title_tr': "{store}'a yönlendirildiniz",
    'lbl_subscription_pending_banner_title_en': "You've been redirected to {store}",
    'lbl_subscription_pending_banner_body_tr':
        'Satın almayı mağaza penceresinde tamamlayın; sonucu bu ekrana biz yansıtacağız.',
    'lbl_subscription_pending_banner_body_en':
        'Complete the purchase in the store window; we will reflect the result on this screen.',
    'lbl_subscription_pending_pill_tr': "{store}'da açıldı",
    'lbl_subscription_pending_pill_en': 'Opened in {store}',
    'lbl_subscription_pending_cta_tr': '{store} bekleniyor…',
    'lbl_subscription_pending_cta_en': 'Waiting for {store}…',
    'lbl_subscription_pending_caption_tr': 'Mağaza penceresi kapanınca güncellenir',
    'lbl_subscription_pending_caption_en': 'Updates once the store window closes',
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
    'lbl_subscription_no_products_tr': 'Şu an satın alınabilir bir abonelik ürünü bulunamadı.',
    'lbl_subscription_no_products_en': 'No purchasable subscription product is available right now.',
  };

  /// Şu anki dil — cihazın dilinden okunur. Cihaz dili Türkçe ise 'tr',
  /// diğer tüm diller (İngilizce dahil) için 'en'. Uygulama içi ayrı bir
  /// dil seçici henüz yok.
  String get currentLocale =>
      PlatformDispatcher.instance.locale.languageCode == 'tr' ? 'tr' : 'en';

  /// Ders/seans onay bildiriminin kaç dakika önce gönderileceği.
  int get sessionReminderMinutesBefore =>
      getInt(RemoteConfigKeys.sessionReminderMinutesBefore);

  /// Grup dersi oluştururken varsayılan kontenjan.
  int get defaultGroupSessionCapacity =>
      getInt(RemoteConfigKeys.defaultGroupSessionCapacity);

  /// Grup dersine katılım/ayrılma başlangıca kaç saat kalana kadar açık.
  int get groupSessionLockHoursBefore =>
      getInt(RemoteConfigKeys.groupSessionLockHoursBefore);

  /// Üye/antrenör seansı en fazla kaç saat öncesine kadar iptal edebilir.
  int get cancellationDeadlineHours =>
      getInt(RemoteConfigKeys.cancellationDeadlineHours);

  /// F3-6 — bir salon override yazmadıysa Yetki Ayarları'nın varsayılanları.
  int get defaultTrainerReminderDelayMinutes =>
      getInt(RemoteConfigKeys.defaultTrainerReminderDelayMinutes);

  bool get defaultOnlineBookingEnabled =>
      getBool(RemoteConfigKeys.defaultOnlineBookingEnabled);

  bool get defaultAllowSessionsAfterPackageExpiry =>
      getBool(RemoteConfigKeys.defaultAllowSessionsAfterPackageExpiry);

  bool get defaultMemberCanCancelSession =>
      getBool(RemoteConfigKeys.defaultMemberCanCancelSession);

  /// Aylık geri bildirim hatırlatmasının gönderileceği gün. -1 = ayın son günü.
  int get feedbackReminderDayOfMonth =>
      getInt(RemoteConfigKeys.feedbackReminderDayOfMonth);

  /// Ücretsiz sürümde reklam gösterilsin mi.
  bool get freeVersionAdsEnabled =>
      getBool(RemoteConfigKeys.freeVersionAdsEnabled);

  /// F6-3 — yeni salonlara tanınan ücretsiz deneme süresi (gün).
  int get trialDurationDays => getInt(RemoteConfigKeys.trialDurationDays);

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

  /// `lbl*` metinlerini okur: `<key>_<currentLocale>` parametresini getirir.
  /// Kod içinde `_tr`/`_en` asla elle yazılmaz, bu metod ekler.
  String getText(String baseKey) => getString('${baseKey}_$currentLocale');

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

  List<Map<String, dynamic>> _getJsonList(String key) {
    final raw = getString(key);
    if (raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded.whereType<Map<String, dynamic>>().toList() : const [];
    } on FormatException {
      return const [];
    }
  }
}

@Riverpod(keepAlive: true)
RemoteConfigService remoteConfigService(RemoteConfigServiceRef ref) =>
    const RemoteConfigService();
