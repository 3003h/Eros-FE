import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_page_large.dart';
import 'home_page_small.dart';

class TabHome extends GetView<TabHomeController> {
  @override
  Widget build(BuildContext context) {
    controller.init(inContext: context);

    final WillPopScope willPopScope = WillPopScope(
      onWillPop: controller.doubleClickBack,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800 && Global.inDebugMode) {
            logger.d('TabHomeLarge');
            return TabHomeLarge();
          } else {
            logger.d('TabHomeSmall');
            return TabHomeSmall();
          }
        },
      ),
    );

    return willPopScope;
  }
}
