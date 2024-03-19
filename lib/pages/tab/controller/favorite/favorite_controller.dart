// import 'package:dio/dio.dart';
// import 'package:eros_fe/common/controller/localfav_controller.dart';
// import 'package:eros_fe/common/controller/user_controller.dart';
// import 'package:eros_fe/const/const.dart';
// import 'package:eros_fe/models/index.dart';
// import 'package:eros_fe/network/request.dart';
// import 'package:eros_fe/pages/controller/favorite_sel_controller.dart';
// import 'package:eros_fe/route/routes.dart';
// import 'package:eros_fe/utils/logger.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
//
// import '../../fetch_list.dart';
// import '../default_tabview_controller.dart';
//
// class FavoriteViewController extends DefaultTabViewController {
//   final RxString _title = ''.obs;
//
//   String get title {
//     if (_title.value.isNotEmpty) {
//       return _title.value;
//     } else {
//       return ehSettingService.lastShowFavTitle ?? '';
//     }
//   }
//
//   set title(String val) => _title.value = val;
//
//   bool enableDelayedLoad = true;
//
//   final CancelToken _cancelToken = CancelToken();
//
//   //页码跳转的控制器
//   final TextEditingController pageController = TextEditingController();
//
//   late Future<(List<GalleryProvider>, int)> futureBuilderFuture;
//   Widget? lastListWidget;
//
//   final LocalFavController _localFavController = Get.find();
//   final UserController _userController = Get.find();
//
//   FavoriteSelectorController? get _favoriteSelectorController {
//     if (Get.isRegistered<FavoriteSelectorController>()) {
//       return Get.find<FavoriteSelectorController>();
//     }
//     return null;
//   }
//
//   @override
//   void onInit() {
//     heroTag = EHRoutes.favorite;
//     super.onInit();
//   }
//
//   @override
//   FetchListClient getFetchListClient(FetchParams fetchParams) {
//     return FavoriteFetchListClient(fetchParams: fetchParams);
//   }
//
//   @override
//   Future<GalleryList?> fetchData({bool refresh = false}) async {
//     final bool _isLogin = _userController.isLogin;
//     if (!_isLogin) {
//       curFavcat = 'l';
//     }
//
//     if (curFavcat != 'l') {
//       // 网络收藏夹
//       final rult = await getGallery(
//         favcat: curFavcat,
//         refresh: refresh,
//         cancelToken: _cancelToken,
//         galleryListType: GalleryListType.favorite,
//       );
//
//       _favoriteSelectorController?.addAllFavList(rult?.favList ?? []);
//
//       return rult;
//     } else {
//       // if (first) {
//       //   ehSettingService.lastShowFavcat = 'l';
//       //   ehSettingService.lastShowFavTitle = L10n.of(Get.context!).local_favorite;
//       // }
//       // 本地收藏夹
//       logger.t('本地收藏');
//       final List<GalleryProvider> localFav = _localFavController.loacalFavs;
//
//       return Future<GalleryList>.value(GalleryList(gallerys: localFav));
//     }
//   }
//
//   Future<void> setOrder(BuildContext context) async {
//     final FavoriteOrder? order = await ehSettingService.showFavOrder(context);
//     if (order != null) {
//       change(state, status: RxStatus.loading());
//       reloadData();
//     }
//   }
//
//   String get orderText =>
//       ehSettingService.favoriteOrder.value == FavoriteOrder.fav ? 'F' : 'P';
// }
