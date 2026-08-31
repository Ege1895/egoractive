import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/onboarding/onboarding_prefs.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'onboarding_role_panel.dart';
import 'phone_login_panel.dart';

/// Ortak 1 · Splash — logo + oturum kontrolü simülasyonu.
///
/// Burada aktif bir Firebase Auth oturumu varsa `main.dart`'taki
/// `appAccessProvider` dinleyicisi zaten devreye girip ilgili role/duruma
/// yönlendirir (bu ekranın timer'ı geçersiz kılınır). Oturum yoksa bu timer
/// [OnboardingPrefs.hasCompletedFirstLogin]'e bakar: cihazda HİÇ tamamlanmış
/// bir girişi yoksa (gerçek ilk kurulum, ya da rol seçilip telefon/salon
/// kurulumu yarıda bırakılmış olması) [OnboardingRolePanel]'e ("antrenör
/// müsün, üye misin?") geçer; aksi halde (daha önce en az bir kez başarıyla
/// giriş yapılmış — ör. kullanıcı çıkış yapıp uygulamayı kapatıp açtı)
/// doğrudan [PhoneLoginPanel]'e gider. Bayrak BURADA değil, `appAccess`'te
/// (`role != null` olduğu an) işaretlenir — aksi halde rol seçilip giriş
/// tamamlanmadan uygulama kapatılırsa kullanıcı bu ekranı bir daha
/// GÖREMEZDİ (bkz. F8-5 sonrası bulunan gerçek hata).
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'assets/images/egora-logo.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  ref.watch(rcTextProvider(RemoteConfigKeys.authSplashTitle)),
                  style: typography.headingMedium.copyWith(
                    color: colors.onSurface,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ref.watch(rcTextProvider(RemoteConfigKeys.authSplashTagline)),
                  style: typography.bodyMedium.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
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
                ref.watch(rcTextProvider(RemoteConfigKeys.authSplashPublisher)),
                style: typography.caption.copyWith(
                  color: colors.onSurfaceMuted,
                ),
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
      final panelStack = ref.read(panelStackControllerProvider.notifier);
      if (OnboardingPrefs.hasCompletedFirstLogin) {
        panelStack.replaceRoot(const PhoneLoginPanel());
      } else {
        panelStack.replaceRoot(const OnboardingRolePanel());
      }
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
