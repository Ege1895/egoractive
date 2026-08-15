import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/subscription/controller/subscription_controller.dart';
import '../../modules/subscription/domain/subscription_state.dart';
import '../../modules/subscription/ui/panels/subscription_panel.dart';
import '../constants/app_spacing.dart';
import '../panels/panel_stack_controller.dart';
import '../theme/app_theme.dart';

/// F6-3 — admin'in hangi sekmede olursa olsun salonun aboneliğinin sona
/// erdiğini FARK ETMESİ için `AppTabShell.topBanner`'a yerleştirilen sabit,
/// kapatılamayan şerit. `subscription_write_gate.dart`'taki dialog sadece bir
/// yazma denemesinde tetiklenir — bu banner ise sorunun varlığını her an
/// görünür kılar. Sadece `status == expired` iken gösterilir; `none`
/// [SubscriptionState]'in ilk yüklenme (henüz Firestore'dan veri gelmemiş)
/// varsayılanı olduğu için kasıtlı olarak dışarıda tutuldu — aksi halde her
/// açılışta bir anlığına yanlış "süresi doldu" uyarısı yanıp sönerdi.
class SubscriptionStatusBanner extends ConsumerWidget {
  const SubscriptionStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(subscriptionControllerProvider).status;
    if (status != SubscriptionStatus.expired) return const SizedBox.shrink();

    final colors = context.appColors;
    final typography = context.appTypography;

    return Material(
      color: colors.errorContainer,
      child: InkWell(
        onTap: () => ref.read(panelStackControllerProvider.notifier).push(const SubscriptionPanel()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: colors.error, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Aboneliğinin süresi doldu — yeni işlem yapabilmek için yenile.',
                  style: typography.bodyMedium.copyWith(color: colors.error, fontSize: 13),
                ),
              ),
              Icon(Icons.chevron_right, color: colors.error, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
