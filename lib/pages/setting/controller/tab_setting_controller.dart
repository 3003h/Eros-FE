import 'package:eros_fe/pages/tab/controller/tabhome_controller.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class TabSettingController extends GetxController {
  // List<Widget> rows = <Widget>[];
  final TabHomeController _tabHomeController = Get.find();

  ScrollController? scrollController;

  RxList<String> get tabList => _tabHomeController.tabNameList;
  RxMap<String, bool> get tabMap => _tabHomeController.tabMap;
  bool get disableSwitch => _showInBarCount == 1;

  int get _showInBarCount => _tabHomeController.tabMap.entries
      .where((element) => element.value)
      .length;

  @override
  void onInit() {
    super.onInit();
    scrollController =
        PrimaryScrollController.maybeOf(Get.context!) ?? ScrollController();
  }

  void onChanged(bool val, String key) {
    _tabHomeController.tabMap[key] = val;
    Get.find<TabHomeController>().resetIndex();
    logger.d('_showInBarCount $_showInBarCount');
  }

  void onReorder(int oldIndex, int newIndex) {
    final row = tabList.removeAt(oldIndex);
    tabList.insert(newIndex, row);

    Get.find<TabHomeController>().resetIndex();

    update();
  }
}
