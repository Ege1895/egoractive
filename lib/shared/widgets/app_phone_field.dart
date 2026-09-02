import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/remote_config/remote_config_service.dart';
import '../../core/theme/app_theme.dart';
import 'app_phone_field_prefs.dart';

/// F8-5 sonrası bulundu — ülke seçici, kendi `CountrySelectorNavigator`'ının
/// `show()`'unu doğrudan `CountryButton.onTap`'inden çağırıyor
/// (`phone_form_field` paketi içinde, bize açık bir hook vermiyor); sheet
/// açılırken numara alanının klavyesi açık kalıyordu. Gerçek navigator'ı
/// SARIP `show()`'dan hemen önce klavyeyi kapatan ince bir decorator.
/// `FocusScope.of(context).unfocus()` burada İŞE YARAMIYOR (widget testiyle
/// doğrulandı — `context`'in scope'u beklenenden farklı bir ata scope'a
/// çözülüyor olmalı); doğrudan `FocusManager.instance.primaryFocus` üzerinden
/// gitmek scope çözümlemesinden bağımsız, her zaman çalışıyor.
class _KeyboardDismissingCountrySelectorNavigator
    extends CountrySelectorNavigator {
  const _KeyboardDismissingCountrySelectorNavigator(this._inner)
    : super(searchAutofocus: false);

  final CountrySelectorNavigator _inner;

  @override
  Future<IsoCode?> show(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    return _inner.show(context);
  }
}

/// F8-5 — bir telefon girişi başlatılırken kullanılacak varsayılan değer.
/// [existingE164] doluysa (düzenlenen bir kayıt) onu kullanır; boşsa (yeni
/// bir giriş) kullanıcının EN SON seçtiği ülkeyle (bkz. `AppPhoneFieldPrefs`)
/// boş bir numara döner — hiçbir kayıt yoksa TR'ye düşer. Bu uygulamadaki
/// TÜM `PhoneController` kuruluş noktalarında hardcoded `'+90'` yerine
/// kullanılmalı.
PhoneNumber initialPhoneNumber([String? existingE164]) {
  if (existingE164 != null && existingE164.isNotEmpty) {
    return PhoneNumber.parse(existingE164);
  }
  final lastIso = AppPhoneFieldPrefs.lastCountryIso;
  return PhoneNumber(
    isoCode: lastIso == null ? IsoCode.TR : IsoCode.values.byName(lastIso),
    nsn: '',
  );
}

/// F8-1/F8-2 — global telefon numarası desteği. `AppTextField`'ın görsel
/// dilini (surfaceRaised zemin, kenarlıksız/odakta primary halka)
/// `PhoneFormField` üzerine taşıyan ortak bileşen. Varsayılan ülke TR;
/// `onChanged` numara değiştikçe E.164 (`+905324187605`) + bölgesel
/// doğrulama sonucuyla (`PhoneNumber.isValid()`) tetiklenir. Ülke seçici her
/// kullanımda seçilen ülkeyi (`AppPhoneFieldPrefs`) hatırlar — bir sonraki
/// YENİ girişte (bkz. [initialPhoneNumber]) oradan başlar.
class AppPhoneField extends ConsumerWidget {
  const AppPhoneField({
    this.controller,
    this.label,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    super.key,
  });

  final PhoneController? controller;
  final String? label;
  final String? errorText;
  final bool enabled;

  /// Numara değiştikçe E.164 (`PhoneNumber.international`) ve o numaranın
  /// seçili ülke için geçerli olup olmadığıyla (`PhoneNumber.isValid()`)
  /// tetiklenir.
  final void Function(String e164, bool isValid)? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final radius = BorderRadius.circular(AppSpacing.radiusInner);
    final searchHint = ref.watch(
      rcTextProvider(RemoteConfigKeys.commonPhoneCountrySearchHint),
    );

    return PhoneFormField(
      controller: controller,
      initialValue: controller == null ? initialPhoneNumber() : null,
      enabled: enabled,
      countrySelectorNavigator: _KeyboardDismissingCountrySelectorNavigator(
        CountrySelectorNavigator.bottomSheet(
          searchBoxDecoration: InputDecoration(
            hintText: searchHint,
            prefixIcon: const Icon(Icons.search, size: 24),
            filled: true,
            isDense: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      countryButtonStyle: const CountryButtonStyle(
        showDialCode: true,
        showIsoCode: false,
      ),
      style: typography.bodyLarge.copyWith(color: colors.onSurface),
      onChanged: (phoneNumber) {
        AppPhoneFieldPrefs.setLastCountryIso(phoneNumber.isoCode.name);
        onChanged?.call(phoneNumber.international, phoneNumber.isValid());
      },
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        labelStyle: typography.bodyLarge.copyWith(
          color: colors.onSurfaceVariant,
        ),
        hintStyle: typography.bodyLarge.copyWith(color: colors.onSurfaceMuted),
        filled: true,
        fillColor: colors.surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
      ),
    );
  }
}
