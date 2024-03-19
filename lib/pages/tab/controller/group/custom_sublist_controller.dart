import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/index.dart';
import 'package:get/get.dart';

import '../../fetch_list.dart';
import '../enum.dart';
import '../tabview_controller.dart';
import 'custom_tabbar_controller.dart';

/// 控制单个自定义列表
class CustomSubListController extends TabViewController {
  CustomSubListController({required this.profileUuid});

  final CustomTabbarController _customTabbarController = Get.find();

  final listModeObs = ListModeEnum.list.obs;

  ListModeEnum get listMode => listModeObs.value;

  set listMode(ListModeEnum val) => listModeObs.value = val;

  final String profileUuid;

  CustomProfile? get profile => _customTabbarController.profileMap[profileUuid];

  FetchListClient getFetchListClient(FetchParams fetchParams) {
    logger.t('CustomSubListController getFetchListClient $fetchParams');
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

    logger.t('fetchData , refresh:$refresh');

    logger.t(' ${jsonEncode(profile)}');

    // 普通搜索
    final fetchConfig = FetchParams(
      cats: profile?.cats,
      refresh: refresh,
      cancelToken: cancelToken,
      searchText: profile?.searchText?.join(' '),
      advanceSearch:
          (profile?.enableAdvance ?? false) ? profile?.advSearch : null,
      galleryListType: profile?.listType ?? GalleryListType.gallery,
    );

    pageState = PageState.Loading;

    try {
      FetchListClient fetchListClient = getFetchListClient(fetchConfig);
      final GalleryList? result = await fetchListClient.fetch();
      pageState = PageState.None;
      if (cancelToken?.isCancelled ?? false) {
        return null;
      }

      final _list = result?.gallerys
              ?.map((e) => e.simpleTags ?? [])
              .expand((List<SimpleTag> element) => element)
              .toList() ??
          [];

      tagController.addAllSimpleTag(_list);

      return result;
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
      pageType: PageType.next,
      // gid: nextGid,
      gid: nextPage > -1 ? (state?.lastOrNull?.gid ?? '') : nextGid,
      cats: profile?.cats,
      refresh: true,
      cancelToken: cancelToken,
      searchText: profile?.searchText?.join(' '),
      advanceSearch:
          (profile?.enableAdvance ?? false) ? profile?.advSearch : null,
      galleryListType: profile?.listType ?? GalleryListType.gallery,
      page: nextPage,
    );
    FetchListClient fetchListClient = getFetchListClient(fetchConfig);
    return await fetchListClient.fetch();
  }

  @override
  Future<GalleryList?> fetchPrevData() async {
    cancelToken = CancelToken();
    final fetchConfig = FetchParams(
      pageType: PageType.prev,
      gid: prevGid,
      cats: profile?.cats,
      refresh: true,
      cancelToken: cancelToken,
      searchText: profile?.searchText?.join(' '),
      advanceSearch:
          (profile?.enableAdvance ?? false) ? profile?.advSearch : null,
      galleryListType: profile?.listType ?? GalleryListType.gallery,
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
    cancelToken = CancelToken();
    final fetchConfig = FetchParams(
      pageType: pageType,
      gid: gid,
      cats: profile?.cats,
      refresh: true,
      cancelToken: cancelToken,
      searchText: profile?.searchText?.join(' '),
      advanceSearch:
          (profile?.enableAdvance ?? false) ? profile?.advSearch : null,
      galleryListType: profile?.listType ?? GalleryListType.gallery,
      jump: jump,
      seek: seek,
      page: page,
    );
    FetchListClient fetchListClient = getFetchListClient(fetchConfig);
    return await fetchListClient.fetch();
  }

  @override
  Future<void> lastComplete() async {
    super.lastComplete();

    logger.d('next $next prev $prev');

    if ((state ?? []).isNotEmpty &&
        next.isNotEmpty &&
        pageState != PageState.Loading) {
      // 加载更多
      loadDataMore();
    }
  }
}
