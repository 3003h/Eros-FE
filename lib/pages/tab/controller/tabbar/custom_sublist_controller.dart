import 'dart:convert';

import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/default_tabview_controller.dart';
import 'package:get/get.dart';

import '../../fetch_list.dart';
import '../enum.dart';
import 'custom_tabbar_controller.dart';

/// 控制单个自定义列表
class CustomSubListController extends DefaultTabViewController {
  CustomSubListController({required this.profileUuid});

  final CustomTabbarController _customTabbarController = Get.find();

  final RxBool _isBackgroundRefresh = false.obs;

  final listModeObs = ListModeEnum.list.obs;

  ListModeEnum get listMode => listModeObs.value;

  set listMode(ListModeEnum val) => listModeObs.value = val;

  final String profileUuid;

  CustomProfile? get profile => _customTabbarController.profileMap[profileUuid];

  @override
  FetchListClient getFetchListClient(FetchParams fetchParams) {
    logger.v('CustomSubListController getFetchListClient $fetchParams');
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
    await super.fetchData();

    logger.v(' ${jsonEncode(profile)}');

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
    await super.fetchMoreData();
    final fetchConfig = FetchParams(
      pageType: PageType.next,
      gid: state?.last.gid ?? '0',
      cats: profile?.cats,
      refresh: true,
      cancelToken: cancelToken,
      searchText: profile?.searchText?.join(' '),
      advanceSearch:
          (profile?.enableAdvance ?? false) ? profile?.advSearch : null,
      galleryListType: profile?.listType ?? GalleryListType.gallery,
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
  }) async {
    await super.fetchDataFrom();
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
    );
    FetchListClient fetchListClient = getFetchListClient(fetchConfig);
    return await fetchListClient.fetch();
  }

  @override
  Future<void> lastComplete() async {
    super.lastComplete();
    if ((state ?? []).isNotEmpty &&
        next.isNotEmpty &&
        pageState != PageState.Loading) {
      // 加载更多
      loadDataMore();
    }
  }
}
