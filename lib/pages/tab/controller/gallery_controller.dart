import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import 'enum.dart';

class GalleryViewController extends GetxController
    with StateMixin<List<GalleryItem>> {
  GalleryViewController({this.cats});

  int cats;

  RxInt curPage = 0.obs;
  int maxPage = 0;

  // final RxBool _isLoadMore = false.obs;
  // bool get isLoadMore => _isLoadMore.value;
  // set isLoadMore(bool val) => _isLoadMore.value = val;

  final Rx<PageState> _pageState = PageState.None.obs;
  PageState get pageState => _pageState.value;
  set pageState(PageState val) => _pageState.value = val;

  final EhConfigService _ehConfigService = Get.find();
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
        _menu.add(GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            VibrateUtil.light();
            customPopupMenuController.hideMenu();
            Get.toNamed(elem.key);
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
                  // color: CupertinoDynamicColor.resolve(
                  //     CupertinoColors.secondaryLabel, Get.context),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      tabPages.tabTitles[elem.key],
                      style: TextStyle(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.label, Get.context),
                        fontWeight: FontWeight.w500,
                        // fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _menu,
    );
  }

  String get title {
    // logger.d('${EHConst.cats.entries.length}');
    if (cats != null) {
      return EHConst.cats.entries
              ?.firstWhere((MapEntry<String, int> element) =>
                  element.value == EHConst.sumCats - cats)
              ?.key ??
          S.of(Get.context).tab_gallery;
    } else {
      return S.of(Get.context).tab_gallery;
    }
  }

  //页码跳转的控制器
  final TextEditingController _pageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    loadData().then((Tuple2<List<GalleryItem>, int> tuple) {
      maxPage = tuple.item2;
      change(tuple.item1, status: RxStatus.success());
    }, onError: (err) {
      change(null, status: RxStatus.error(err.toString()));
    });

    Future<void>.delayed(const Duration(milliseconds: 500)).then((_) {
      reloadData();
    });
  }

  Future<Tuple2<List<GalleryItem>, int>> loadData(
      {bool refresh = false}) async {
    logger.v('_loadDataFirst  gallery');
    final int _catNum = _ehConfigService.catFilter.value;

    final Future<Tuple2<List<GalleryItem>, int>> tuple = Api.getGallery(
      cats: cats ?? _catNum,
      refresh: refresh,
    );
    return tuple;
  }

  Future<void> reloadData() async {
    curPage.value = 0;
    final Tuple2<List<GalleryItem>, int> tuple = await loadData(
      refresh: true,
    );
    // _frontGallerItemBeans = tuple.item1;
    change(tuple.item1);
  }

  Future<void> onRefresh() async {
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

    final int _catNum = _ehConfigService.catFilter.value;

    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    logger.d('${curPage.value + 1}');

    final String fromGid = state.last.gid;
    try {
      pageState = PageState.Loading;
      final Tuple2<List<GalleryItem>, int> tuple = await Api.getGallery(
        page: curPage.value + 1,
        fromGid: fromGid,
        cats: cats ?? _catNum,
        refresh: true,
      );

      final List<GalleryItem> galleryItemBeans = tuple.item1;

      if (galleryItemBeans.isNotEmpty &&
          state.indexWhere((GalleryItem element) =>
                  element.gid == galleryItemBeans.first.gid) ==
              -1) {
        state.addAll(galleryItemBeans);

        logger.d('${state.length}');
        maxPage = tuple.item2;
      }
      // 成功才+1
      curPage += 1;
      pageState = PageState.None;
      update();
    } catch (e, stack) {
      pageState = PageState.LoadingException;
      rethrow;
    }
  }

  Future<void> loadFromPage(int page) async {
    logger.v('jump to page =>  $page');

    final int _catNum = _ehConfigService.catFilter.value;

    change(state, status: RxStatus.loading());
    Api.getGallery(
      page: page,
      cats: cats ?? _catNum,
      refresh: true,
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
