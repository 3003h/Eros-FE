import 'dart:ui';

import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/models/galleryItem.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'gallery_clipper.dart';
import 'gallery_item.dart';

const double kRadius = 6.0;
const double kWidth = 28.0;
const double kHeight = 18.0;

class GalleryItemFlow extends StatelessWidget {
  GalleryItemFlow({@required this.tabTag, this.galleryItem}) {
    Get.lazyPut(
      () => GalleryItemController.initData(galleryItem, tabTag: tabTag),
      tag: galleryItem.gid,
    );
  }

  final String tabTag;
  final GalleryItem galleryItem;
  GalleryItemController get _galleryItemController =>
      Get.find(tag: galleryItem.gid);

  Widget _buildFavcatIcon() {
    return Obx(() {
      // logger.d('${_galleryItemController.isFav}');
      return Container(
        child: _galleryItemController.isFav ?? false
            ? Container(
                child: Icon(
                  FontAwesomeIcons.solidHeart,
                  size: 12,
                  color: ThemeColors
                      .favColor[_galleryItemController.galleryItem.favcat],
                ),
              )
            : Container(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget item = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final GalleryItem galleryItem = _galleryItemController.galleryItem;

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
              tag: '${galleryItem.gid}_cover_$tabTag',
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
                        height:
                            galleryItem.imgWidth != null ? _getHeigth() : null,
                        child: CoverImg(imgUrl: galleryItem.imgUrl),
                      ),
                      ClipPath(
                        clipper:
                            CategoryClipper(width: kWidth, height: kHeight),
                        child: Container(
                          width: kWidth,
                          height: kHeight,
                          color: _colorCategory,
                        ),
                      ),
                      Positioned(
                          bottom: 4, right: 4, child: _buildFavcatIcon()),
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
        onTap: () => _galleryItemController.onTap(tabTag),
        onLongPress: _galleryItemController.onLongPress,
      );
    });

    return item;
  }
}
