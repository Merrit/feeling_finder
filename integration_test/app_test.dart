import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:feeling_finder/main.dart' as app;

/// Configure the test device.
void setDeviceProperties(WidgetTester tester) {
  // Default surface size is quite small and causes the appbar to overflow.
  // Set the surface size to a more reasonable size.
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
}

Future<ClipboardData?> getClipboardData() async =>
    await Clipboard.getData('text/plain');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('basic usage', (tester) async {
    setDeviceProperties(tester);

    // Launch the app.
    app.main([]);
    await tester.pumpAndSettle();

    // Verify there is no notification shown at start.
    expect(find.byType(SnackBar), findsNothing);

    // Find the 'Smileys & Emotion' category button.
    // We want to switch from 'Recent' if needs be for the test.
    final categoryButton = find.text('Smileys & Emotion');

    // Switch to the 'Smileys & Emotion' category.
    await tester.tap(categoryButton);

    // Ensure the transition to the new category has completed.
    await tester.pumpAndSettle();

    // Verify the emoji we want to copy is not in the clipboard.
    ClipboardData? clipboardData = await getClipboardData();
    expect(clipboardData?.text, isNot('😃'));

    // Find an emoji to tap on.
    final emojiWidget = find.text('😃');

    // Emulate a tap on the emoji.
    await tester.tap(emojiWidget);

    // Trigger a frame, long enough for the SnackBar to have been triggered.
    await tester.pump(const Duration(milliseconds: 50));

    // Verify a SnackBar notification is shown.
    expect(find.byType(SnackBar), findsOneWidget);

    // Verify the target emoji was copied to the clipboard.
    clipboardData = await getClipboardData();
    expect(clipboardData?.text, '😃');
  });
}
