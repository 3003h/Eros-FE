import 'dart:collection';

import 'package:fehviewer/common/controller/quicksearch_controller.dart';
import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/store/floor/entity/tag_translat.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import '../fetch_list.dart';
import 'enum.dart';
import 'favorite_controller.dart';
import 'tabview_controller.dart';

enum SearchType {
  normal,
  watched,
  favorite,
}

enum ListType {
  gallery,
  tag,
  init,
}

class SearchPageController extends TabViewController {
  SearchPageController();

  late final String? initSearchText;
  final RxString _searchText = ''.obs;
  String get searchText => _searchText.value;
  set searchText(String val) => _searchText.value = val;
  late bool _autoComplete = false;
  final String tabIndex = 'search_$searchPageCtrlDepth';

  // 搜索输入框的控制器
  late final TextEditingController searchTextController;
  bool get textIsNotEmpty => searchTextController.text.isNotEmpty;

  // 搜索类型
  final Rx<SearchType> _searchType = SearchType.normal.obs;
  SearchType get searchType => _searchType.value;

  String get placeholderText {
    final BuildContext context = Get.context!;
    // logger.v('$searchType');
    switch (searchType) {
      case SearchType.favorite:
        return '${L10n.of(context).search} ${L10n.of(context).tab_favorite}';
      case SearchType.watched:
        return '${L10n.of(context).search} ${L10n.of(context).tab_watched}';
      case SearchType.normal:
      default:
        return '${L10n.of(context).search} ${L10n.of(context).tab_gallery}';
    }
  }

  set searchType(SearchType val) => _searchType.value = val;

  final Rx<ListType> _listType = ListType.init.obs;

  ListType get listType => _listType.value;

  set listType(ListType val) => _listType.value = val;

  final RxList<TagTranslat> qryTags = <TagTranslat>[].obs;
  late String _currQryText;

  FocusNode searchFocusNode = FocusNode();

  late String _search = '';

  late DateTime _lastInputCompleteAt; //上次输入完成时间

  final _lastSearchText = ''.obs;
  String get lastSearchText => _lastSearchText.value;
  set lastSearchText(String val) => _lastSearchText.value = val;

  /// 自动获取焦点
  bool autofocus = false;

  final EhConfigService _ehConfigService = Get.find();
  final QuickSearchController quickSearchController = Get.find();
  final FavoriteViewController _favoriteViewController = Get.find();
  final LocaleService localeService = Get.find();

  bool get isTagTranslat => _ehConfigService.isTagTranslat;

  /// 控制右侧按钮展开折叠
  bool get isSearchBarComp => _ehConfigService.isSearchBarComp.value;

  set isSearchBarComp(bool val) => _ehConfigService.isSearchBarComp.value = val;

