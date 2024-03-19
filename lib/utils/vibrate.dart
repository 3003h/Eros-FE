import 'dart:io';

import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

import 'logger.dart';

final VibrateUtil vibrateUtil = VibrateUtil();

class VibrateUtil {
  VibrateUtil();

  /// 设备是否具有控制振动幅度的能力
  Future<bool?> get _hasCustomVibrationsSupport =>
      Vibration.hasCustomVibrationsSupport();

  /// 设备是否能够按照自定义的持续时间，模式或强度振动
  Future<bool?> get _hasAmplitudeControl => Vibration.hasAmplitudeControl();

  EhSettingService get _ehSettingService => Get.find();

  Future<void> impact() async {
    if (!_ehSettingService.vibrate.value) {
      return;
    }
    if (Platform.isIOS || (await _hasAmplitudeControl ?? false)) {
      Vibrate.feedback(FeedbackType.impact);
    } else if (Platform.isAndroid) {
      Vibration.vibrate(duration: 2);
    }
  }

  Future<void> light() async {
    if (!_ehSettingService.vibrate.value) {
      return;
    }
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.light);
    } else if (Platform.isAndroid && (await _hasAmplitudeControl ?? false)) {
      Vibration.vibrate(amplitude: 100, duration: 5);
    } else if (Platform.isAndroid) {
      Vibration.vibrate(duration: 5);
    }
  }

  Future<void> medium() async {
    logger
        .v('_hasCustomVibrationsSupport:${await _hasCustomVibrationsSupport}\n'
            '_hasAmplitudeControl:${await _hasAmplitudeControl}');

    if (!_ehSettingService.vibrate.value) {
      return;
    }

    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.medium);
    } else if (Platform.isAndroid && (await _hasAmplitudeControl ?? false)) {
      Vibration.vibrate(amplitude: 120, duration: 15);
    } else if (Platform.isAndroid) {
      Vibration.vibrate(duration: 20);
    }
  }

  Future<void> heavy() async {
    if (!_ehSettingService.vibrate.value) {
      return;
    }
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.heavy);
    } else if (Platform.isAndroid && (await _hasAmplitudeControl ?? false)) {
      Vibration.vibrate(amplitude: 255, duration: 10);
    } else if (Platform.isAndroid) {
      Vibration.vibrate(duration: 35);
    }
  }

  Future<void> success() async {
    if (!_ehSettingService.vibrate.value) {
      return;
    }
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.success);
    }
  }

  Future<void> error() async {
    if (!_ehSettingService.vibrate.value) {
      return;
    }
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.error);
    }
  }
}
