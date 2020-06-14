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
    gallerItemBeans.add(GalleryItemBean(
        japanese_title:
            "[いーむす・アキ] 異世界エロスとブタ野郎 後編 (COMIC快楽天 2020年5月号) [中国翻訳] [DL版]",
        uploader: "真實爽粉",
        category: "Manga",
        postTime: "2020-06-13 13:28",
        imgUrl:
            "https://ul.ehgt.org/d0/2e/d02e75d58d2055faf137fee545082bd6eadb4686-1231285-1200-1600-jpg_250.jpg"));
    gallerItemBeans.add(GalleryItemBean(
        category: "Artist CG",
        uploader: "xxxhentaii",
        postTime: "2020-06-14 09:34",
        japanese_title: "[Hasosa] Komorojo-chan. (Oshiro Project)",
        tags: [
          "oshiro project",
          "f:ahegao",
          "f:big penis",
          "f:futanari",
          "f:huge penis",
          "variant set"
        ],
        imgUrl:
            "https://ul.ehgt.org/d0/2e/d02e75d58d2055faf137fee545082bd6eadb4686-1231285-1200-1600-jpg_250.jpg"));
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
