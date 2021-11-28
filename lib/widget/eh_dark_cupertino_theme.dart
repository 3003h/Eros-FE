import 'package:flutter/cupertino.dart';

class EhDarkCupertinoTheme extends StatelessWidget {
  const EhDarkCupertinoTheme({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
        data: const CupertinoThemeData(brightness: Brightness.dark),
        child: child);
  }
}
