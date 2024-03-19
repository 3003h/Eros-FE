import 'package:flutter/cupertino.dart';

class EhDarkCupertinoTheme extends StatelessWidget {
  const EhDarkCupertinoTheme({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
        data: const CupertinoThemeData(brightness: Brightness.dark),
        child: child);
  }
}
