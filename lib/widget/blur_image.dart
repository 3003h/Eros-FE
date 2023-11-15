import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BlurImage extends StatelessWidget {
  const BlurImage({
    required this.child,
    this.isBlur = true,
    this.sigma = 5.0,
    this.expand = true,
  });

  final Widget child;
  final bool isBlur;
  final double sigma;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: expand ? StackFit.expand : StackFit.loose,
      children: <Widget>[
        Container(child: child),
        if (isBlur)
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: sigma,
              sigmaY: sigma,
            ),
            child: Container(
                // color: Colors.white.withOpacity(0.1),
                ),
          ),
      ],
    );
  }
}
