import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/tabview_controller.dart';
import 'package:get/get.dart';

import '../fetch_list.dart';
import 'custom_tabbar_controller.dart';
import 'enum.dart';

/// 控制单个自定义列表
class CustomSubListController extends TabViewController {
  final CustomTabbarController _customTabbarController = Get.find();

  final RxBool _isBackgroundRefresh = false.obs;
  bool get isBackgroundRefresh => _isBackgroundRefresh.value;
  set isBackgroundRefresh(bool val) => _isBackgroundRefresh.value = val;

  late String profileUuid;
  CustomProfile? get profile => _customTabbarController.profileMap[profileUuid];

  FetchListClient getFetchListClient(FetchParams fetchParams) {
    return SearchFetchListClient(fetchParams: fetchParams);
  }

  @override
  Future<void> firstLoad() async {
    await super.firstLoad();

    try {
      if (cancelToken?.isCancelled ?? false) {
        return;
      }
      isBackgroundRefresh = true;
      await reloadData();
    } catch (_) {
    } finally {
      isBackgroundRefresh = false;
    }
  }

  @override
  Future<GalleryList?> fetchData({bool refresh = false}) async {
    cancelToken = CancelToken();

    logger.d('${jsonEncode(profile)}');

    final fetchConfig = FetchParams(
      cats: profile?.cats,
      refresh: refresh,
      cancelToken: cancelToken,
      searchText: profile?.searchText?.join(' '),
      advanceSearchParam: (profile?.enableAdvance ?? false)
          ? profile?.advSearch?.param ?? {}
          : {},
      galleryListType: profile?.listType ?? GalleryListType.gallery,
    );

    pageState = PageState.Loading;

    try {
      FetchListClient fetchListClient = getFetchListClient(fetchConfig);
      final GalleryList? rult = await fetchListClient.fetch();

      if (cancelToken?.isCancelled ?? false) {
        return null;
      }

      pageState = PageState.None;

      return rult;
    } on EhError catch (eherror) {
      logger.e('type:${eherror.type}\n${eherror.message}');
      showToast(eherror.message);
      pageState = PageState.LoadingError;
      rethrow;
    } on Exception catch (e) {
      pageState = PageState.LoadingError;
      rethrow;
    }
  }

  @override
  Future<GalleryList?> fetchMoreData() async {
    cancelToken = CancelToken();
    final fetchConfig = FetchParams(
      page: nextPage,
      fromGid: state?.last.gid ?? '0',
      cats: profile?.cats,
      refresh: true,
      cancelToken: cancelToken,
      searchText: profile?.searchText?.join(' '),
      advanceSearchParam: (profile?.enableAdvance ?? false)
          ? profile?.advSearch?.param ?? {}
          : {},
      galleryListType: profile?.listType ?? GalleryListType.gallery,
    );
    FetchListClient fetchListClient = getFetchListClient(fetchConfig);
    return await fetchListClient.fetch();
  }

  @override
  Future<void> loadFromPage(int page) async {
    canLoadMore = false;
    pageState = PageState.Loading;
    change(state, status: RxStatus.loading());

    cancelToken = CancelToken();
    final fetchConfig = FetchParams(
      page: page,
      cats: profile?.cats,
      refresh: true,
      cancelToken: cancelToken,
      searchText: profile?.searchText?.join(' '),
      advanceSearchParam: (profile?.enableAdvance ?? false)
          ? profile?.advSearch?.param ?? {}
          : {},
      galleryListType: profile?.listType ?? GalleryListType.gallery,
    );

    try {
      FetchListClient fetchListClient = getFetchListClient(fetchConfig);
      final GalleryList? rult = await fetchListClient.fetch();

      curPage = page;
      minPage = page;
      nextPage = rult?.nextPage ?? page + 1;
      logger.d('after loadFromPage nextPage is $nextPage');
      if (rult != null) {
        change(rult.gallerys, status: RxStatus.success());
      }
      pageState = PageState.None;
    } catch (e) {
      pageState = PageState.LoadingError;
      change(null, status: RxStatus.error('$e'));
      rethrow;
    } finally {
      canLoadMore = true;
    }
  }

  // @override
  // Future<void> loadPrevious() async {
  //   await reloadData();
  // }

  @override
  Future<void> lastComplete() async {
    super.lastComplete();
    if (curPage < maxPage - 1 && pageState != PageState.Loading) {
      // 加载更多
      loadDataMore();
    }
  }
}
