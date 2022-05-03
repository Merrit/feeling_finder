import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../helpers/helpers.dart';
import '../settings/settings_page.dart';
import 'cubit/emoji_cubit.dart';
import 'emoji.dart';
import 'emoji_category.dart';
import 'styles.dart';
import 'widgets/widgets.dart';

/// The app's primary page, containing the category buttons & emoji grid.
class EmojiPage extends StatefulWidget {
  static const routeName = '/';

  const EmojiPage({
    Key? key,
  }) : super(key: key);

  @override
  State<EmojiPage> createState() => _EmojiPageState();
}

class _EmojiPageState extends State<EmojiPage> {
  late FocusScopeNode gridViewFocusNode;
  late FocusNode searchBoxFocusNode;

  @override
  void initState() {
    gridViewFocusNode = FocusScopeNode(debugLabel: 'gridViewFocusNode');
    searchBoxFocusNode = FocusNode(debugLabel: 'searchBoxFocusNode');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onKey: (FocusNode node, RawKeyEvent event) {
        return _redirectSearchKeys(event, searchBoxFocusNode);
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
        drawer: (platformIsMobile())
            ? const Drawer(child: CategoryListView())
            : null,
        body: Row(
          children: [
            // Category buttons shown in a drawer on mobile.
            if (!platformIsMobile()) const CategoryListView(),
            EmojiGridView(gridViewFocusNode),
          ],
        ),
      ),
    );
  }

  /// Automatically focuses the search field when the user types.
  KeyEventResult _redirectSearchKeys(
    RawKeyEvent event,
    FocusNode searchBoxFocusNode,
  ) {
    const navigationKeys = <LogicalKeyboardKey>[
      LogicalKeyboardKey.tab,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
    ];

    final isNavigationKey = navigationKeys.contains(event.logicalKey);

    // If the key is not for navigating, start searching.
    if (!isNavigationKey) {
      searchBoxFocusNode.requestFocus();
      return KeyEventResult.ignored;
    }

    // Navigation keys switch from search bar to results.
    final searchHasFocus = searchBoxFocusNode.hasFocus;
    if (searchHasFocus && isNavigationKey) {
      gridViewFocusNode.requestFocus();
      gridViewFocusNode.nextFocus(); // Skip focus to first result item.
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    gridViewFocusNode.dispose();
    searchBoxFocusNode.dispose();
    super.dispose();
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
                  title: Text(
                    category.localizedName(context),
                    textAlign: TextAlign.center,
                  ),
                  selected: (state.category == category),
                  onTap: () {
                    emojiCubit.setCategory(category);
                    // Dismiss the drawer if present.
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
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
  final FocusScopeNode gridViewFocusNode;

  const EmojiGridView(
    this.gridViewFocusNode, {
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
        thumbVisibility: true,
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
              return FocusScope(
                node: gridViewFocusNode,
                child: GridView.builder(
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
