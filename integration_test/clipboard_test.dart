import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:feeling_finder/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('notify when copy to clipboard finished', (tester) async {
    // Launch the app.
    app.main();
    await tester.pumpAndSettle();

    // Verify there is no notification shown at start.
    expect(find.byType(SnackBar), findsNothing);

    // Find an emoji to tap on.
    final emojiWidget = find.text('😃');

    // Emulate a tap on the emoji.
    await tester.tap(emojiWidget);

    // Trigger a frame, long enough for the SnackBar to have been triggered.
    await tester.pump(const Duration(milliseconds: 50));

    // Verify a SnackBar notification is shown.
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
