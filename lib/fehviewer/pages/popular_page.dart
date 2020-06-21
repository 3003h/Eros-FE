import 'package:FEhViewer/fehviewer/client/parser/GalleryListParser.dart';
import 'package:FEhViewer/models/entity/gallery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'item/gallery_item.dart';

class PopularListTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PopularListTab();
}

class _PopularListTab extends State<PopularListTab> {
  String _title = "当前热门";
  List<GalleryItemBean> _gallerItemBeans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    var gallerItemBeans = await GalleryListParser.getPopular();
    setState(() {
      _gallerItemBeans.clear();
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
    CustomScrollView customScrollView = CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text(_title),
        ),
        SliverSafeArea(
          top: false,
          sliver: gallerySliverListView(_gallerItemBeans),
        )
      ],
    );

    EasyRefresh re = EasyRefresh(
//      header: DeliveryHeader(enableHapticFeedback: true),
      child: customScrollView,
      onRefresh: () async {
        _loadData();
      },
      onLoad: () async {
        _loadData();
      },
    );

    return re;
  }
}
