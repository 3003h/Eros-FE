import 'package:eros_fe/common/controller/user_controller.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/controller/favorite_sel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../default_tabview_controller.dart';
import 'favorite_sublist_controller.dart';

class FavoriteTabberController extends DefaultTabViewController {
  final FavoriteSelectorController favoriteSelectorController = Get.find();
  final UserController userController = Get.find();

  bool get showBarsBtn => userController.isLogin;

  List<Favcat> get favcatList => favoriteSelectorController.favcatList;

  Map<String, FavoriteSubListController> subControllerMap = {};

  FavConfig? get favConfig => Global.profile.favConfig;
  set favConfig(FavConfig? val) =>
      Global.profile = Global.profile.copyWith(favConfig: val.oN);

  final _currFavcat = 'a'.obs;
  String get currFavcat => _currFavcat.value;
  set currFavcat(String val) => _currFavcat.value = val;

  FavoriteSubListController? get _currSubController => userController.isLogin
      ? subControllerMap[currFavcat]
      : subControllerMap['l'];

  final _index = 0.obs;
  int get index => _index.value;
  set index(int val) => _index.value = val;

  @override
  Future<void> firstLoad() async {}

  @override
  void onInit() {
    super.onInit();
    subControllerMap.clear();

    for (final favcat in favcatList) {
      Get.lazyPut(() => FavoriteSubListController(), tag: favcat.favId);
    }

    // index
    index = favConfig?.lastIndex ?? 0;
    ever<int>(_index, (value) {
      favConfig = favConfig?.copyWith(lastIndex: value.oN) ??
          FavConfig(lastIndex: value);
      Global.saveProfile();
    });
  }

  String get orderText =>
      ehSettingService.favoriteOrder.value == FavoriteOrder.fav ? 'F' : 'P';

  Future<void> setOrder(BuildContext context) async {
    final FavoriteOrder? order = await ehSettingService.showFavOrder(context);
    if (order != null) {
      _currSubController?.change(state, status: RxStatus.loading());
      _currSubController?.reloadData();
    }
  }

  @override
  Future<void> showJumpDialog(BuildContext context) async {
    await _currSubController?.showJumpDialog(context);
  }

  @override
  bool get afterJump => _currSubController?.afterJump ?? false;

  @override
  Future<void> jumpToTop() async {
    await _currSubController?.jumpToTop();
  }

  @override
  Future<void> reloadData() async {
    if (_currSubController?.reloadData != null) {
      await _currSubController!.reloadData();
    } else {
      update();
      await _currSubController?.reloadData();
    }
  }

  void onPageChanged(int index) {
    currFavcat = favoriteSelectorController.favcatList[index].favId;
    this.index = index;
  }
}
