import 'package:FEhViewer/client/parser/gallery_list_parser.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'item/gallery_item.dart';

class GalleryListTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GalleryListTab();
  }
}

class _GalleryListTab extends State<GalleryListTab> {
  String _title = "Gallery";
  int _curPage = 0;
  bool _isLoadMore = false;
  bool _loading = false;
  final List<GalleryItem> _gallerItemBeans = [];

  //页码跳转的控制器
  TextEditingController _pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // _loadData() async {
  //   var gallerItemBeans = await GalleryListParser.getGallery();
  //   setState(() {
  //     _gallerItemBeans.clear();
  //     _gallerItemBeans.addAll(gallerItemBeans);
  //   });
  // }
  _loadData() async {
    setState(() {
      _gallerItemBeans.clear();
      _loading = true;
    });
    var gallerItemBeans = await GalleryListParser.getGallery();
    _gallerItemBeans.addAll(gallerItemBeans);
    setState(() {
      _loading = false;
    });
  }

  _reloadData() async {
    setState(() {
      _loading = false;
    });
    var gallerItemBeans = await GalleryListParser.getGallery();
    setState(() {
      _curPage = 0;
      _gallerItemBeans.clear();
      _gallerItemBeans.addAll(gallerItemBeans);
    });
  }

  _loadDataMore() async {
    _isLoadMore = true;
    Global.logger.v('last gid   ===>  ${_gallerItemBeans.last.gid}');
    _curPage += 1;
    var fromGid = _gallerItemBeans.last.gid;
    var gallerItemBeans =
        await GalleryListParser.getGallery(page: _curPage, fromGid: fromGid);
    _isLoadMore = false;
    setState(() {
      _gallerItemBeans.addAll(gallerItemBeans);
    });
  }

  _loadFromPage(int page) async {
    Global.logger.v('jump to page   ===>  $page');
    setState(() {
      _loading = true;
    });
    _curPage = page;
    var gallerItemBeans = await GalleryListParser.getGallery(page: _curPage);
    setState(() {
      _gallerItemBeans.clear();
      _gallerItemBeans.addAll(gallerItemBeans);
      _loading = false;
    });
  }

  SliverList gallerySliverListView(List gallerItemBeans) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < gallerItemBeans.length) {
            return GalleryItemWidget(galleryItemBean: gallerItemBeans[index]);
          }
          return null;
        },
      ),
    );
  }

  /// 跳转页码
  Future<void> _jumtToPage(BuildContext context) async {
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
                  child: Text("跳转范围 1~100"),
                ),
                CupertinoTextField(
                  controller: _pageController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  onEditingComplete: () {
                    // 点击键盘完成
                    // 画廊跳转
                    _loadFromPage(int.parse(_pageController.text) - 1);
                    Navigator.of(context).pop();
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
                _loadFromPage(int.parse(_pageController.text) - 1);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);
    _title = ln.tab_gallery;
    CustomScrollView customScrollView = CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: TabPageTitle(
            title: _title,
            isLoading: _loading,
          ),
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Text('${_curPage + 1}'),
            onPressed: () {
              _jumtToPage(context);
            },
          ),
          transitionBetweenRoutes: false,
        ),
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await _reloadData();
          },
        ),
        SliverSafeArea(
          top: false,
          sliver: gallerySliverListView(_gallerItemBeans),
        ),
      ],
    );

    EasyRefresh re = EasyRefresh(
      child: customScrollView,
      // footer: BallPulseFooter(),
      onLoad: () async {
        // ignore: unnecessary_statements
        _isLoadMore ? null : _loadDataMore();
      },
    );

    return re;
  }
}
