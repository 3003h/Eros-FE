import 'dart:io';

import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

final VibrateUtil vibrateUtil = VibrateUtil();

class VibrateUtil {
  VibrateUtil();

  /// 设备是否具有控制振动幅度的能力
  bool _hasCustomVibrationsSupport = false;

  /// 设备是否能够按照自定义的持续时间，模式或强度振动
  bool _hasAmplitudeControl = false;

  EhConfigService get _ehConfigService => Get.find();

  Future<void> init() async {
    _hasCustomVibrationsSupport =
        (await Vibration.hasAmplitudeControl()) ?? false;
    _hasAmplitudeControl =
        (await Vibration.hasCustomVibrationsSupport()) ?? false;
  }

  void light() {
    if (!_ehConfigService.vibrate.value) {
      return;
    }
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.light);
    } else if (Platform.isAndroid) {
      Vibration.vibrate(duration: 10);
    }
  }

  void medium() {
    if (!_ehConfigService.vibrate.value) {
      return;
    }
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.medium);
    } else if (Platform.isAndroid) {
      Vibration.vibrate(duration: 30);
    }
  }

  void heavy() {
    if (!_ehConfigService.vibrate.value) {
      return;
    }
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.heavy);
    } else if (Platform.isAndroid) {
      Vibration.vibrate(duration: 50);
    }
  }

  void success() {
    if (!_ehConfigService.vibrate.value) {
      return;
    }
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.success);
    }
  }

  void error() {
    if (!_ehConfigService.vibrate.value) {
      return;
    }
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.error);
    }
  }
}
