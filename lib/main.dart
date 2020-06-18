import 'package:FEhViewer/fehviewer/pages/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/global.dart';
import 'fehviewer/route/Application.dart';

void main() => Global.init().then((e) => runApp(MyApp()));

class MyApp extends StatelessWidget {
  //statusBar设置为透明，去除半透明遮罩
  final SystemUiOverlayStyle _style =
      SystemUiOverlayStyle(statusBarColor: Colors.transparent);

  @override
  Widget build(BuildContext context) {
    //将style设置到app
    SystemChrome.setSystemUIOverlayStyle(_style);
    return CupertinoApp(
      onGenerateRoute: Application.router.generator,
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: SplashPage(),
    );
  }
}
