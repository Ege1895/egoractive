import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egoractive/main.dart';

void main() {
  testWidgets('Shows Hello Egoractive on launch', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: EgoractiveApp()),
    );

    expect(find.text('Hello Egoractive'), findsOneWidget);
  });
}
