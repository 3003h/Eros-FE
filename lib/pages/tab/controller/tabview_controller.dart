import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:eros_fe/common/controller/tag_controller.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/app_dio/pdio.dart';
import 'package:eros_fe/pages/tab/controller/tabhome_controller.dart';
import 'package:eros_fe/pages/tab/fetch_list.dart';
import 'package:eros_fe/utils/app_cupertino_localizations_delegate.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../comm.dart';
import 'enum.dart';

const CupertinoDynamicColor _kClearButtonColor =
    CupertinoDynamicColor.withBrightness(
  color: Color(0xFF636366),
  darkColor: Color(0xFFAEAEB2),
);

abstract class TabViewController extends GetxController {
  // 当前页码
  // final _curPage = (-1).obs;
  // int get curPage => _curPage.value;
  // set curPage(int val) => _curPage.value = val;

  final TagController tagController = Get.find();

  String get listViewId => 'listViewId';

  // 最大页码
  int? maxPage = 1;

  final RxInt _nextPage = (-1).obs;
  int get nextPage => _nextPage.value;
  set nextPage(int? val) => _nextPage.value = val ?? -1;

  final RxInt _prevPage = (-1).obs;
  int get prevPage => _prevPage.value;
  set prevPage(int? val) => _prevPage.value = val ?? -1;

  // 下一页
  final RxString _nextGid = ''.obs;
  String get nextGid => _nextGid.value;
  set nextGid(String? value) => _nextGid.value = value ?? '';

  // 上一页
  final RxString _prevGid = ''.obs;
  String get prevGid => _prevGid.value;
  set prevGid(String? value) => _prevGid.value = value ?? '';

  String get next => '${nextPage > 0 ? nextPage : nextGid}';

  String get prev => '${prevPage > -1 ? prevPage : prevGid}';

  final _afterJump = false.obs;
  bool get afterJump => _afterJump.value;
  set afterJump(bool value) => _afterJump.value = value;

  final TextEditingController pageTextEditController = TextEditingController();

  final TextEditingController gidTextEditController = TextEditingController();

  final TextEditingController jumpOrSeekTextEditController =
      TextEditingController();
  final gidNode = FocusNode();

  String? heroTag;

  CancelToken? cancelToken = CancelToken();

  bool canLoadMore = false;

  bool get keepPosition => prevGid.isNotEmpty || prevPage > -1;

  final RxBool _isBackgroundRefresh = false.obs;
  bool get isBackgroundRefresh => _isBackgroundRefresh.value;
  set isBackgroundRefresh(bool val) => _isBackgroundRefresh.value = val;

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
      pageState != PageState.Loading &&
      pageState != PageState.LoadingMore &&
      pageState != PageState.LoadingPrev;

  final EhSettingService ehSettingService = Get.find();

  @override
  void onReady() {
    super.onReady();
    logger.t('onReady');
    firstLoad();
  }

  // 请求一批画廊数据
  Future<GalleryList?> fetchData({bool refresh = false}) async {
    // logger.d('super fetchData ....');
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

  Future<GalleryList?> fetchDataFrom({
    String? gid,
    PageType? pageType,
    String? jump,
    String? seek,
    int? page,
  }) async {
    cancelToken = CancelToken();
    return null;
  }

  void setResultPage(GalleryList result) {
    nextGid = result.nextGid;
    prevGid = result.prevGid;
    nextPage = result.nextPage;
    prevPage = result.prevPage;
    maxPage = result.maxPage;
  }

  void resetResultPage() {
    nextGid = null;
    prevGid = null;
    nextPage = null;
    prevPage = null;
    maxPage = null;
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

      logger.t('_listItem ${_listItem?.length}');

      setResultPage(result);
      change(_listItem, status: RxStatus.success());
    } catch (err, stack) {
      logger.e('$err\n$stack');
      final errMsg = err is HttpException ? err.message : '$err';
      change(null, status: RxStatus.error(errMsg));
    } finally {
      canLoadMore = true;
    }
  }

  // 重新加载
  Future<void> reloadData() async {
    resetResultPage();

    try {
      final GalleryList? result = await fetchData(
        refresh: true,
      );

      logger.t('reloadData length ${result?.gallerys?.length}');

      if (result == null) {
        return;
      }

      final List<GalleryProvider>? resultList = result.gallerys;

      setResultPage(result);

      logger.t('reloadData next $next, prev $prev');

      change(resultList, status: RxStatus.success());
      afterJump = false;
    } catch (err) {
      // change(state, status: RxStatus.error(err.toString()));
      final errmsg = err is HttpException ? err.message : '$err';
      showToast(errmsg);
    }
  }

