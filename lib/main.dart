import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:fehviewer/common/controller/auto_lock_controller.dart';
import 'package:fehviewer/common/controller/log_controller.dart';
import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/store/get_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

import 'common/service/layout_service.dart';
import 'get_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded<Future<void>>(() async {
    // final dsn = await getSentryDsn();
    // if (dsn != null && dsn.isNotEmpty) {
    //   await SentryFlutter.init(
    //     (SentryFlutterOptions options) {
    //       options
    //         ..dsn = dsn
    //         ..debug = false
    //         ..diagnosticLevel = SentryLevel.warning;
    //     },
    //   );
    // }

    Get.lazyPut(() => LogService(), fenix: true);
    Get.lazyPut(() => GStore());
    await Global.init();

    getinit();

    if (Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    }

    if (Get.find<EhConfigService>().debugMode || kDebugMode) {
      Logger.level = Level.debug;
      logger.v('Level.debug');
    } else {
      Logger.level = Level.error;
    }
    resetLogLevel();

    updateTagTranslate();

    runApp(MyApp());
  }, (Object error, StackTrace stackTrace) async {
    if (error is EhError && error.type == EhErrorType.image509) {
      debugPrint('EhErrorType.image509');
      return;
    }
    debugPrint(
        'runZonedGuarded: Caught error in my root zone.\n$error\n$stackTrace');

    // if (!kDebugMode) {
    //   await Sentry.captureException(error, stackTrace: stackTrace);
    // }
  });
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
    WidgetsBinding.instance.addObserver(this);
    _autoLockController.resumed();
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
    Widget cupertinoApp({
      CupertinoThemeData? theme,
      Locale? locale,
    }) {
      return GetCupertinoApp(
        // debugShowCheckedModeBanner: false,
        onGenerateTitle: (BuildContext context) => L10n.of(context).app_title,
        navigatorObservers: [
          // if (GetPlatform.isMobile)
          //   FirebaseAnalyticsObserver(analytics: analytics),
          // SentryNavigatorObserver(),
          // FlutterSmartDialog.observer,
          MainNavigatorObserver(),
        ],
        // builder: kReleaseMode
        //     ? FlutterSmartDialog.init(
        //         styleBuilder: (child) => child,
        //       )
        //     : null,
        builder: FlutterSmartDialog.init(
          styleBuilder: (child) => child,
        ),
        getPages: AppPages.routes,
        defaultTransition: Transition.cupertino,
        initialRoute: EHRoutes.root,
        theme: theme,
        locale: locale,
        enableLog: false && kDebugMode,
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
          final Locale _locale = window.locale;
          logger.v(
              'system Locale \n${_locale.languageCode}  ${_locale.scriptCode}  ${_locale.countryCode}');
          // logger.d('${_locale} ${supportedLocales}');
          if (locale != null) {
            // logger.d('sel $locale');
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

Future<void> updateTagTranslate() async {
  await 10.seconds.delay();
  final EhConfigService ehConfigService = Get.find();
  final TagTransController tagTransController = Get.find();

  if (ehConfigService.tagTranslateDataUpdateMode ==
      TagTranslateDataUpdateMode.everyStartApp) {
    logger.d('updateTagTranslate everyStartApp');
    if (await tagTransController.checkUpdate()) {
      await tagTransController.updateDB();
    }
  }
}
