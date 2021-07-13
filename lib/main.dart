import 'dart:async';
import 'dart:ui';

import 'package:fehviewer/common/controller/auto_lock_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/common/service/log_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/tab/view/splash_page.dart';
import 'package:fehviewer/route/app_pages.dart';
import 'package:fehviewer/store/get_store.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';

import 'common/isolate_download/download_manager.dart';
import 'get_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFlutterFire();
  runZonedGuarded<Future<void>>(() async {
    Get.lazyPut(() => LogService(), fenix: true);
    Get.lazyPut(() => GStore());
    await Global.init();

    await _initializeFlutterFire();

    getinit();

    if (Get.find<EhConfigService>().debugMode) {
      Logger.level = Level.debug;
      logger.v('Level.debug');
    } else {
      Logger.level = Level.error;
    }
    resetLogLevel();

    downloadManagerIsolate.init();

    runApp(MyApp());
  }, (Object error, StackTrace stackTrace) {
    // logger.e('runZonedGuarded: Caught error in my root zone.');
    print('runZonedGuarded: Caught error in my root zone.');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

Future<void> _initializeFlutterFire() async {
  // Wait for Firebase to initialize
  await Firebase.initializeApp();

  // await FirebaseCrashlytics.instance
  //     .setCrashlyticsCollectionEnabled(!Global.inDebugMode);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Pass all uncaught errors to Crashlytics.
  final Function? originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    // Forward to original handler.
    // if (originalOnError != null) {
    //   originalOnError(errorDetails);
    // }
    originalOnError?.call(errorDetails);
  };
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final LocaleService localeService = Get.find();
  final ThemeService themeService = Get.find();
  final EhConfigService _ehConfigService = Get.find();
  final AutoLockController _autoLockController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _autoLockController.resumed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    themeService.platformBrightness.value =
        WidgetsBinding.instance?.window.platformBrightness;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // went to Background
      _autoLockController.paused();
    }
    if (state == AppLifecycleState.resumed) {
      // came back to Foreground
      // logger.d('resumed');
      _autoLockController.resumed();

      _ehConfigService.chkClipboardLink(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // logger.d(' MyApp build');
    Widget cupertinoApp({
      CupertinoThemeData? theme,
      Locale? locale,
    }) {
      return GetCupertinoApp(
        // builder: EasyLoading.init(),
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (BuildContext context) => S.of(context).app_title,
        // navigatorObservers: [
        //   FirebaseAnalyticsObserver(analytics: analytics),
        // ],
        getPages: AppPages.routes,
        defaultTransition: Transition.cupertino,
        // initialRoute: EHRoutes.root,
        home: SplashPage(),
        theme: theme,
        locale: locale,
        enableLog: false,
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
        localeResolutionCallback: (_, Iterable<Locale> supportedLocales) {
          final Locale _locale = window.locale;
          // logger.v(
          //     'Locale \n${_locale?.languageCode}  ${_locale?.scriptCode}  ${_locale?.countryCode}');
          // logger.d('${_locale} ${supportedLocales}');
          if (locale != null) {
            //如果已经选定语言，则不跟随系统
            return locale;
          } else {
            logger.d('语言跟随系统语言  ${window.locale}');

            Locale locale;
            //APP语言跟随系统语言，如果系统语言不是中文简体或美国英语，
            //则默认使用美国英语
            if (supportedLocales.contains(_locale)) {
              // logger.d('系统语言在支持列表中');
              locale = _locale;
            } else {
              locale = const Locale('en', 'US');
            }

            // 中文 简繁体处理
            if (_locale.languageCode == 'zh') {
              if (_locale.scriptCode == 'Hant') {
                locale = const Locale('zh', 'HK'); //繁体
              } else {
                locale = const Locale('zh', 'CN'); //简体
              }
            }
            // logger.d('$locale');
            return Locale(locale.languageCode, locale.countryCode);
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
