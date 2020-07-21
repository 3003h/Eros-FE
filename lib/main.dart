import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/models/states/locale_model.dart';
import 'package:FEhViewer/models/states/user_model.dart';
import 'package:FEhViewer/pages/splash_page.dart';
import 'package:FEhViewer/route/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'models/states/gallery_model.dart';

void main() => Global.init().then((e) => runApp(MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget cupertinoApp = Consumer<LocaleModel>(
        builder: (BuildContext context, localeModel, Widget child) {
      return CupertinoApp(
        onGenerateTitle: (context) => S.of(context).app_title,
        onGenerateRoute: Application.router.generator,
        theme: CupertinoThemeData(
          brightness: Brightness.light,
//          textTheme: CupertinoTextThemeData(
//            textStyle: TextStyle(
//              fontFamilyFallback: EHConst.FONT_FAMILY_FB,
//              color: CupertinoColors.black,
//              fontSize: 18,
//            ),
//          ),
        ),
        home: SplashPage(),
        locale: localeModel.getLocale(),
        supportedLocales: [
          const Locale('en', ''),
          ...S.delegate.supportedLocales
        ],
        localizationsDelegates: [
          // 本地化的代理类
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback:
            (Locale _locale, Iterable<Locale> supportedLocales) {
          Global.loggerNoStack.v(
              '${_locale?.languageCode}  ${_locale?.scriptCode}  ${_locale?.countryCode}');
          if (localeModel.getLocale() != null) {
            //如果已经选定语言，则不跟随系统
            return localeModel.getLocale();
          } else {
            Locale locale;
            //APP语言跟随系统语言，如果系统语言不是中文简体或美国英语，
            //则默认使用美国英语
            if (supportedLocales.contains(_locale)) {
              locale = _locale;
            } else {
              locale = Locale('en', 'US');
            }

            // 中文 简繁体处理
            if (_locale?.languageCode == 'zh') {
              if (_locale?.scriptCode == 'Hant') {
                locale = Locale('zh', 'HK'); //繁体
              } else {
                locale = Locale('zh', 'CN'); //简体
              }
            }
            return locale;
          }
        },
      );
    });

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
