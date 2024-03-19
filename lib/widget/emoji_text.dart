import 'package:eros_fe/const/const.dart';
import 'package:flutter/cupertino.dart';

class EmojiText extends StatelessWidget {
  const EmojiText({
    super.key,
    required this.text,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _buildText(text),
    );
  }

  TextSpan _buildText(String text) {
    final children = <TextSpan>[];
    final runes = text.runes;

    for (int i = 0; i < runes.length; /* empty */) {
      int current = runes.elementAt(i);

      // we assume that everything that is not
      // in Extended-ASCII set is an emoji...
      final isEmoji = current > 255;
      final shouldBreak = isEmoji ? (int x) => x <= 255 : (int x) => x > 255;

      final chunk = <int>[];
      while (!shouldBreak(current)) {
        chunk.add(current);
        if (++i >= runes.length) {
          break;
        }
        current = runes.elementAt(i);
      }

      late final TextStyle? _style;
      if (style == null) {
        _style = TextStyle(
          fontFamily: isEmoji ? EHConst.emojiFontFamily : null,
        );
      } else {
        _style = isEmoji
            ? style?.copyWith(fontFamily: EHConst.emojiFontFamily)
            : style;
      }

      children.add(
        TextSpan(text: String.fromCharCodes(chunk), style: _style),
      );
    }

    return TextSpan(children: children);
  }
}
