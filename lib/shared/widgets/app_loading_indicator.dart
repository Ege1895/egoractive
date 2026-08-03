import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// CLAUDE.md §2.4 bileşen kütüphanesi — tüm yükleniyor durumlarında
/// kullanılan tek gösterge.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({this.size = 28, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation(context.appColors.primary),
      ),
    );
  }
}
