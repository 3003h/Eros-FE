// import 'package:fehviewer/utils/cust_lib/flutter_linkify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
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
    this.textScaleFactor = 1.0,
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
  final LinkCallback? onOpen;

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
  final double? textScaleFactor;

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
    return _ExpandableLinkifyState(expand);
  }
}

class _ExpandableLinkifyState extends State<ExpandableLinkify> {
  _ExpandableLinkifyState(this._expand) {
    _expand ??= false;
  }

  bool _expand;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final TextSpan span =
            TextSpan(text: widget.text ?? '', style: widget.style);

        final TextPainter tp = TextPainter(
            text: span,
            maxLines: widget.maxLines,
            textDirection: TextDirection.ltr);

        tp.layout(maxWidth: size.maxWidth);

        if (tp.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_expand)
                Linkify(
                  text: widget.text ?? '',
                  style: widget.style,
                  onOpen: widget.onOpen,
                  options: widget.options,
                  softWrap: widget.softWrap,
                  textAlign: widget.textAlign,
                )
              else
                Linkify(
                  text: widget.text ?? '',
                  maxLines: widget.maxLines,
                  overflow: widget.overflow,
                  style: widget.style,
                  onOpen: widget.onOpen,
                  options: widget.options,
                  softWrap: widget.softWrap,
                  textAlign: widget.textAlign,
                ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    _expand = !_expand;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(_expand ? widget.collapseText : widget.expandText,
                      style: TextStyle(
                          fontSize: widget.style?.fontSize,
                          color: widget.colorExpandText)),
                ),
              ),
            ],
          );
        } else {
          return Linkify(text: widget.text ?? '', style: widget.style);
        }
      },
    );
  }
}
