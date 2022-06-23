import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/profile.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

class QuickSearchController extends ProfileController {
  RxList<String> searchTextList = <String>[].obs;
  final WebdavController webdavController = Get.find();

  List<String> get _trimList =>
      searchTextList.map((element) => element.trim()).toList();

  void addText(String text, {bool silent = false}) {
    if (_trimList.contains(text.trim())) {
      // logger.e('搜索词已存在');
      // if (!silent) showToast('搜索词已存在');
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
    final _rs = await webdavController.downloadQuickSearch();
    _rs.forEach((e) => addText(e, silent: true));
    webdavController.uploadQuickSearch(searchTextList);
  }

  @override
  void onInit() {
    super.onInit();
    final Profile _profile = Global.profile;
    searchTextList(_profile.searchText.map((e) => e.toString()).toList());

    syncQuickSearch();

    everProfile<List<String>>(searchTextList, (List<String> value) {
      // _profile.searchText = value;
      Global.profile = Global.profile.copyWith(searchText: value);
    });

    debounce<List<String>>(searchTextList, (List<String> value) {
      syncQuickSearch();
    }, time: const Duration(seconds: 1));
  }
}
