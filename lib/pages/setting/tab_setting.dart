import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/controller/tab_setting_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';

class TabSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      navigationBar: CupertinoNavigationBar(
        middle: Text(S.of(context)!.tabbar_setting),
      ),
      child: SafeArea(
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
                  S.of(context)!.tab_sort,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const TablistView(),
          ],
        ),
      ),
    );
  }
}

class TablistView extends StatelessWidget {
  const TablistView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TabSettingController>(
        init: TabSettingController(),
        builder: (TabSettingController controller) {
          return ReorderableSliverList(
            delegate: ReorderableSliverChildListDelegate(controller.rows),
            onReorder: controller.onReorder,
          );
        });
  }
}
