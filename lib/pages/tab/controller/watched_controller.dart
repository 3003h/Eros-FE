import 'package:dio/dio.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import 'enum.dart';

class WatchedViewController extends GetxController
    with StateMixin<List<GalleryItem>> {
  WatchedViewController({this.cats});

  final RxBool _isBackgroundRefresh = false.obs;
  bool get isBackgroundRefresh => _isBackgroundRefresh.value;
  set isBackgroundRefresh(bool val) => _isBackgroundRefresh.value = val;

  int cats;

  RxInt curPage = 0.obs;
  int maxPage = 1;

  final Rx<PageState> _pageState = PageState.None.obs;
  PageState get pageState => _pageState.value;
  set pageState(PageState val) => _pageState.value = val;

  final EhConfigService ehConfigService = Get.find();

  String get title => S.of(Get.context).tab_watched;

  final CancelToken _cancelToken = CancelToken();

  //页码跳转的控制器
  final TextEditingController _pageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    _firstLoad();
  }

  Future<void> _firstLoad() async {
    try {
      final Tuple2<List<GalleryItem>, int> tuple = await _fetchData();
      final List<GalleryItem> _listItem = tuple.item1;
      maxPage = tuple.item2;
      change(_listItem, status: RxStatus.success());
    } catch (err) {
      logger.e('$err');
      change(null, status: RxStatus.error(err.toString()));
    }

    try {
      if (_cancelToken.isCancelled) {
        return;
      }
      isBackgroundRefresh = true;
      await reloadData();
    } catch (_) {} finally {
      isBackgroundRefresh = false;
    }
  }

  Future<Tuple2<List<GalleryItem>, int>> _fetchData(
      {bool refresh = false}) async {
    logger.v('_loadDataFirst  gallery');
    final int _catNum = ehConfigService.catFilter.value;

    final Future<Tuple2<List<GalleryItem>, int>> tuple = Api.getWatched(
      cats: cats ?? _catNum,
      refresh: refresh,
      cancelToken: _cancelToken,
    );
    return tuple;
  }

  Future<void> reloadData() async {
    curPage.value = 0;
    final Tuple2<List<GalleryItem>, int> tuple = await _fetchData(
      refresh: true,
    );
    maxPage = tuple.item2;
    change(tuple.item1);
  }

  Future<void> onRefresh() async {
    isBackgroundRefresh = false;
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel();
    }
    change(state, status: RxStatus.success());
    await reloadData();
  }

  Future<void> reLoadDataFirst() async {
    change(null, status: RxStatus.loading());
    onInit();
  }

  Future<void> loadDataMore() async {
    if (pageState == PageState.Loading) {
      return;
    }

    final int _catNum = ehConfigService.catFilter.value;

    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    try {
      pageState = PageState.Loading;

      logger.d('${state.length}');

      final String fromGid = state.last.gid;
      final Tuple2<List<GalleryItem>, int> tuple = await Api.getWatched(
        page: curPage.value + 1,
        fromGid: fromGid,
        cats: cats ?? _catNum,
        refresh: true,
        cancelToken: _cancelToken,
      );
      curPage += 1;
      final List<GalleryItem> galleryItemBeans = tuple.item1;

      if (galleryItemBeans.isNotEmpty &&
          state.indexWhere((GalleryItem element) =>
                  element.gid == galleryItemBeans.first.gid) ==
              -1) {
        state.addAll(galleryItemBeans);

        logger.d('${state.length}');
        maxPage = tuple.item2;
      }
      pageState = PageState.None;
      update();
    } catch (e, stack) {
      pageState = PageState.LoadingException;
      rethrow;
    }
  }

  Future<void> loadFromPage(int page) async {
    logger.v('jump to page =>  $page');

    final int _catNum = ehConfigService.catFilter.value;

    change(state, status: RxStatus.loading());
    Api.getWatched(
      page: page,
      cats: cats ?? _catNum,
      refresh: true,
      cancelToken: _cancelToken,
    ).then((tuple) {
      curPage.value = page;
      change(tuple.item1, status: RxStatus.success());
    });
  }

  /// 跳转页码
  Future<void> jumpToPage() async {
    void _jump() {
      final String _input = _pageController.text.trim();

      if (_input.isEmpty) {
        showToast('输入为空');
      }

      // 数字检查
      if (!RegExp(r'(^\d+$)').hasMatch(_input)) {
        showToast('输入格式有误');
      }

      final int _toPage = int.parse(_input) - 1;
      if (_toPage >= 0 && _toPage <= maxPage) {
        FocusScope.of(Get.context).requestFocus(FocusNode());
        loadFromPage(_toPage);
        Get.back();
      } else {
        showToast('输入范围有误');
      }
    }

    return showCupertinoDialog<void>(
      context: Get.overlayContext,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('页面跳转'),
          content: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('跳转范围 1~$maxPage'),
                ),
                CupertinoTextField(
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
              child: const Text('取消'),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定'),
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
}
