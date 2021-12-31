import 'package:english_words/english_words.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'custom_sublist_controller.dart';
import 'default_tabview_controller.dart';

const CustomProfile kProfileChinese =
    CustomProfile(name: '汉语', searchText: ['l:chinese']);

/// 控制所有自定义列表
class CustomTabbarController extends DefaultTabViewController {
  CustomTabConfig? get customTabConfig => Global.profile.customTabConfig;
  set customTabConfig(CustomTabConfig? val) =>
      Global.profile = Global.profile.copyWith(customTabConfig: val);

  RxList<CustomProfile> profiles = <CustomProfile>[].obs;
  Map<String, CustomProfile> get profileMap {
    Map<String, CustomProfile> _map = {};
    for (final profile in profiles) {
      // logger.d('${profile.toJson()}');
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

  final _reorderable = false.obs;
  bool get reorderable => _reorderable.value;
  set reorderable(bool val) => _reorderable.value = val;

  Map<String, CustomSubListController> subControllerMap = {};
  CustomSubListController? get currSubController =>
      subControllerMap[currProfileName];

  @override
  int get maxPage => currSubController?.maxPage ?? 1;

  @override
  int get minPage => currSubController?.minPage ?? 1;

  @override
  int get curPage => currSubController?.curPage ?? 1;

  late final PageController pageController;

  final LinkScrollBarController linkScrollBarController =
      LinkScrollBarController();

  @override
  void onInit() {
    super.onInit();

    heroTag = EHRoutes.customlist;

    profiles.value = customTabConfig?.profiles ??
        [
          const CustomProfile(name: 'All'),
          if (Get.find<LocaleService>().isLanguageCodeZh) kProfileChinese,
        ];

    ever<List<CustomProfile>>(profiles, (value) {
      customTabConfig = customTabConfig?.copyWith(profiles: value) ??
          CustomTabConfig(profiles: value);
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

  Future<void> pressedBar() async {
    await Get.toNamed(
      EHRoutes.customProfiles,
      id: isLayoutLarge ? 1 : null,
    );
  }

  void onReorder(int oldIndex, int newIndex) {
    final _profilename = currProfileName;
    final _profile = profiles.removeAt(oldIndex);
    profiles.insert(newIndex, _profile);
    index = profiles.indexWhere((element) => element.name == _profilename);
    Future.delayed(100.milliseconds).then((_) {
      pageController.jumpToPage(index);
      // linkScrollBarController.scrollToItem(index);
    });
  }

  void deleteProfile({required String name}) {
    final _profilename = currProfileName;
    profiles.removeWhere((element) => element.name == name);
    if (_profilename == name) {
      Future.delayed(100.milliseconds).then((_) {
        pageController.jumpToPage(0);
      });
    }
  }
}
