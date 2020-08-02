import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../item/gallery_item.dart';

class GalleryListTab extends StatefulWidget {
  final tabIndex;
  final scrollController;

  final simpleSearch;
  final int cats;

  const GalleryListTab(
      {Key key,
      this.tabIndex,
      this.scrollController,
      this.simpleSearch,
      this.cats})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _GalleryListTabState();
}

class _GalleryListTabState extends State<GalleryListTab> {
  String _title = "Gallery";
  int _curPage = 0;
  int _maxPage = 0;
  bool _isLoadMore = false;
  bool _firstLoading = false;
  final List<GalleryItem> _gallerItemBeans = [];
  String _search;

  //页码跳转的控制器
  TextEditingController _pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _parserSearch();
    _loadDataFirst();
  }

  _parserSearch() {
    _search = '${widget.simpleSearch}'.trim();
  }

  _loadDataFirst() async {
    setState(() {
      _gallerItemBeans.clear();
      _firstLoading = true;
    });
    var tuple = await Api.getGallery(cats: widget.cats, serach: _search);
    var gallerItemBeans = tuple.item1;
    _gallerItemBeans.addAll(gallerItemBeans);
    _maxPage = tuple.item2;
    setState(() {
      _firstLoading = false;
    });
  }

  _reloadData() async {
    if (_firstLoading) {
      setState(() {
        _firstLoading = false;
      });
    }
    var tuple = await Api.getGallery(cats: widget.cats, serach: _search);
    var gallerItemBeans = tuple.item1;
    setState(() {
      _curPage = 0;
      _gallerItemBeans.clear();
      _gallerItemBeans.addAll(gallerItemBeans);
      _maxPage = tuple.item2;
    });
  }

  _loadDataMore() async {
    if (_isLoadMore) {
      return;
    }

    // 增加延时 避免build期间进行 setState
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      _isLoadMore = true;
    });
    _curPage += 1;
    var fromGid = _gallerItemBeans.last.gid;
    var tuple = await Api.getGallery(
        page: _curPage, fromGid: fromGid, cats: widget.cats, serach: _search);
    var gallerItemBeans = tuple.item1;

    setState(() {
      _gallerItemBeans.addAll(gallerItemBeans);
      _maxPage = tuple.item2;
      _isLoadMore = false;
    });
  }

  _loadFromPage(int page) async {
    Global.logger.v('jump to page   ===>  $page');
    setState(() {
      _firstLoading = true;
    });
    _curPage = page;
    var tuple = await Api.getGallery(
        page: _curPage, cats: widget.cats, serach: _search);
    var gallerItemBeans = tuple.item1;
    setState(() {
      _gallerItemBeans.clear();
      _gallerItemBeans.addAll(gallerItemBeans);
      _maxPage = tuple.item2;
      _firstLoading = false;
    });
  }

  SliverList gallerySliverListView(List gallerItemBeans) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == gallerItemBeans.length - 1 && _curPage < _maxPage - 1) {
//            Global.logger.v('load more');
            _loadDataMore();
          }

          return ChangeNotifierProvider.value(
            value: GalleryModel(),
            child: GalleryItemWidget(
              galleryItem: gallerItemBeans[index],
              tabIndex: widget.tabIndex,
            ),
          );
        },
        childCount: gallerItemBeans.length,
      ),
    );
  }

  /// 跳转页码
  Future<void> _jumtToPage(BuildContext context) async {
    _jump(context) {
      var _input = _pageController.text.trim();

      if (_input.isEmpty) {
        showToast('输入为空');
      }

      // 数字检查
      if (!RegExp(r'(^\d+$)').hasMatch(_input)) {
        showToast('输入格式有误');
      }

      int _toPage = int.parse(_input) - 1;
      if (_toPage >= 0 && _toPage <= _maxPage) {
        FocusScope.of(context).requestFocus(FocusNode());
        _loadFromPage(_toPage);
        Navigator.of(context).pop();
      } else {
        showToast('输入范围有误');
      }
    }

    return showCupertinoDialog<void>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('页面跳转'),
          content: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("跳转范围 1~$_maxPage"),
                ),
                CupertinoTextField(
                  controller: _pageController,
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
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('确定'),
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

  @override
  Widget build(BuildContext context) {
//    final size = MediaQuery.of(context).size;
//    // final width = size.width;
//    final height = size.height;

    var ln = S.of(context);
    _title = ln.tab_gallery;
    CustomScrollView customScrollView = CustomScrollView(
      controller: widget.scrollController,
      physics: AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          heroTag: 'gallery',
          largeTitle: TabPageTitle(
            title: _title,
            isLoading: false,
          ),
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                color: CupertinoColors.activeBlue,
                child: Text(
                  '${_curPage + 1}',
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ),
            ),
            onPressed: () {
              _jumtToPage(context);
            },
          ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await _reloadData();
          },
        ),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: _firstLoading
              ? SliverFillRemaining(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: CupertinoActivityIndicator(
                      radius: 14.0,
                    ),
                  ),
                )
              : gallerySliverListView(_gallerItemBeans),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(top: 50, bottom: 100),
            child: _isLoadMore
                ? CupertinoActivityIndicator(
                    radius: 14,
//                    iOSVersionStyle:
//                        CupertinoActivityIndicatorIOSVersionStyle.iOS14,
                  )
                : Container(),
          ),
        ),
      ],
    );

    return CupertinoPageScaffold(
      child: customScrollView,
    );
  }
}
