import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../clipboard_service.dart';

part 'clipboard_state.dart';

/// Convenient global access to the ClipboardCubit.
///
/// There is only ever 1 instance of this cubit, and having this variable
/// means not having to do `context.read<ClipboardCubit>()` to access it every
/// time, as well as making it available without a BuildContext.
late ClipboardCubit clipboardCubit;

/// Manages the state and interations related to the clipboard.
class ClipboardCubit extends Cubit<ClipboardState> {
  ClipboardCubit()
      : super(
          const ClipboardState(),
        ) {
    clipboardCubit = this;
  }

  /// Set the clipboard contents to [value].
  Future<void> setClipboardContents(String value) async {
    await ClipboardService.setClipboardContents(value);
    emit(state.copyWith(copiedEmoji: value));
  }
}