  /// 执行搜索
  Future<void> _startSearch({bool clear = true}) async {
    curPage.value = 0;
    searchText = searchTextController.text.trim();

    if (_searchText.isNotEmpty) {
      _search = searchText;

      analytics.logSearch(searchTerm: _search);

      _addHistory();

      // logger.d('${state?.length}');

      if (clear) {
        // logger.v('clear $clear');
        change(state, status: RxStatus.loading());
      }

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

  /// 点击键盘完成
  Future<void> onEditingComplete({bool clear = true}) async {
    isBackgroundRefresh = false;
    if (!cancelToken.isCancelled) {
      cancelToken.cancel();
    }
    change(state, status: RxStatus.success());
    listType = ListType.gallery;
    await _startSearch(clear: clear);
  }

  /// 延迟搜索
  Future<void> _delayedSearch() async {
    searchText = searchTextController.text.trim();
    update([GetIds.SEARCH_CLEAR_BTN]);
    logger.v(' _delayedSearch');
    const Duration _duration = Duration(milliseconds: 800);
    _lastInputCompleteAt = DateTime.now();
    await Future<void>.delayed(_duration);

    // logger.d('$_lastSearchText\n${searchTextController.text}');

    if (lastSearchText.trim() != searchTextController.text.trim() &&
        DateTime.now().difference(_lastInputCompleteAt) >= _duration) {
      // logger.d('_autoComplete $_autoComplete');
      if (searchTextController.text.trim().isEmpty) {
        logger.v('ListType to ListType.init');
        listType = ListType.init;
        return;
      }

      lastSearchText = searchTextController.text.trim();

      if (_autoComplete) {
        listType = ListType.gallery;
        _autoComplete = false;
        return await _startSearch();
      }

      listType = ListType.tag;

      _currQryText = searchTextController.text.split(RegExp(r'[ ;"]')).last;
      if (_currQryText.isEmpty) {
        qryTags([]);
        return;
      }

      /// 模糊搜索
      try {
        // 中文从翻译库匹配
        if (localeService.isLanguageCodeZh) {
          logger.d('isLanguageCodeZh');
          List<TagTranslat> qryTagsTemp = await Get.find<TagTransController>()
              .getTagTranslatesLike(text: _currQryText, limit: 200);
          if (qryTagsTemp.isNotEmpty) {
            qryTags.value = qryTagsTemp;
          }
        } else {
          // 其它通过eh的api
          qryTags.clear();
          logger.d('tagSuggest $_currQryText');
          List<TagTranslat> tagTranslateList =
              await Api.tagSuggest(text: _currQryText);
          qryTags.value = tagTranslateList;
        }
      } catch (_) {}

      logger.d('_autoComplete $_autoComplete');
      if (_autoComplete) {
        listType = ListType.gallery;
        await _startSearch();
      }
    }
  }

  /// 加载更多
  @override
  Future<void> loadDataMore({bool cleanSearch = false}) async {
    logger5.i('$searchPageCtrlDepth loadDataMore');
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (pageState == PageState.Loading) {
      logger.d('loadDataMore return');
      return;
    }

    if (cleanSearch) {
      _search = '';
    }

    final int _catNum = _ehConfigService.catFilter.value;
    pageState = PageState.Loading;

    try {
      final String? fromGid = state?.last.gid;
      final GalleryList? rult = searchType != SearchType.favorite
          ? await getGallery(
              page: curPage.value + 1,
              fromGid: fromGid,
              cats: _catNum,
              serach: _search,
              refresh: true,
            )
          : await getGallery(
              page: curPage.value + 1,
              favcat: _favoriteViewController.curFavcat,
              serach: _search,
              refresh: true,
              galleryListType: GalleryListType.favorite,
            );
      final List<GalleryItem> rultList = rult?.gallerys
              ?.map(
                  (GalleryItem e) => e.copyWith(pageOfList: curPage.value + 1))
              .toList() ??
          [];

      // state?.addAll(rultList);
      final insertIndex = state?.length ?? 0;
      change([...?state, ...rultList], status: RxStatus.success());

      for (final item in rultList) {
        sliverAnimatedListKey.currentState?.insertItem(insertIndex);
      }

      logger.d('added rultList first ${rultList.first.gid} ');

      maxPage = rult?.maxPage ?? 0;
      curPage.value += 1;
      pageState = PageState.None;
      // update();
    } catch (e, stack) {
      pageState = PageState.LoadingException;
      rethrow;
    }
  }

  @override
  Future<void> loadPrevious({bool cleanSearch = false}) async {
    logger5.i('$searchPageCtrlDepth loadDataMore');
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (pageState == PageState.Loading) {
      logger.d('loadDataMore return');
      return;
    }

    if (cleanSearch) {
      _search = '';
    }

    final int _catNum = _ehConfigService.catFilter.value;
    pageState = PageState.Loading;

    try {
      final String? fromGid = state?.last.gid;
      final GalleryList? rult = searchType != SearchType.favorite
          ? await getGallery(
              page: curPage.value - 1,
              fromGid: fromGid,
              cats: _catNum,
              serach: _search,
              refresh: true,
            )
          : await getGallery(
              page: curPage.value - 1,
              favcat: _favoriteViewController.curFavcat,
              serach: _search,
              refresh: true,
              galleryListType: GalleryListType.favorite,
            );
      final List<GalleryItem> gallerItemBeans = rult?.gallerys
              ?.map(
                  (GalleryItem e) => e.copyWith(pageOfList: curPage.value - 1))
              .toList() ??
          [];

      state?.insertAll(0, gallerItemBeans);

      logger.d('insert gallerItemBeans first ${gallerItemBeans.first.gid} ');

      maxPage = rult?.maxPage ?? 0;
      curPage.value -= 1;
      pageState = PageState.None;
      update();
    } catch (e, stack) {
      pageState = PageState.LoadingException;
      rethrow;
    }
  }

  /// 获取数据
  Future<List<GalleryItem>> _fetchData({bool refresh = false}) async {
    logger.v('$searchPageCtrlDepth _fetchData');

    final int _catNum = _ehConfigService.catFilter.value;

    // logger.v('_loadDataFirst');

    final GalleryList? rult = searchType != SearchType.favorite
        ? await getGallery(
            cats: _catNum,
            serach: _search,
            refresh: refresh,
          )
        : await getGallery(
            favcat: _favoriteViewController.curFavcat,
            serach: _search,
            refresh: refresh,
            galleryListType: GalleryListType.favorite,
          );
    final List<GalleryItem> gallerItemBeans = rult?.gallerys
            ?.map((GalleryItem e) => e.copyWith(pageOfList: 0))
            .toList() ??
        [];
    maxPage = rult?.maxPage ?? 0;
    return gallerItemBeans;
  }

  /// 从指定页数开始
  @override
  Future<void> loadFromPage(int page) async {
    logger.v('jump to page =>  $page');

    final int _catNum = _ehConfigService.catFilter.value;

    change(state, status: RxStatus.loading());
    final GalleryList? rult = searchType != SearchType.favorite
        ? await getGallery(
            page: page,
            cats: _catNum,
            serach: _search,
            refresh: true,
          )
        : await getGallery(
            page: page,
            favcat: _favoriteViewController.curFavcat,
            serach: _search,
            refresh: true,
            galleryListType: GalleryListType.favorite,
          );
    isLoadPrevious = page > 1;
    curPage.value = page;
    change(
        rult?.gallerys
                ?.map((GalleryItem e) => e.copyWith(pageOfList: page))
                .toList() ??
            [],
        status: RxStatus.success());
  }

  List<String> searchHistory = <String>[].obs;

  void _addHistory() {
    searchHistory.insert(0, searchTextController.text.trim());
    searchHistory = LinkedHashSet<String>.from(searchHistory).toList();
    if (searchHistory.length > 100) {
      searchHistory.removeRange(100, searchHistory.length);
    }
    // _gStore.searchHistory = searchHistory;
    hiveHelper.setSearchHistory(searchHistory);
  }

  void removeHistory(Object? value) {
    searchHistory.remove(value);
    update([GetIds.SEARCH_INIT_VIEW]);
    // _gStore.searchHistory = searchHistory;
    hiveHelper.setSearchHistory(searchHistory);
  }

  void clearHistory() {
    searchHistory.clear();
    update([GetIds.SEARCH_INIT_VIEW]);
    hiveHelper.setSearchHistory(searchHistory);
  }

  @override
  void onInit() {
    logger.d('onInit $searchPageCtrlDepth');

    SearchRepository searchRepository = Get.find();
    initSearchText = searchRepository.searchText;
    searchType = searchRepository.searchType;

    searchTextController = TextEditingController();

    // fetchNormal = getGallery;
    searchHistory = hiveHelper.getAllSearchHistory();
    _autoComplete = initSearchText?.trim().isNotEmpty ?? false;
    searchTextController.addListener(_delayedSearch);
    super.onInit();
  }

  @override
  Future<void> firstLoad() async {
    if (initSearchText != null && initSearchText!.trim().isNotEmpty) {
      // logger.d('$searchText');
      searchTextController.text = initSearchText!.trim();
      autofocus = false;
    } else {
      autofocus = true;
    }
    change(<GalleryItem>[], status: RxStatus.empty());
  }

  @override
  void onClose() {
    // searchTextController.dispose();
    // Get.find<DepthService>().popSearchPageCtrl();
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
  Future<void> quickSearchList() async {
    final text = await Get.toNamed(
      EHRoutes.quickSearch,
      id: isLayoutLarge ? 2 : null,
    );

    if (text == null) {
      return;
    }
    searchTextController.value = TextEditingValue(
      text: '$text ',
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: '$text '.length,
        ),
      ),
    );

    FocusScope.of(Get.context!).requestFocus(searchFocusNode);
  }

  /// tag搜索结果上屏
  void addQryTag(int index) {
    final TagTranslat _qry = qryTags[index];
    final String _add = _qry.key.contains(' ')
        ? '${_qry.namespace.trim().shortName}:"${_qry.key}\$"'
        : '${_qry.namespace.trim().shortName}:${_qry.key}\$';
    logger.d('_add $_add ');

    final String _lastSearchText = lastSearchText;
    final String _newSearch =
        _lastSearchText.replaceAll(RegExp('$_currQryText\$'), _add);
    logger.d(
        '_lastSearchText $_lastSearchText \n_currQry $_currQryText\n_newSearch $_newSearch ');

    _autoComplete = false;
    searchTextController.value = TextEditingValue(
      text: '$_newSearch ',
      selection: TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream, offset: '$_newSearch '.length)),
    );

    FocusScope.of(Get.context!).requestFocus(searchFocusNode);
    qryTags.clear();
  }

  void appendTextToSearch(String text) {
    final String _lastSearchText = searchTextController.text;
    final String _newSearch = '$_lastSearchText $text';
    _autoComplete = false;
    searchTextController.value = TextEditingValue(
      text: '$_newSearch ',
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: '$_newSearch '.length,
        ),
      ),
    );

    FocusScope.of(Get.context!).requestFocus(searchFocusNode);
  }

  void clearText() {
    vibrateUtil.light();
    searchTextController.clear();
    curPage.value = 0;
  }
}
