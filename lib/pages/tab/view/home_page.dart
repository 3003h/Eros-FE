import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/tab/controller/tabhome_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_page_large.dart';
import 'home_page_small.dart';

class HomePage extends GetView<TabHomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // controller.init(inContext: context);
    final LayoutServices layoutServices = Get.find();
    final EhSettingService ehSettingService = Get.find();

    final child = Obx(
      () {
        final tabletLayoutType = ehSettingService.tabletLayoutType;
        final half = layoutServices.half;
        final vOffset = layoutServices.sideProportion;

        logger.t(' ${context.width} ${context.height}');

        layoutServices.layoutMode = getLayoutMode(context, tabletLayoutType);

        if (isLayoutLarge) {
          return TabHomeLarge(
            sideProportion: vOffset,
          );
        } else {
          return const TabHomeSmall();
        }
      },
    );

    // return PopScope(
    //   canPop: false,
    //   onPopInvoked: controller.onPopInvoked,
    //   child: child,
    // );

    return WillPopScope(
      onWillPop: controller.onWillPop,
      child: child,
    );
  }

  LayoutMode getLayoutMode(
      BuildContext context, TabletLayout tabletLayoutType) {
    // 非平板
    if (!context.isTablet) {
      return LayoutMode.small;
    } else {
      // 平板
      if (tabletLayoutType == TabletLayout.never) {
        return LayoutMode.small;
      } else if (tabletLayoutType == TabletLayout.landscape &&
          !context.isLandscape) {
        return LayoutMode.small;
      } else {
        return LayoutMode.large;
      }
    }
  }
}
