import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../controller/partner_gyms_controller.dart';
import '../../domain/partner_gym.dart';

/// Ortak 1a · Anlaşmalı Salonlar — [OnboardingRolePanel]'den girişten önce
/// açılan, tüm salonların (`listPartnerGyms` callable'ı üzerinden, auth
/// gerektirmeden) listelendiği panel.
class PartnerGymsPanel extends BasePanel {
  const PartnerGymsPanel({super.key});

  @override
  ConsumerState<PartnerGymsPanel> createState() => _PartnerGymsPanelState();
}

class _PartnerGymsPanelState extends BasePanelState<PartnerGymsPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final gymsAsync = ref.watch(partnerGymsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(
                      onTap: () =>
                          ref.read(panelStackControllerProvider.notifier).pop(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.partnerGymsTitle),
                    ),
                    style: typography.headingLarge.copyWith(
                      color: colors.onSurface,
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: gymsAsync.when(
                loading: () => const Center(child: AppLoadingIndicator()),
                error: (error, stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenEdge,
                    ),
                    child: Text(
                      ref.watch(
                        rcTextProvider(RemoteConfigKeys.partnerGymsError),
                      ),
                      textAlign: TextAlign.center,
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                  ),
                ),
                data: (gyms) => gyms.isEmpty
                    ? Center(
                        child: Text(
                          ref.watch(
                            rcTextProvider(RemoteConfigKeys.partnerGymsEmpty),
                          ),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenEdge,
                          0,
                          AppSpacing.screenEdge,
                          AppSpacing.lg,
                        ),
                        itemCount: gyms.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) =>
                            _PartnerGymCard(gym: gyms[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartnerGymCard extends StatelessWidget {
  const _PartnerGymCard({required this.gym});

  final PartnerGym gym;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final locationLabel = [
      gym.address,
      gym.city,
    ].where((part) => part.trim().isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            ),
            alignment: Alignment.center,
            child: gym.logoUrl.isEmpty
                ? Icon(
                    Icons.fitness_center_rounded,
                    color: colors.onPrimaryContainer,
                    size: 24,
                  )
                : CachedNetworkImage(
                    imageUrl: gym.logoUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Icon(
                      Icons.fitness_center_rounded,
                      color: colors.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gym.name,
                  style: typography.headingSmall.copyWith(
                    color: colors.onSurface,
                    fontSize: 17,
                  ),
                ),
                if (locationLabel.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 15,
                        color: colors.onSurfaceMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationLabel,
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (gym.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.call_outlined,
                        size: 15,
                        color: colors.onSurfaceMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        gym.phone,
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
