import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines,
    this.style,
    this.expand = false,
  });

  final String text;

  final int? maxLines;

  final TextStyle? style;

  final bool expand;

  @override
  State<StatefulWidget> createState() {
    return _ExpandableTextState(text, maxLines, style, expand);
  }
}

class _ExpandableTextState extends State<ExpandableText> {
  _ExpandableTextState(this.text, this.maxLines, this.style, this.expand);
  final String text;

  final int? maxLines;

  final TextStyle? style;

  bool expand;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final TextSpan span = TextSpan(text: text, style: style);

        final TextPainter tp = TextPainter(
            text: span, maxLines: maxLines, textDirection: TextDirection.ltr);

        tp.layout(maxWidth: size.maxWidth);

        if (tp.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (expand)
                Text(text, style: style)
              else
                Text(text,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: style),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    expand = !expand;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(expand ? '收起' : '全文',
                      style: TextStyle(
                          fontSize: style?.fontSize, color: Colors.blue)),
                ),
              ),
            ],
          );
        } else {
          return Text(text, style: style);
        }
      },
    );
  }
}
