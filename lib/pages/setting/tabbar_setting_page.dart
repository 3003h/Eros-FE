import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/setting/controller/tab_setting_controller.dart';
import 'package:eros_fe/pages/tab/controller/tabhome_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';
import 'package:sliver_tools/sliver_tools.dart';

class TabbarSettingPage extends StatelessWidget {
  const TabbarSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).tabbar_setting),
      ),
      child: CustomScrollView(slivers: [
        SliverSafeArea(
          sliver: MultiSliver(children: [
            SliverCupertinoListSection.listInsetGrouped(
              footer: Text(L10n.of(context).tab_sort),
              children: const [TabbarListView()],
            ),
          ]),
        ),
      ]),
    );
  }
}

class TabbarListView extends StatelessWidget {
  const TabbarListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TabSettingController controller = Get.put(TabSettingController());
    return Obx(() {
      return ReorderableColumn(
        onReorder: controller.onReorder,
        children: _buildList(context),
      );
    });
  }

  List<Widget> _buildList(BuildContext context) {
    final TabSettingController controller = Get.put(TabSettingController());
    final List<Widget> list = [];

    final Widget shortDivider = Container(
      margin: const EdgeInsetsDirectional.only(start: 60),
      color: CupertinoColors.separator.resolveFrom(context),
      height: 0.5,
    );

    Widget buildEhCupertinoListTile(String tag) {
      return EhCupertinoListTile(
        title: Text(tabPages.tabTitles[tag] ?? ''),
        key: ValueKey(tag),
        leading: Icon(
          tabPages.iconDatas[tag],
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey, context),
        ),
        trailing: Obx(() {
          return CupertinoSwitch(
            value: controller.tabMap[tag] ?? false,
            onChanged: (controller.disableSwitch && controller.tabMap[tag]!)
                ? null
                : (bool val) {
                    controller.onChanged(val, tag);
                  },
          );
        }),
      );
    }

    // for in controller.tabList -1
    for (int i = 0; i < controller.tabList.length - 1; i++) {
      final String tag = controller.tabList[i];
      list.add(
        Column(
          key: ValueKey(tag),
          children: [
            buildEhCupertinoListTile(controller.tabList[i]),
            shortDivider,
          ],
        ),
      );
    }

    list.add(
      buildEhCupertinoListTile(controller.tabList.last),
    );

    return list;
  }
}
