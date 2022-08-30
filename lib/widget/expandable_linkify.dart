// import 'package:fehviewer/utils/cust_lib/flutter_linkify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:linkfy_text/linkfy_text.dart';
import 'package:linkify/linkify.dart'
    show
        LinkifyElement,
        LinkifyOptions,
        LinkableElement,
        TextElement,
        Linkifier,
        UrlElement,
        UrlLinkifier,
        EmailElement,
        defaultLinkifiers,
        EmailLinkifier;

import 'eh_linkify_text.dart';

const Duration _kExpandDuration = Duration(milliseconds: 200);

class ExpandableLinkify extends StatefulWidget {
  const ExpandableLinkify({
    Key? key,
    required this.text,
    this.maxLines,
    this.style,
    this.expand = false,
    this.linkifiers = defaultLinkifiers,
    this.onOpen,
    this.options = const LinkifyOptions(),
    this.linkStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.overflow = TextOverflow.clip,
    // this.textScaleFactor = 1.0,
    this.softWrap = true,
    this.strutStyle,
    this.locale,
    this.textWidthBasis = TextWidthBasis.parent,
    this.colorExpandText = Colors.blueAccent,
    this.expandText = 'expand',
    this.collapseText = 'compress',
  }) : super(key: key);

  final bool expand;

  /// Text to be linkified
  final String text;

  /// Linkifiers to be used for linkify
  final List<Linkifier> linkifiers;

  /// Callback for tapping a link
  final ValueChanged<String?>? onOpen;

  /// linkify's options.
  final LinkifyOptions options;

  // TextSpan

  /// Style for non-link text
  final TextStyle? style;

  /// Style of link text
  final TextStyle? linkStyle;

  // RichText

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// Text direction of the text
  final TextDirection? textDirection;

  /// The maximum number of lines for the text to span, wrapping if necessary
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// The number of font pixels for each logical pixel
  // final double? textScaleFactor;

  /// Whether the text should break at soft line breaks.
  final bool softWrap;

  /// The strut style used for the vertical layout
  final StrutStyle? strutStyle;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale
  final Locale? locale;

  /// Defines how to measure the width of the rendered text.
  final TextWidthBasis? textWidthBasis;

  final Color colorExpandText;

  final String expandText;

  final String collapseText;

  @override
  State<StatefulWidget> createState() {
    return _ExpandableLinkifyState();
  }
}

class _ExpandableLinkifyState extends State<ExpandableLinkify>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.expand;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints size) {
        final TextSpan span = TextSpan(text: widget.text, style: widget.style);

        final TextPainter textPainter = TextPainter(
            text: span,
            maxLines: widget.maxLines,
            textDirection: TextDirection.ltr);

        textPainter.layout(maxWidth: size.maxWidth);

        Widget getLinkifyText({required bool isExpanded}) {
          return Linkify(
            text: widget.text,
            maxLines: isExpanded ? null : widget.maxLines,
            overflow: isExpanded ? TextOverflow.clip : widget.overflow,
            style: widget.style,
            onOpen: (link) => widget.onOpen?.call(link.url),
            options: widget.options,
            softWrap: widget.softWrap,
            textAlign: widget.textAlign,
          );
        }

        Widget getLinkifyText2({required bool isExpanded}) {
          return EhLinkifyText(
            widget.text,
            maxLines: isExpanded ? null : widget.maxLines,
            overflow: isExpanded ? TextOverflow.clip : widget.overflow,
            textStyle: widget.style,
            onTap: (link) => widget.onOpen?.call(link.value),
            softWrap: widget.softWrap,
            textAlign: widget.textAlign,
            selectable: false,
          );
        }

        Widget _getLinkify() {
          return AnimatedCrossFade(
            duration: _kExpandDuration,
            firstCurve: Curves.easeIn,
            secondCurve: Curves.easeOut,
            firstChild: getLinkifyText2(isExpanded: true),
            secondChild: getLinkifyText2(isExpanded: false),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          );
        }

        if (textPainter.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _getLinkify(),
              // 切换文字
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                      _isExpanded ? widget.collapseText : widget.expandText,
                      style: widget.style
                          ?.copyWith(color: widget.colorExpandText)),
                ),
              ),
            ],
          );
        } else {
          return EhLinkifyText(
            widget.text,
            textStyle: widget.style,
            onTap: (link) => widget.onOpen?.call(link.value),
          );
        }
      },
    );
  }
}
