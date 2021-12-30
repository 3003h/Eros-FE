import 'package:english_words/english_words.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:get/get.dart';

import 'custom_sublist_controller.dart';
import 'default_tabview_controller.dart';

List<String> titleList = [
  '画廊测试',
  '画廊',
  '画廊画廊',
  '单词',
];

/// 控制所有自定义列表
class CustomTabbarController extends DefaultTabViewController {
  CustomTabbarController();

  final titles = <String>[].obs;
  final wordList = <WordPair>[].obs;

  CustomTabConfig? get customTabConfig => Global.profile.customTabConfig;
  set customTabConfig(CustomTabConfig? val) =>
      Global.profile = Global.profile.copyWith(customTabConfig: val);

  RxList<CustomProfile> profiles = <CustomProfile>[].obs;

  @override
  void onInit() {
    tabTag = EHRoutes.coutomlist;
    titles.addAll(titleList);

    profiles.value = customTabConfig?.profiles ?? [];
    ever<List<CustomProfile>>(profiles, (value) {
      customTabConfig = customTabConfig?.copyWith(profiles: value);
      Global.saveProfile();
    });

    for (final profile in profiles) {
      Get.lazyPut(() => CustomSubListController(), tag: profile.name);
    }

    super.onInit();
  }
}
