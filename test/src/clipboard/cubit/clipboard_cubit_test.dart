import 'package:feeling_finder/src/clipboard/cubit/clipboard_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ClipboardCubit clipboardCubit;

  setUpAll(() {
    clipboardCubit = ClipboardCubit();
  });

  test('setClipboardContents(), then copiedEmoji value has changed', () async {
    // Verify value is null to start.
    expect(clipboardCubit.state.copiedEmoji, isNull);

    // Call the method that should change the copiedEmoji variable.
    await clipboardCubit.setClipboardContents('😶‍🌫️');

    // Verify the variable has been updated.
    expect(clipboardCubit.state.copiedEmoji, '😶‍🌫️');
  });
}
