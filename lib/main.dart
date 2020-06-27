import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/models/states/locale_model.dart';
import 'package:FEhViewer/models/states/user_model.dart';
import 'package:FEhViewer/pages/splash_page.dart';
import 'package:FEhViewer/route/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() => Global.init().then((e) => runApp(MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CupertinoApp cupertinoApp = CupertinoApp(
      onGenerateRoute: Application.router.generator,
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: SplashPage(),
    );

    MultiProvider multiProvider = MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: UserModel()),
        ChangeNotifierProvider.value(value: LocaleModel()),
        ChangeNotifierProvider.value(value: EhConfigModel()),
      ],
      child: cupertinoApp,
    );

    return multiProvider;
  }
}
