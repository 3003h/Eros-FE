import 'package:FEhViewer/model/gallery.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'gallery_item.dart';

class PopularListTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PopularListTab();
  }
}

class _PopularListTab extends State<PopularListTab> {
  String _title = "当前热门";
  final List<GalleryItemBean> gallerItemBeans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    gallerItemBeans.clear();
    gallerItemBeans.add(GalleryItemBean(japanese_title: "测试标题"));
    gallerItemBeans.add(GalleryItemBean(japanese_title: "测试标题"));
    gallerItemBeans.add(GalleryItemBean(japanese_title: "测试标题"));
    gallerItemBeans.add(GalleryItemBean(japanese_title: "测试标题"));
    gallerItemBeans.add(GalleryItemBean(japanese_title: "测试标题"));
    gallerItemBeans.add(GalleryItemBean(japanese_title: "测试标题22222222"));
  }

  void _reload() {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    CustomScrollView customScrollView = CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text(_title),
          trailing: GestureDetector(
            child: Icon(CupertinoIcons.refresh),
            onTap: () => _reload() ,
          ),
        ),
        SliverSafeArea(
          top: false,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < gallerItemBeans.length) {
                  return GalleryItemWidget(
                      galleryItemBean: gallerItemBeans[index]);
                }
              },
            ),
          ),
        )
      ],
    );

    return customScrollView;

    return EasyRefresh(
      child: customScrollView,
      onRefresh: () async {},
      onLoad: () async {},
    );
  }
}
