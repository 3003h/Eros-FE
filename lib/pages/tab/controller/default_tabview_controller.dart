import 'dart:ui' show ImageFilter;

import 'package:collection/collection.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:dio/dio.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/const/theme_colors.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/tab/controller/search_page_controller.dart';
import 'package:eros_fe/pages/tab/controller/tabhome_controller.dart';
import 'package:eros_fe/pages/tab/controller/toplist_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../comm.dart';
import '../fetch_list.dart';
import 'enum.dart';
import 'tabview_controller.dart';

class DefaultTabViewController extends TabViewController {
  DefaultTabViewController();

  int? cats;

  String? initSearchText;
  final RxString _searchText = ''.obs;

  String get searchText => _searchText.value;

  set searchText(String val) => _searchText.value = val;

  // 搜索类型
  final Rx<SearchType> _searchType = SearchType.normal.obs;

  SearchType get searchType => _searchType.value;

  set searchType(SearchType val) => _searchType.value = val;

  // 页码跳转输入框的控制器
  final TextEditingController pageJumpTextEditController =
      TextEditingController();

  FetchListClient? fetchClient;

  String? _curFavcat;

  String get curFavcat {
    return _curFavcat ?? ehSettingService.lastShowFavcat ?? 'a';
  }

  set curFavcat(String? val) {
    _curFavcat = val;
  }

  String get currToplist => topListVal[ehSettingService.toplist] ?? '15';

  int lastTopitemIndex = 0;

  final previousList = <GalleryProvider>[].obs;

  bool lastItemBuildComplete = false;

