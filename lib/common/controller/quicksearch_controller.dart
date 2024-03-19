import 'package:collection/collection.dart';
import 'package:eros_fe/common/controller/webdav_controller.dart';
import 'package:eros_fe/index.dart';
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

    final _rs = await webdavController.downloadQuickSearch(_remoteTimes.max);
    final remoteList = _rs?.$1 ?? <String>[];
    final remoteTime = _rs?.$2 ?? 0;
    logger.d(
        '远程时间 $remoteTime, 本地最后更新时间 $lastEditTime, 需要下载: ${remoteTime > lastEditTime}');
    // 远程时间大于等于本地最后编辑时间 下载远程数据
    if (remoteTime >= lastEditTime) {
      remoteList.forEach((e) => addText(e, silent: true));
    } else {
      // 上传本地数据
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
      if (value.isNotEmpty) {
        lastEditTime = DateTime.now().millisecondsSinceEpoch;
        logger.d('最后更新时间: $lastEditTime');
        hiveHelper.setQuickSearchLastEditTime(lastEditTime);
      }
    });

    debounce<List<String>>(searchTextList, (List<String> value) {
      syncQuickSearch();
    }, time: const Duration(seconds: 1));
  }
}
