import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_page_large.dart';
import 'home_page_small.dart';

class HomePage extends GetView<TabHomeController> {
  @override
  Widget build(BuildContext context) {
    controller.init(inContext: context);
    final LayoutServices layoutServices = Get.find();
    final EhConfigService _ehConfigService = Get.find();

    final WillPopScope willPopScope = WillPopScope(
      onWillPop: controller.doubleClickBack,
      child: Obx(() {
        final tabletLayout = _ehConfigService.tabletLayout;
        return LayoutBuilder(
          builder: (context, constraints) {
            logger.v('${constraints.maxWidth}');
            if (context.width > 700 && context.isTablet && tabletLayout) {
              layoutServices.layoutMode = LayoutMode.large;
            } else {
              layoutServices.layoutMode = LayoutMode.small;
            }

            if (!isLayoutLarge) {
              return TabHomeSmall();
            }

            if (context.width > 1080) {
              return const TabHomeLarge(wide: true);
            } else if (context.width > 700) {
              return const TabHomeLarge();
            } else {
              return TabHomeSmall();
            }
          },
        );
      }),
    );

    return willPopScope;
  }
}
