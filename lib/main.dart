import 'dart:async';
import 'dart:ui';

import 'package:device_preview/device_preview.dart';
import 'package:fehviewer/common/controller/auto_lock_controller.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/common/service/log_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/route/app_pages.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/store/get_store.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';

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

    runApp(!kReleaseMode
        ? DevicePreview(
            // enabled: !kReleaseMode,
            enabled: false,
            isToolbarVisible: true,
            builder: (context) => MyApp(),
          )
        : MyApp());
  }, (Object error, StackTrace stackTrace) {
    if (error is EhError && error.type == EhErrorType.image509) {
      debugPrint('EhErrorType.image509');
      return;
    }
    debugPrint('runZonedGuarded: Caught error in my root zone.');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

Future<void> _initializeFlutterFire() async {
  // Wait for Firebase to initialize
  await Firebase.initializeApp();

  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  // Pass all uncaught errors to Crashlytics.
  final Function? originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
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
    if (state != AppLifecycleState.resumed) {
      // went to Background
      // loggerTime.d('paused');
      _autoLockController.paused();
    }
    if (state == AppLifecycleState.resumed) {
      // came back to Foreground
      // loggerTime.d('resumed');
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
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (BuildContext context) => L10n.of(context).app_title,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
          FlutterSmartDialogCupertino.observer,
        ],
        builder: FlutterSmartDialogCupertino.init(),
        getPages: AppPages.routes,
        defaultTransition: Transition.cupertino,
        initialRoute: EHRoutes.root,
        theme: theme,
        locale: locale,
        enableLog: false,
        logWriterCallback: loggerGetx,
        supportedLocales: <Locale>[
          ...L10n.delegate.supportedLocales,
        ],
        localizationsDelegates: const [
          // 本地化的代理类
          L10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (_, Iterable<Locale> supportedLocales) {
          final Locale _locale = DevicePreview.locale(context) ?? window.locale;
          logger.d(
              'system Locale \n${_locale.languageCode}  ${_locale.scriptCode}  ${_locale.countryCode}');
          // logger.d('${_locale} ${supportedLocales}');
          if (locale != null) {
            logger.d('sel $locale');
            //如果已经选定语言，则不跟随系统
            return locale;
          } else {
            logger.d('语言跟随系统语言  $_locale');
            return null;
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
