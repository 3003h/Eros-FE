import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class TabHomeSmall extends GetView<TabHomeController> {
  const TabHomeSmall({super.key});
  @override
  Widget build(BuildContext context) {
    controller.init(inContext: context);

    return Obx(() => CupertinoTabScaffold(
          controller: controller.tabController,
          tabBar: CupertinoTabBar(
            backgroundColor: kEnableImpeller
                ? CupertinoTheme.of(context).barBackgroundColor.withOpacity(1)
                : null,
            items: controller.listBottomNavigationBarItem,
            onTap: controller.onTap,
          ),
          tabBuilder: (BuildContext context, int index) {
            // return controller.viewList[index];
            return CupertinoTabView(
              builder: (BuildContext context) {
                // logger.d('build CupertinoTabView');
                return controller.viewList[index];
              },
            );
          },
        ));
  }
}
