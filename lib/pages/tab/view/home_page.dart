import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/const/const.dart';
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
          return LayoutBuilder(
            builder: (context, constraints) {
              logger.v('${constraints.maxWidth}');
              if (context.width >= kThresholdTabletWidth &&
                  context.isTablet &&
                  tabletLayout) {
                layoutServices.layoutMode = LayoutMode.large;
                // layoutServices.layoutMode = LayoutMode.small;
              } else {
                layoutServices.layoutMode = LayoutMode.small;
              }

              if (!isLayoutLarge) {
                return const TabHomeSmall();
              }

              if (context.width >= kThresholdTabletWidth) {
                // return const TabHomeSmall();
                return TabHomeLarge(
                  sideProportion: vOffset,
                );
              } else {
                // return const TabHomeSmall();
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );

    return willPopScope;
  }
}
