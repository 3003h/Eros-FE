import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import 'tabview_controller.dart';

class FavoriteViewController extends TabViewController {
  RxString title = ''.obs;
  String curFavcat = '';

  bool enableDelayedLoad = true;

  final CancelToken _cancelToken = CancelToken();

  //页码跳转的控制器
  final TextEditingController pageController = TextEditingController();

  Future<Tuple2<List<GalleryItem>, int>> futureBuilderFuture;
  Widget lastListWidget;

  final EhConfigService _ehConfigService = Get.find();
  final LocalFavController _localFavController = Get.find();
  final UserController _userController = Get.find();

  @override
  void onInit() {
    fetchNormal = Api.getFavorite;
    curFavcat = _ehConfigService.lastShowFavcat ?? 'a';
    title.value = _ehConfigService.lastShowFavTitle;

    super.onInit();
  }

  @override
  Future<Tuple2<List<GalleryItem>, int>> fetchData({
    bool refresh = false,
    bool first = false,
  }) async {
    logger.v('_loadDataFirst  fav');

    final bool _isLogin = _userController.isLogin;
    if (!_isLogin) {
      curFavcat = 'l';
    }

    if (curFavcat != 'l') {
      // 网络收藏夹
      final Future<Tuple2<List<GalleryItem>, int>> tuple = Api.getFavorite(
        favcat: curFavcat,
        refresh: refresh,
        cancelToken: _cancelToken,
      );
      return tuple;
    } else {
      if (first) {
        _ehConfigService.lastShowFavcat = 'l';
        _ehConfigService.lastShowFavTitle = S.of(Get.context).local_favorite;
      }
      // 本地收藏夹
      logger.v('本地收藏');
      final List<GalleryItem> localFav = _localFavController.loacalFavs;

      return Future<Tuple2<List<GalleryItem>, int>>.value(Tuple2(localFav, 1));
    }
  }

  Future<void> setOrder() async {
    final FavoriteOrder order = await _ehConfigService.showFavOrder();
    if (order != null) {
      change(state, status: RxStatus.loading());
      reloadData();
    }
  }

  String get orderText =>
      _ehConfigService.favoriteOrder.value == FavoriteOrder.fav ? 'F' : 'P';
}