  @override
  Future<void> firstLoad() async {
    await super.firstLoad();
    lastItemBuildComplete = false;

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

  FetchListClient getFetchListClient(FetchParams fetchParams) {
    return DefaultFetchListClient(fetchParams: fetchParams);
  }

  @override
  Future<GalleryList?> fetchData({bool refresh = false}) async {
    final int _catNum = ehSettingService.catFilter.value;
    cancelToken = CancelToken();

    final fetchConfig = FetchParams(
      cats: cats ?? _catNum,
      toplist: currToplist,
      refresh: refresh,
      cancelToken: cancelToken,
      searchType: searchType,
      searchText: searchText,
    );

    pageState = PageState.Loading;

    try {
      FetchListClient fetchListClient = getFetchListClient(fetchConfig);
      final GalleryList? rult = await fetchListClient.fetch();

      if (cancelToken?.isCancelled ?? false) {
        return null;
      }

      pageState = PageState.None;

      final _list = rult?.gallerys
              ?.map((e) => e.simpleTags ?? [])
              .expand((List<SimpleTag> element) => element)
              .toList() ??
          [];

      tagController.addAllSimpleTag(_list);
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
  Future<void> reloadData() async {
    await super.reloadData();
    lastItemBuildComplete = false;
  }

  @override
  Future<void> onRefresh() async {
    isBackgroundRefresh = false;
    await super.onRefresh();
  }

  @override
  Future<void> reLoadDataFirst() async {
    logger.d('reLoadDataFirst isCancelled ${cancelToken?.isCancelled}');
    isBackgroundRefresh = false;
    await super.reLoadDataFirst();
  }

  @override
  Future<GalleryList?> fetchMoreData() async {
    logger.t('fetchMoreData nextPage $nextPage');
    cancelToken = CancelToken();
    final fetchConfig = FetchParams(
      pageType: PageType.next,
      gid: nextPage > -1 ? (state?.lastOrNull?.gid ?? '') : nextGid,
      cats: cats ?? ehSettingService.catFilter.value,
      refresh: true,
      cancelToken: cancelToken,
      favcat: curFavcat,
      toplist: currToplist,
      searchType: searchType,
      searchText: searchText,
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
      cats: cats ?? ehSettingService.catFilter.value,
      refresh: true,
      cancelToken: cancelToken,
      favcat: curFavcat,
      toplist: currToplist,
      searchType: searchType,
      searchText: searchText,
      page: prevPage,
    );
    FetchListClient fetchListClient = getFetchListClient(fetchConfig);
    return await fetchListClient.fetch();
  }

  @override
  Future<void> loadDataMore() async {
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    super.loadDataMore();
    lastItemBuildComplete = false;
  }

  @override
  Future<GalleryList?> fetchDataFrom({
    String? gid,
    PageType? pageType,
    String? jump,
    String? seek,
    int? page,
  }) async {
    final fetchConfig = FetchParams(
      pageType: pageType,
      gid: gid,
      cats: cats ?? ehSettingService.catFilter.value,
      refresh: true,
      cancelToken: cancelToken,
      favcat: curFavcat,
      toplist: currToplist,
      searchType: searchType,
      searchText: searchText,
      jump: jump,
      seek: seek,
      page: page,
    );

    FetchListClient fetchListClient = getFetchListClient(fetchConfig);
    final result = await fetchListClient.fetch();
    return result;
  }

  final TabHomeController _tabHomeController = Get.find();

  int get hidenTagCount => _tabHomeController.tabMap.entries
      .where((MapEntry<String, bool> element) => !element.value)
      .length;

  // 至少收起两个的时候 使用PopupMenu
  bool get enablePopupMenu => hidenTagCount >= 2;

  bool get enableSingle => hidenTagCount == 1;

  String get singleTabFlag => _tabHomeController.tabMap.entries
      .where((MapEntry<String, bool> element) => !element.value)
      .first
      .key;

  final CustomPopupMenuController customPopupMenuController =
      CustomPopupMenuController();

  Widget get popupMenu {
    final List<Widget> _menu = <Widget>[];
    for (final MapEntry<String, bool> elem
        in _tabHomeController.tabMap.entries) {
      if (!elem.value) {
        _menu.add(
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // vibrateUtil.light();
              customPopupMenuController.hideMenu();
              Get.toNamed(
                elem.key,
                id: isLayoutLarge ? 1 : null,
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.only(left: 14, right: 18, top: 5, bottom: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    tabPages.iconDatas[elem.key],
                    size: 20,
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        tabPages.tabTitles[elem.key] ?? '',
                        style: TextStyle(
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.label, Get.context!),
                          fontWeight: FontWeight.normal,
                          // fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _menu,
    );
  }

  Widget buildLeadingSingle(BuildContext context) {
    if (!enableSingle) {
      return const SizedBox.shrink();
    }

    final tabFlag = singleTabFlag;

    return CupertinoButton(
        child: Icon(
          tabPages.iconDatas[tabFlag],
          size: 20,
        ),
        onPressed: () {
          Get.toNamed(
            tabFlag,
            id: isLayoutLarge ? 1 : null,
          );
        });
  }

  Widget buildLeadingCustomPopupMenu(BuildContext context) {
    return CupertinoTheme(
      data: ehTheme.themeData!,
      child: CustomPopupMenu(
        child: Container(
          padding: const EdgeInsets.only(left: 14, bottom: 2),
          child: const Icon(
            CupertinoIcons.ellipsis_circle,
            size: 24,
          ),
        ),
        // arrowColor: _color,
        showArrow: false,
        menuBuilder: () {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                color: CupertinoDynamicColor.resolve(
                    ThemeColors.dialogColor, context),
                child: IntrinsicWidth(
                  child: popupMenu,
                ),
              ),
            ),
          );
        },
        pressType: PressType.singleClick,
        verticalMargin: -2,
        horizontalMargin: 8,
        controller: customPopupMenuController,
      ),
    );
  }

  Widget? getLeading(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      return null;
    }

    return Obx(() {
      if (enablePopupMenu && (!Get.find<EhSettingService>().isSafeMode.value)) {
        return buildLeadingCustomPopupMenu(context);
      }

      if (enableSingle) {
        return buildLeadingSingle(context);
      }
      return const SizedBox.shrink();
    });
  }

  void initStateForListPage({
    required BuildContext context,
    required EhTabController ehTabController,
  }) {
    initEhTabController(context: context, ehTabController: ehTabController);

    // initStateAddPostFrameCallback(context);
  }

  @override
  Future<void> lastComplete() async {
    lastItemBuildComplete = true;
    logger.d('加载更多...$next');
    if ((state ?? []).isNotEmpty &&
        next.isNotEmpty &&
        pageState != PageState.Loading) {
      // 加载更多
      logger.d('加载更多');
      await loadDataMore();
    }
  }

  // void initStateAddPostFrameCallback(BuildContext context) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final _scrollController = PrimaryScrollController.of(context);
  //     _scrollController?.addListener(() async {
  //       if (_scrollController.position.pixels >
  //           _scrollController.position.maxScrollExtent -
  //               context.mediaQuerySize.longestSide) {
  //         if (next.isNotEmpty &&
  //             lastItemBuildComplete &&
  //             pageState != PageState.Loading) {
  //           // 加载更多
  //           await loadDataMore();
  //         } else {
  //           // 没有更多了
  //           // showToast('No More');
  //         }
  //       }
  //     });
  //   });
  // }
}
