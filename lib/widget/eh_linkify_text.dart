import 'package:flutter/cupertino.dart';
import 'package:linkfy_text/linkfy_text.dart';
import 'package:linkfy_text/src/model/link.dart';

class EhLinkifyText extends StatelessWidget {
  const EhLinkifyText(
    this.text, {
    this.textStyle,
    this.linkStyle,
    this.linkTypes,
    this.onTap,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.selectable,
    Key? key,
  }) : super(key: key);

  final String text;

  final TextStyle? textStyle;

  final TextStyle? linkStyle;

  final void Function(Link)? onTap;

  final List<LinkType>? linkTypes;

  final StrutStyle? strutStyle;

  final TextAlign? textAlign;

  final TextDirection? textDirection;

  final Locale? locale;

  final bool? softWrap;

  final int? maxLines;

  final TextOverflow? overflow;

  final double? textScaleFactor;

  final String? semanticsLabel;

  final TextWidthBasis? textWidthBasis;

  final bool? selectable;

  @override
  Widget build(BuildContext context) {
    if (selectable ?? false) {
      return LinkifySelectableText(
        text,
        textStyle: textStyle,
        linkStyle: linkStyle ??
            textStyle?.copyWith(
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.activeBlue, context)),
        linkTypes: linkTypes,
        onTap: onTap,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaleFactor: textScaleFactor,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        scrollPhysics: const NeverScrollableScrollPhysics(),
      );
    } else {
      return LinkifyText(
        text,
        textStyle: textStyle,
        linkStyle: linkStyle ??
            textStyle?.copyWith(
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.activeBlue, context)),
        linkTypes: linkTypes,
        onTap: onTap,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaleFactor: textScaleFactor,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
      );
    }
  }
}
