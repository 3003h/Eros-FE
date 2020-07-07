import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BlurImage extends StatelessWidget {
  final Widget child;

  BlurImage({this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(child: child),
        BackdropFilter(
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
      ],
    );
  }
}
