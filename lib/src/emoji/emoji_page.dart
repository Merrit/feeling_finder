import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../settings/settings_page.dart';
import 'cubit/emoji_cubit.dart';
import 'emoji.dart';
import 'emoji_category.dart';
import 'styles.dart';
import 'widgets/widgets.dart';

/// The app's primary page, containing the category buttons & emoji grid.
class EmojiPage extends StatelessWidget {
  static const routeName = '/';

  const EmojiPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchBoxFocusNode = FocusNode();

    return FocusScope(
      onKey: (FocusNode node, RawKeyEvent event) {
        return handleShortcuts(event, searchBoxFocusNode);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: SearchBox(focusNode: searchBoxFocusNode),
          actions: [
            IconButton(
              // Keyboard navigation shouldn't focus settings button.
              focusNode: FocusNode(skipTraversal: true),
              onPressed: () {
                Navigator.restorablePushNamed(context, SettingsPage.routeName);
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: Row(
          children: const [
            CategoryListView(),
            EmojiGridView(),
          ],
        ),
      ),
    );
  }

  /// Decides what to do when keystrokes are detected.
  KeyEventResult handleShortcuts(
      RawKeyEvent event, FocusNode searchBoxFocusNode) {
    const navigationKeys = <LogicalKeyboardKey>[
      LogicalKeyboardKey.escape,
      LogicalKeyboardKey.tab,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
    ];

    final isNavigationKeys = navigationKeys.contains(event.logicalKey);

    // If the key is not for navigating, start searching.
    if (!isNavigationKeys) {
      searchBoxFocusNode.requestFocus();
      return KeyEventResult.ignored;
    }

    final isEscapeKey = event.isKeyPressed(LogicalKeyboardKey.escape);

    // Exit app if user presses escape.
    if (isEscapeKey) {
      log('Escape pressed, exiting.');
      exit(0);
    } else {
      return KeyEventResult.ignored;
    }
  }
}

/// A list of buttons to change the emoji category.
class CategoryListView extends StatelessWidget {
  const CategoryListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Requires a specific ScrollController so that
    /// it doesn't conflict with [EmojiGridView].
    final sidebarScrollController = ScrollController();

    return ConstrainedBox(
      // Constrain width to be just big enough to fit the buttons.
      constraints: const BoxConstraints(maxWidth: 180),
      child: BlocBuilder<EmojiCubit, EmojiState>(
        builder: (context, state) {
          return ListView.builder(
            controller: sidebarScrollController,
            itemCount: EmojiCategory.values.length,
            itemBuilder: (context, index) {
              final category = EmojiCategory.values[index];
              if ((category == EmojiCategory.recent) &&
                  !state.haveRecentEmojis) {
                // Only show recent category if we have any recents.
                return const SizedBox();
              } else {
                return ListTile(
                  title: Center(child: Text(category.value)),
                  selected: (state.category == category),
                  onTap: () => emojiCubit.setCategory(category),
                );
              }
            },
          );
        },
      ),
    );
  }
}

/// A GridView that displays the emojis as clickable buttons.
class EmojiGridView extends StatelessWidget {
  const EmojiGridView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Requires a specific ScrollController so that
    /// it doesn't conflict with [CategoryListView].
    final gridviewScrollController = ScrollController();

    return Expanded(
      child: Scrollbar(
        controller: gridviewScrollController,
        isAlwaysShown: true,
        child: BlocListener<EmojiCubit, EmojiState>(
          listenWhen: (previous, current) =>
              previous.copiedEmoji != current.copiedEmoji,
          listener: (context, state) {
            // Show a notification when an emoji is copied to clipboard.
            if (state.copiedEmoji == null) return;
            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  '${state.copiedEmoji} copied to clipboard.',
                  style: const TextStyle(
                    fontSize: 25,
                    fontFamily: emojiFont,
                  ),
                ),
              ),
            );
          },
          child: BlocBuilder<EmojiCubit, EmojiState>(
            builder: (context, state) {
              return GridView.builder(
                // Key is required for scroll position to be reset when
                // the emoji category is changed.
                key: ValueKey(state.category),
                controller: gridviewScrollController,
                padding: const EdgeInsets.only(
                  top: 10,
                  right: 20,
                  bottom: 10,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemCount: state.emojis.length,
                itemBuilder: (context, index) {
                  final Emoji emoji = state.emojis[index];

                  return EmojiTile(emoji, index);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
