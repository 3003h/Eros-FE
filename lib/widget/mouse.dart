import 'package:flutter/widgets.dart';

class MouseRegionClick extends StatelessWidget {
  const MouseRegionClick(
      {super.key, required this.child, this.disable = false});
  final Widget child;
  final bool disable;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: disable ? MouseCursor.defer : SystemMouseCursors.click,
        child: child);
  }
}
