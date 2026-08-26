import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../packages/controller/package_controller.dart';
import '../../controller/auth_controller.dart';

List<String> _deleteItems(WidgetRef ref, int remainingSessions) => [
  ref
      .watch(
        rcTextProvider(RemoteConfigKeys.authDeleteAccountItemRemainingSessions),
      )
      .replaceAll('{count}', '$remainingSessions'),
  ref.watch(
    rcTextProvider(RemoteConfigKeys.authDeleteAccountItemMeasurementsBadges),
  ),
  ref.watch(rcTextProvider(RemoteConfigKeys.authDeleteAccountItemFeedback)),
];

/// Ortak 4 · Hesap Silme Onayı — geri dönüşü olmadığını vurgulayan, çift
/// onaylı (işaret kutusu + kırmızı buton) silme akışı.
class DeleteAccountConfirmPanel extends BasePanel {
  const DeleteAccountConfirmPanel({super.key});

  @override
  ConsumerState<DeleteAccountConfirmPanel> createState() =>
      _DeleteAccountConfirmPanelState();
}

class _DeleteAccountConfirmPanelState
    extends BasePanelState<DeleteAccountConfirmPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final remainingSessions = ref
        .watch(packageControllerProvider)
        .remainingSessions;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  64,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.authDeleteAccountConfirmTitle,
                        ),
                      ),
                      style: typography.headingLarge.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _GhostBlock(height: 120),
                    const SizedBox(height: AppSpacing.lg),
                    const _GhostBlock(height: 190),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.72)),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.lg,
                AppSpacing.screenEdge,
                AppSpacing.xxl,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border(
                  top: BorderSide(color: colors.error.withValues(alpha: 0.35)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colors.outlineStrong,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.watch(
                          rcTextProvider(
                            RemoteConfigKeys.authDeleteAccountConfirmHeading,
                          ),
                        ),
                        style: typography.headingMedium.copyWith(
                          color: colors.onSurface,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        ref
                            .watch(
                              rcTextProvider(
                                RemoteConfigKeys.authDeleteAccountConfirmBody,
                              ),
                            )
                            .replaceAll('{count}', '$remainingSessions'),
                        style: typography.bodyLarge.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final item in _deleteItems(ref, remainingSessions))
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xs,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.only(top: 7),
                                  decoration: BoxDecoration(
                                    color: colors.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: typography.bodyMedium.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _AcknowledgeCheckbox(
                    checked: authState.deleteAccountAcknowledged,
                    onTap: authController.toggleDeleteAcknowledged,
                  ),
                  if (authState.deleteAccountErrorMessage != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      authState.deleteAccountErrorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _DangerButton(
                    label: authState.isDeletingAccount
                        ? ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .authDeleteAccountInProgressButton,
                            ),
                          )
                        : ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonHesabimiSil),
                          ),
                    enabled:
                        authState.deleteAccountAcknowledged &&
                        !authState.isDeletingAccount,
                    // Başarılıysa girişe dönüş burada elle yapılmıyor —
                    // `deleteAccount()` zaten sonunda signOut() çağırıyor,
                    // `main.dart`'taki merkezi `appAccessProvider` dinleyicisi
                    // auth state null olunca `PhoneLoginPanel`'e geçiyor (iki
                    // ayrı `replaceRoot` çağrısının yarışa girmesini önlemek
                    // için — bkz. `profile_panel.dart`'taki aynı düzeltme).
                    onPressed: () => authController.deleteAccount(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: ref.watch(
                      rcTextProvider(RemoteConfigKeys.commonVazgec),
                    ),
                    variant: AppButtonVariant.text,
                    onPressed: () =>
                        ref.read(panelStackControllerProvider.notifier).pop(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostBlock extends StatelessWidget {
  const _GhostBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
    );
  }
}

class _AcknowledgeCheckbox extends StatelessWidget {
  const _AcknowledgeCheckbox({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.primaryActionHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            border: Border.all(
              color: checked
                  ? colors.error.withValues(alpha: 0.55)
                  : colors.outlineStrong,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: checked ? colors.error : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: checked ? colors.error : colors.outlineStrong,
                  ),
                ),
                child: checked
                    ? Icon(Icons.check, size: 16, color: colors.background)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) => Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.authDeleteAccountAcknowledgeLabel,
                      ),
                    ),
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yıkıcı eylemler için tek kullanımlık kırmızı buton — [AppButton]'ın 3
/// varyantına (primary/secondary/text) yeni bir varyant eklemek yerine,
/// bu tek ekrana özgü tutuldu.
class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Material(
      color: enabled ? colors.error : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: enabled ? () => onPressed() : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: AppSpacing.primaryActionHeight,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: typography.headingSmall.copyWith(
              fontSize: 15,
              color: enabled ? colors.background : colors.onSurfaceMuted,
            ),
          ),
        ),
      ),
    );
  }
}
