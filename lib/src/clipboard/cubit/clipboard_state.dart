part of 'clipboard_cubit.dart';

/// Holds state relating to the clipboard functionality.
@immutable
class ClipboardState {
  final String? copiedEmoji;

  const ClipboardState({
    this.copiedEmoji,
  });

  ClipboardState copyWith({
    String? copiedEmoji,
  }) {
    return ClipboardState(
      copiedEmoji: copiedEmoji ?? this.copiedEmoji,
    );
  }
}
