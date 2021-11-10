import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../cubit/emoji_cubit.dart';

class SearchBox extends StatelessWidget {
  final FocusNode focusNode;

  const SearchBox({
    Key? key,
    required this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 45,
        maxWidth: 300,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchHintText,
        ),
        focusNode: focusNode,
        onChanged: (value) => emojiCubit.search(value),
      ),
    );
  }
}
