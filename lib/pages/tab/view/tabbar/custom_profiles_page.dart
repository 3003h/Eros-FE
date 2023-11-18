import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/group/custom_tabbar_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';

class CustomProfilesPage extends GetView<CustomTabbarController> {
  const CustomProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Widget shortDivider = Container(
      margin: const EdgeInsetsDirectional.only(start: 20),
      color: CupertinoColors.separator.resolveFrom(context),
      height: 0.5,
    );

    Widget buildNormalItem(CustomProfile element, {bool isLast = false}) {
      Widget buildTile({Key? key}) => EhCupertinoListTile(
            key: key,
            title: Text(element.name),
            trailing: const CupertinoListTileChevron(),
            onTap: () {
              controller.toEditPage(uuid: element.uuid);
            },
          );

      return Slidable(
        key: ValueKey(element.uuid),
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => controller.deleteProfile(uuid: element.uuid),
              backgroundColor: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemRed, context),
              foregroundColor: Colors.white,
              icon: CupertinoIcons.delete,
              // label: L10n.of(context).delete,
            ),
          ],
        ),
        child: isLast
            ? buildTile(key: ValueKey(element.uuid))
            : Column(
                key: ValueKey(element.uuid),
                children: [
                  buildTile(),
                  shortDivider,
                ],
              ),
      );
    }

    Widget buildReorderableItem(CustomProfile element, {bool isLast = false}) {
      Widget _tile({Key? key}) => EhCupertinoListTile(
            key: key,
            trailing: const Icon(CupertinoIcons.bars),
            title: Text(element.name),
          );

      if (isLast) {
        return _tile(key: ValueKey(element.uuid));
      } else {
        return Column(
          key: ValueKey(element.uuid),
          children: [
            _tile(),
            shortDivider,
          ],
        );
      }
    }

    Widget normalView = Obx(() {
      return Column(
        children: () {
          final List<Widget> _list = <Widget>[];
          for (var i = 0; i < controller.profiles.length; i++) {
            _list.add(buildNormalItem(controller.profiles[i],
                isLast: i == controller.profiles.length - 1));
          }
          return _list;
        }(),
      );
    });

    Widget reorderableView = Obx(() {
      return ReorderableColumn(
        onReorder: controller.onReorder,
        children: () {
          final List<Widget> _list = <Widget>[];
          for (var i = 0; i < controller.profiles.length; i++) {
            _list.add(buildReorderableItem(controller.profiles[i],
                isLast: i == controller.profiles.length - 1));
          }
          return _list;
        }(),
      );
    });

    return WillPopScope(
      onWillPop: () async {
        controller.reorderable = false;
        return true;
      },
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
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
              sliver: SliverCupertinoListSection.listInsetGrouped(children: [
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
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
