import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// "Kalan ders" göstergesi gibi ortasında sayı olan dairesel ilerleme
/// halkası. Tasarımdaki çok renkli tek-border-per-side hilesi Flutter'da
/// `BoxShape.circle` ile birlikte desteklenmediği için (yalnızca tek renk
/// kabul eder) [CircularProgressIndicator] üzerine bindirildi.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.size,
    required this.progress,
    required this.child,
    super.key,
  });

  final double size;
  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1,
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(colors.outline),
          ),
          CircularProgressIndicator(
            value: progress.clamp(0, 1),
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
          child,
        ],
      ),
    );
  }
}
