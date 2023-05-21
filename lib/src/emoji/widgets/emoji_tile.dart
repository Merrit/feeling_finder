import 'package:flutter/material.dart';

import '../cubit/emoji_cubit.dart';
import '../emoji.dart';
import '../emoji_category.dart';
import '../styles.dart';

/// Widget that displays an emoji.
class EmojiTile extends StatefulWidget {
  final Emoji emoji;
  final int index;

  const EmojiTile(
    this.emoji,
    this.index, {
    Key? key,
  }) : super(key: key);

  @override
  State<EmojiTile> createState() => _EmojiTileState();
}

class _EmojiTileState extends State<EmojiTile> {
  final focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Decoration? hasVariantsIndicator;
    if (widget.emoji.variants != null &&
        widget.emoji.variants!.isNotEmpty &&
        emojiCubit.state.category != EmojiCategory.recent) {
      hasVariantsIndicator = _TriangleDecoration();
    } else {
      hasVariantsIndicator = null;
    }

    return Center(
      child: Container(
        decoration: hasVariantsIndicator,
        child: Tooltip(
          waitDuration: const Duration(milliseconds: 400),
          richMessage: TextSpan(
            text: widget.emoji.description,
            style: const TextStyle(fontSize: 12),
          ),
          child: MouseRegion(
            onEnter: (_) => focusNode.requestFocus(),
            onExit: (_) => focusNode.unfocus(),
            child: InkWell(
              focusNode: focusNode,
              autofocus: (widget.index == 0) ? true : false,
              focusColor: Colors.lightBlue,
              onTap: () async {
                await emojiCubit.userSelectedEmoji(widget.emoji);
                focusNode.unfocus();
              },
              onLongPress: () => _showVariantsPopup(),
              onSecondaryTap: () => _showVariantsPopup(),
              child: Text(
                widget.emoji.emoji,
                style: const TextStyle(
                  fontSize: 35,
                  fontFamily: emojiFont,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a popup menu with the variants of the selected emoji.
  Future<void> _showVariantsPopup() async {
    if (widget.emoji.variants == null ||
        widget.emoji.variants!.isEmpty ||
        emojiCubit.state.category == EmojiCategory.recent) {
      return;
    }

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selectedValue = await showMenu(
      context: context,
      position: position,
      items: [
        for (final variant in widget.emoji.variants!)
          PopupMenuItem(
            value: variant.emoji,
            child: Center(
              child: Text(
                variant.emoji,
                style: const TextStyle(
                  fontSize: 35,
                  fontFamily: emojiFont,
                ),
              ),
            ),
          ),
      ],
    );

    if (selectedValue != null) {
      final selectedEmoji = widget.emoji.variants!.firstWhere(
        (variant) => variant.emoji == selectedValue,
      );
      emojiCubit.userSelectedEmoji(selectedEmoji);
    }
  }
}

/// Decoration that adds a triangle to the bottom-right corner of the emoji.
///
/// This is used to indicate that the emoji can be long pressed or right
/// clicked to view its variants.
class _TriangleDecoration extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _TrianglePainter();
  }
}

class _TrianglePainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(offset.dx + configuration.size!.width,
          offset.dy + configuration.size!.height)
      ..lineTo(offset.dx + configuration.size!.width,
          offset.dy + configuration.size!.height - 10)
      ..lineTo(offset.dx + configuration.size!.width - 10,
          offset.dy + configuration.size!.height)
      ..close();

    canvas.drawPath(path, paint);
  }
}
