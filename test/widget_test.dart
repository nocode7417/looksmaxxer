// Basic Flutter widget test for Looksmaxxer app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:looksmaxxer/app.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LooksmaxxerApp(),
      ),
    );

    // Verify the app loads without errors
    expect(find.byType(LooksmaxxerApp), findsOneWidget);
  });
}
