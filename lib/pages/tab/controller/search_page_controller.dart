import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fehviewer/common/controller/quicksearch_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/tab/view/quick_search_page.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import 'enum.dart';
import 'favorite_controller.dart';

enum SearchType {
  normal,
  watched,
  favorite,
}

class SearchPageController extends GetxController
    with StateMixin<List<GalleryItem>> {
  SearchPageController({SearchType searchType = SearchType.normal}) {
    this.searchType = searchType;
  }
  SearchPageController.fromText(this.searchText);
  String searchText;
  final String tabIndex = 'search_$searchPageCtrlDepth';
  final CustomPopupMenuController customPopupMenuController =
      CustomPopupMenuController();

  // 搜索内容的控制器
  final TextEditingController searchTextController = TextEditingController();

  // 搜索类型
  final Rx<SearchType> _searchType = SearchType.normal.obs;
  SearchType get searchType => _searchType.value;
  set searchType(SearchType val) => _searchType.value = val;

  final RxInt _curPage = 0.obs;
  int get curPage => _curPage.value;
  set curPage(int val) => _curPage.value = val;

  final Rx<PageState> _pageState = PageState.None.obs;
  PageState get pageState => _pageState.value;
  set pageState(PageState val) => _pageState.value = val;

  int maxPage = 0;
  String _search = '';

  DateTime _lastInputCompleteAt; //上次输入完成时间
  String _lastSearchText;

  /// 自动获取焦点
  bool autofocus = false;

  final EhConfigService _ehConfigService = Get.find();
  final QuickSearchController quickSearchController = Get.find();

  final FavoriteViewController _favoriteViewController = Get.find();

  bool get isSearchBarComp => _ehConfigService.isSearchBarComp.value;
  set isSearchBarComp(bool val) => _ehConfigService.isSearchBarComp.value = val;

  Future<void> _startSearch() async {
    final String _searchText = searchTextController.text.trim();
    if (_searchText.isNotEmpty) {
      _search = _searchText;
      // if (state == null || state.isEmpty) {
      //   change(state, status: RxStatus.loading());
      // }
      change(state, status: RxStatus.loading());
      try {
        final List<GalleryItem> _list = await _fetchData(refresh: true);
        change(_list, status: RxStatus.success());
      } catch (err) {
        change(null, status: RxStatus.error(err.toString()));
      }
    } else {
      state?.clear();
      update();
    }
  }

  Future<void> onEditingComplete() async {
    // 点击键盘完成
    await _startSearch();
  }

  Future<void> _delayedSearch() async {
    const Duration _duration = Duration(milliseconds: 800);
    _lastInputCompleteAt = DateTime.now();
    await Future<void>.delayed(_duration);
    if (_lastSearchText?.trim() != searchTextController.text.trim() &&
        DateTime.now().difference(_lastInputCompleteAt) >= _duration) {
      _lastSearchText = searchTextController.text;
      await _startSearch();
    }
  }

  Future<void> loadDataMore({bool cleanSearch = false}) async {
    if (pageState == PageState.Loading) {
      return;
    }

    if (cleanSearch) {
      _search = '';
    }

    final int _catNum = _ehConfigService.catFilter.value;

    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    try {
      pageState = PageState.Loading;

      final String fromGid = state.last.gid;
      final Tuple2<List<GalleryItem>, int> tuple =
          searchType != SearchType.favorite
              ? await Api.getGallery(
                  page: curPage + 1,
                  fromGid: fromGid,
                  cats: _catNum,
                  serach: _search,
                  searchType: searchType,
                  refresh: true,
                )
              : await Api.getFavorite(
                  page: curPage + 1,
                  favcat: _favoriteViewController.curFavcat,
                  serach: _search,
                  refresh: true,
                );
      final List<GalleryItem> gallerItemBeans = tuple.item1;

      state.addAll(gallerItemBeans);

      maxPage = tuple.item2;
      curPage += 1;
      pageState = PageState.None;
      update();
    } catch (e, stack) {
      pageState = PageState.LoadingException;
      rethrow;
    }
  }

  Future<List<GalleryItem>> _fetchData({bool refresh = false}) async {
    final int _catNum = _ehConfigService.catFilter.value;

    logger.v('_loadDataFirst');

    final Tuple2<List<GalleryItem>, int> tuple =
        searchType != SearchType.favorite
            ? await Api.getGallery(
                cats: _catNum,
                serach: _search,
                refresh: refresh,
                searchType: searchType,
              )
            : await Api.getFavorite(
                favcat: _favoriteViewController.curFavcat,
                serach: _search,
                refresh: refresh,
              );
    final List<GalleryItem> gallerItemBeans = tuple.item1;
    maxPage = tuple.item2;
    return gallerItemBeans;
  }

  Future<void> _loadFromPage(int page) async {
    logger.v('jump to page =>  $page');

    final int _catNum = _ehConfigService.catFilter.value;

    change(state, status: RxStatus.loading());
    final Tuple2<List<GalleryItem>, int> tuple =
        searchType != SearchType.favorite
            ? await Api.getGallery(
                page: page,
                cats: _catNum,
                serach: _search,
                refresh: true,
                searchType: searchType,
              )
            : await Api.getFavorite(
                page: page,
                favcat: _favoriteViewController.curFavcat,
                serach: _search,
                refresh: true,
              );
    curPage = page;
    change(tuple.item1, status: RxStatus.success());

    // Api.getGallery(
    //   page: page,
    //   cats: _catNum,
    //   serach: _search,
    //   refresh: true,
    //   searchType: searchType,
    // ).then((Tuple2<List<GalleryItem>, int> tuple) {
    //   curPage = page;
    //   change(tuple.item1, status: RxStatus.success());
    // });
  }

  /// 页码跳转的控制器
  final TextEditingController _pageController = TextEditingController();

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
        _loadFromPage(_toPage);
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

  @override
  void onInit() {
    super.onInit();
    searchTextController.addListener(_delayedSearch);
    if (searchText != null && searchText.trim().isNotEmpty) {
      logger.d('$searchText');
      searchTextController.text = searchText.trim();
      autofocus = false;
    } else {
      // autofocus = true;
    }
    change(<GalleryItem>[], status: RxStatus.empty());
  }

  @override
  void onClose() {
    searchTextController.dispose();
    Get.find<DepthService>().popSearchPageCtrl();
    super.onClose();
  }

  /// 添加当前搜索框内容到快速搜索
  void addToQuickSearch() {
    final String _text = searchTextController.text;
    if (_text.isNotEmpty) {
      quickSearchController.addText(_text);
    }
  }

  /// 打开快速搜索列表
  void quickSearchList() {
    Get.to<String>(
      QuickSearchListPage(),
      transition: Transition.cupertino,
    ).then((String value) => searchTextController.text = value);
  }
}
