import 'package:FEhViewer/fehviewer/pages/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'common/global.dart';
import 'fehviewer/route/Application.dart';
import 'models/states/localeModel.dart';
import 'models/states/userModel.dart';

void main() => Global.init().then((e) => runApp(MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CupertinoApp cApp = CupertinoApp(
      onGenerateRoute: Application.router.generator,
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: SplashPage(),
    );

    MultiProvider multiProvider = MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: UserModel()),
        ChangeNotifierProvider.value(value: LocaleModel()),
      ],
      child: cApp,
    );

    return multiProvider;
  }
}
