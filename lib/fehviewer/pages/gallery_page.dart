import 'package:FEhViewer/fehviewer/model/gallery.dart';
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
  final List<GalleryItemBean> _gallerItemBeans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    var gallerItemBeans = await EHUtils.getGallery();
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
