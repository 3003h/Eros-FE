import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/tag_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/app_dio/pdio.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../comm.dart';
import 'enum.dart';

abstract class TabViewController extends GetxController {
  // 当前页码
  final _curPage = (-1).obs;
  int get curPage => _curPage.value;
  set curPage(int val) => _curPage.value = val;

  final TagController tagController = Get.find();

  String get listViewId => 'listViewId';

  // 最小页码
  int minPage = 1;
  // 最大页码
  int maxPage = 1;
  // 下一页
  int nextPage = 1;
  // 上一页
  int? prevPage;

  String? heroTag;

  CancelToken? cancelToken = CancelToken();

  bool canLoadMore = false;

  bool get keepPosition => curPage > -1;

  final GlobalKey<SliverAnimatedListState> sliverAnimatedListKey =
      GlobalKey<SliverAnimatedListState>();

  Key galleryGroupKey = UniqueKey();

  List<GalleryProvider>? state = [];
  RxStatus status = RxStatus.loading();

  void change(List<GalleryProvider>? newState, {RxStatus? status}) {
    state = newState;
    if (status != null) {
      this.status = status;
    }
    update([listViewId]);
  }

  final Rx<PageState> _pageState = PageState.None.obs;
  PageState get pageState => _pageState.value;
  set pageState(PageState val) => _pageState.value = val;

  bool get canLoadData =>
      pageState != PageState.Loading && pageState != PageState.LoadingMore;

  final EhConfigService ehConfigService = Get.find();

  // 请求一批画廊数据
  Future<GalleryList?> fetchData({bool refresh = false}) async {
    cancelToken = CancelToken();
    return null;
  }

  Future<GalleryList?> fetchMoreData() async {
    cancelToken = CancelToken();
    return null;
  }

  // 首次请求
  Future<void> firstLoad() async {
    canLoadMore = false;
    await Future.delayed(200.milliseconds);
    try {
      cancelToken = CancelToken();
      final GalleryList? rult = await fetchData();
      if (rult == null) {
        change(null, status: RxStatus.loading());
        return;
      }

      final _listItem = rult.gallerys;

      logger.v('_listItem ${_listItem?.length}');

      maxPage = rult.maxPage ?? 0;
      nextPage = rult.nextPage ?? 1;
      change(_listItem, status: RxStatus.success());
    } catch (err, stack) {
      logger.e('$err\n$stack');
      final errmsg = err is HttpException ? err.message : '$err';
      change(null, status: RxStatus.error(errmsg));
    } finally {
      canLoadMore = true;
    }
  }

  // 重新加载
  Future<void> reloadData() async {
    curPage = 0;

    try {
      final GalleryList? rult = await fetchData(
        refresh: true,
      );

      logger.v('reloadData length ${rult?.gallerys?.length}');

      if (rult == null) {
        return;
      }

      final List<GalleryProvider>? rultList = rult.gallerys;

      maxPage = rult.maxPage ?? 0;
      nextPage = rult.nextPage ?? 1;
      change(rultList, status: RxStatus.success());
    } catch (err) {
      // change(state, status: RxStatus.error(err.toString()));
      final errmsg = err is HttpException ? err.message : '$err';
      showToast(errmsg);
    }
  }

  int? lastNextPage;

  // 加载更多
  Future<void> loadDataMore() async {
    await Future.delayed(100.milliseconds);
    if (!canLoadData) {
      logger.e('not canLoadData');
      return;
    }

    if (!canLoadMore) {
      logger.e('not canLoadMore');
      return;
    }

    if (lastNextPage == nextPage) {
      logger.v('lastNextPage == nextPage  $nextPage');
      return;
    }

    logger.v('loadDataMore .....');
    pageState = PageState.LoadingMore;

    logger.d('load page: $nextPage');

    lastNextPage = nextPage;

    try {
      final GalleryList? rult = await fetchMoreData();

      if (rult == null) {
        return;
      }

      final List<GalleryProvider> rultList = rult.gallerys ?? [];

      if (rultList.isNotEmpty &&
          state?.indexWhere(
                  (GalleryProvider e) => e.gid == rultList.first.gid) ==
              -1) {
        maxPage = rult.maxPage ?? 0;
        nextPage = rult.nextPage ?? 1;
        curPage = nextPage;
      }

      final insertIndex = state?.length ?? 0;

      logger.v('insertIndex $insertIndex');

      change([...?state, ...rultList], status: RxStatus.success());

      // for (final _ in rultList) {
      //   sliverAnimatedListKey.currentState?.insertItem(insertIndex);
      // }
    } catch (e, stack) {
      pageState = PageState.LoadingException;
      rethrow;
    }
    // 成功才更新

    pageState = PageState.None;
  }

  // 加载上一页
  Future<void> loadPrevious() async {
    // keepPosition = true;

    await loadFromPage(prevPage ?? 0, previous: true);
  }

  // 跳转到指定页加载
  Future<void> loadFromPage(int page, {bool previous = false}) async {
    cancelToken = CancelToken();
  }

  Future<void> onRefresh() async {
    if (!(cancelToken?.isCancelled ?? false)) {
      cancelToken?.cancel();
    }
    change(state, status: RxStatus.success());
    logger.v('minPage: $minPage');
    if (minPage > 1) {
      await loadPrevious();
    } else {
      await reloadData();
    }
  }

  Future<void> reLoadDataFirst() async {
    if (!(cancelToken?.isCancelled ?? false)) {
      cancelToken?.cancel();
    }
    change(null, status: RxStatus.loading());
    onReady();
  }

  Future<void> lastComplete() async {}

  void initEhTabController({
    required BuildContext context,
    required EhTabController ehTabController,
    String? tabTag,
  }) {
    ehTabController.scrollToTopCall = () => srcollToTop(context);
    ehTabController.scrollToTopRefreshCall = () => srcollToTopRefresh(context);

    tabPages.scrollControllerMap[tabTag ?? heroTag ?? ''] = ehTabController;
  }

  void srcollToTop(BuildContext context) {
    PrimaryScrollController.of(context)?.animateTo(0.0,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  void srcollToTopRefresh(BuildContext context) {
    PrimaryScrollController.of(context)?.animateTo(
        -kDefaultRefreshTriggerPullDistance,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease);
  }

  @override
  void onReady() {
    super.onReady();
    firstLoad();
  }
}
