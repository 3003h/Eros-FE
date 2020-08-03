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
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';

void main() => Global.init().then((e) => runApp(MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Widget cupertinoApp = Consumer<LocaleModel>(
        builder: (BuildContext context, LocaleModel localeModel, Widget child) {
      return CupertinoApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (BuildContext context) => S.of(context).app_title,
        onGenerateRoute: Application.router.generator,
        theme: const CupertinoThemeData(
          brightness: Brightness.light,
//          textTheme: CupertinoTextThemeData(
//            textStyle: TextStyle(
//              textBaseline: TextBaseline.alphabetic,
//              fontFamilyFallback: EHConst.FONT_FAMILY_FB,
//              color: CupertinoColors.black,
//              fontSize: 17,
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
              locale = const Locale('en', 'US');
            }

            // 中文 简繁体处理
            if (_locale?.languageCode == 'zh') {
              if (_locale?.scriptCode == 'Hant') {
                locale = const Locale('zh', 'HK'); //繁体
              } else {
                locale = const Locale('zh', 'CN'); //简体
              }
            }
            return locale;
          }
        },
      );
    });

    final MultiProvider multiProvider = MultiProvider(
      providers: [
        ChangeNotifierProvider<UserModel>.value(value: UserModel()),
        ChangeNotifierProvider<LocaleModel>.value(value: LocaleModel()),
        ChangeNotifierProvider<EhConfigModel>.value(value: EhConfigModel()),
      ],
      child: OKToast(child: cupertinoApp),
    );

    return multiProvider;
  }
}
