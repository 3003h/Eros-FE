import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fehviewer/common/controller/quicksearch_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/tab/view/quick_search_page.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

class SearchPageController extends GetxController
    with StateMixin<List<GalleryItem>> {
  SearchPageController();
  SearchPageController.fromText(this.searchText);
  String searchText;
  final String tabIndex = 'search_$searchPageCtrlDepth';
  final CustomPopupMenuController customPopupMenuController =
      CustomPopupMenuController();

  // 搜索内容的控制器
  final TextEditingController searchTextController = TextEditingController();

  final RxInt _curPage = 0.obs;
  int get curPage => _curPage.value;
  set curPage(int val) => _curPage.value = val;

  final RxBool _isLoadMore = false.obs;
  bool get isLoadMore => _isLoadMore.value;
  set isLoadMore(bool val) => _isLoadMore.value = val;

  int maxPage = 0;
  String _search = '';

  DateTime _lastInputCompleteAt; //上次输入完成时间
  String _lastSearchText;

  bool autofocus;

  final EhConfigService _ehConfigService = Get.find();
  final QuickSearchController quickSearchController = Get.find();

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
    if (isLoadMore) {
      return;
    }

    if (cleanSearch) {
      _search = '';
    }

    final int _catNum = _ehConfigService.catFilter.value;

    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    isLoadMore = true;

    curPage += 1;
    final String fromGid = state.last.gid;
    final Tuple2<List<GalleryItem>, int> tuple = await Api.getGallery(
      page: curPage,
      fromGid: fromGid,
      cats: _catNum,
      serach: _search,
      refresh: true,
    );
    final List<GalleryItem> gallerItemBeans = tuple.item1;

    state.addAll(gallerItemBeans);

    maxPage = tuple.item2;
    isLoadMore = false;
    update();
  }

  Future<List<GalleryItem>> _fetchData({bool refresh = false}) async {
    final int _catNum = _ehConfigService.catFilter.value;

    logger.v('_loadDataFirst');

    final Tuple2<List<GalleryItem>, int> tuple =
        await Api.getGallery(cats: _catNum, serach: _search, refresh: refresh);
    final List<GalleryItem> gallerItemBeans = tuple.item1;
    // state.addAll(gallerItemBeans);
    maxPage = tuple.item2;
    return gallerItemBeans;
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

  @override
  void onInit() {
    super.onInit();
    searchTextController.addListener(_delayedSearch);
    if (searchText != null && searchText.trim().isNotEmpty) {
      logger.d('$searchText');
      searchTextController.text = searchText.trim();
      autofocus = false;
    } else {
      autofocus = true;
    }
    change(<GalleryItem>[], status: RxStatus.empty());
  }

  @override
  void onClose() {
    searchTextController.dispose();
    Get.find<DepthService>().popSearchPageCtrl();
    super.onClose();
  }
}
