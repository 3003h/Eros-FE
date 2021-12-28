import 'package:dio/dio.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../comm.dart';
import 'enum.dart';

class TabViewController extends GetxController
    with StateMixin<List<GalleryItem>> {
  // 当前页码
  final _curPage = 0.obs;
  int get curPage => _curPage.value;
  set curPage(int val) => _curPage.value = val;

  // 最小页码
  int minPage = 1;
  // 最大页码
  int maxPage = 1;
  // 下一页
  int nextPage = 1;

  String? tabTag;

  CancelToken? cancelToken = CancelToken();

  final GlobalKey<SliverAnimatedListState> sliverAnimatedListKey =
      GlobalKey<SliverAnimatedListState>();

  final Rx<PageState> _pageState = PageState.None.obs;
  PageState get pageState => _pageState.value;
  set pageState(PageState val) => _pageState.value = val;

  bool get canLoadData =>
      pageState != PageState.Loading && pageState != PageState.LoadingMore;

  final EhConfigService ehConfigService = Get.find();

  // 请求一批画廊数据
  Future<GalleryList?> fetchData({bool refresh = false}) async {}

  Future<GalleryList?> fetchMoreData() async {}

  // 首次请求
  Future<void> firstLoad() async {
    await Future.delayed(200.milliseconds);
    try {
      final GalleryList? rult = await fetchData();
      if (rult == null) {
        change(null, status: RxStatus.loading());
        return;
      }

      final _listItem = rult.gallerys;

      logger.d('_listItem ${_listItem?.length}');

      maxPage = rult.maxPage ?? 0;
      nextPage = rult.nextPage ?? 1;
      change(_listItem, status: RxStatus.success());
    } catch (err, stack) {
      logger.e('$err\n$stack');
      change(null, status: RxStatus.error(err.toString()));
    }
  }

  // 重新加载
  Future<void> reloadData() async {
    curPage = 0;
    final GalleryList? rult = await fetchData(
      refresh: true,
    );

    logger.d('reloadData length ${rult?.gallerys?.length}');

    if (rult == null || (rult.gallerys?.isEmpty ?? true)) {
      return;
    }

    final List<GalleryItem> rultList = rult.gallerys ?? [];

    maxPage = rult.maxPage ?? 0;
    nextPage = rult.nextPage ?? 1;
    // change([], status: RxStatus.success());
    change(rult.gallerys, status: RxStatus.success());
  }

  // 加载更多
  Future<void> loadDataMore() async {
    await Future.delayed(100.milliseconds);
    if (!canLoadData) {
      logger.e('not canLoadData');
      return;
    }

    logger.d('loadDataMore .....');
    cancelToken = CancelToken();
    pageState = PageState.LoadingMore;

    logger.d('load page: $nextPage');
    final lastNextPage = nextPage;

    try {
      final GalleryList? rult = await fetchMoreData();

      if (rult == null) {
        return;
      }

      final List<GalleryItem> rultList = rult.gallerys ?? [];

      if (rultList.isNotEmpty &&
          state?.indexWhere((GalleryItem e) => e.gid == rultList.first.gid) ==
              -1) {
        maxPage = rult.maxPage ?? 0;
        nextPage = rult.nextPage ?? 1;
      }

      final insertIndex = state?.length ?? 0;

      logger.v('insertIndex $insertIndex');

      change([...?state, ...rultList], status: RxStatus.success());

      for (final item in rultList) {
        sliverAnimatedListKey.currentState?.insertItem(insertIndex);
      }
    } catch (e, stack) {
      pageState = PageState.LoadingException;
      rethrow;
    }
    // 成功才更新
    curPage = lastNextPage;
    pageState = PageState.None;
  }

  // 加载上一页
  Future<void> loadPrevious() async {}

  // 跳转到指定页加载
  Future<void> loadFromPage(int page) async {}

  Future<void> onRefresh() async {
    if (!(cancelToken?.isCancelled ?? false)) {
      cancelToken?.cancel();
    }
    change(state, status: RxStatus.success());
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

    tabPages.scrollControllerMap[tabTag ?? this.tabTag ?? ''] = ehTabController;
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
