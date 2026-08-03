import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import 'phone_login_panel.dart';

/// Ortak 1 · Splash — logo + oturum kontrolü simülasyonu.
///
/// F1-10'da gerçek oturum kontrolüne (mevcut Firebase Auth oturumu var mı?)
/// bağlanınca burada rol bazlı shell'e ya da giriş ekranına yönlenecek;
/// şimdilik doğrudan [PhoneLoginPanel]'e geçiyor.
class SplashPanel extends BasePanel {
  const SplashPanel({super.key});

  @override
  ConsumerState<SplashPanel> createState() => _SplashPanelState();
}

class _SplashPanelState extends BasePanelState<SplashPanel> {
  Timer? _sessionCheckTimer;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Image.asset('assets/images/egora-logo.png'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Egoractive',
                  style: typography.headingMedium.copyWith(
                    color: colors.onSurface,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Spor salonu yönetimi',
                  style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dot(color: colors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    _Dot(color: colors.primary.withValues(alpha: 0.45)),
                    const SizedBox(width: AppSpacing.sm),
                    _Dot(color: colors.onSurfaceMuted.withValues(alpha: 0.3)),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 56,
            child: Center(
              child: Text(
                'Egora Games',
                style: typography.caption.copyWith(color: colors.onSurfaceMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onPanelShow() {
    _sessionCheckTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      ref.read(panelStackControllerProvider.notifier).replaceRoot(const PhoneLoginPanel());
    });
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    super.dispose();
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
