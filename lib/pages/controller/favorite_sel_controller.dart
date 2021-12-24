import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/favcat.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/tab/fetch_list.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteSelectorController extends GetxController
    with StateMixin<List<Favcat>> {
  FavoriteSelectorController();

  final _favcatList = <Favcat>[].obs;
  List<Favcat> get favcatList => _favcatList.value;

  final LocalFavController _localFavController = Get.find();

  int get _allNetworkFavcatCount {
    int _totnum = 0;
    for (final Favcat favcat in state ?? []) {
      if (favcat.favId != 'a' && favcat.favId != 'l') {
        _totnum += favcat.totNum ?? 0;
      }
    }
    return _totnum;
  }

  @override
  void onInit() {
    super.onInit();
    _initFavItemBeans();
    change(_favcatList, status: RxStatus.success());

    _fetchFavCatList().then((List<Favcat> value) {
      addAllFavList(value, isUpdate: false);
      change(_favcatList, status: RxStatus.success());
    }, onError: (err) {
      change(null, status: RxStatus.error('$err'));
    });
  }

  void increase(String favId) {
    final _index = _favcatList.indexWhere((element) => element.favId == favId);
    final int _num = (_favcatList[_index].totNum ?? 0) + 1;
    _favcatList[_index] = _favcatList[_index].copyWith(totNum: _num);
    logger.v(' $_num');
    change(_favcatList, status: RxStatus.success());
  }

  void decrease(String favId) {
    final _index = _favcatList.indexWhere((element) => element.favId == favId);
    final int _num = (_favcatList[_index].totNum ?? 1) - 1;
    _favcatList[_index] = _favcatList[_index].copyWith(totNum: _num);
    change(_favcatList, status: RxStatus.success());
  }

  void addAllFavList(List<Favcat> list, {bool isUpdate = true}) {
    for (final fav in list) {
      final _index =
          _favcatList.indexWhere((element) => element.favId == fav.favId);
      if (_index > -1) {
        _favcatList[_index] = fav;
      }
    }

    final _indexAll = _favcatList.indexWhere((element) => element.favId == 'a');
    if (_indexAll > -1) {
      _favcatList[_indexAll] =
          _favcatList[_indexAll].copyWith(totNum: _allNetworkFavcatCount);
    }

    final _indexLocal =
        _favcatList.indexWhere((element) => element.favId == 'l');
    if (_indexLocal > -1) {
      _favcatList[_indexLocal] = _favcatList[_indexLocal]
          .copyWith(totNum: _localFavController.loacalFavs.length);
    }

    if (isUpdate) {
      // logger.v(
      //     '_favcatList isUpdate  \n${_favcatList.map((e) => jsonEncode(e)).join('\n')}');
      change(_favcatList, status: RxStatus.success());
    }
  }

  Future<List<Favcat>> _fetchFavCatList() async {
    final rult = await getGallery(
      favcat: 'a',
      refresh: true,
      galleryListType: GalleryListType.favorite,
    );
    return rult?.favList ?? [];
  }

  void _initFavItemBeans() {
    final List<Favcat> favListFromSP = EHUtils.getFavListFromProfile();
    if (favListFromSP.isNotEmpty) {
      _favcatList.clear();
      _favcatList.addAll(favListFromSP);
      logger.v('_initFavItemBeans from sp');
    } else {
      _favcatList.clear();
      for (final Map<String, String> catmap in EHConst.favList) {
        final String favTitle = catmap['desc'] ?? '';
        final String favId = catmap['favcat'] ?? '';

        _favcatList.add(
          Favcat(favTitle: favTitle, favId: favId, totNum: 0),
        );
      }

      logger.v('_initFavItemBeans new');
    }

    if (!_favcatList.any((element) => element.favId == 'a')) {
      _favcatList.insert(
          0,
          Favcat(
              favTitle: L10n.current.all_Favorites,
              favId: 'a',
              totNum: _allNetworkFavcatCount));
    }
    if (!_favcatList.any((element) => element.favId == 'l')) {
      _favcatList.add(Favcat(
          favTitle: L10n.current.local_favorite,
          favId: 'l',
          totNum: _localFavController.loacalFavs.length));
    }
  }
}

class FavSelectorItemController extends GetxController {
  Rx<Color?> colorTap = const Color.fromARGB(0, 0, 0, 0).obs;

  void updateNormalColor() {
    colorTap.value = Colors.transparent;
  }

  void updatePressedColor() {
    colorTap.value = CupertinoDynamicColor.resolve(
        CupertinoColors.systemGrey4, Get.context!);
  }
}
