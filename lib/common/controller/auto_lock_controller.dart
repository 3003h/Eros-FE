import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

import '../global.dart';

class AutoLockController extends GetxController {
  AutoLock get autoLock => Global.profile.autoLock;
  set autoLock(AutoLock val) =>
      Global.profile = Global.profile.copyWith(autoLock: val);
  final EhSettingService _ehSettingService = Get.find();

  static final IOSAuthMessages iOSAuthMessages = IOSAuthMessages(
      cancelButton: L10n.of(Get.context!).cancel,
      goToSettingsButton: L10n.of(Get.context!).tab_setting,
      goToSettingsDescription: 'Please set up your Touch & Face ID.',
      lockOut: 'Please reenable your Touch & Face ID');

  static final AndroidAuthMessages androidAuthMessages = AndroidAuthMessages(
    signInTitle: L10n.of(Get.context!).auth_signInTitle,
    biometricHint: L10n.of(Get.context!).auth_biometricHint,
    // biometricNotRecognized: 'Not recognized. Try again.',
    biometricSuccess: L10n.of(Get.context!).done,
    cancelButton: L10n.of(Get.context!).cancel,
  );

  /// 最后挂起时间
  int _lastLeaveTime = DateTime.now().millisecondsSinceEpoch;
  int get lastLeaveTime => _lastLeaveTime;
  set lastLeaveTime(int val) {
    _lastLeaveTime = val;
    autoLock = autoLock.copyWith(lastLeaveTime: val);
    Global.saveProfile();
  }

  void resetLastLeaveTime() {
    lastLeaveTime = DateTime.now().millisecondsSinceEpoch + 500;
  }

  bool _isLocking = false;
  bool get isLocking => _isLocking;
  set isLocking(bool val) {
    _isLocking = val;
    autoLock = autoLock.copyWith(isLocking: val);
    Global.saveProfile();
  }

  bool _isResumed = false;

  Future<bool> checkBiometrics({String? localizedReason}) async {
    final bool didAuthenticate = await localAuth.authenticate(
      localizedReason: localizedReason ?? ' ',
      authMessages: [
        AutoLockController.iOSAuthMessages,
        AutoLockController.androidAuthMessages,
      ],
    );
    return didAuthenticate;
  }

  void paused() {
    if (!_isLocking) {
      resetLastLeaveTime();
      _isResumed = false;
      logger.d('更新最后离开时间 $lastLeaveTime');
    } else {
      logger.t('保持原离开时间 不更新');
    }
  }

  Future<void> checkLock({bool forceLock = false}) async {
    final nowTime = DateTime.now().millisecondsSinceEpoch;
    final subTime = nowTime - lastLeaveTime;
    final autoLockTimeOut = _ehSettingService.autoLockTimeOut.value;

    logger.t('now time $nowTime, lastLeaveTime: $lastLeaveTime');

    final locked =
        autoLockTimeOut >= 0 && (subTime / 1000 > autoLockTimeOut || forceLock);
    logger.t('离开时间为: ${subTime}ms  锁定超时为: $autoLockTimeOut  需要解锁: $locked');

    if (locked && !_isResumed) {
      _isLocking = true;

      final result = await Get.toNamed(EHRoutes.unlockPage);

      if (result is bool) {
        final bool didAuthenticate = result;
        if (didAuthenticate) {
          localAuth.stopAuthentication();
          _isResumed = true;
          _isLocking = false;
        }
      }
    }
  }
}
