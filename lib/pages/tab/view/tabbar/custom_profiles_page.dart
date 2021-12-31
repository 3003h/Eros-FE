import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/custom_tabbar_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';

class CustomProfilesPage extends GetView<CustomTabbarController> {
  const CustomProfilesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _style = TextStyle(
        color:
            CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context));

    Widget normalView = Obx(() {
      return Column(
        children: controller.profiles
            .map((element) => SelectorSettingItem(
                  title: element.name,
                ))
            .toList(),
      );
    });

    Widget reorderableView = Obx(() {
      return ReorderableColumn(
        onReorder: (int oldIndex, int newIndex) {
          final _profile = controller.profiles.removeAt(oldIndex);
          controller.profiles.insert(newIndex, _profile);
        },
        children: controller.profiles
            .map((element) => BarsItem(
                  title: element.name,
                  key: UniqueKey(),
                ))
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
              ),
            ],
          );
        }),
      ),
    ];

    return Obx(() {
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
                'Edit',
                style: _style,
              ),
              firstChild: Text(
                'Done',
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
    });
  }
}
