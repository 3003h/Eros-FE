import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/custom_tabbar_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';

class CustomProfilesPage extends GetView<CustomTabbarController> {
  const CustomProfilesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _style = TextStyle(
      height: 1,
      color: CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context),
    );

    Widget normalView = Obx(() {
      return Column(
        children: controller.profiles
            .map((element) => SelectorSettingItem(
                  title: element.name,
                  onTap: () {
                    Get.toNamed(
                      EHRoutes.customProfileSetting,
                      arguments: element.uuid,
                    );
                  },
                ))
            .toList(),
      );
    });

    Widget reorderableView = Obx(() {
      return ReorderableColumn(
        onReorder: controller.onReorder,
        children: controller.profiles
            .map(
              (element) => Slidable(
                  key: ValueKey(element.uuid),
                  child: BarsItem(
                    title: element.name,
                    key: ValueKey(element.uuid),
                  ),
                  endActionPane: ActionPane(
                    extentRatio: 0.25,
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) =>
                            controller.deleteProfile(uuid: element.uuid),
                        backgroundColor: CupertinoDynamicColor.resolve(
                            CupertinoColors.systemRed, context),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        // label: L10n.of(context).delete,
                      ),
                    ],
                  )),
            )
            .toList(),
      );
    });

    final List<Widget> _list = <Widget>[
      GroupItem(
        title: '自定分组',
        child: Obx(() {
          return Column(
            children: [
              AnimatedCrossFade(
                secondChild: normalView,
                firstChild: reorderableView,
                crossFadeState: controller.reorderable
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: 300.milliseconds,
              ),
              TextItem(
                '新建分组',
                hideLine: true,
                textColor: CupertinoDynamicColor.resolve(
                    CupertinoColors.activeBlue, context),
                onTap: () => Get.toNamed(EHRoutes.customProfileSetting),
              ),
            ],
          );
        }),
      ),
    ];

    return WillPopScope(
      onWillPop: () async {
        controller.reorderable = false;
        return true;
      },
      child: Obx(() {
        return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
            middle: Text('Profile'),
            trailing: GestureDetector(
              onTap: () => controller.reorderable = !controller.reorderable,
              child: AnimatedCrossFade(
                secondChild: Text(
                  '编辑',
                  style: _style,
                ),
                firstChild: Text(
                  L10n.of(context).done,
                  style: _style,
                ),
                crossFadeState: controller.reorderable
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: 100.milliseconds,
              ),
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverSafeArea(
                bottom: false,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _list[index];
                    },
                    childCount: _list.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
