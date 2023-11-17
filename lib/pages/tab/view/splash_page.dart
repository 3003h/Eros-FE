import 'package:fehviewer/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../controller/splash_controller.dart';

/// 闪屏页
class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Widget container = (controller.sharedText != null &&
            (controller.sharedText?.isNotEmpty ?? false))
        ? const Center(child: CupertinoActivityIndicator(radius: 20.0))
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.cat,
                  // FontAwesomeIcons.heading,
                  size: 150.0,
                  color: Colors.grey,
                ),
                Text(
                  L10n.of(context).app_title,
                  style: const TextStyle(color: Colors.grey),
                ).paddingSymmetric(vertical: 20),
              ],
            ),
          );

    return CupertinoPageScaffold(
      child: container,
    );
  }
}
