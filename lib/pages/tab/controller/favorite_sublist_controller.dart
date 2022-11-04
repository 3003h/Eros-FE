import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/controller/favorite_sel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../fetch_list.dart';
import 'enum.dart';
import 'tabview_controller.dart';

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
      final rult = await getGallery(
        favcat: favcat,
        refresh: refresh,
        cancelToken: cancelToken,
        galleryListType: GalleryListType.favorite,
      );

      _favoriteSelectorController?.addAllFavList(rult?.favList ?? []);

      return rult;
    } else {
      // 本地收藏夹
      logger.v('本地收藏');
      final List<GalleryProvider> localFav = _localFavController.loacalFavs;

      return Future<GalleryList>.value(
          GalleryList(gallerys: localFav, maxPage: 1));
    }
  }

  @override
  Future<GalleryList?> fetchMoreData() async {
    await super.fetchMoreData();
    final fetchConfig = FetchParams(
      page: nextPage,
      fromGid: state?.last.gid ?? '0',
      refresh: true,
      cancelToken: cancelToken,
      favcat: favcat,
    );
    FetchListClient fetchListClient = getFetchListClient(fetchConfig);
    return await fetchListClient.fetch();
  }

  @override
  Future<void> loadFromPage(int page, {bool previous = false}) async {
    await super.loadFromPage(page);
    logger.d('jump to page =>  $page');
    canLoadMore = false;
    pageState = PageState.Loading;
    if (!previous) {
      change(state, status: RxStatus.loading());
    }

    final fetchConfig = FetchParams(
      page: page,
      refresh: true,
      cancelToken: cancelToken,
      favcat: favcat,
    );
    try {
      FetchListClient fetchListClient = getFetchListClient(fetchConfig);
      final GalleryList? rult = await fetchListClient.fetch();

      curPage = page;
      minPage = page;
      if (!previous) {
        nextPage = rult?.nextPage ?? page + 1;
      }
      prevPage = rult?.prevPage;
      logger.d('after loadFromPage nextPage is $nextPage');
      if (rult != null) {
        if (previous) {
          state?.insertAll(0, rult.gallerys ?? []);
          change(state, status: RxStatus.success());
        } else {
          change(rult.gallerys, status: RxStatus.success());
        }
      }
      pageState = PageState.None;
    } catch (e) {
      pageState = PageState.LoadingError;
      if (!previous) {
        change(null, status: RxStatus.error('$e'));
      } else {
        showToast('$e');
      }
      rethrow;
    } finally {
      canLoadMore = true;
    }
  }

  FetchListClient getFetchListClient(FetchParams fetchParams) {
    return FavoriteFetchListClient(fetchParams: fetchParams);
  }

  @override
  Future<void> lastComplete() async {
    await super.lastComplete();
    if ((state ?? []).isNotEmpty &&
        curPage < maxPage - 1 &&
        pageState != PageState.Loading) {
      // 加载更多
      logger.d('加载更多');
      await loadDataMore();
    }
  }

  Future<void> setOrder(BuildContext context) async {
    final FavoriteOrder? order = await ehConfigService.showFavOrder(context);
    if (order != null) {
      change(state, status: RxStatus.loading());
      reloadData();
    }
  }
}
