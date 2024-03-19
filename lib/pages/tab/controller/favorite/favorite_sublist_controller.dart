import 'package:collection/collection.dart';
import 'package:eros_fe/common/controller/localfav_controller.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/request.dart';
import 'package:eros_fe/pages/controller/favorite_sel_controller.dart';
import 'package:eros_fe/pages/tab/controller/tabview_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../fetch_list.dart';
import '../enum.dart';

class FavoriteSubListController extends TabViewController {
  late String favcat;

  final LocalFavController _localFavController = Get.find();

  FavoriteSelectorController? get _favoriteSelectorController {
    if (Get.isRegistered<FavoriteSelectorController>()) {
      return Get.find<FavoriteSelectorController>();
    }
    return null;
  }

  @override
  Future<GalleryList?> fetchData({bool refresh = false}) async {
    await super.fetchData();
    if (favcat != 'l') {
      // 网络收藏夹
      final GalleryList? result = await getGallery(
        favcat: favcat,
        refresh: refresh,
        cancelToken: cancelToken,
        galleryListType: GalleryListType.favorite,
      );

      logger.t(
          'favcat $favcat, result prev:${result?.prevPage} next:${result?.nextPage}, max:${result?.maxPage}');

      _favoriteSelectorController?.addAllFavList(result?.favList ?? []);

      return result;
    } else {
      // 本地收藏夹
      logger.t('本地收藏');
      final List<GalleryProvider> localFav = _localFavController.loacalFavs;

      return Future<GalleryList>.value(GalleryList(gallerys: localFav));
    }
  }

  @override
  Future<GalleryList?> fetchMoreData() async {
    await super.fetchMoreData();
    final fetchConfig = FetchParams(
      pageType: PageType.next,
      gid: nextPage > -1 ? (state?.lastOrNull?.gid ?? '') : nextGid,
      refresh: true,
      cancelToken: cancelToken,
      favcat: favcat,
      page: nextPage,
    );
    FetchListClient fetchListClient = getFetchListClient(fetchConfig);
    return await fetchListClient.fetch();
  }

  @override
  Future<GalleryList?> fetchPrevData() async {
    await super.fetchPrevData();
    final fetchConfig = FetchParams(
      pageType: PageType.prev,
      gid: prevGid,
      refresh: true,
      cancelToken: cancelToken,
      favcat: favcat,
      page: prevPage,
    );
    FetchListClient fetchListClient = getFetchListClient(fetchConfig);
    return await fetchListClient.fetch();
  }

  @override
  Future<GalleryList?> fetchDataFrom({
    String? gid,
    PageType? pageType,
    String? jump,
    String? seek,
    int? page,
  }) async {
    await super.fetchDataFrom();
    final fetchConfig = FetchParams(
      pageType: pageType,
      gid: gid,
      jump: jump,
      seek: seek,
      refresh: true,
      cancelToken: cancelToken,
      favcat: favcat,
      page: page,
    );
    FetchListClient fetchListClient = getFetchListClient(fetchConfig);
    return await fetchListClient.fetch();
  }

  FetchListClient getFetchListClient(FetchParams fetchParams) {
    return FavoriteFetchListClient(fetchParams: fetchParams);
  }

  @override
  Future<void> lastComplete() async {
    await super.lastComplete();
    logger.d('加载更多...$next');
    if ((state ?? []).isNotEmpty &&
        next.isNotEmpty &&
        pageState != PageState.Loading) {
      // 加载更多
      logger.d('加载更多');
      await loadDataMore();
    }
  }

  Future<void> setOrder(BuildContext context) async {
    final FavoriteOrder? order = await ehSettingService.showFavOrder(context);
    if (order != null) {
      change(state, status: RxStatus.loading());
      reloadData();
    }
  }
}
