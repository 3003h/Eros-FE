import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/profile.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

class QuickSearchController extends ProfileController {
  RxList<String> searchTextList = <String>[].obs;

  void addText(String text) {
    if (searchTextList.contains(text.trim())) {
      showToast('搜索词已存在');
    } else {
      searchTextList.add(text);
      showToast('保存成功');
    }
  }

  void removeTextAt(int idx) {
    searchTextList.removeAt(idx);
  }

  void removeAll() {
    searchTextList.clear();
  }

  @override
  void onInit() {
    super.onInit();
    final Profile _profile = Global.profile;
    searchTextList(_profile.searchText.map((e) => e.toString()).toList());

    everProfile<List<String>>(searchTextList, (List<String> value) {
      // _profile.searchText = value;
      Global.profile = Global.profile.copyWith(searchText: value);
    });
  }
}
