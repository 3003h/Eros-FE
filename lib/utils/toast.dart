import 'package:fehviewer/common/service/theme_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart' as oktoast;
import 'package:oktoast/oktoast.dart';

void showToast(
  String msg, {
  ToastPosition? position =
      const ToastPosition(align: Alignment.bottomCenter, offset: -60.0),
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
                    CupertinoColors.systemGrey, Get.context!)
                .withOpacity(0.1),
            offset: const Offset(0, 5),
            blurRadius: 10, //阴影模糊程度
            spreadRadius: 3, //阴影扩散程度
          ),
        ],
      ),
      child: CupertinoPopupSurface(
        child: Container(
          padding: const EdgeInsets.all(10),
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
                LineIcons.fill,
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
    position: ToastPosition.center,
    onDismiss: () => _isShowing509 = false,
  );
}
