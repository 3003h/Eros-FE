import 'dart:ui';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/galleryItem.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'gallery_item.dart';

class GalleryItemFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Window windows = WidgetsBinding.instance.window;
    final Size size = windows.physicalSize / windows.devicePixelRatio;
    final double width = size.width - 2 * EHConst.waterfallFlowCrossAxisSpacing;

    double _width = 0.0;
    int count = 0;
    while (_width < width) {
      count++;
      _width = count *
          (EHConst.waterfallFlowCrossAxisSpacing +
              EHConst.waterfallFlowMaxCrossAxisExtent);
    }

    final double _sWidth =
        (width + EHConst.waterfallFlowCrossAxisSpacing) / count -
            EHConst.waterfallFlowCrossAxisSpacing;

    final Widget item = Selector<GalleryModel, Tuple2<GalleryItem, int>>(
        selector: (_, GalleryModel galleryModel) => Tuple2<GalleryItem, int>(
            galleryModel.galleryItem, galleryModel.tabIndex),
        builder: (BuildContext context, Tuple2<GalleryItem, int> tuple, _) {
          final GalleryItem galleryItem = tuple.item1;

          final Widget container = Container(
//            color: CupertinoColors.systemGrey2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0), //圆角
                      // ignore: prefer_const_literals_to_create_immutables
                      boxShadow: [
                        //阴影
                        const BoxShadow(
                          color: CupertinoColors.systemGrey2,
                          blurRadius: 2.0,
                        )
                      ]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: galleryItem.imgHeight *
                          _sWidth /
                          galleryItem.imgWidth,
                      color: CupertinoColors.systemGrey6,
                      child: Hero(
                        tag: '${galleryItem.url}_cover_${tuple.item2}',
                        child: Container(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CoverImg(imgUrl: galleryItem.imgUrl)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: container,
            onTap: () {
              Global.logger.v(galleryItem.englishTitle);
              NavigatorUtil.goGalleryDetailPr(
                context,
              );
            },
          );
        });

    return item;
  }
}
