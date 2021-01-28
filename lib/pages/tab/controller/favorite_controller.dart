import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import 'enum.dart';

class FavoriteViewController extends GetxController
    with StateMixin<List<GalleryItem>> {
  RxString title = ''.obs;
  String curFavcat = '';
  RxInt curPage = 0.obs;
  int maxPage = 1;

  final RxBool _isBackgroundRefresh = false.obs;
  bool get isBackgroundRefresh => _isBackgroundRefresh.value;
  set isBackgroundRefresh(bool val) => _isBackgroundRefresh.value = val;

  final Rx<PageState> _pageState = PageState.None.obs;
  PageState get pageState => _pageState.value;
  set pageState(PageState val) => _pageState.value = val;

  bool enableDelayedLoad = true;

  //页码跳转的控制器
  final TextEditingController pageController = TextEditingController();

  Future<Tuple2<List<GalleryItem>, int>> futureBuilderFuture;
  Widget lastListWidget;

  final EhConfigService _ehConfigService = Get.find();
  final LocalFavController _localFavController = Get.find();
  final UserController _userController = Get.find();

  @override
  void onInit() {
    super.onInit();
    curFavcat = _ehConfigService.lastShowFavcat ?? 'a';
    title.value = _ehConfigService.lastShowFavTitle;

    loadData(first: true).then((Tuple2<List<GalleryItem>, int> tuple) {
      maxPage = tuple.item2;
      change(tuple.item1, status: RxStatus.success());
    }, onError: (err) {
      change(null, status: RxStatus.error(err.toString()));
    }).then((_) {
      isBackgroundRefresh = true;
      reloadData(delayed: true).then((_) => isBackgroundRefresh = false);
    });
  }

  Future<Tuple2<List<GalleryItem>, int>> loadData({
    bool refresh = false,
    bool first = false,
  }) async {
    logger.v('_loadDataFirst  fav');

    final bool _isLogin = _userController.isLogin;
    if (!_isLogin) {
      curFavcat = 'l';
    }

    if (curFavcat != 'l') {
      // 网络收藏夹
      final Future<Tuple2<List<GalleryItem>, int>> tuple = Api.getFavorite(
        favcat: curFavcat,
        refresh: refresh,
      );
      return tuple;
    } else {
      if (first) {
        _ehConfigService.lastShowFavcat = 'l';
        _ehConfigService.lastShowFavTitle = S.of(Get.context).local_favorite;
      }
      // 本地收藏夹
      logger.v('本地收藏');
      final List<GalleryItem> localFav = _localFavController.loacalFavs;

      return Future<Tuple2<List<GalleryItem>, int>>.value(Tuple2(localFav, 1));
    }
  }

  Future<void> reLoadDataFirst() async {
    change(null, status: RxStatus.loading());
    reloadData();
  }

  Future<void> reloadData({bool delayed = false}) async {
    curPage.value = 0;
    final Tuple2<List<GalleryItem>, int> tuple = await loadData(refresh: true);
    if (delayed && enableDelayedLoad) {
      logger.d(' delayed reload');
      maxPage = tuple.item2;
      change(tuple.item1, status: RxStatus.success());
    } else {
      maxPage = tuple.item2;
      logger.d('${tuple.item1.map((e) => e.ratingFallBack).join('\n')} ');
      change(tuple.item1, status: RxStatus.success());
    }
  }

  Future<void> onRefresh() async {
    change(state, status: RxStatus.success());
    await reloadData();
  }

  Future<void> loadFromPage(int page, {bool cleanSearch = false}) async {
    logger.v('jump to page =>  $page');

    change(state, status: RxStatus.loading());
    Api.getFavorite(favcat: curFavcat, page: page, refresh: true).then((tuple) {
      curPage.value = page;
      change(tuple.item1, status: RxStatus.success());
    });
  }

  Future<void> loadDataMore() async {
    if (pageState == PageState.Loading) {
      return;
    }

    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    try {
      pageState = PageState.Loading;

      logger.d('get add list');
      final Tuple2<List<GalleryItem>, int> tuple = await Api.getFavorite(
        favcat: curFavcat,
        page: curPage.value + 1,
        refresh: true,
      );

      final List<GalleryItem> galleryItemBeans = tuple.item1;
      logger.d('from $curPage add ${galleryItemBeans.length}');
      state.addAll(galleryItemBeans);
      curPage += 1;
      pageState = PageState.None;
      update();
    } catch (e, stack) {
      pageState = PageState.LoadingException;
      rethrow;
    }
  }

  /// 跳转页码
  Future<void> jumtToPage(BuildContext context) async {
    void _jump(BuildContext context) {
      final String _input = pageController.text.trim();

      if (_input.isEmpty) {
        showToast('输入为空');
      }

      // 数字检查
      if (!RegExp(r'(^\d+$)').hasMatch(_input)) {
        showToast('输入格式有误');
      }

      final int _toPage = int.parse(_input) - 1;
      if (_toPage >= 0 && _toPage <= maxPage) {
        FocusScope.of(context).requestFocus(FocusNode());
        loadFromPage(_toPage);
        Get.back();
      } else {
        showToast('输入范围有误');
      }
    }

    return showCupertinoDialog<void>(
      context: context,
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
                  controller: pageController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  onEditingComplete: () {
                    // 点击键盘完成
                    // 画廊跳转
                    _jump(context);
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
                _jump(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> setOrder() async {
    final FavoriteOrder order = await _ehConfigService.showFavOrder();
    if (order != null) {
      change(state, status: RxStatus.loading());
      reloadData();
    }
  }

  String get orderText =>
      _ehConfigService.favoriteOrder.value == FavoriteOrder.fav ? 'F' : 'P';
}
