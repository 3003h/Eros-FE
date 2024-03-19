import 'dart:collection';

import 'package:eros_fe/common/controller/quicksearch_controller.dart';
import 'package:eros_fe/common/controller/tag_trans_controller.dart';
import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/common/service/locale_service.dart';
import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/models/base/eh_models.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/pages/tab/view/list/tab_base.dart';
import 'package:eros_fe/route/navigator_util.dart';
import 'package:eros_fe/route/routes.dart';
import 'package:eros_fe/store/db/entity/tag_translat.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:eros_fe/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../fetch_list.dart';
import 'default_tabview_controller.dart';

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

class SearchPageController extends DefaultTabViewController {
  SearchPageController();

  late bool _autoComplete = false;
  final String tabIndex = 'search_$searchPageCtrlTag';

  bool textIsGalleryUrl = false;
  String? _jumpToUrl;

  bool get translateSearchHistory => ehSettingService.translateSearchHistory;
  set translateSearchHistory(bool value) =>
      ehSettingService.translateSearchHistory = value;

  final TagTransController tagTransController = Get.find<TagTransController>();

  // 搜索输入框的控制器
  late final TextEditingController searchTextController =
      TextEditingController();

  bool get textIsNotEmpty => searchTextController.text.isNotEmpty;

  String get placeholderText {
    final BuildContext context = Get.context!;
    // logger.t('$searchType');
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

  final Rx<ListType> _listType = ListType.init.obs;
  ListType get listType => _listType.value;
  set listType(ListType val) => _listType.value = val;

  final RxList<TagTranslat> qryTags = <TagTranslat>[].obs;
  late String currQryText;

  FocusNode searchFocusNode = FocusNode();

  late DateTime _lastInputCompleteAt; //上次输入完成时间

  final _lastSearchText = ''.obs;

  String get lastSearchText => _lastSearchText.value;

  set lastSearchText(String val) => _lastSearchText.value = val;

  /// 自动获取焦点
  bool autofocus = false;

  final QuickSearchController quickSearchController = Get.find();
  final LocaleService localeService = Get.find();

  bool get isTagTranslat => ehSettingService.isTagTranslate;

  /// 控制右侧按钮展开折叠
  bool get isSearchBarComp => ehSettingService.isSearchBarComp.value;

  set isSearchBarComp(bool val) => ehSettingService.isSearchBarComp.value = val;

  @override
  FetchListClient getFetchListClient(FetchParams fetchParams) {
    return SearchFetchListClient(
      fetchParams: fetchParams..galleryListType = _currListType,
      globalSearch: true,
    );
  }

  /// 执行搜索
  Future<void> _startSearch({bool clear = true}) async {
    resetResultPage();

    searchText = searchTextController.text.trim();
    Global.analytics?.logSearch(searchTerm: searchText);

    if (searchText.isNotEmpty) {
      _addHistory();

      if (clear) {
        change(state, status: RxStatus.loading());
      }

      try {
        final rult = await fetchData(refresh: true);
        if (rult == null) {
          change(null, status: RxStatus.loading());
          return;
        }

        nextGid = rult.nextGid;
        prevGid = rult.prevGid;
        nextPage = rult.nextPage;
        prevPage = rult.prevPage;
        maxPage = rult.maxPage;

        change(rult.gallerys ?? [], status: RxStatus.success());
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
    if (!(cancelToken?.isCancelled ?? false)) {
      cancelToken?.cancel();
    }
    change(state, status: RxStatus.success());
    listType = ListType.gallery;
    await _startSearch(clear: clear);
  }

  /// 延迟搜索
  Future<void> _delayedSearch() async {
    searchText = searchTextController.text.trim();
    update([GetIds.SEARCH_CLEAR_BTN]);
    logger.t(' _delayedSearch');
    const Duration _duration = Duration(milliseconds: 500);
    _lastInputCompleteAt = DateTime.now();
    await Future<void>.delayed(_duration);

    if (lastSearchText.trim() != searchTextController.text.trim() &&
        DateTime.now().difference(_lastInputCompleteAt) >= _duration) {
      if (searchTextController.text.trim().isEmpty) {
        logger.t('ListType to ListType.init');
        listType = ListType.init;
        textIsGalleryUrl = false;
        update([GetIds.SEARCH_CLEAR_BTN]);
        return;
      }

      lastSearchText = searchTextController.text.trim();

      if (_autoComplete) {
        listType = ListType.gallery;
        _autoComplete = false;
        return await _startSearch();
      }

      listType = ListType.tag;

      // url 直接打开
      if (searchText.isURL && await canLaunchUrlString(searchText)) {
        if (regGalleryUrl.hasMatch(searchText) ||
            regGalleryPageUrl.hasMatch(searchText)) {
          _jumpToUrl = regGalleryUrl.firstMatch(searchText)?.group(0) ??
              regGalleryPageUrl.firstMatch(searchText)?.group(0);
          logger.d('_jumpToUrl $_jumpToUrl');
          textIsGalleryUrl = true;
        } else {
          textIsGalleryUrl = false;
        }
        update([GetIds.SEARCH_CLEAR_BTN]);
      } else {
        textIsGalleryUrl = false;
        update([GetIds.SEARCH_CLEAR_BTN]);
      }

      currQryText = searchTextController.text.split(RegExp(r'[ ;"]')).last;
      logger.d('currQryText $currQryText');
      if (currQryText.isEmpty) {
        qryTags([]);
        return;
      }

      /// 模糊搜索
      try {
        // 中文从翻译库匹配
        if (localeService.isLanguageCodeZh) {
          logger.d('isLanguageCodeZh');
          List<TagTranslat> qryTagsTemp = await tagTransController
              .getTagTranslatesLike(text: currQryText, limit: 200);
          if (qryTagsTemp.isNotEmpty) {
            qryTags.value = qryTagsTemp;
          }
        } else {
          // 其它通过eh的api
          qryTags.clear();
          logger.d('tagSuggest $currQryText');
          List<TagTranslat> tagTranslateList =
              await Api.tagSuggest(text: currQryText);
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

  final _typeMap = {
    SearchType.favorite: GalleryListType.favorite,
    SearchType.normal: GalleryListType.gallery,
    SearchType.watched: GalleryListType.watched,
  };

  GalleryListType get _currListType =>
      _typeMap[searchType] ?? GalleryListType.gallery;

  List<String> searchHistory = <String>[].obs;

  void _addHistory() {
    searchHistory.insert(0, searchTextController.text.trim());
    searchHistory = LinkedHashSet<String>.from(searchHistory).toList();
    if (searchHistory.length > 100) {
      searchHistory.removeRange(100, searchHistory.length);
    }
    hiveHelper.setSearchHistory(searchHistory);
  }

  void removeHistory(Object? value) {
    searchHistory.remove(value);
    update([GetIds.SEARCH_INIT_VIEW]);
    hiveHelper.setSearchHistory(searchHistory);
  }

  void clearHistory() {
    searchHistory.clear();
    update([GetIds.SEARCH_INIT_VIEW]);
    hiveHelper.setSearchHistory(searchHistory);
  }

  void switchTranslateHistory() {
    translateSearchHistory = !translateSearchHistory;
    update([GetIds.SEARCH_INIT_VIEW]);
  }

  @override
  void onInit() {
    logger.d('onInit searchPageCtrlDepth $searchPageCtrlTag');

    searchHistory = hiveHelper.getAllSearchHistory();
    super.onInit();
  }

  @override
  void onReady() {
    SearchRepository searchRepository = Get.find();
    initSearchText = searchRepository.searchText;
    searchType = searchRepository.searchType;
    _autoComplete = initSearchText?.trim().isNotEmpty ?? false;
    searchTextController.addListener(_delayedSearch);
    // searchHistory = hiveHelper.getAllSearchHistory();
    super.onReady();
  }

  @override
  Future<void> firstLoad() async {
    if (initSearchText != null && initSearchText!.trim().isNotEmpty) {
      searchTextController.text = initSearchText!.trim();
      autofocus = false;
    } else {
      autofocus = true;
    }
    change(<GalleryProvider>[], status: RxStatus.empty());
    canLoadMore = true;
  }

  @override
  void onClose() {
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
        _lastSearchText.replaceAll(RegExp('$currQryText\$'), _add);
    logger.d(
        '_lastSearchText $_lastSearchText \n_currQry $currQryText\n_newSearch $_newSearch ');

    _autoComplete = false;
    searchTextController.value = TextEditingValue(
      text: '$_newSearch ',
      selection: TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream, offset: '$_newSearch '.length)),
    );

    FocusScope.of(Get.context!).requestFocus(searchFocusNode);
    qryTags.clear();

    tagTransController.tapTagTranslate(_qry);
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
    resetResultPage();
  }

  void jumpToGallery() {
    NavigatorUtil.goGalleryPage(
      url: _jumpToUrl,
    );
  }
}
