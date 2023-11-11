import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/controller/tab_setting_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';
import 'package:sliver_tools/sliver_tools.dart';

class TabbarSettingPage extends StatelessWidget {
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
        child: CustomScrollView(
          controller: Get.find<TabSettingController>().scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverSafeArea(
              left: false,
              right: false,
              sliver: MultiSliver(children: [
                const TablistView(),
                Container(
                  padding: const EdgeInsets.only(
                    left: 20,
                    top: 4,
                    bottom: 10,
                    right: 20,
                  ),
                  width: double.infinity,
                  child: Text(
                    L10n.of(context).tab_sort,
                    style: TextStyle(
                      fontSize: kSummaryFontSize,
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.secondaryLabel, context),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ]),
            ),
          ],
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
                hideDivider: e == controller.tabList.last,
                icon: Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: Icon(
                    tabPages.iconDatas[e],
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey, Get.context!),
                  ),
                ),
                iconIndent: 32,
                value: controller.tabMap[e] ?? false,
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
