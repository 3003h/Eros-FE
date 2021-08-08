import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_page_small.dart';
import 'home_page_small_persistent.dart';

class HomePage extends GetView<TabHomeController> {
  @override
  Widget build(BuildContext context) {
    controller.init(inContext: context);
    final LayoutServices layoutServices = Get.find();

    final WillPopScope willPopScope = WillPopScope(
      onWillPop: controller.doubleClickBack,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // logger.d('${constraints.maxWidth}');
          // if (context.width > 1080) {
          //   layoutServices.layoutMode = LayoutMode.large;
          //   return const TabHomeLarge(
          //     wide: true,
          //   );
          // } else if (context.width > 700) {
          //   layoutServices.layoutMode = LayoutMode.large;
          //   return const TabHomeLarge();
          // } else {
          //   layoutServices.layoutMode = LayoutMode.small;
          //   return TabHomeSmall();
          // }
          return TabHomeSmall();
        },
      ),
    );

    return willPopScope;
  }
}
