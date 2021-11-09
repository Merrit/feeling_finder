import 'package:flutter/material.dart';

import '../cubit/emoji_cubit.dart';
import '../emoji.dart';
import '../styles.dart';

class EmojiTile extends StatelessWidget {
  final Emoji emoji;
  final int index;

  const EmojiTile(
    this.emoji,
    this.index, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();

    return Center(
      child: Tooltip(
        waitDuration: const Duration(milliseconds: 400),
        richMessage: TextSpan(
          text: emoji.description,
          style: const TextStyle(fontSize: 12),
        ),
        child: InkWell(
          focusNode: focusNode,
          autofocus: (index == 0) ? true : false,
          focusColor: Colors.lightBlue,
          onHover: (value) => focusNode.requestFocus(),
          onTap: () async {
            await emojiCubit.userSelectedEmoji(emoji);
          },
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
  }
}
