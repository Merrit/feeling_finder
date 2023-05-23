import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../cubit/emoji_cubit.dart';

/// Widget that allows the user to search for emoji by keyword.
class SearchBarWidget extends StatefulWidget {
  final FocusNode searchBarFocusNode;

  const SearchBarWidget(
    this.searchBarFocusNode, {
    Key? key,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode shortcutFocusNode = FocusNode(
    debugLabel: 'searchBarEscapeShortcutFocusNode',
  );

  @override
  Widget build(BuildContext context) {
    final List<Widget> trailing = [];

    final clearButton = IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
        searchTextController.clear();
        EmojiCubit.instance.search('');
        setState(() {});
      },
    );

    if (searchTextController.text.isNotEmpty) {
      trailing.add(clearButton);
    }

    return Focus(
      focusNode: shortcutFocusNode,
      onKey: (FocusNode focusNode, RawKeyEvent event) {
        if (event.logicalKey != LogicalKeyboardKey.escape) {
          return KeyEventResult.ignored;
        }

        widget.searchBarFocusNode.unfocus();
        searchTextController.clear();
        EmojiCubit.instance.search('');
        setState(() {});
        return KeyEventResult.handled;
      },
      child: SearchBar(
        constraints: const BoxConstraints(minWidth: 360.0, maxWidth: 400.0),
        controller: searchTextController,
        focusNode: widget.searchBarFocusNode,
        hintText: AppLocalizations.of(context)!.searchHintText,
        leading: const Icon(Icons.search),
        onChanged: (value) async {
          if (value.isEmpty) {
            trailing.clear();
          } else {
            trailing.add(clearButton);
          }

          setState(() {});
          await EmojiCubit.instance.search(value);
        },
        trailing: trailing,
      ),
    );
  }
}
