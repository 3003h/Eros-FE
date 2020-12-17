import 'package:FEhViewer/common/controller/ehconfig_controller.dart';
import 'package:FEhViewer/common/controller/quicksearch_controller.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/pages/tab/view/gallery_base.dart';
import 'package:FEhViewer/pages/tab/view/search_text_page.dart';
import 'package:FEhViewer/pages/tab/view/tab_base.dart';
import 'package:FEhViewer/utils/cust_lib/popup_menu.dart';
import 'package:FEhViewer/utils/logger.dart';
import 'package:FEhViewer/utils/network/gallery_request.dart';
import 'package:FEhViewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

enum SearchMenuEnum {
  filter,
  quickSearchList,
  addToQuickSearch,
}

class GallerySearchPage extends StatefulWidget {
  const GallerySearchPage({Key key, this.searchText}) : super(key: key);
  final String searchText;

  @override
  _GallerySearchPageState createState() => _GallerySearchPageState();
}

class _GallerySearchPageState extends State<GallerySearchPage>
    with SingleTickerProviderStateMixin {
  final String _index = 'search_idx';

  final GlobalKey _searchMenukey = GlobalKey();

  // 搜索内容的控制器
  final TextEditingController _searchTextController = TextEditingController();

  int _curPage = 0;
  int _maxPage = 0;
  bool _isLoadMore = false;
  bool _firstLoading = false;
  final List<GalleryItem> _gallerItemBeans = <GalleryItem>[];
  String _search = '';

  DateTime _lastInputCompleteAt; //上次输入完成时间
  String _lastSearchText;

  bool _autofocus;

  final EhConfigController ehConfigController = Get.find();
  final QuickSearchController quickSearchController = Get.find();

  void _jumpSearch() {
    final String _searchText = _searchTextController.text.trim();
    final int _catNum = ehConfigController.catFilter.value;
    if (_searchText.isNotEmpty) {
      // FocusScope.of(context).requestFocus(FocusNode());
      _search = _searchText;
      _loadData(refresh: true);
    } else {
      setState(() {
        _gallerItemBeans.clear();
      });
    }
  }

  Future<void> _delayedSearch() async {
    const Duration _duration = Duration(milliseconds: 800);
    _lastInputCompleteAt = DateTime.now();
    await Future<void>.delayed(_duration);
    if (_lastSearchText != _searchTextController.text &&
        DateTime.now().difference(_lastInputCompleteAt) >= _duration) {
      _lastSearchText = _searchTextController.text;
      _jumpSearch();
    }
  }

  @override
  void initState() {
    super.initState();
    _searchTextController.addListener(_delayedSearch);
    if (widget.searchText != null && widget.searchText.trim().isNotEmpty) {
      _searchTextController.text = widget.searchText.trim();
      _autofocus = false;
    } else {
      _autofocus = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const BorderSide _kDefaultRoundedBorderSide = BorderSide(
      color: CupertinoDynamicColor.withBrightness(
        color: Color(0x33000000),
        darkColor: Color(0x33FFFFFF),
      ),
      style: BorderStyle.solid,
      width: 0.0,
    );
    const Border _kDefaultRoundedBorder = Border(
      top: _kDefaultRoundedBorderSide,
      bottom: _kDefaultRoundedBorderSide,
      left: _kDefaultRoundedBorderSide,
      right: _kDefaultRoundedBorderSide,
    );

    final Widget cfp = CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(start: 0),
//        border: null,

        middle: CupertinoTextField(
          style: const TextStyle(
            height: 1,
            textBaseline: TextBaseline.alphabetic,
          ),
          decoration: const BoxDecoration(
            color: CupertinoDynamicColor.withBrightness(
              color: CupertinoColors.white,
              darkColor: CupertinoColors.black,
            ),
            border: _kDefaultRoundedBorder,
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          clearButtonMode: OverlayVisibilityMode.editing,
          padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
          controller: _searchTextController,
          autofocus: _autofocus,
          textInputAction: TextInputAction.search,
          onEditingComplete: () {
            // 点击键盘完成
            _jumpSearch();
          },
        ),
        transitionBetweenRoutes: false,
        leading: Container(
          width: 0,
        ),
        trailing: _buildTrailing(context),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // 触摸收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        onPanDown: (DragDownDetails details) {
          // 滑动收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverSafeArea(
              // top: false,
              // bottom: false,
              sliver: _firstLoading
                  ? SliverFillRemaining(
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: const CupertinoActivityIndicator(
                          radius: 14.0,
                        ),
                      ),
                    )
                  : getGalleryList(
                      _gallerItemBeans,
                      _index,
                      maxPage: _maxPage,
                      curPage: _curPage,
                      loadMord: _loadDataMore,
                    ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(top: 50, bottom: 100),
                child: _isLoadMore
                    ? const CupertinoActivityIndicator(
                        radius: 14,
                      )
                    : Container(),
              ),
            ),
          ],
        ),
      ),
    );

    return cfp;
  }

  Widget _buildTrailing(BuildContext context) {
    PopupMenu.context = context;
    final TextStyle _menuTextStyle = TextStyle(
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
      fontSize: 12,
    );
    final PopupMenu _menu = PopupMenu(
      maxColumn: 2,
      lineColor: CupertinoDynamicColor.resolve(
          CupertinoColors.systemBackground, context),
      backgroundColor:
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey6, context),
      // highlightColor:
      //     CupertinoDynamicColor.resolve(CupertinoColors.label, context),
      items: <MenuItemProvider>[
        MenuItem(
            title: '筛选',
            itemKey: SearchMenuEnum.filter,
            textStyle: _menuTextStyle,
            image: const Icon(
              FontAwesomeIcons.filter,
              size: 20,
            )),
        MenuItem(
            title: '添加',
            itemKey: SearchMenuEnum.addToQuickSearch,
            textStyle: _menuTextStyle,
            image: const Icon(
              FontAwesomeIcons.plusCircle,
              size: 20,
            )),
        MenuItem(
            title: '列表',
            itemKey: SearchMenuEnum.quickSearchList,
            textStyle: _menuTextStyle,
            image: const Icon(
              FontAwesomeIcons.alignJustify,
              size: 20,
            )),
      ],
      onClickMenu: (MenuItemProvider item) {
        logger.v('${item.menuKey}');
        switch (item.menuKey) {
          case SearchMenuEnum.filter:
            showFilterSetting();
            break;
          case SearchMenuEnum.addToQuickSearch:
            final String _text = _searchTextController.text;
            if (_text.isNotEmpty) {
              quickSearchController.addText(_text);
            }
            break;
          case SearchMenuEnum.quickSearchList:
            Get.to<String>(SearchQuickListPage())
                .then((String value) => _searchTextController.text = value);
            break;
        }
      },
    );

    Widget _buildListBtns() {
      return GestureDetector(
        onLongPress: () {
          ehConfigController.isSearchBarComp.value = true;
          VibrateUtil.heavy();
        },
        child: Container(
          width: 153,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              CupertinoButton(
                minSize: 40,
                padding: const EdgeInsets.all(0),
                child: const Text('取消'),
                onPressed: () {
                  Get.back();
                },
              ),
              CupertinoButton(
                minSize: 36,
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.filter,
                  size: 20,
                ),
                onPressed: () {
                  showFilterSetting();
                },
              ),
              CupertinoButton(
                minSize: 36,
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.plusCircle,
                  size: 20,
                ),
                onPressed: () {
                  final String _text = _searchTextController.text;
                  if (_text.isNotEmpty) {
                    quickSearchController.addText(_text);
                  }
                },
              ),
              CupertinoButton(
                minSize: 36,
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.alignJustify,
                  size: 20,
                ),
                onPressed: () {
                  Get.to<String>(SearchQuickListPage()).then(
                      (String value) => _searchTextController.text = value);
                },
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildPopMenuBtn() {
      return GestureDetector(
        onLongPress: () {
          ehConfigController.isSearchBarComp.value = false;
          VibrateUtil.heavy();
        },
        child: Container(
          width: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              CupertinoButton(
                minSize: 40,
                padding: const EdgeInsets.all(0),
                child: const Text('取消'),
                onPressed: () {
                  Get.back();
                },
              ),
              CupertinoButton(
                key: _searchMenukey,
                minSize: 40,
                padding: const EdgeInsets.only(right: 4),
                child: const Icon(
                  FontAwesomeIcons.th,
                  size: 20,
                ),
                onPressed: () {
                  _menu.show(widgetKey: _searchMenukey);
                },
              ),
            ],
          ),
        ),
      );
    }

    return Obx(() {
      final Size size = MediaQuery.of(context).size;
      final double width = size.width;
      // logger.v(width);
      if (width > 450) {
        return _buildListBtns();
      } else {
        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 0),
            child: ehConfigController.isSearchBarComp.value
                ? Container(key: UniqueKey(), child: _buildPopMenuBtn())
                : Container(key: UniqueKey(), child: _buildListBtns()));
      }
    });
  }

  Future<void> _loadDataMore({bool cleanSearch = false}) async {
    if (_isLoadMore) {
      return;
    }

    if (cleanSearch) {
      _search = '';
    }

    final int _catNum = ehConfigController.catFilter.value;

    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));
    setState(() {
      _isLoadMore = true;
    });
    _curPage += 1;
    final String fromGid = _gallerItemBeans.last.gid;
    final Tuple2<List<GalleryItem>, int> tuple = await Api.getGallery(
      page: _curPage,
      fromGid: fromGid,
      cats: _catNum,
      serach: _search,
      refresh: true,
    );
    final List<GalleryItem> gallerItemBeans = tuple.item1;

    setState(() {
      _gallerItemBeans.addAll(gallerItemBeans);
      _maxPage = tuple.item2;
      _isLoadMore = false;
    });
  }

  Future<void> _loadData({bool refresh = false}) async {
    final int _catNum = ehConfigController.catFilter.value;

    loggerNoStack.v('_loadDataFirst');
    setState(() {
      _gallerItemBeans.clear();
      _firstLoading = true;
    });

    final Tuple2<List<GalleryItem>, int> tuple =
        await Api.getGallery(cats: _catNum, serach: _search, refresh: refresh);
    final List<GalleryItem> gallerItemBeans = tuple.item1;
    _gallerItemBeans.addAll(gallerItemBeans);
    _maxPage = tuple.item2;
    setState(() {
      _firstLoading = false;
    });
  }
}
