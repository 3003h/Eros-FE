import 'package:device_preview/device_preview.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/dns_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/route/app_pages.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/store/gallery_store.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import 'common/controller/advance_search_controller.dart';
import 'common/controller/gallerycache_controller.dart';
import 'common/controller/history_controller.dart';
import 'common/controller/localfav_controller.dart';
import 'common/controller/quicksearch_controller.dart';
import 'common/controller/user_controller.dart';
import 'common/service/depth_service.dart';

void main() {
  Global.init().then((_) {
    Get.lazyPut(() => EhConfigService(), fenix: true);
    //LocaleController
    Get.lazyPut(() => LocaleService(), fenix: true);
    // ThemeController
    Get.lazyPut(() => ThemeService(), fenix: true);
    // DnsConfigController
    Get.put(DnsService(), permanent: true);

    Get.put(DepthService());

    /// 一些全局设置或者控制
    Get.put(LocalFavController(), permanent: true);
    Get.put(HistoryController(), permanent: true);
    Get.put(UserController(), permanent: true);
    Get.lazyPut(() => GalleryCacheController(), fenix: true);

    Get.put(QuickSearchController(), permanent: true);
    Get.lazyPut(() => AdvanceSearchController(), fenix: true);
    Get.lazyPut(() => GStore());

    runApp(
      DevicePreview(
        // enabled: Global.inDebugMode,
        enabled: false,
        builder: (BuildContext context) => MyApp(), // Wrap your app
      ),
    );
  }).catchError((e, stack) {
    logger.e('$e \n $stack');
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final LocaleService localeService = Get.find();
  final ThemeService themeService = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    themeService.platformBrightness.value =
        WidgetsBinding.instance.window.platformBrightness;
  }

  @override
  Widget build(BuildContext context) {
    Widget cupertinoApp({
      CupertinoThemeData theme,
      Locale locale,
    }) {
      return GetCupertinoApp(
        debugShowCheckedModeBanner: false,
        // translations: Messages(),
        onGenerateTitle: (BuildContext context) => S.of(context).app_title,
        getPages: AppPages.routes,
        initialRoute: EHRoutes.root,
        theme: theme,
        locale: locale,
        builder: DevicePreview.appBuilder,
        logWriterCallback: loggerGetx,
        // ignore: prefer_const_literals_to_create_immutables
        supportedLocales: <Locale>[
          const Locale('en', ''),
          ...S.delegate.supportedLocales,
          // const Locale('zh', 'CN'),
        ],
        // ignore: prefer_const_literals_to_create_immutables
        localizationsDelegates: [
          // 本地化的代理类
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback:
            (Locale _locale, Iterable<Locale> supportedLocales) {
          logger.v(
              'Locale \n${_locale?.languageCode}  ${_locale?.scriptCode}  ${_locale?.countryCode}');
          if (locale != null) {
            //如果已经选定语言，则不跟随系统
            return locale;
          } else {
            // logger.d('语言跟随系统语言');
            Locale locale;
            //APP语言跟随系统语言，如果系统语言不是中文简体或美国英语，
            //则默认使用美国英语
            if (supportedLocales.contains(_locale)) {
              // logger.d('语言跟随系统语言');
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
    }

    return OKToast(
      child: Obx(() => cupertinoApp(
            theme: themeService.themeData,
            locale: localeService.locale,
          )),
    );
  }
}
