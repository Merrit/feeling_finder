import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/emoji_cubit.dart';
import 'widgets.dart';

/// Widget that allows the user to search for emoji by keyword.
class SearchBarWidget extends StatefulWidget {
  final FocusNode focusNode;
  final SearchController searchController;

  const SearchBarWidget({
    super.key,
    required this.focusNode,
    required this.searchController,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final EmojiCubit emojiCubit;
  late final SearchController searchController;

  @override
  void initState() {
    super.initState();
    emojiCubit = context.read<EmojiCubit>();
    searchController = widget.searchController;
    searchController.addListener(() {
      if (searchController.isOpen) {
        emojiCubit.search(searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      child: Focus(
        focusNode: widget.focusNode,
        child: SearchAnchor.bar(
          viewTrailing: [
            Focus(
              // Tab navigation goes straight to the emojis.
              descendantsAreTraversable: false,
              skipTraversal: true,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  searchController.clear();
                  emojiCubit.search('');
                },
              ),
            ),
          ],
          searchController: searchController,
          barHintText: 'Search',
          viewHintText: 'Search for emoji',
          barTrailing: const [
            // Hint that Ctrl + F can be used to search.
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Ctrl'),
                  WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('+'),
                    ),
                  ),
                  TextSpan(text: 'F'),
                ],
              ),
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey,
              ),
            ),
          ],
          suggestionsBuilder: (context, controller) {
            return [
              BlocBuilder<EmojiCubit, EmojiState>(
                builder: (context, state) {
                  return Wrap(
                    children: state.searchResults.map((emoji) {
                      return EmojiTile(emoji, state.emojis.indexOf(emoji), isSearchResult: true);
                    }).toList(),
                  );
                },
              ),
            ];
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
