import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// "Kalan ders"/"tamamlanan" gibi ortasında sayı olan dairesel ilerleme
/// halkası. `CustomPainter` ile çiziliyor (önceki sürüm iki
/// [CircularProgressIndicator]'ı üst üste bindiriyordu — arka plan rengi
/// kart zeminiyle neredeyse aynı tonda olduğundan boş kısım görünmüyor,
/// halka değil kartın üstünde küçük bir yay gibi duruyordu).
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.size,
    required this.progress,
    required this.child,
    this.strokeWidth,
    super.key,
  });

  final double size;
  final double progress;
  final Widget child;

  /// Verilmezse boyuta oranlı (size'ın ~%11'i) hesaplanır — farklı
  /// `size`larda kullanılan tüm ekranlarda (admin ana sayfa, üye ana
  /// sayfası, paket detayı) tutarlı, premium bir kalınlık için.
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProgressRingPainter(
          progress: progress.clamp(0.0, 1.0),
          strokeWidth: strokeWidth ?? size * 0.11,
          trackColor: colors.outlineStrong,
          progressColor: colors.primary,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  static const _startAngle = -math.pi / 2; // Saat 12 yönü.

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;

    // Hafif, kontrollü bir glow — abartılı neon efekti değil, sadece
    // ilerleme yayının etrafında yumuşak bir parlaklık.
    canvas.drawArc(
      rect,
      _startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = progressColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawArc(
      rect,
      _startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
