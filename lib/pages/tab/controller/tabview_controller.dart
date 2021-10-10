import 'dart:ui' show ImageFilter;

import 'package:collection/collection.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:dio/dio.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/pages/tab/controller/toplist_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/widget/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../fetch_list.dart';
import 'enum.dart';

typedef FetchCallBack = Future<GalleryList?> Function({
  int page,
  bool refresh,
  int cats,
  String fromGid,
  String favcat,
  String toplist,
  SearchType searchType,
  CancelToken cancelToken,
});

class TabViewController extends GetxController
    with StateMixin<List<GalleryItem>> {
  TabViewController({this.cats});

  int? cats;

  late String tabTag;

  RxInt curPage = 0.obs;
  int maxPage = 1;

  final RxBool _isBackgroundRefresh = false.obs;

  bool get isBackgroundRefresh => _isBackgroundRefresh.value;

  set isBackgroundRefresh(bool val) => _isBackgroundRefresh.value = val;

  final Rx<PageState> _pageState = PageState.None.obs;

  PageState get pageState => _pageState.value;

  set pageState(PageState val) => _pageState.value = val;

  final EhConfigService _ehConfigService = Get.find();

  final CancelToken cancelToken = CancelToken();

  final GlobalKey<SliverAnimatedListState> sliverAnimatedListKey =
      GlobalKey<SliverAnimatedListState>();

  // 页码跳转输入框的控制器
  final TextEditingController _pageController = TextEditingController();

  // FetchCallBack? fetchNormal;

  FetchListClient? fetchList;

  String? _curFavcat;
  String get curFavcat {
    return _curFavcat ?? _ehConfigService.lastShowFavcat ?? 'a';
  }

  set curFavcat(String? val) {
    _curFavcat = val;
  }

  String get currToplist => topListVal[_ehConfigService.toplist] ?? '15';

  bool isLoadPrevious = false;
  int lastTopitemIndex = 0;

  @override
  void onReady() {
    super.onReady();
    firstLoad();
  }

  Future<void> firstLoad() async {
    try {
      final GalleryList? rult = await fetchData();
      if (rult == null) {
        return;
      }

      final List<GalleryItem> _listItem = rult.gallerys ?? [];
      // Api.getMoreGalleryInfo(_listItem);

      maxPage = rult.maxPage ?? 0;
      change(_listItem, status: RxStatus.success());
    } catch (err, stack) {
      logger.e('$err\n$stack');
      change(null, status: RxStatus.error(err.toString()));
    }

    try {
      if (cancelToken.isCancelled) {
        return;
      }
      isBackgroundRefresh = true;
      await reloadData();
    } catch (_) {
    } finally {
      isBackgroundRefresh = false;
    }
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

  FetchListClient getFetchListClient(FetchParams fetchParams) {
    return DefaultFetchListClient(fetchParams: fetchParams);
  }

  Future<GalleryList?> fetchData({bool refresh = false}) async {
    logger.d('fetchData');
    final int _catNum = _ehConfigService.catFilter.value;

    final fetchConfig = FetchParams(
      cats: cats ?? _catNum,
      toplist: currToplist,
      refresh: refresh,
      cancelToken: cancelToken,
    );

    try {
      // final Future<GalleryList?>? rult = fetchNormal?.call(
      //   cats: cats ?? _catNum,
      //   toplist: currToplist,
      //   refresh: refresh,
      //   cancelToken: cancelToken,
      // );

      FetchListClient fetchListClient = getFetchListClient(fetchConfig);
      final Future<GalleryList?> rult = fetchListClient.fetch();

      return rult;
    } on EhError catch (eherror) {
      logger.e('type:${eherror.type}\n${eherror.message}');
      showToast(eherror.message);
      rethrow;
    }
  }

  Future<void> reloadData() async {
    curPage.value = 0;
    final GalleryList? tuple = await fetchData(
      refresh: true,
    );
    if (tuple == null) {
      return;
    }

    maxPage = tuple.maxPage ?? 0;
    change(tuple.gallerys, status: RxStatus.success());
  }

  Future<void> onRefresh({GlobalKey? centerKey}) async {
    isBackgroundRefresh = false;
    if (!cancelToken.isCancelled) {
      cancelToken.cancel();
    }
    change(state, status: RxStatus.success());
    if (isLoadPrevious) {
      logger.d('isLoadPrevious');
      await loadPrevious();

      // WidgetsBinding.instance?.addPostFrameCallback((_) {
      //   Future.delayed(const Duration(milliseconds: 50)).then(
      //     (value) {
      //       //获取position
      //       RenderBox? box =
      //           centerKey?.currentContext?.findRenderObject() as RenderBox?;
      //       Offset? offset = box?.localToGlobal(Offset.zero);
      //       logger.d('offset $offset');
      //
      //       Scrollable.ensureVisible(centerKey!.currentContext!);
      //     },
      //   );
      // });
    } else {
      await reloadData();
    }
  }

  Future<void> reLoadDataFirst() async {
    logger.d('reLoadDataFirst ');
    isBackgroundRefresh = false;
    if (!cancelToken.isCancelled) {
      cancelToken.cancel();
    }
    change(null, status: RxStatus.loading());
    onInit();
  }

  Future<void> loadDataMore() async {
    if (pageState == PageState.Loading) {
      return;
    }

    logger.d('loadDataMore .....');

    final int _catNum = _ehConfigService.catFilter.value;

    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    logger.d('load page: ${curPage.value + 1}');

    final String fromGid = state?.last.gid ?? '0';
    try {
      pageState = PageState.Loading;
      // final GalleryList? rult = await fetchNormal?.call(
      //   page: curPage.value + 1,
      //   fromGid: fromGid,
      //   cats: cats ?? _catNum,
      //   refresh: true,
      //   cancelToken: cancelToken,
      //   favcat: curFavcat,
      //   toplist: currToplist,
      // );

      final fetchConfig = FetchParams(
        page: curPage.value + 1,
        fromGid: fromGid,
        cats: cats ?? _catNum,
        refresh: true,
        cancelToken: cancelToken,
        favcat: curFavcat,
        toplist: currToplist,
      );
      FetchListClient fetchListClient = getFetchListClient(fetchConfig);
      final GalleryList? rult = await fetchListClient.fetch();

      if (rult == null) {
        return;
      }

      final List<GalleryItem> rultList = rult.gallerys ?? [];

      logger.d('ori len:${state?.length}');

      if (rultList.isNotEmpty &&
          state?.indexWhere((GalleryItem e) => e.gid == rultList.first.gid) ==
              -1) {
        // state?.addAll(rultList);
        maxPage = rult.maxPage ?? 0;

        // logger.d('add all to end ${state?.length}');
      }

      final insertIndex = state?.length ?? 0;

      change([...?state, ...rultList], status: RxStatus.success());

      for (final item in rultList) {
        sliverAnimatedListKey.currentState?.insertItem(insertIndex);
      }

      // 成功才+1
      curPage.value += 1;
      pageState = PageState.None;
    } catch (e, stack) {
      pageState = PageState.LoadingException;
      rethrow;
    }
  }

  // 加载上一页
  Future<void> loadPrevious() async {
    if (pageState == PageState.Loading) {
      return;
    }

    final int _catNum = _ehConfigService.catFilter.value;

    final lastTopitemGid = state?.first.gid ?? '';
    logger.d('lastTopitemGid $lastTopitemGid');

    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    try {
      // final GalleryList? rult = await fetchNormal?.call(
      //   page: curPage.value - 1,
      //   cats: cats ?? _catNum,
      //   refresh: true,
      //   cancelToken: cancelToken,
      //   favcat: curFavcat,
      //   toplist: currToplist,
      // );

      final fetchConfig = FetchParams(
        page: curPage.value - 1,
        cats: cats ?? _catNum,
        refresh: true,
        cancelToken: cancelToken,
        favcat: curFavcat,
        toplist: currToplist,
      );
      FetchListClient fetchListClient = getFetchListClient(fetchConfig);
      final GalleryList? rult = await fetchListClient.fetch();

      if (rult == null) {
        return;
      }

      final List<GalleryItem> galleryItemBeans = rult.gallerys ?? [];

      if (galleryItemBeans.isNotEmpty) {
        state?.insertAll(0, galleryItemBeans);

        maxPage = rult.maxPage ?? 0;

        lastTopitemIndex =
            state?.indexWhere((e) => e.gid == lastTopitemGid) ?? 0;
        logger.d('lastTopitemIndex $lastTopitemIndex');

        change(state);
      }
      // 成功才-1
      curPage.value -= 1;
      // update();
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<void> loadFromPage(int page) async {
    logger.v('jump to page =>  $page');

    final int _catNum = _ehConfigService.catFilter.value;

    change(state, status: RxStatus.loading());
    // final rult = await fetchNormal?.call(
    //   page: page,
    //   cats: cats ?? _catNum,
    //   refresh: true,
    //   cancelToken: cancelToken,
    //   favcat: curFavcat,
    //   toplist: currToplist,
    // );

    final fetchConfig = FetchParams(
      page: page,
      cats: cats ?? _catNum,
      refresh: true,
      cancelToken: cancelToken,
      favcat: curFavcat,
      toplist: currToplist,
    );
    FetchListClient fetchListClient = getFetchListClient(fetchConfig);
    final GalleryList? rult = await fetchListClient.fetch();

    isLoadPrevious = page > 1;
    curPage.value = page;
    if (rult != null) {
      change(rult.gallerys, status: RxStatus.success());
    }
  }

  /// 跳转页码
  Future<void> jumpToPage() async {
    void _jump() {
      final String _input = _pageController.text.trim();

      if (_input.isEmpty) {
        showToast(L10n.of(Get.context!).input_empty);
      }

      // 数字检查
      if (!RegExp(r'(^\d+$)').hasMatch(_input)) {
        showToast(L10n.of(Get.context!).input_error);
      }

      final int _toPage = int.parse(_input) - 1;
      if (_toPage >= 0 && _toPage <= maxPage) {
        FocusScope.of(Get.context!).requestFocus(FocusNode());
        loadFromPage(_toPage);
        Get.back();
      } else {
        showToast(L10n.of(Get.context!).page_range_error);
      }
    }

    return showCupertinoDialog<void>(
      context: Get.overlayContext!,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(L10n.of(context).jump_to_page),
          content: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${L10n.of(context).page_range} 1~$maxPage'),
                ),
                CupertinoTextField(
                  decoration: BoxDecoration(
                    color: ehTheme.textFieldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  controller: _pageController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  onEditingComplete: () {
                    // 点击键盘完成
                    // 画廊跳转
                    _jump();
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(L10n.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                L10n.of(context).ok,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                // 画廊跳转
                _jump();
              },
            ),
          ],
        );
      },
    );
  }

  final TabHomeController _tabHomeController = Get.find();

  bool get enablePopupMenu =>
      _tabHomeController.tabMap.entries
          .toList()
          .indexWhere((MapEntry<String, bool> element) => !element.value) >
      -1;

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
                          fontWeight: FontWeight.w500,
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

  Widget? getLeading(BuildContext context) => Navigator.of(context).canPop()
      ? null
      : enablePopupMenu && (!Get.find<EhConfigService>().isSafeMode.value)
          ? buildLeadingCustomPopupMenu(Get.context!)
          : const SizedBox();
}
