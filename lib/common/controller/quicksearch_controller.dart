import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

class QuickSearchController extends ProfileController {
  RxList<String> searchTextList = <String>[].obs;
  final WebdavController webdavController = Get.find();
  int lastEditTime = 0;

  List<String> get _trimList =>
      searchTextList.map((element) => element.trim()).toList();

  void addText(String text, {bool silent = false}) {
    if (_trimList.contains(text.trim()) || text.trim().isEmpty) {
      return;
    } else {
      searchTextList.add(text.trim());
      if (!silent) {
        showToast(L10n.of(Get.context!).saved_successfully);
      }
    }
  }

  void removeTextAt(int idx) {
    searchTextList.removeAt(idx);
  }

  void removeAll() {
    searchTextList.clear();
  }

  Future<void> syncQuickSearch() async {
    final _remoteTimes = await webdavController.getQuickList();
    if (_remoteTimes.isEmpty) {
      await webdavController.uploadQuickSearch(searchTextList, lastEditTime);
      return;
    }

    final _rs =
        await webdavController.downloadQuickSearch(_remoteTimes.reduce(max));
    final remoteTime = _rs?.item2 ?? 0;
    // 远程时间大于等于本地最后编辑时间 下载远程数据
    if (remoteTime >= lastEditTime) {
      _rs?.item1.forEach((e) => addText(e, silent: true));
    } else {
      await webdavController.uploadQuickSearch(searchTextList, lastEditTime);
      for (final time in _remoteTimes) {
        await webdavController.deleteQuickSearch(time);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    final Profile _profile = Global.profile;
    searchTextList(_profile.searchText.map((e) => e.toString()).toList());

    lastEditTime = hiveHelper.getQuickSearchLastEditTime();

    syncQuickSearch();

    everProfile<List<String>>(searchTextList, (List<String> value) {
      Global.profile = Global.profile.copyWith(searchText: value);
      lastEditTime = DateTime.now().millisecondsSinceEpoch;
      logger.d('lastEditTime: $lastEditTime');
      hiveHelper.setQuickSearchLastEditTime(lastEditTime);
    });

    debounce<List<String>>(searchTextList, (List<String> value) {
      syncQuickSearch();
    }, time: const Duration(seconds: 1));
  }
}
