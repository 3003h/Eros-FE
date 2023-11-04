import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/group/custom_tabbar_controller.dart';
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
      // height: 1,
      color: CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context),
    );

    Widget buildNormalItem(CustomProfile element, {bool hideDivider = false}) {
      return Slidable(
        key: ValueKey(element.uuid),
        child: SelectorSettingItem(
          key: ValueKey(element.uuid),
          title: element.name,
          hideDivider: hideDivider,
          selector: (element.hideTab ?? false) ? L10n.of(context).hide : '',
          maxLines: 2,
          onTap: () {
            controller.toEditPage(uuid: element.uuid);
          },
        ),
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => controller.deleteProfile(uuid: element.uuid),
              backgroundColor: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemRed, context),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              // label: L10n.of(context).delete,
            ),
          ],
        ),
      );
    }

    Widget buildReorderableItem(CustomProfile element) {
      return BarsItem(
        title: element.name,
        maxLines: 2,
        hideDivider: true,
        key: ValueKey(element.uuid),
      );
    }

    Widget normalView = Obx(() {
      return Column(
        // children: controller.profiles.map(buildNormalItem).toList(),
        children: () {
          final List<Widget> _list = <Widget>[];
          for (var i = 0; i < controller.profiles.length; i++) {
            _list.add(buildNormalItem(controller.profiles[i],
                hideDivider: i == controller.profiles.length - 1));
          }
          return _list;
        }(),
      );
    });

    Widget reorderableView = Obx(() {
      return ReorderableColumn(
        onReorder: controller.onReorder,
        children: controller.profiles.map(buildReorderableItem).toList(),
      );
    });

    final List<Widget> _list = <Widget>[
      // GroupItem(
      //   title: L10n.of(context).group,
      //   child: Obx(() {
      //     return Column(
      //       children: [
      //         AnimatedCrossFade(
      //           secondChild: normalView,
      //           firstChild: reorderableView,
      //           crossFadeState: controller.reorderable
      //               ? CrossFadeState.showFirst
      //               : CrossFadeState.showSecond,
      //           duration: 300.milliseconds,
      //         ),
      //       ],
      //     );
      //   }),
      // ),
      Obx(() {
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
          ],
        );
      }),
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
            middle: Text(L10n.of(context).group),
            padding: const EdgeInsetsDirectional.only(end: 8),
            trailing: Obx(() {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 同步按钮
                  AnimatedOpacity(
                    opacity: Get.find<WebdavController>().syncGroupProfile &&
                            !controller.reorderable
                        ? 1
                        : 0,
                    duration: const Duration(milliseconds: 300),
                    child: CupertinoButton(
                      minSize: 40,
                      padding: const EdgeInsets.all(0),
                      child: const Icon(
                        CupertinoIcons.refresh_thick,
                        size: 26,
                      ),
                      onPressed: () async {
                        await controller.syncProfiles();
                      },
                    ),
                  ),
                  AnimatedCrossFade(
                    crossFadeState: controller.reorderable
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                    firstChild: CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      minSize: 40,
                      child: const Icon(
                        CupertinoIcons.sort_down_circle_fill,
                        size: 28,
                      ),
                      onPressed: () =>
                          controller.reorderable = !controller.reorderable,
                    ),
                    secondChild: CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      minSize: 40,
                      child: const Icon(
                        CupertinoIcons.sort_down_circle,
                        size: 28,
                      ),
                      onPressed: () =>
                          controller.reorderable = !controller.reorderable,
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    minSize: 40,
                    child: const Icon(
                      // FontAwesomeIcons.plus,
                      CupertinoIcons.plus_circle,
                      size: 28,
                    ),
                    onPressed: controller.toEditPage,
                  ),
                ],
              );
            }),
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
