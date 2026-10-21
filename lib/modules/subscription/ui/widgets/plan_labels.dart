import '../../../../core/remote_config/remote_config_service.dart';
import '../../domain/subscription_state.dart';

/// Plan kartlarında fiyatın altında gösterilen satır. Apple 3.1.2(c),
/// satın alma noktasında aboneliğin SÜRESİNİN açıkça görünmesini istiyor;
/// bu yüzden satır her zaman yenilenme dönemiyle başlar ("Yıllık
/// yenilenir"), ardından varsa deneme süresi ya da yıllık avantaj gelir.
String planSubLabel(
  SubscriptionProduct product, {
  required bool isYearly,
  required RemoteConfigService rc,
  required String locale,
}) {
  final period = rc.getText(
    isYearly
        ? RemoteConfigKeys.subscriptionPeriodYearly
        : RemoteConfigKeys.subscriptionPeriodMonthly,
    locale,
  );
  final days = product.trialDays;
  final extra = days != null
      ? rc
            .getText(RemoteConfigKeys.subscriptionTrialSubLabel, locale)
            .replaceAll('{days}', '$days')
      : isYearly
      ? rc.getText(RemoteConfigKeys.subscriptionYearlySub, locale)
      : null;
  return extra == null ? period : '$period · $extra';
}
