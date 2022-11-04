import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/controller/favorite_sel_controller.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import '../fetch_list.dart';
import 'default_tabview_controller.dart';

class FavoriteViewController extends DefaultTabViewController {
  final RxString _title = ''.obs;

  String get title {
    if (_title.value.isNotEmpty) {
      return _title.value;
    } else {
      return ehConfigService.lastShowFavTitle ?? '';
    }
  }

  set title(String val) => _title.value = val;

  bool enableDelayedLoad = true;

  final CancelToken _cancelToken = CancelToken();

  //页码跳转的控制器
  final TextEditingController pageController = TextEditingController();

  late Future<Tuple2<List<GalleryProvider>, int>> futureBuilderFuture;
  Widget? lastListWidget;

  final LocalFavController _localFavController = Get.find();
  final UserController _userController = Get.find();

  FavoriteSelectorController? get _favoriteSelectorController {
    if (Get.isRegistered<FavoriteSelectorController>()) {
      return Get.find<FavoriteSelectorController>();
    }
  }

  @override
  void onInit() {
    heroTag = EHRoutes.favorite;
    super.onInit();
  }

  @override
  FetchListClient getFetchListClient(FetchParams fetchParams) {
    return FavoriteFetchListClient(fetchParams: fetchParams);
  }

  @override
  Future<GalleryList?> fetchData({bool refresh = false}) async {
    final bool _isLogin = _userController.isLogin;
    if (!_isLogin) {
      curFavcat = 'l';
    }

    if (curFavcat != 'l') {
      // 网络收藏夹
      final rult = await getGallery(
        favcat: curFavcat,
        refresh: refresh,
        cancelToken: _cancelToken,
        galleryListType: GalleryListType.favorite,
      );

      _favoriteSelectorController?.addAllFavList(rult?.favList ?? []);

      return rult;
    } else {
      // if (first) {
      //   ehConfigService.lastShowFavcat = 'l';
      //   ehConfigService.lastShowFavTitle = L10n.of(Get.context!).local_favorite;
      // }
      // 本地收藏夹
      logger.v('本地收藏');
      final List<GalleryProvider> localFav = _localFavController.loacalFavs;

      return Future<GalleryList>.value(
          GalleryList(gallerys: localFav, maxPage: 1));
    }
  }

  Future<void> setOrder(BuildContext context) async {
    final FavoriteOrder? order = await ehConfigService.showFavOrder(context);
    if (order != null) {
      change(state, status: RxStatus.loading());
      reloadData();
    }
  }

  String get orderText =>
      ehConfigService.favoriteOrder.value == FavoriteOrder.fav ? 'F' : 'P';
}
