import 'package:flutter/material.dart';

import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/measurement_metric.dart';
import '../../domain/measurement_point.dart';

const _boxWidth = 362.0;
const _boxHeight = 478.0;
const _imgWidth = 268.0;
const _imgHeight = 372.0;
const _imgX = (_boxWidth - _imgWidth) / 2;
const _imgY = 48.0;
const _lane = 84.0;

/// Egoractive'in imza görsel öğesi — silüet üzerindeki tıklanabilir
/// ölçüm noktaları (nokta-küme motifi, logodaki "o" harfinden geliyor).
class MeasurementAvatar extends StatelessWidget {
  const MeasurementAvatar({
    required this.points,
    required this.selected,
    required this.onSelect,
    this.gender,
    super.key,
  });

  final Map<MeasurementMetric, MeasurementPoint> points;
  final MeasurementMetric selected;
  final ValueChanged<MeasurementMetric> onSelect;

  /// `users/{uid}.gender` ham değeri ('erkek' | 'kadin' | null). Bilinmiyorsa
  /// kadın silüeti gösterilir (önceki sabit davranışla aynı varsayılan).
  final String? gender;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final asset = gender == 'erkek'
        ? 'assets/images/silhouette-erkek.png'
        : 'assets/images/silhouette-kadin.png';

    return SizedBox(
      width: _boxWidth,
      height: _boxHeight,
      child: Stack(
        children: [
          Positioned(
            left: _imgX,
            top: _imgY,
            width: _imgWidth,
            height: _imgHeight,
            child: Opacity(
              opacity: 0.92,
              child: Image.asset(asset, fit: BoxFit.contain),
            ),
          ),
          // avatarLayout TÜM metrikler için sabit bir konum tanımlar —
          // henüz hiç ölçülmemiş bir metrik için de bir dokunma hedefi
          // çizilir (ilk ölçümü eklemek üzere), sadece etiketi farklıdır.
          for (final entry in avatarLayout.entries)
            ..._buildPointLayer(
              context,
              metric: entry.key,
              layout: entry.value,
              point: points[entry.key],
              active: entry.key == selected,
              colors: colors,
            ),
        ],
      ),
    );
  }

  List<Widget> _buildPointLayer(
    BuildContext context, {
    required MeasurementMetric metric,
    required ({double fx, double fy, AvatarSide side}) layout,
    required MeasurementPoint? point,
    required bool active,
    required AppColorScheme colors,
  }) {
    final x = _imgX + layout.fx * _imgWidth;
    final y = _imgY + layout.fy * _imgHeight;
    final isLeft = layout.side == AvatarSide.left;
    final typography = context.appTypography;
    final label = point == null
        ? '${metric.label} ekle'
        : '${metric.label} ${point.value}';

    return [
      Positioned(
        top: y,
        left: isLeft ? _lane : null,
        right: isLeft ? null : _lane,
        width: isLeft ? (_boxWidth - x - 16 - _lane) : (x - 16 - _lane),
        child: Container(
          height: 1,
          color: active
              ? colors.primary.withValues(alpha: 0.7)
              : colors.outlineStrong,
        ),
      ),
      Positioned(
        top: y - 14,
        left: isLeft ? 0 : null,
        right: isLeft ? null : 0,
        child: GestureDetector(
          onTap: () => onSelect(metric),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: active ? colors.primary : colors.surfaceRaised,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active ? colors.primary : colors.outlineStrong,
              ),
            ),
            child: Text(
              label,
              style: typography.dataSmall.copyWith(
                fontSize: 13,
                color: active ? colors.onPrimary : colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: x - 22,
        top: y - 22,
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () => onSelect(metric),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: active ? 32 : 20,
                  height: active ? 32 : 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? colors.primaryContainer
                        : Colors.transparent,
                    border: Border.all(
                      color: active ? colors.primary : colors.outlineStrong,
                    ),
                  ),
                ),
                Container(
                  width: active ? 12 : 8,
                  height: active ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? colors.primary : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}
