/// Disabling because:
/// 
/// 1. Keeps throwing an exception:
/// ```
/// _AssertionError ('dart:ui/painting.dart': Failed assertion: line 50 pos 10: 
/// '<optimized out>': Matrix4 entries must be finite.)
/// ```
/// 
/// 2. Integration tests don't work on headless (GitHub) testing environments.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';

// import 'package:feeling_finder/main.dart' as app;

// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();

//   testWidgets('notify when copy to clipboard finished', (tester) async {
//     // Launch the app.
//     app.main();
//     await tester.pumpAndSettle();

//     // Verify there is no notification shown at start.
//     expect(find.byType(SnackBar), findsNothing);

//     // Find the 'All' category button.
//     // We want to switch from 'Recent' if needs be for the test.
//     final categoryButton = find.text('All');

//     // Switch to the 'All' category.
//     await tester.tap(categoryButton);

//     // Ensure the transition to the new category has completed.
//     await tester.pumpAndSettle();

//     // Find an emoji to tap on.
//     final emojiWidget = find.text('😃');

//     // Emulate a tap on the emoji.
//     await tester.tap(emojiWidget);

//     // Trigger a frame, long enough for the SnackBar to have been triggered.
//     await tester.pump(const Duration(milliseconds: 50));

//     // Verify a SnackBar notification is shown.
//     expect(find.byType(SnackBar), findsOneWidget);
//   });
// }
