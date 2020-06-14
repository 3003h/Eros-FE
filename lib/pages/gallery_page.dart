import 'package:FEhViewer/model/gallery.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/icon.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'gallery_item.dart';

class GalleryListTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GalleryListTab();
  }
}

class _GalleryListTab extends State<GalleryListTab> {
  String _title = "画廊";
  final List<GalleryItemBean> gallerItemBeans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    gallerItemBeans.clear();
    var rult = await API.getGallery(); // 网络请求
    gallerItemBeans.addAll(rult);
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
            onTap: () => _reload(),
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
