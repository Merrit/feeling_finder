import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../settings/settings_page.dart';
import 'cubit/emoji_cubit.dart';
import 'emoji.dart';
import 'emoji_category.dart';
import 'styles.dart';

/// The app's primary page, containing the category buttons & emoji grid.
class EmojiPage extends StatelessWidget {
  static const routeName = '/';

  const EmojiPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
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
    );
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

                  return Center(
                    child: Tooltip(
                      waitDuration: const Duration(milliseconds: 400),
                      richMessage: TextSpan(
                        text: emoji.description,
                        style: const TextStyle(fontSize: 12),
                      ),
                      child: InkWell(
                        hoverColor: Colors.lightBlue,
                        onTap: () async {
                          await emojiCubit.userSelectedEmoji(emoji);
                        },
                        radius: 50,
                        child: Text(
                          emoji.emoji,
                          style: const TextStyle(
                            fontSize: 35,
                            fontFamily: emojiFont,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
