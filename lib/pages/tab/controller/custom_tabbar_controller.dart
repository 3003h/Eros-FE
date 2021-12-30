import 'package:english_words/english_words.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'custom_sublist_controller.dart';
import 'default_tabview_controller.dart';

/// 控制所有自定义列表
class CustomTabbarController extends DefaultTabViewController {
  CustomTabConfig? get customTabConfig => Global.profile.customTabConfig;
  set customTabConfig(CustomTabConfig? val) =>
      Global.profile = Global.profile.copyWith(customTabConfig: val);

  RxList<CustomProfile> profiles = <CustomProfile>[].obs;
  Map<String, CustomProfile> get profileMap {
    Map<String, CustomProfile> _map = {};
    for (final profile in profiles) {
      logger.d('${profile.toJson()}');
      _map[profile.name] = profile;
    }
    return _map;
  }

  final _currProfileName = ''.obs;
  String get currProfileName => _currProfileName.value;
  set currProfileName(String val) => _currProfileName.value = val;

  final _index = 0.obs;
  int get index => _index.value;
  set index(int val) => _index.value = val;

  Map<String, CustomSubListController> subControllerMap = {};
  CustomSubListController? get currSubController =>
      subControllerMap[currProfileName];

  @override
  int get maxPage => currSubController?.maxPage ?? 1;

  @override
  int get minPage => currSubController?.minPage ?? 1;

  @override
  int get curPage => currSubController?.curPage ?? 1;

  @override
  void onInit() {
    super.onInit();

    tabTag = EHRoutes.coutomlist;

    profiles.value = customTabConfig?.profiles ??
        [
          CustomProfile(name: 'All'),
          CustomProfile(name: '3D', searchText: ['o:3d']),
          CustomProfile(name: '汉语', searchText: ['l:chinese']),
          CustomProfile(name: 'NTR', searchText: ['f:netorare']),
          CustomProfile(
              name: 'NTR 汉语', searchText: ['f:netorare', 'l:chinese']),
        ];

    ever<List<CustomProfile>>(profiles, (value) {
      customTabConfig = customTabConfig?.copyWith(profiles: value);
      Global.saveProfile();
    });

    index = customTabConfig?.lastIndex ?? 0;
    ever<int>(_index, (value) {
      customTabConfig = customTabConfig?.copyWith(lastIndex: value) ??
          CustomTabConfig(lastIndex: value);
      Global.saveProfile();
    });

    currProfileName = profiles[index].name;

    for (final profile in profiles) {
      Get.lazyPut(() => CustomSubListController(), tag: profile.name);
    }
  }

  void onPageChanged(int index) {
    currProfileName = profiles[index].name;
    this.index = index;
  }

  @override
  Future<void> showJumpToPage() async {
    void _jump() {
      logger.d('jumpToPage');
      final String _input = pageJumpTextEditController.text.trim();

      if (_input.isEmpty) {
        showToast(L10n.of(Get.context!).input_empty);
      }

      // 数字检查
      if (!RegExp(r'(^\d+$)').hasMatch(_input)) {
        showToast(L10n.of(Get.context!).input_error);
      }

      final int _toPage = int.parse(_input) - 1;
      if (_toPage >= 0 && _toPage <= maxPage - 1) {
        FocusScope.of(Get.context!).requestFocus(FocusNode());
        currSubController?.loadFromPage(_toPage);
        Get.back();
      } else {
        showToast(L10n.of(Get.context!).page_range_error);
      }
    }

    return await showJumpDialog(jump: _jump, maxPage: maxPage);
  }

  @override
  Future<void> firstLoad() async {}
}
