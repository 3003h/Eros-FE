import 'package:flutter/widgets.dart';

class AnimatedClipRRect extends StatelessWidget {
  const AnimatedClipRRect({
    required this.duration,
    this.curve = Curves.linear,
    required this.borderRadius,
    required this.child,
    super.key,
  });

  final Duration duration;
  final Curve curve;
  final BorderRadius borderRadius;
  final Widget child;

  static Widget _builder(
      BuildContext context, BorderRadius radius, Widget? child) {
    return ClipRRect(borderRadius: radius, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<BorderRadius>(
      duration: duration,
      curve: curve,
      tween: Tween(
        // begin: BorderRadius.zero,
        end: borderRadius,
      ),
      builder: _builder,
      child: child,
    );
  }
}
