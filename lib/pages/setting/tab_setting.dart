import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/controller/tab_setting_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';

class TabSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          middle: Text(L10n.of(context).tabbar_setting),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            controller: Get.find<TabSettingController>().scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.only(left: 20, bottom: 4),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    L10n.of(context).tab_sort,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const TablistView(),
            ],
          ),
        ),
      );
    });
  }
}

class TablistView extends StatelessWidget {
  const TablistView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TabSettingController controller = Get.put(TabSettingController());
    return Obx(() {
      return ReorderableSliverList(
        delegate: ReorderableSliverChildListDelegate(controller.tabList
            .map(
              (e) => TextSwitchItem(
                tabPages.tabTitles[e] ?? '',
                key: UniqueKey(),
                icon: Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: Icon(
                    tabPages.iconDatas[e],
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey, Get.context!),
                  ),
                ),
                iconIndent: 32,
                intValue: controller.tabMap[e],
                onChanged: (controller.disableSwitch && controller.tabMap[e]!)
                    ? null
                    : (bool val) {
                        controller.onChanged(val, e);
                      },
              ),
            )
            .toList()),
        onReorder: controller.onReorder,
      );
    });
  }
}
