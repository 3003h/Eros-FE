import 'package:fehviewer/const/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common/enum.dart';

const List<Color> kDefaultAvatarsColors = [
  Color(0xffA3A948),
  Color(0xffEDB92E),
  Color(0xffF85931),
  Color(0xffCE1836),
  Color(0xff009989)
];

const kBorderWidth = 1.5;

class TextAvatar extends StatelessWidget {
  const TextAvatar({
    Key? key,
    required this.name,
    this.type = TextAvatarsType.firstText,
    this.colors = kDefaultAvatarsColors,
    this.radius,
  }) : super(key: key);
  final String name;
  final TextAvatarsType type;
  final List<Color> colors;
  final double? radius;

  int getIndex(String name, int range) {
    return name.hashCode % range;
  }

  Widget borderAvatar({Widget? child}) => LayoutBuilder(
        builder: (context, c) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  (radius ?? c.maxWidth / 2) + kBorderWidth),
              border: Border.all(
                color: colors[getIndex(name, colors.length)],
                width: kBorderWidth,
              ),
            ),
            child: Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: child,
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case TextAvatarsType.onlyBorder:
        return borderAvatar();
      case TextAvatarsType.borderFirstText:
        return borderAvatar(
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: colors[getIndex(name, colors.length)],
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case TextAvatarsType.borderFirstTowText:
        return borderAvatar(
          child: Text(
            '${name.substring(0, 1).toUpperCase()}${name.substring(1, 2)}',
            textScaleFactor: 0.75,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors[getIndex(name, colors.length)],
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case TextAvatarsType.transparent:
        return Container(
          color: Colors.transparent,
        );
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
            maxLines: 1,
            style: TextStyle(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemBackground, context),
              fontWeight: FontWeight.bold,
            ),
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
                  CupertinoColors.systemBackground, context),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }
}
