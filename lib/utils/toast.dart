import 'package:fehviewer/common/service/theme_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart' as oktoast;

void showToast(
  String msg, {
  Duration duration = const Duration(seconds: 3),
  oktoast.ToastPosition? position =
      const oktoast.ToastPosition(align: Alignment.bottomCenter, offset: -60.0),
}) {
  final Widget widget = CupertinoTheme(
    data: Get.find<ThemeService>().themeData!,
    child: Container(
      margin: const EdgeInsets.all(50.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: CupertinoDynamicColor.resolve(
                    CupertinoColors.darkBackgroundGray, Get.context!)
                .withOpacity(0.16),
            offset: const Offset(0, 8),
            blurRadius: 20, //阴影模糊程度
            spreadRadius: 4, //阴影扩散程度
          ),
        ],
      ),
      child: CupertinoPopupSurface(
        child: Container(
          padding: const EdgeInsets.all(10),
          color: CupertinoTheme.of(Get.context!).barBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                msg,
                textScaleFactor: 0.8,
                style: CupertinoTheme.of(Get.context!).textTheme.textStyle,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  oktoast.showToastWidget(
    widget,
    position: position,
    duration: duration,
  );
}

// 同时间只显示一个。防止叠加
bool _isShowing509 = false;
void show509Toast() {
  if (_isShowing509) {
    return;
  }
  _isShowing509 = true;
  final Widget widget = ClipRect(
    child: CupertinoTheme(
      data: Get.find<ThemeService>().themeData!,
      child: CupertinoPopupSurface(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                // LineIcons.toriiGate,
                FontAwesomeIcons.fill,
                size: 80,
                color: CupertinoColors.systemPink,
              ),
              Text(
                'IMAGE 509',
                textScaleFactor: 0.8,
                style: CupertinoTheme.of(Get.context!).textTheme.textStyle,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  oktoast.showToastWidget(
    widget,
    position: oktoast.ToastPosition.center,
    onDismiss: () => _isShowing509 = false,
    duration: 3.seconds,
  );
}

void showActionToast(String msg, {IconData? icon, VoidCallback? onPressed}) {
  SmartDialog.show(
    alignment: Alignment.bottomCenter,
    useAnimation: true,
    displayTime: 5.seconds,
    // consumeEvent: true,
    usePenetrate: true,
    clickMaskDismiss: false,
    maskColor: Colors.transparent,
    builder: (_) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: CupertinoDynamicColor.resolve(
                    CupertinoColors.darkBackgroundGray, Get.context!)
                .withOpacity(0.16),
            offset: const Offset(0, 0),
            blurRadius: 20, //阴影模糊程度
            spreadRadius: 4, //阴影扩散程度
          ),
        ],
      ),
      child: ClipRect(
        child: CupertinoTheme(
          data: Get.find<ThemeService>().themeData!,
          child: CupertinoPopupSurface(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg,
                    textScaleFactor: 0.8,
                    style: CupertinoTheme.of(Get.context!).textTheme.textStyle,
                    softWrap: true,
                  ),
                  CupertinoButton(
                    minSize: 20,
                    child: Icon(
                      icon,
                      size: 18,
                    ),
                    padding: const EdgeInsets.only(left: 28),
                    onPressed: () {
                      SmartDialog.dismiss();
                      onPressed?.call();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
