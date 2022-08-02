import 'package:fehviewer/common/controller/auto_lock_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/route/app_pages.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class UnlockPageController extends GetxController {
  final _infoText = ''.obs;
  String get infoText => _infoText.value;
  set infoText(String val) => _infoText.value = val;

  Future<bool> _unlock({required BuildContext context}) async {
    infoText = '';
    try {
      final bool didAuthenticate = await localAuth.authenticate(
        localizedReason: ' ',
        authMessages: <AuthMessages>[
          AutoLockController.iOSAuthMessages,
          AutoLockController.androidAuthMessages,
        ],
      );
      return didAuthenticate;
    } on PlatformException catch (e, stack) {
      logger.e('$e\n$stack');
      switch (e.code) {
        case auth_error.notAvailable:
        default:
          infoText = e.message as String;
          break;
      }
      rethrow;
    }
  }

  Future<void> unlockAndback({required BuildContext context}) async {
    await Future.delayed(kUnLockPageTransitionDuration);
    final didAuthenticate = await _unlock(context: context);
    if (didAuthenticate) {
      Get.back(result: didAuthenticate);
    }
  }
}
