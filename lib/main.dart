import 'package:FEhViewer/fehviewer/pages/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common/global.dart';
import 'fehviewer/route/Application.dart';

void main() => Global.init().then((e) => runApp(MyApp()));

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      onGenerateRoute: Application.router.generator,
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: SplashPage(),
    );
  }
}
