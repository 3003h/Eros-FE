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
      onWillPop: controller.onWillPop,
      child: Obx(
        () {
          final tabletLayout = _ehConfigService.tabletLayout;
          final half = layoutServices.half;
          final vOffset = layoutServices.sideProportion;

          logger.v(' ${context.width} ${context.height}');

          if (context.isTablet && tabletLayout) {
            layoutServices.layoutMode = LayoutMode.large;
          } else {
            layoutServices.layoutMode = LayoutMode.small;
          }

          if (isLayoutLarge) {
            return TabHomeLarge(
              sideProportion: vOffset,
            );
          } else {
            return const TabHomeSmall();
          }
        },
      ),
    );

    return willPopScope;
  }
}
