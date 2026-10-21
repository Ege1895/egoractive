import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/remote_config/remote_config_service.dart';
import 'package:egoractive/core/theme/app_color_scheme.dart';
import 'package:egoractive/core/theme/app_theme.dart';
import 'package:egoractive/core/theme/app_typography.dart';
import 'package:egoractive/modules/subscription/ui/widgets/subscription_products_unavailable.dart';

void main() {
  testWidgets('mağaza planları alınamayınca hata ve tekrar dene gösterir', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          for (final key in [
            RemoteConfigKeys.subscriptionProductsUnavailableTitle,
            RemoteConfigKeys.subscriptionProductsUnavailableBody,
            RemoteConfigKeys.subscriptionProductsRetry,
          ])
            rcTextProvider(key).overrideWithValue(key),
        ],
        child: MaterialApp(
          theme: AppTheme.build(
            colors: AppColorScheme.defaultScheme(),
            typography: AppTypography.standard(),
          ),
          home: Scaffold(
            body: SubscriptionProductsUnavailable(onRetry: () => retries++),
          ),
        ),
      ),
    );

    expect(
      find.text(RemoteConfigKeys.subscriptionProductsUnavailableTitle),
      findsOneWidget,
    );
    expect(
      find.text(RemoteConfigKeys.subscriptionProductsUnavailableBody),
      findsOneWidget,
    );

    await tester.tap(find.text(RemoteConfigKeys.subscriptionProductsRetry));
    expect(retries, 1);
  });
}
