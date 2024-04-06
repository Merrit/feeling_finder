import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../app/app.dart';
import '../core/core.dart';
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
  final FocusScopeNode emojiPageFocusScope = FocusScopeNode(
    debugLabel: 'emojiPageFocusScope',
  );
  final FocusScopeNode gridViewFocusNode = FocusScopeNode(
    debugLabel: 'gridViewFocusNode',
  );
  final FocusNode searchBoxFocusNode = FocusNode(
    debugLabel: 'searchBoxFocusNode',
  );

  final SearchController searchController = SearchController();

  final FocusNode settingsButtonFocusNode = FocusNode(
    debugLabel: 'settingsButtonFocusNode',
    skipTraversal: false,
  );

  final floatingActionButtonKey = GlobalKey(debugLabel: 'floatingActionButton');

  bool haveShownReleaseNotes = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (state.releaseNotes != null) {
            _showReleaseNotesDialog(context, state.releaseNotes!);
          }
        });

        return GestureDetector(
          onTap: () {
            // When the background is clicked or tapped, remove focus from whatever has it.
            ContextMenuController.removeAny();
            emojiPageFocusScope.requestFocus();
          },
          child: CallbackShortcuts(
            bindings: <ShortcutActivator, VoidCallback>{
              // If the user presses the Escape key, remove focus from the search box.
              const SingleActivator(
                LogicalKeyboardKey.escape,
              ): () {
                if (searchBoxFocusNode.hasFocus) {
                  searchBoxFocusNode.unfocus();
                }
              },
              // If the user presses Ctrl+F, focus the search box.
              const SingleActivator(
                LogicalKeyboardKey.keyF,
                control: true,
              ): () {
                searchController.openView();
              },
            },
            child: FocusScope(
              debugLabel: 'emojiPageFocusScope',
              node: emojiPageFocusScope,
              child: BlocBuilder<EmojiCubit, EmojiState>(
                buildWhen: (previous, current) => previous.category != current.category,
                builder: (context, state) {
                  Widget? floatingActionButton;
                  if (state.category == EmojiCategory.custom) {
                    floatingActionButton = FloatingActionButton(
                      key: floatingActionButtonKey,
                      onPressed: () => _showAddCustomEmojiDialog(context),
                      child: const Icon(Icons.add),
                    );
                  }

                  return Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      title: SearchBarWidget(
                        focusNode: searchBoxFocusNode,
                        searchController: searchController,
                      ),
                      actions: [
                        _SettingsButton(focusNode: settingsButtonFocusNode),
                      ],
                    ),
                    drawer: (platformIsMobile()) ? const Drawer(child: CategoryListView()) : null,
                    body: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category buttons shown in a drawer on mobile.
                        if (!platformIsMobile()) const CategoryListView(),
                        EmojiGridView(floatingActionButtonKey, gridViewFocusNode),
                      ],
                    ),
                    floatingActionButton: floatingActionButton,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showReleaseNotesDialog(
    BuildContext context,
    ReleaseNotes releaseNotes,
  ) {
    if (haveShownReleaseNotes) return Future.value();
    haveShownReleaseNotes = true;

    return showDialog(
      context: context,
      builder: (context) => ReleaseNotesDialog(
        releaseNotes: releaseNotes,
        donateCallback: () => AppCubit.instance.launchURL(kDonateUrl),
        launchURL: (url) => AppCubit.instance.launchURL(url),
        onClose: () {
          AppCubit.instance.dismissReleaseNotesDialog();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    gridViewFocusNode.dispose();
    searchBoxFocusNode.dispose();
    settingsButtonFocusNode.dispose();
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
              if ((category == EmojiCategory.recent) && !state.haveRecentEmojis) {
                // Only show recent category if we have any recents.
                return const SizedBox();
              } else {
                final listTile = ListTile(
                  title: Text(
                    category.localizedName(),
                    textAlign: TextAlign.center,
                  ),
                  selected: (state.category == category),
                );

                // TODO: transition this MenuAnchor to ContextMenuRegion
                return MenuAnchor(
                  menuChildren: [
                    /// If the category is [EmojiCategory.recent], show a
                    /// button to clear the recent emojis.
                    if (category == EmojiCategory.recent)
                      MenuItemButton(
                        trailingIcon: const Icon(Icons.delete),
                        onPressed: () {
                          EmojiCubit.instance.clearRecentEmojis();
                        },
                        child: const Text('Clear recent emojis'),
                      ),
                  ],
                  style: Theme.of(context).menuTheme.style?.copyWith(
                        alignment: Alignment.centerRight,
                      ),
                  builder: (context, controller, child) {
                    return GestureDetector(
                      onLongPressEnd: (details) => controller.open(
                        position: details.localPosition,
                      ),
                      onSecondaryTapDown: (details) => controller.open(
                        position: details.localPosition,
                      ),
                      onTap: () {
                        EmojiCubit.instance.setCategory(category);
                        // Dismiss the drawer if present.
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      },
                      child: listTile,
                    );
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
class EmojiGridView extends StatefulWidget {
  final GlobalKey floatingActionButtonKey;
  final FocusScopeNode gridViewFocusNode;

  const EmojiGridView(
    this.floatingActionButtonKey,
    this.gridViewFocusNode, {
    Key? key,
  }) : super(key: key);

  @override
  State<EmojiGridView> createState() => _EmojiGridViewState();
}

class _EmojiGridViewState extends State<EmojiGridView> {
  bool haveShownCustomEmojisTutorial = false;

  /// Requires a specific ScrollController so that
  /// it doesn't conflict with [CategoryListView].
  final gridviewScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        controller: gridviewScrollController,
        thumbVisibility: true,
        child: BlocListener<EmojiCubit, EmojiState>(
          listenWhen: (previous, current) => previous.copiedEmoji != current.copiedEmoji,
          listener: (context, state) {
            // Show a notification when an emoji is copied to clipboard.
            if (state.copiedEmoji == null) return;
            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  '${state.copiedEmoji} copied to clipboard.',
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: emojiFont,
                  ),
                ),
              ),
            );
          },
          child: BlocBuilder<EmojiCubit, EmojiState>(
            builder: (context, state) {
              final isCustomCategory = state.category == EmojiCategory.custom;

              if (isCustomCategory && state.emojis.isNotEmpty) {
                haveShownCustomEmojisTutorial = true;
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (state.category == EmojiCategory.custom &&
                    state.emojis.isEmpty &&
                    !haveShownCustomEmojisTutorial) {
                  haveShownCustomEmojisTutorial = true;
                  // Small delay for the floating action button to animate in.
                  Future.delayed(const Duration(milliseconds: 500)).then((value) {
                    _showCustomEmojisTutorial(
                      context,
                      widget.floatingActionButtonKey,
                    );
                  });
                }
              });

              // Recent and custom emojis are shown with a Wrap so they can
              // display emojis of various widths in order to accomodate
              // the custom emojis.
              final Widget recentAndCustomView = SingleChildScrollView(
                controller: gridviewScrollController,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (var emoji in state.emojis) EmojiTile(emoji, state.emojis.indexOf(emoji)),
                  ],
                ),
              );

              // Regular emojis are shown with an efficient GridView.
              final Widget emojiCategoryView = GridView.builder(
                // Key is required for scroll position to be reset when
                // the emoji category is changed.
                key: ValueKey(state.category),
                controller: gridviewScrollController,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 50,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: state.emojis.length,
                itemBuilder: (context, index) {
                  final Emoji emoji = state.emojis[index];

                  return EmojiTile(emoji, index);
                },
              );

              final Widget view;
              if (state.category == EmojiCategory.recent ||
                  state.category == EmojiCategory.custom) {
                view = recentAndCustomView;
              } else {
                view = emojiCategoryView;
              }

              return Focus(
                focusNode: widget.gridViewFocusNode,
                child: view,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    gridviewScrollController.dispose();
    super.dispose();
  }
}

/// A dialog that allows the user to add a custom emoji.
class _AddCustomEmojiDialog extends StatelessWidget {
  _AddCustomEmojiDialog();

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmojiCubit, EmojiState>(
      builder: (context, state) {
        const customEmojiTextStyle = TextStyle(fontSize: 20);

        final exampleButtonStyle = TextButton.styleFrom(
          padding: const EdgeInsets.all(15),
        );

        final instructionWidgets = [
          const Text('Type your own, or try one of these:'),
          const SizedBox(height: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                style: exampleButtonStyle,
                onPressed: () => controller.text = r'¯\_(ツ)_/¯',
                child: const Text(r'¯\_(ツ)_/¯', style: customEmojiTextStyle),
              ),
              TextButton(
                style: exampleButtonStyle,
                onPressed: () => controller.text = '˗ˏˋ ★ˎˊ˗',
                child: const Text('˗ˏˋ ★ˎˊ˗', style: customEmojiTextStyle),
              ),
              TextButton(
                style: exampleButtonStyle,
                onPressed: () => controller.text = "It's Adventure Time!",
                child: const Text(
                  "It's Adventure Time!",
                  style: customEmojiTextStyle,
                ),
              ),
            ],
          ),
        ];

        final textField = CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            // If the user presses enter, add the emoji.
            const SingleActivator(LogicalKeyboardKey.enter): () => _addCustomEmoji(context),
            // If the user presses Shift+Enter, the shortcut doesn't catch
            // the event and the TextFormField should add a newline.
          },
          child: TextFormField(
            autofocus: true,
            controller: controller,
            maxLines: null,
            onFieldSubmitted: (value) => _addCustomEmoji(context),
            style: customEmojiTextStyle,
          ),
        );

        final List<Widget> contents = [
          if (state.emojis.isEmpty) ...instructionWidgets,
          textField,
        ];

        return AlertDialog(
          scrollable: true,
          title: const Text('Add custom emoji'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: contents,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _addCustomEmoji(context),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addCustomEmoji(BuildContext context) {
    final emoji = controller.text;
    if (emoji.isNotEmpty) {
      EmojiCubit.instance.addCustomEmoji(emoji);
    }
    Navigator.pop(context);
  }
}

Future<void> _showAddCustomEmojiDialog(BuildContext context) async {
  tutorial?.skip();
  tutorial = null;

  // Delay required for the tutorial widget to be disposed, or else it will
  // throw an exception when trying to close the dialog.
  Future.delayed(const Duration(milliseconds: 10), () {
    return showDialog(
      context: context,
      builder: (context) => _AddCustomEmojiDialog(),
    );
  });
}

TutorialCoachMark? tutorial;

void _showCustomEmojisTutorial(
  BuildContext context,
  GlobalKey floatingActionButtonKey,
) {
  // Dismiss snackbar if present, otherwise the position of the FAB will change
  // and the tutorial will be misplaced.
  ScaffoldMessenger.of(context).removeCurrentSnackBar();

  final List<TargetFocus> targets = [];
  final floatingActionButton = floatingActionButtonKey.currentContext;
  if (floatingActionButton != null) {
    targets.add(
      TargetFocus(
        enableOverlayTab: true,
        identify: "Target 1",
        keyTarget: floatingActionButtonKey,
        paddingFocus: 20,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              left: MediaQuery.of(context).size.width / 2 - 100,
              bottom: 70,
            ),
            child: const Text(
              "Add your own custom emojis!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  tutorial = TutorialCoachMark(
    targets: targets,
    pulseEnable: false,
    alignSkip: Alignment.topRight,
    skipWidget: const Icon(Icons.close),
    onClickTarget: (_) {
      return _showAddCustomEmojiDialog(context);
    },
  );

  tutorial?.show(context: context);
}

class _SettingsButton extends StatelessWidget {
  final FocusNode focusNode;

  const _SettingsButton({
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        // Show a badge on the settings button if there is an update available.
        return Badge(
          isLabelVisible: state.updateAvailable,
          backgroundColor: Colors.greenAccent,
          label: Container(
            padding: const EdgeInsets.all(1),
          ),
          largeSize: 10.0,
          offset: const Offset(-3, 3),
          child: IconButton(
            focusNode: focusNode,
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsPage.routeName);
            },
            icon: const Icon(Icons.settings),
          ),
        );
      },
    );
  }
}
