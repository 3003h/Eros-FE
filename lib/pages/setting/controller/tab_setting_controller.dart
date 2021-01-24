import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class TabSettingController extends GetxController {
  List<Widget> rows = <Widget>[];
  final TabHomeController _tabHomeController = Get.find();

  ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController =
        PrimaryScrollController.of(Get.context) ?? ScrollController();

    final RxList<String> _tabList = _tabHomeController.tabNameList;
    final RxMap<String, bool> _tabMap = _tabHomeController.tabMap;

    for (int index = 0; index < _tabList.length; index++) {
      final String key = _tabList[index];
      if (_tabMap[key] != null) {
        if (!Global.inDebugMode && key == EHRoutes.download) {
          continue;
        }

        rows.add(
          TextSwitchItem(
            tabPages.tabTitles[key],
            key: UniqueKey(),
            icon: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: Icon(
                tabPages.iconDatas[key],
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey, Get.context),
              ),
            ),
            iconIndent: 32,
            intValue: _tabMap[key],
            onChanged: key != EHRoutes.gallery
                ? (val) {
                    onChanged(val, key);
                  }
                : null,
          ),
        );
      }
    }
  }

  void onChanged(bool val, String key) {
    _tabHomeController.tabMap[key] = val;
    Get.find<TabHomeController>().resetIndex();
  }

  void onReorder(int oldIndex, int newIndex) {
    final Widget row = rows.removeAt(oldIndex);
    rows.insert(newIndex, row);

    final String name = _tabHomeController.tabNameList.removeAt(oldIndex);
    _tabHomeController.tabNameList.insert(newIndex, name);

    Get.find<TabHomeController>().resetIndex();

    update();
  }
}
