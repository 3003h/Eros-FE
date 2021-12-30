import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/controller/favorite_sel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import 'default_tabview_controller.dart';
import 'favorite_sublist_controller.dart';

class FavoriteTabberController extends DefaultTabViewController {
  final FavoriteSelectorController favoriteSelectorController = Get.find();

  List<Favcat> get favcatList => favoriteSelectorController.favcatList;

  Map<String, FavoriteSubListController> subControllerMap = {};

  FavConfig? get favConfig => Global.profile.favConfig;
  set favConfig(FavConfig? val) =>
      Global.profile = Global.profile.copyWith(favConfig: val);

  final _currFavcat = 'a'.obs;
  String get currFavcat => _currFavcat.value;
  set currFavcat(String val) => _currFavcat.value = val;

  FavoriteSubListController? get currSubController =>
      subControllerMap[currFavcat];

  final _index = 0.obs;
  int get index => _index.value;
  set index(int val) => _index.value = val;

  @override
  Future<void> firstLoad() async {}

  @override
  void onInit() {
    super.onInit();
    for (final favcat in favcatList) {
      Get.lazyPut(() => FavoriteSubListController(), tag: favcat.favId);
    }

    // index
    index = favConfig?.lastIndex ?? 0;
    ever<int>(_index, (value) {
      favConfig = favConfig?.copyWith(lastIndex: value);
      Global.saveProfile();
    });
  }

  String get orderText =>
      ehConfigService.favoriteOrder.value == FavoriteOrder.fav ? 'F' : 'P';

  Future<void> setOrder(BuildContext context) async {
    final FavoriteOrder? order = await ehConfigService.showFavOrder(context);
    if (order != null) {
      currSubController?.change(state, status: RxStatus.loading());
      currSubController?.reloadData();
      // for (final favcat in favcatList) {
      //   Get.replace(() => FavoriteSubListController(), tag: favcat.favId);
      // }
    }
  }

  Future<void> loadFromPageFav(int page) {
    return loadFromPage(page);
  }

  @override
  int get maxPage => currSubController?.maxPage ?? 1;

  @override
  int get minPage => currSubController?.minPage ?? 1;

  @override
  int get curPage => currSubController?.curPage ?? 1;

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

  void onPageChanged(int index) {
    currFavcat = favoriteSelectorController.favcatList[index].favId;
    this.index = index;
  }
}
