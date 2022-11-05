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

  bool get isBackgroundRefresh => _isBackgroundRefresh.value;

  set isBackgroundRefresh(bool val) => _isBackgroundRefresh.value = val;

  final listModeObs = ListModeEnum.list.obs;

  ListModeEnum get listMode => listModeObs.value;

  set listMode(ListModeEnum val) => listModeObs.value = val;

  final String profileUuid;

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

  // @override
  // Future<void> loadFromPage(int page, {bool previous = false}) async {
  //   logger.v('loadFromPage $page');
  //   await super.loadFromPage(page);
  //   canLoadMore = false;
  //   pageState = PageState.Loading;
  //   if (!previous) {
  //     change(state, status: RxStatus.loading());
  //   }
  //
  //   final fetchConfig = FetchParams(
  //     pageType: page,
  //     cats: profile?.cats,
  //     refresh: true,
  //     cancelToken: cancelToken,
  //     searchText: profile?.searchText?.join(' '),
  //     advanceSearch:
  //         (profile?.enableAdvance ?? false) ? profile?.advSearch : null,
  //     galleryListType: profile?.listType ?? GalleryListType.gallery,
  //   );
  //
  //   try {
  //     FetchListClient fetchListClient = getFetchListClient(fetchConfig);
  //     final GalleryList? result = await fetchListClient.fetch();
  //
  //     curPage = page;
  //     minPage = page;
  //     if (!previous) {
  //       nextPage = result?.nextPage ?? page + 1;
  //     }
  //     prevPage = result?.prevPage;
  //
  //     if (result != null) {
  //       if (previous) {
  //         final allIn = result.gallerys
  //             ?.map((e) => e.gid)
  //             .every((gid) => state?.map((e) => e.gid).contains(gid) ?? false);
  //         if (allIn ?? false) {
  //           logger.v('${result.gallerys?.length}  $prevPage');
  //           await loadPrevious();
  //         } else {
  //           state?.insertAll(0, result.gallerys ?? []);
  //           change(state, status: RxStatus.success());
  //         }
  //       } else {
  //         change(result.gallerys, status: RxStatus.success());
  //       }
  //     }
  //     pageState = PageState.None;
  //   } catch (e) {
  //     pageState = PageState.LoadingError;
  //     if (!previous) {
  //       change(null, status: RxStatus.error('$e'));
  //     } else {
  //       showToast('$e');
  //     }
  //     rethrow;
  //   } finally {
  //     canLoadMore = true;
  //   }
  // }

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
