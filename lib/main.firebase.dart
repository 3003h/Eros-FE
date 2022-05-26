import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview/device_preview.dart';
import 'package:fehviewer/common/controller/log_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/store/get_store.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'get_init.dart';
import 'main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  enableFirebase = true;
  await _initializeFlutterFire();
  runZonedGuarded<Future<void>>(() async {
    final dsn = await getSentryDsn();
    if (dsn != null && dsn.isNotEmpty) {
      await SentryFlutter.init(
        (SentryFlutterOptions options) {
          options
            ..dsn = dsn
            ..debug = false
            ..diagnosticLevel = SentryLevel.warning;
        },
      );
    }

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

    runApp(kReleaseMode || GetPlatform.isDesktop
        ? MyApp()
        : DevicePreview(
            // enabled: !kReleaseMode,
            enabled: false,
            isToolbarVisible: true,
            builder: (context) => MyApp(),
          ));
  }, (Object error, StackTrace stackTrace) async {
    if (error is EhError && error.type == EhErrorType.image509) {
      debugPrint('EhErrorType.image509');
      return;
    }
    debugPrint(
        'runZonedGuarded: Caught error in my root zone.\n$error\n$stackTrace');
    if (!Platform.isWindows && !kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
    if (!kDebugMode) {
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  });
}

Future<void> _initializeFlutterFire() async {
  // Wait for Firebase to initialize
  if (Platform.isWindows) {
    return;
  }
  final firebaseApp = await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );

  analytics = FirebaseAnalytics.instanceFor(app: firebaseApp);
  firestore = FirebaseFirestore.instance;

  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  // Pass all uncaught errors to Crashlytics.
  final Function? originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    originalOnError?.call(errorDetails);
  };
}
