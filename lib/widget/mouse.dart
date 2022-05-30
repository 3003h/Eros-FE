import 'package:flutter/widgets.dart';

class MouseRegionClick extends StatelessWidget {
  const MouseRegionClick({Key? key, required this.child, this.disable = false})
      : super(key: key);
  final Widget child;
  final bool disable;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: disable ? MouseCursor.defer : SystemMouseCursors.click,
        child: child);
  }
}