  Future<void> jumpToTop() async {
    await reloadData();
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
      logger.t('lastNext == next  $next');
      return;
    }

    logger.t('loadDataMore .....');
    pageState = PageState.LoadingMore;

    logger.d('load page next: $next');

    lastNext = next;

    try {
      final GalleryList? result = await fetchMoreData();

      if (result == null) {
        return;
      }

      final List<GalleryProvider> resultList = result.gallerys ?? [];

      final n = state?.indexWhere(
              (GalleryProvider e) => e.gid == resultList.firstOrNull?.gid) ==
          -1;

      if (resultList.isNotEmpty && n) {
        setResultPage(result);

        logger.d('loadDataMore next $next, prev $prev');
      }

      final insertIndex = state?.length ?? 0;

      logger.t('insertIndex $insertIndex');

      change([...?state, ...resultList], status: RxStatus.success());
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
    logger.d('loadPrevious .....');
    if (!canLoadData) {
      logger.e('not loadPrevious');
      return;
    }

    if (!canLoadMore) {
      logger.e('not loadPrevious');
      return;
    }

    if (lastPrev == prev) {
      logger.t('lastPrev == prev  $prev');
      return;
    }

    logger.t('loadPrevious .....');
    pageState = PageState.LoadingPrev;

    logger.t('load page prev: $prevGid');

    lastPrev = prevGid;

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
        setResultPage(result);
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

  Future<void> loadFrom({
    String? gid,
    PageType? pageType,
    String? jump,
    String? seek,
    int? page,
  }) async {
    cancelToken = CancelToken();

    canLoadMore = false;
    pageState = PageState.Loading;
    change(state, status: RxStatus.loading());
    try {
      final GalleryList? result = await fetchDataFrom(
        gid: gid,
        pageType: pageType,
        jump: jump,
        seek: seek,
        page: page,
      );
      if (result == null) {
        change(null, status: RxStatus.loading());
        return;
      }

      final _listItem = result.gallerys;

      logger.t('loadFrom _listItem ${_listItem?.length}');

      setResultPage(result);
      change(_listItem, status: RxStatus.success());
      pageState = PageState.None;
      logger.d('loadFrom next $next, prev $prev');
      afterJump = true;
    } catch (err, stack) {
      logger.e('$err\n$stack');
      final errMsg = err is HttpException ? err.message : '$err';
      pageState = PageState.LoadingError;
      change(null, status: RxStatus.error(errMsg));
    } finally {
      canLoadMore = true;
    }
  }

  Future<void> onRefresh() async {
    if (!(cancelToken?.isCancelled ?? false)) {
      cancelToken?.cancel();
    }
    change(state, status: RxStatus.success());
    logger.d('prevGid: $prevGid, prevPage $prevPage,  afterJump: $afterJump');
    if ((prevGid.isNotEmpty || prevPage >= 0) && afterJump) {
      logger.d('>>>>> loadPrevious');
      await loadPrevious();
    } else {
      logger.d('>>>>> reloadData');
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
    ehTabController.scrollToTopCall = () => scrollToTop(context);
    ehTabController.scrollToTopRefreshCall = () => scrollToTopRefresh(context);

    tabPages.scrollControllerMap[tabTag ?? heroTag ?? ''] = ehTabController;
  }

  void scrollToTop(BuildContext context) {
    PrimaryScrollController.of(context).animateTo(0.0,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  void scrollToTopRefresh(BuildContext context) {
    PrimaryScrollController.of(context).animateTo(
        -kDefaultRefreshTriggerPullDistance,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease);
  }

  final _showDatePicker = true.obs;
  bool get showDatePicker => _showDatePicker.value;
  set showDatePicker(bool value) => _showDatePicker.value = value;

  String? lastSeek;
  String? lastJump;

  Future<void> showJumpDialog(BuildContext context) async {
    logger.d('showJumpDialog');
    return showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return nextPage > -1
            ? buildPageDialog(context)
            : buildTimeDialog(context);
      },
    );
  }

  Widget buildPageDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(L10n.of(context).jump_to_page),
      content: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${L10n.of(context).page_range} 1 - ${maxPage ?? 0}'),
            ),
            CupertinoTextField(
              decoration: BoxDecoration(
                color: ehTheme.textFieldBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              clearButtonMode: OverlayVisibilityMode.editing,
              controller: pageTextEditController,
              autofocus: true,
              keyboardType: TextInputType.number,
              onEditingComplete: () {
                // 点击键盘完成
                _jumpToPage(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(L10n.of(context).cancel),
          onPressed: () async {
            Get.back();
          },
        ),
        CupertinoDialogAction(
          child: Text(L10n.of(context).ok),
          onPressed: () async {
            // 画廊跳转
            try {
              await _jumpToPage(context);
            } catch (e, stack) {
              logger.e('jump to page error', error: e, stackTrace: stack);
              showToast(e.toString());
            }
          },
        ),
      ],
    );
  }

  Widget buildTimeDialog(BuildContext context) {
    bool editingDate = false;
    bool editingGid = false;
    if (jumpOrSeekTextEditController.text.isEmpty) {
      jumpOrSeekTextEditController.text =
          lastJump ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    return CupertinoAlertDialog(
      title: Text(L10n.of(context).jump_or_seek),
      content: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(L10n.of(context).enter_date_or_offset_or_gid),
            ),
            StatefulBuilder(builder: (context, setState) {
              return CupertinoTextField(
                decoration: BoxDecoration(
                  color: ehTheme.textFieldBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                clearButtonMode: OverlayVisibilityMode.editing,
                placeholder: L10n.of(context).date_or_offset,
                controller: jumpOrSeekTextEditController,
                autofocus: false,
                suffix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (editingDate)
                      GestureDetector(
                        onTap: () {
                          jumpOrSeekTextEditController.clear();
                          setState(() {
                            editingDate = false;
                          });
                        },
                        child: Icon(
                          FontAwesomeIcons.circleXmark,
                          size: 20.0,
                          color: CupertinoDynamicColor.resolve(
                              _kClearButtonColor, Get.context!),
                        ).paddingSymmetric(horizontal: 6),
                      ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showDatePicker = !showDatePicker;
                        });
                      },
                      child: Icon(
                        FontAwesomeIcons.calendar,
                        size: 20.0,
                        color: showDatePicker
                            ? null
                            : CupertinoDynamicColor.resolve(
                                _kClearButtonColor, Get.context!),
                      ).paddingSymmetric(horizontal: 6),
                    ),
                  ],
                ),
                onChanged: (value) {
                  setState(() {
                    editingDate = value.isNotEmpty;
                  });
                },
                // keyboardType: TextInputType.number,
                onEditingComplete: () {
                  // 点击键盘完成
                  FocusScope.of(context).requestFocus(gidNode);
                },
              );
            }),
            Obx(() {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(top: 8.0),
                height: showDatePicker ? 120 : 0,
                child: Localizations.override(
                  context: context,
                  delegates: const [
                    AppGlobalCupertinoLocalizationsDelegate(),
                  ],
                  child: LayoutBuilder(builder: (context, constraints) {
                    if (constraints.maxHeight < 40) {
                      return Container();
                    }
                    return CupertinoDatePicker(
                      // yyyy-MM-dd
                      mode: CupertinoDatePickerMode.date,
                      // DateTime from lastSeek
                      initialDateTime: lastSeek != null
                          ? DateTime.tryParse(lastSeek!) ?? DateTime.now()
                          : DateTime.now(),
                      dateOrder: DatePickerDateOrder.ymd,
                      minimumYear: 2007,
                      minimumDate: DateTime(2007, 3, 20),
                      maximumYear: DateTime.now().year,
                      maximumDate:
                          DateTime.now().add(const Duration(minutes: 1)),
                      onDateTimeChanged: (value) {
                        jumpOrSeekTextEditController.text =
                            DateFormat('yyyy-MM-dd').format(value);
                      },
                    );
                  }),
                ),
              );
            }),
            const SizedBox(height: 8),
            StatefulBuilder(builder: (context, setState) {
              return CupertinoTextField(
                decoration: BoxDecoration(
                  color: ehTheme.textFieldBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                clearButtonMode: OverlayVisibilityMode.editing,
                focusNode: gidNode,
                placeholder: 'GID',
                controller: gidTextEditController,
                // keyboardType: TextInputType.number,
                suffix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (editingGid)
                      GestureDetector(
                        onTap: () {
                          gidTextEditController.clear();
                          setState(() {
                            editingGid = false;
                          });
                        },
                        child: Icon(
                          FontAwesomeIcons.circleXmark,
                          size: 20.0,
                          color: CupertinoDynamicColor.resolve(
                              _kClearButtonColor, Get.context!),
                        ).paddingSymmetric(horizontal: 6),
                      ),
                  ],
                ),
                onChanged: (value) {
                  setState(() {
                    editingGid = value.isNotEmpty;
                  });
                },
                onEditingComplete: () {
                  // 点击键盘完成
                  _jumpToPageWithGidOrTime(
                    pageType: PageType.next,
                  );
                },
              );
            }),
            const SizedBox(height: 8),
            Container(
              height: 40,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (prevGid.isNotEmpty)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.circleArrowLeft,
                            size: 16,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, context),
                          ).paddingSymmetric(horizontal: 8),
                          Expanded(
                              child: Text(
                            prevGid.replaceFirst('-', '-\n'),
                            textAlign: TextAlign.left,
                          )),
                        ],
                      ),
                    ),
                  if (nextGid.isNotEmpty)
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                            nextGid.replaceFirst('-', '-\n'),
                            textAlign: TextAlign.right,
                          )),
                          Icon(
                            FontAwesomeIcons.circleArrowRight,
                            size: 16,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, context),
                          ).paddingSymmetric(horizontal: 8),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Icon(
            FontAwesomeIcons.circleArrowLeft,
          ),
          onPressed: () async {
            try {
              await _jumpToPageWithGidOrTime(pageType: PageType.prev);
            } catch (e, stack) {
              logger.e('jump to Prev error', error: e, stackTrace: stack);
              showToast('$e');
            }
          },
        ),
        CupertinoDialogAction(
          child: const Icon(
            FontAwesomeIcons.circleArrowRight,
          ),
          onPressed: () async {
            // 画廊跳转
            logger.t('jump to Next');
            try {
              await _jumpToPageWithGidOrTime(
                pageType: PageType.next,
              );
            } catch (e, stack) {
              logger.e('jump to Next error', error: e, stackTrace: stack);
              showToast(e.toString());
            }
          },
        ),
      ],
    );
  }

  Future<void> _jumpToPage(BuildContext context) async {
    final String toPage = pageTextEditController.text.trim();
    if (toPage.isEmpty) {
      return;
    }
    final int page = (int.tryParse(toPage) ?? 1) - 1;
    if (page < 0 || page > (maxPage ?? 0)) {
      showToast(L10n.of(context).page_range_error);
    }
    loadFrom(
      page: page,
    );
    Get.back();
  }

  Future<void> _jumpToPageWithGidOrTime({
    PageType? pageType,
  }) async {
    final String jumpOrSeek = jumpOrSeekTextEditController.text.trim();
    final String _gid = gidTextEditController.text.trim();

    logger.t('jumpOrSeek is $jumpOrSeek _gid is $_gid');

    if (jumpOrSeek.isEmpty && _gid.isEmpty) {
      showToast(L10n.of(Get.context!).input_empty);
      return;
    }

    final jumpExp = RegExp(r'^\d+[wmy]?$');
    // YYYY, YYYY-MM or YYYY-MM-DD
    final dateExpFull = RegExp(r'^\d{4}(-\d{2}){0,2}$');
    // YY-MM or YY-MM-DD
    final dateExpShort = RegExp(r'^\d{2}(-\d{2}){1,2}$');

    String jump = '';
    String seek = '';
    if (jumpExp.hasMatch(jumpOrSeek)) {
      jump = jumpOrSeek;
    } else if (dateExpFull.hasMatch(jumpOrSeek) ||
        dateExpShort.hasMatch(jumpOrSeek)) {
      seek = jumpOrSeek;
    } else {
      showToast(L10n.of(Get.context!).input_error);
    }

    logger.t('jump is $jump, seek is $seek, gid is $_gid');

    FocusScope.of(Get.context!).requestFocus(FocusNode());

    // if _gid is not empty, toGid is _gid ,
    // else if pageType is prev, toGid is prev,
    // else if pageType is next, toGid is next
    final toGid = _gid.isEmpty
        ? pageType == PageType.prev
            ? prevGid
            : nextGid
        : _gid;

    loadFrom(
      jump: jump,
      seek: seek,
      gid: toGid,
      pageType: pageType,
    );
    Get.back();
    lastSeek = seek;
    lastJump = jump;
    jumpOrSeekTextEditController.clear();
    gidTextEditController.clear();
  }
}
