import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';

import '../../core/core.dart';
import '../cubit/emoji_cubit.dart';
import '../emoji.dart';
import '../emoji_category.dart';
import '../styles.dart';

/// Widget that displays an emoji.
class EmojiTile extends StatefulWidget {
  final Emoji emoji;
  final int index;
  final bool isSearchResult;

  const EmojiTile(
    this.emoji,
    this.index, {
    super.key,
    bool? isSearchResult,
  }) : isSearchResult = isSearchResult ?? false;

  @override
  State<EmojiTile> createState() => _EmojiTileState();
}

class _EmojiTileState extends State<EmojiTile> {
  final focusNode = FocusNode(debugLabel: 'emojiTileFocusNode');

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCustomEmoji = widget.emoji.aliases.contains('custom');

    double? fontSize;
    if (isCustomEmoji) {
      fontSize = 20.0;
    } else {
      fontSize = 35.0;
    }

    return BlocBuilder<EmojiCubit, EmojiState>(
      builder: (context, state) {
        final bool hasVariants = widget.emoji.variants?.isNotEmpty == true;

        final bool categoryIsRecent = EmojiCubit.instance.state.category == EmojiCategory.recent;

        final bool showVariantIndicator =
            hasVariants && (!categoryIsRecent || widget.isSearchResult);

        final Decoration? hasVariantsIndicator;
        if (showVariantIndicator) {
          hasVariantsIndicator = _TriangleDecoration();
        } else {
          hasVariantsIndicator = null;
        }

        final bool categoryIsCustom = EmojiCubit.instance.state.category == EmojiCategory.custom;
        final bool enableContextMenu = showVariantIndicator || categoryIsRecent || categoryIsCustom;

        final tileContents = Container(
          decoration: hasVariantsIndicator,
          child: Tooltip(
            waitDuration: const Duration(milliseconds: 400),
            // By default on mobile the tooltip is triggered on long press.
            // Since long-press is used to show the variants popup, we disable
            // the tooltip trigger on mobile.
            triggerMode: defaultTargetPlatform.isMobile ? TooltipTriggerMode.manual : null,
            richMessage: TextSpan(
              text: widget.emoji.name,
              style: const TextStyle(fontSize: 12),
            ),
            child: MouseRegion(
              onEnter: (_) => focusNode.requestFocus(),
              onExit: (_) => focusNode.unfocus(),
              child: Focus(
                debugLabel: 'emojiTileShortcutFocusNode',
                canRequestFocus: false,
                onKeyEvent: (FocusNode focusNode, KeyEvent event) {
                  if (event.logicalKey == LogicalKeyboardKey.contextMenu && hasVariants) {
                    _showVariantsPopup(enableContextMenu);
                    return KeyEventResult.handled;
                  } else {
                    return KeyEventResult.ignored;
                  }
                },
                child: Text(
                  widget.emoji.emoji,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamily: (widget.emoji.aliases.contains('custom')) ? null : emojiFont,
                  ),
                ),
              ),
            ),
          ),
        );

        Widget tileWrapper;
        if (isCustomEmoji) {
          // Only custom emojis get wrapped with a Card, because otherwise
          // they can be difficult to differentiate from each other.
          tileWrapper = Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: tileContents,
            ),
          );
        } else {
          // Regular emojis get wrapped with a Center, because otherwise they
          // all sit off center of the focus color background.
          //
          // IntrinsicWidth is used to prevent the Center from expanding to
          // fill the entire width of the available space.
          tileWrapper = IntrinsicWidth(
            child: Center(
              child: tileContents,
            ),
          );
        }

        final List<ContextMenuButtonItem> contextMenuItems = [];

        if (categoryIsRecent) {
          contextMenuItems.add(
            ContextMenuButtonItem(
              onPressed: () {
                ContextMenuController.removeAny();
                EmojiCubit.instance.removeRecentEmoji(widget.emoji);
              },
              label: 'Remove from recents',
            ),
          );
        } else if (isCustomEmoji) {
          contextMenuItems.add(
            ContextMenuButtonItem(
              onPressed: () {
                ContextMenuController.removeAny();
                _showRemoveCustomEmojiDialog();
              },
              label: 'Remove custom emoji',
            ),
          );
        }

        final bool categorySupportsVariants = !categoryIsRecent && !categoryIsCustom;

        final basicTileContents = CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.enter): () async {
              await EmojiCubit.instance.userSelectedEmoji(widget.emoji);
              focusNode.unfocus();
            },
          },
          child: InkWell(
            focusNode: focusNode,
            autofocus: (widget.index == 0) ? true : false,
            focusColor: Colors.lightBlue,
            onTap: () async {
              await EmojiCubit.instance.userSelectedEmoji(widget.emoji);
              focusNode.unfocus();
            },
            onLongPress: (categorySupportsVariants) //
                ? () => _showVariantsPopup(enableContextMenu)
                : null,
            onSecondaryTapUp: (categorySupportsVariants)
                ? (details) => _showVariantsPopup(enableContextMenu)
                : null,
            child: tileWrapper,
          ),
        );

        if (categorySupportsVariants) {
          return basicTileContents;
        } else {
          return ContextMenuRegion(
            contextMenuBuilder: (context, offset) {
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: TextSelectionToolbarAnchors(primaryAnchor: offset),
                buttonItems: contextMenuItems,
              );
            },
            child: basicTileContents,
          );
        }
      },
    );
  }

  /// Shows a popup menu with the variants of the selected emoji.
  Future<void> _showVariantsPopup(bool enableContextMenu) async {
    if (!enableContextMenu) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final List<PopupMenuItem<String>> items = [];

    for (final variant in widget.emoji.variants!) {
      items.add(
        PopupMenuItem(
          value: variant.emoji,
          child: Center(
            child: Text(
              variant.emoji,
              style: TextStyle(
                fontSize: 35,
                fontFamily: emojiFont,
              ),
            ),
          ),
        ),
      );
    }

    final String? selectedValue = await showMenu<String>(
      context: context,
      position: position,
      items: items,
    );

    if (selectedValue == null) return;

    final selectedEmoji = widget.emoji.variants!.firstWhere(
      (variant) => variant.emoji == selectedValue,
    );

    EmojiCubit.instance.userSelectedEmoji(selectedEmoji);
  }

  /// Shows a dialog to confirm the removal of a custom emoji.
  Future<void> _showRemoveCustomEmojiDialog() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove custom emoji?'),
          content: Text(widget.emoji.emoji),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await EmojiCubit.instance.removeCustomEmoji(widget.emoji);
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
      ..moveTo(offset.dx + configuration.size!.width, offset.dy + configuration.size!.height)
      ..lineTo(offset.dx + configuration.size!.width, offset.dy + configuration.size!.height - 10)
      ..lineTo(offset.dx + configuration.size!.width - 10, offset.dy + configuration.size!.height)
      ..close();

    canvas.drawPath(path, paint);
  }
}
