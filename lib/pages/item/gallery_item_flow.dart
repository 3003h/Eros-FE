import 'dart:ui';

import 'package:FEhViewer/models/galleryItem.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/logger.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'gallery_clipper.dart';
import 'gallery_item.dart';

const double kRadius = 6.0;
const double kWidth = 28.0;
const double kHeight = 18.0;

class GalleryItemFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /*final Window windows = WidgetsBinding.instance.window;
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
            EHConst.waterfallFlowCrossAxisSpacing;*/
    final Widget item = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Selector<GalleryModel, Tuple2<GalleryItem, dynamic>>(
          selector: (_, GalleryModel galleryModel) =>
              Tuple2<GalleryItem, dynamic>(
                  galleryModel.galleryItem, galleryModel.tabIndex),
          shouldRebuild: (_, __) => true,
          builder:
              (BuildContext context, Tuple2<GalleryItem, dynamic> tuple, _) {
            final GalleryItem galleryItem = tuple.item1;
            final dynamic _tabIndex = tuple.item2;

            final Color _colorCategory = CupertinoDynamicColor.resolve(
                ThemeColors.catColor[galleryItem?.category ?? 'default'] ??
                    CupertinoColors.systemBackground,
                context);

            // 获取图片高度
            num _getHeigth() {
              if (galleryItem.imgWidth >= constraints.maxWidth) {
                return galleryItem.imgHeight *
                    constraints.maxWidth /
                    galleryItem.imgWidth;
              } else {
                return galleryItem.imgHeight;
              }
            }

            final Widget container = Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag:
                        '${galleryItem.gid}_${galleryItem.token}_cover_$_tabIndex',
                    child: Container(
                      decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(kRadius), //圆角
                          // ignore: prefer_const_literals_to_create_immutables
                          boxShadow: [
                            //阴影
                            BoxShadow(
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.systemGrey6, context),
                              blurRadius: 5,
                            )
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(kRadius),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              height: galleryItem.imgWidth != null
                                  ? _getHeigth()
                                  : null,
                              child: CoverImg(imgUrl: galleryItem.imgUrl),
                            ),
                            ClipPath(
                              clipper: CategoryClipper(
                                  width: kWidth, height: kHeight),
                              child: Container(
                                width: kWidth,
                                height: kHeight,
                                color: _colorCategory,
                              ),
                            ),
                            Container(
                              height: (kHeight + kRadius) / 2,
                              width: (kWidth + kRadius) / 2,
                              alignment: Alignment.center,
                              child: Text(
                                galleryItem?.translated ?? '',
                                style: const TextStyle(
                                    fontSize: 8,
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.bold,
                                    height: 1),
                              ),
                            ),
                          ],
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
                logger.v(galleryItem.englishTitle);
                NavigatorUtil.goGalleryDetailPr(
                  context,
                );
              },
            );
          });
    });

    return item;
  }
}
