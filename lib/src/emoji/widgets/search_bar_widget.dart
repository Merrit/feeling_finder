import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../cubit/emoji_cubit.dart';

/// Widget that allows the user to search for emoji by keyword.
class SearchBarWidget extends StatefulWidget {
  final FocusNode focusNode;
  final TextEditingController textController;

  const SearchBarWidget({
    Key? key,
    required this.focusNode,
    required this.textController,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController searchTextController;

  @override
  void initState() {
    super.initState();
    searchTextController = widget.textController;
  }

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

    return SearchBar(
      constraints: const BoxConstraints(minWidth: 360.0, maxWidth: 400.0),
      controller: searchTextController,
      focusNode: widget.focusNode,
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
    );
  }
}
