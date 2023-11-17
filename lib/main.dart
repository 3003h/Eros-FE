import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fehviewer/common/controller/auto_lock_controller.dart';
import 'package:fehviewer/common/controller/log_controller.dart';
import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/widget/system_ui_overlay.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'firebase_options_sample.dart' as fo;
import 'get_init.dart';
import 'widget/desktop.dart';

Future<void> main() async {
  // BindingBase.debugZoneErrorsAreFatal = true;
  // runZonedGuarded<Future<void>>(() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dsn = await getSentryDsn();

  Global.enableFirebase =
      fo.DefaultFirebaseOptions.currentPlatform.apiKey.isNotEmpty;

  if (Global.enableFirebase) {
    final FirebaseApp firebaseApp = await Firebase.initializeApp(
      options: fo.DefaultFirebaseOptions.currentPlatform,
    );
    Global.firebaseApp = firebaseApp;
    Global.analytics = FirebaseAnalytics.instanceFor(app: firebaseApp);
  }

  Get.lazyPut(() => LogService(), fenix: true);

  await Global.init();
  getinit();
  Global.proxyInit();

  if (Get.find<EhSettingService>().debugMode || kDebugMode) {
    Logger.level = Level.debug;
    logger.t('Level.debug');
  } else {
    Logger.level = Level.error;
  }
  resetLogLevel();
  updateTagTranslate();

  if (Global.enableFirebase) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  if (dsn != null && dsn.isNotEmpty) {
    await SentryFlutter.init(
      (SentryFlutterOptions options) {
        options
          ..dsn = dsn
          // ..debug = kDebugMode
          ..diagnosticLevel = SentryLevel.warning;
      },
      appRunner: () => runApp(MyApp()),
    );
  } else {
    runApp(MyApp());
  }

  if (GetPlatform.isDesktop) {
    doWhenWindowReady(() {
      const minSize = Size(400, 400);
      appWindow.minSize = minSize;
      // appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = L10n.current.app_title;
      appWindow.show();
    });

    // setWindowTitle(L10n.of(Get.context!).app_title);
  }
  // }, (Object error, StackTrace stackTrace) async {
  //   if (error is EhError && error.type == EhErrorType.image509) {
  //     debugPrint('EhErrorType.image509');
  //     return;
  //   }
  //   if (error is NetworkException) {
  //     debugPrint('NetworkException');
  //     return;
  //   }
  //   if (error is CancelException) {
  //     debugPrint('CancelException');
  //     return;
  //   }
  //
  //   debugPrint(
  //       'runZonedGuarded: Caught error in my root zone.\n$error\n$stackTrace');
  //
  //   if (!kDebugMode) {
  //     await Sentry.captureException(error, stackTrace: stackTrace);
  //   }
  // });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final LocaleService localeService = Get.find();
  final ThemeService themeService = Get.find();
  final EhSettingService _ehSettingService = Get.find();
  final AutoLockController _autoLockController = Get.find();

  late final AppLifecycleListener _listener;
  late AppLifecycleState? _state;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoLockController.checkLock();

    _state = SchedulerBinding.instance.lifecycleState;
    _listener = AppLifecycleListener(
      onShow: () {
        _handleTransition('show');
        // Get.toNamed(EHRoutes.unlockPage);
        // _autoLockController.checkLock();
      },
      onResume: () async {
        _handleTransition('resume');

        await _autoLockController.checkLock();

        // resumed 时清除 FLAG_SECURE ,避免无法截屏
        FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);

        if (context.mounted) {
          _ehSettingService.chkClipboardLink(context);
        }
      },
      onHide: () {
        _handleTransition('hide');
        _autoLockController.paused();
      },
      onInactive: () {
        _handleTransition('inactive');
        // 添加 FLAG_SECURE
        _ehSettingService.applyBlurredInRecentTasks();
      },
      onPause: () => _handleTransition('pause'),
      onDetach: () => _handleTransition('detach'),
      onRestart: () => _handleTransition('restart'),
    );
  }

  void _handleTransition(String name) {
    logger.d('########################## main $name');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    themeService.platformBrightness.value =
        View.of(context).platformDispatcher.platformBrightness;
  }

  @override
  Widget build(BuildContext context) {
    Widget cupertinoApp() {
      return Obx(() {
        return GetCupertinoApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (BuildContext context) => L10n.of(context).app_title,
          navigatorObservers: [
            if (GetPlatform.isMobile && Global.analytics != null)
              FirebaseAnalyticsObserver(analytics: Global.analytics!),
            SentryNavigatorObserver(),
            FlutterSmartDialog.observer,
            MainNavigatorObserver(),
          ],
          // builder: kReleaseMode
          //     ? FlutterSmartDialog.init(
          //         styleBuilder: (child) => child,
          //       )
          //     : null,
          // builder: FlutterSmartDialog.init(
          //   styleBuilder: (child) {
          //     if (GetPlatform.isDesktop) {
          //       return Desktop(child: child);
          //     } else {
          //       return child;
          //     }
          //   },
          // ),
          builder: SystemUIOverlay.init(
            builder: FlutterSmartDialog.init(
              styleBuilder: (child) {
                if (GetPlatform.isDesktop) {
                  return Desktop(child: child);
                } else {
                  return child;
                }
              },
            ),
          ),

          getPages: AppPages.routes,
          defaultTransition: Transition.cupertino,
          initialRoute: EHRoutes.root,
          theme: themeService.themeData,
          locale: localeService.locale,
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
            final Locale locale = PlatformDispatcher.instance.locale;

            return localeService.locale ??
                supportedLocales.firstWhere(
                  (Locale sl) => sl.languageCode == locale.languageCode,
                  orElse: () => supportedLocales.first,
                );
          },
        );
      });
    }

    return OKToast(
      child: cupertinoApp(),
    );
  }
}

Future<void> updateTagTranslate() async {
  await 10.seconds.delay();
  final EhSettingService ehSettingService = Get.find();
  final TagTransController tagTransController = Get.find();

  if (ehSettingService.tagTranslateDataUpdateMode ==
      TagTranslateDataUpdateMode.everyStartApp) {
    logger.t('updateTagTranslate everyStartApp');
    if (await tagTransController.checkUpdate()) {
      await tagTransController.updateDB();
    }
  }
}
