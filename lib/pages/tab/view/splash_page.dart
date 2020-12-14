import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/splash_controller.dart';

/// 闪屏页
class SplashPage extends GetView<SplashController> {
  @override
  Widget build(BuildContext context) {
    final Widget container = (controller.sharedText != null &&
            controller.sharedText.isNotEmpty)
        ? Container(
            child:
                const Center(child: CupertinoActivityIndicator(radius: 20.0)),
          )
        : Container(
            child: Center(
              child: Column(
                // center the children
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.local_cafe,
                    // FontAwesomeIcons.heading,
                    size: 150.0,
                    color: Colors.grey,
                  ),
                  Text(
                    'welcome_text'.tr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'app_title'.tr,
                    style: const TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
          );

    return CupertinoPageScaffold(
      child: container,
    );
  }
}
