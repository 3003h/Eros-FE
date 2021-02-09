import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/auto_lock_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class UnlockPageController extends GetxController {
  final _infoText = ''.obs;
  get infoText => _infoText.value;
  set infoText(val) => _infoText.value = val;

  Future<bool> _unlock() async {
    infoText = '';
    try {
      final bool didAuthenticate = await localAuth.authenticateWithBiometrics(
        localizedReason: '验证以解锁应用',
        iOSAuthStrings: AutoLockController.iosStrings,
        androidAuthStrings: AutoLockController.androidStrings,
      );
      return didAuthenticate;
    } on PlatformException catch (e, stack) {
      logger.e('$e\n$stack');
      switch (e.code) {
        case auth_error.notAvailable:
        default:
          infoText = e.message;
          break;
      }
      rethrow;
    }
  }

  Future<void> unlockAndback() async {
    Future.delayed(const Duration(milliseconds: 500));
    final didAuthenticate = await _unlock();
    if (didAuthenticate) {
      Get.back(result: didAuthenticate);
    }
  }
}
