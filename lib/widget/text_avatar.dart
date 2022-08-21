import 'package:fehviewer/const/theme_colors.dart';
import 'package:flutter/cupertino.dart';

import '../common/enum.dart';

const List<Color> kDefaultAvatarsColors = [
  Color(0xffA3A948),
  Color(0xffEDB92E),
  Color(0xffF85931),
  Color(0xffCE1836),
  Color(0xff009989)
];

class TextAvatar extends StatelessWidget {
  const TextAvatar({
    Key? key,
    required this.name,
    this.type = TextAvatarsType.firstText,
    this.colors = kDefaultAvatarsColors,
  }) : super(key: key);
  final String name;
  final TextAvatarsType type;
  final List<Color> colors;

  int getIndex(String name, int range) {
    return name.hashCode % range;
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case TextAvatarsType.noText:
        return Container(
          color: colors[getIndex(name, colors.length)],
          alignment: Alignment.center,
        );
      case TextAvatarsType.firstTowText:
        return Container(
          color: colors[getIndex(name, colors.length)],
          alignment: Alignment.center,
          child: Text(
            '${name.substring(0, 1).toUpperCase()}${name.substring(1, 2)}',
            textScaleFactor: 0.8,
            style: TextStyle(
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemBackground, context)),
          ),
        );
      case TextAvatarsType.firstText:
      default:
        return Container(
          color: colors[getIndex(name, colors.length)],
          alignment: Alignment.center,
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: TextStyle(
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemBackground, context)),
          ),
        );
    }
  }
}
