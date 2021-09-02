import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BlurImage extends StatelessWidget {
  const BlurImage({required this.child, this.isBlur = true});

  final Widget child;
  final bool isBlur;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.loose,
      children: <Widget>[
        Container(child: child),
        Offstage(
          offstage: !isBlur,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5,
              sigmaY: 5,
            ),
            child: Container(
              color: Colors.white.withOpacity(0.1),
              width: 1,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}
