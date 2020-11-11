import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/pages/tab/gallery_base.dart';
import 'package:FEhViewer/pages/tab/tab_base.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class GallerySearchPage extends StatefulWidget {
  @override
  _GallerySearchPageState createState() => _GallerySearchPageState();
}

class _GallerySearchPageState extends State<GallerySearchPage>
    with SingleTickerProviderStateMixin {
  final String _index = 'search_idx';

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

  void _jumpSearch() {
    final String _searchText = _searchTextController.text.trim();
    final int _catNum =
        Provider.of<EhConfigModel>(context, listen: false).catFilter;
    if (_searchText.isNotEmpty) {
      // FocusScope.of(context).requestFocus(FocusNode());
      _search = _searchText;
      _loadDataFirst();
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
      Global.logger.v('${_searchTextController.text}');
      _lastSearchText = _searchTextController.text;
      _jumpSearch();
    }
  }

  void _printLatestValue() {
    // print('Second text field: ${_searchTextController.text}');
    _delayedSearch();
  }

  @override
  void initState() {
    super.initState();
    _searchTextController.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S ln = S.of(context);

    final Widget cfp = CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(start: 0),
//        border: null,
        backgroundColor: ThemeColors.navigationBarBackground,
        middle: CupertinoTextField(
          controller: _searchTextController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onEditingComplete: () {
            // 点击键盘完成
            _jumpSearch();
          },
        ),
        transitionBetweenRoutes: false,
        previousPageTitle: '返回',
        trailing: Container(
          width: 90,
          child: Row(
            children: [
              // CupertinoButton(
              //   padding: const EdgeInsets.all(0),
              //   child: const Icon(
              //     FontAwesomeIcons.search,
              //     size: 20,
              //   ),
              //   onPressed: () {
              //     Global.logger.v('search Btn');
              //     _jumpSearch();
              //   },
              // ),
              CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.solidTimesCircle,
                  size: 21.5,
                ),
                onPressed: () {
                  Global.logger.v('search Btn');
                  _searchTextController.clear();
                },
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.filter,
                  size: 20,
                ),
                onPressed: () {
                  GalleryBase().setCats(context);
                },
              ),
            ],
          ),
        ),
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

  Future<void> _loadDataMore({bool cleanSearch = false}) async {
    if (_isLoadMore) {
      return;
    }

    if (cleanSearch) {
      _search = '';
    }

    final int _catNum =
        Provider.of<EhConfigModel>(context, listen: false).catFilter;

    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));
    setState(() {
      _isLoadMore = true;
    });
    _curPage += 1;
    final String fromGid = _gallerItemBeans.last.gid;
    final Tuple2<List<GalleryItem>, int> tuple = await Api.getGallery(
        page: _curPage, fromGid: fromGid, cats: _catNum, serach: _search);
    final List<GalleryItem> gallerItemBeans = tuple.item1;

    setState(() {
      _gallerItemBeans.addAll(gallerItemBeans);
      _maxPage = tuple.item2;
      _isLoadMore = false;
    });
  }

  Future<void> _loadDataFirst() async {
    final int _catNum =
        Provider.of<EhConfigModel>(context, listen: false).catFilter;

    Global.loggerNoStack.v('_loadDataFirst');
    setState(() {
      _gallerItemBeans.clear();
      _firstLoading = true;
    });

    final Tuple2<List<GalleryItem>, int> tuple =
        await Api.getGallery(cats: _catNum, serach: _search);
    final List<GalleryItem> gallerItemBeans = tuple.item1;
    _gallerItemBeans.addAll(gallerItemBeans);
    _maxPage = tuple.item2;
    setState(() {
      _firstLoading = false;
    });
  }
}
