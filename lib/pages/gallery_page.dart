import 'package:FEhViewer/client/parser/gallery_list_parser.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/entity/gallery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
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
  final List<GalleryItemBean> _gallerItemBeans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    var gallerItemBeans = await GalleryListParser.getGallery();
    setState(() {
      _gallerItemBeans.clear();
      _gallerItemBeans.addAll(gallerItemBeans);
    });
  }

  _reloadData() async {
    var gallerItemBeans = await GalleryListParser.getGallery();
    setState(() {
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

  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);
    _title = ln.tab_gallery;
    CustomScrollView customScrollView = CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text(_title,
              style: TextStyle(fontFamilyFallback: ['JyuuGothic'])),
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
      footer: BallPulseFooter(),
      onLoad: () async {
        // ignore: unnecessary_statements
        _isLoadMore ? null : _loadDataMore();
      },
    );

    return re;
  }
}
