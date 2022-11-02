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
  final TagController tagController = Get.find();

  String get listViewId => 'listViewId';

  // 下一页
  String? next;
  // 上一页
  String? prev;

  String? heroTag;

  CancelToken? cancelToken = CancelToken();

  bool canLoadMore = false;

  bool get keepPosition => prev?.isNotEmpty ?? false;

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

  Future<GalleryList?> fetchPrevData() async {
    cancelToken = CancelToken();
    return null;
  }

  // 首次请求
  Future<void> firstLoad() async {
    canLoadMore = false;
    await Future.delayed(200.milliseconds);
    try {
      cancelToken = CancelToken();
      final GalleryList? result = await fetchData();
      if (result == null) {
        change(null, status: RxStatus.loading());
        return;
      }

      final _listItem = result.gallerys;

      logger.v('_listItem ${_listItem?.length}');

      next = result.next;
      prev = result.prev;
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
    next = null;
    prev = null;

    try {
      final GalleryList? result = await fetchData(
        refresh: true,
      );

      logger.v('reloadData length ${result?.gallerys?.length}');

      if (result == null) {
        return;
      }

      final List<GalleryProvider>? resultList = result.gallerys;

      next = result.next;
      prev = result.prev;

      logger.v('reloadData next $next, prev $prev');

      change(resultList, status: RxStatus.success());
    } catch (err) {
      // change(state, status: RxStatus.error(err.toString()));
      final errmsg = err is HttpException ? err.message : '$err';
      showToast(errmsg);
    }
  }

  String? lastNext;
  String? lastPrev;

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

    if (lastNext == next) {
      logger.v('lastNext == next  $next');
      return;
    }

    logger.v('loadDataMore .....');
    pageState = PageState.LoadingMore;

    logger.v('load page next: $next');

    lastNext = next;

    try {
      final GalleryList? result = await fetchMoreData();

      if (result == null) {
        return;
      }

      final List<GalleryProvider> resultList = result.gallerys ?? [];

      if (resultList.isNotEmpty &&
          state?.indexWhere(
                  (GalleryProvider e) => e.gid == resultList.first.gid) ==
              -1) {
        next = result.next;
        prev = result.prev;
      }

      final insertIndex = state?.length ?? 0;

      logger.v('insertIndex $insertIndex');

      change([...?state, ...resultList], status: RxStatus.success());

      // for (final _ in resultList) {
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
    await Future.delayed(100.milliseconds);
    if (!canLoadData) {
      logger.e('not canLoadData');
      return;
    }

    if (!canLoadMore) {
      logger.e('not canLoadMore');
      return;
    }

    if (lastPrev == prev) {
      logger.v('lastNext == next  $next');
      return;
    }

    logger.v('loadDataMore .....');
    pageState = PageState.LoadingMore;

    logger.v('load page prev: $prev');

    lastPrev = prev;

    try {
      final GalleryList? result = await fetchPrevData();

      if (result == null) {
        return;
      }

      final List<GalleryProvider> resultList = result.gallerys ?? [];

      if (resultList.isNotEmpty &&
          state?.indexWhere(
                  (GalleryProvider e) => e.gid == resultList.first.gid) ==
              -1) {
        next = result.next;
        prev = result.prev;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        change([...resultList, ...?state], status: RxStatus.success());
      });
    } catch (e, stack) {
      pageState = PageState.LoadingException;
      rethrow;
    }
    // 成功才更新

    pageState = PageState.None;
  }

  // 跳转到指定页加载
  // Future<void> loadFromPage(int page, {bool previous = false}) async {
  //   cancelToken = CancelToken();
  // }

  Future<void> onRefresh() async {
    if (!(cancelToken?.isCancelled ?? false)) {
      cancelToken?.cancel();
    }
    change(state, status: RxStatus.success());
    logger.v('prev: $prev');
    if ((prev ?? '').isNotEmpty) {
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
