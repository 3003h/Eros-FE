import 'package:FEhViewer/pages/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'common/global.dart';
import 'route/application.dart';
import 'models/states/locale_model.dart';
import 'models/states/user_model.dart';

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
