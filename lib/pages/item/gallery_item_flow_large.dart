import 'dart:ui';

import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/widget/rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'gallery_clipper.dart';
import 'gallery_item.dart';

const double kRadius = 6.0;
const double kWidth = 28.0;
const double kHeight = 18.0;

class GalleryItemFlowLarge extends StatelessWidget {
  GalleryItemFlowLarge({@required this.tabTag, required this.galleryItem}) {
    Get.lazyPut(
      () => GalleryItemController(galleryItem),
      tag: galleryItem.gid,
    );
  }

  final String? tabTag;
  final GalleryItem galleryItem;

  GalleryItemController get _galleryItemController =>
      Get.find(tag: galleryItem.gid);

  Widget _buildFavcatIcon() {
    return Obx(() {
      // logger.d('${_galleryItemController.isFav}');
      return Container(
        child: _galleryItemController.isFav
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

  Widget _buildRating() {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
          child: StaticRatingBar(
            size: 14.0,
            rate: _galleryItemController.galleryItem.ratingFallBack ?? 0,
            radiusRatio: 1.5,
            colorLight: ThemeColors.colorRatingMap[
                _galleryItemController.galleryItem.colorRating?.trim() ?? 'ir'],
            colorDark: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey3, Get.context!),
          ),
        ),
      ],
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    return Obx(() => Text(
          _galleryItemController.title,
          maxLines: 2,
          textAlign: TextAlign.left, // 对齐方式
          overflow: TextOverflow.ellipsis, // 超出部分省略号
          style: const TextStyle(
            fontSize: 14.5,
            // fontWeight: FontWeight.w500,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final Widget item = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final GalleryItem galleryItem = _galleryItemController.galleryItem;

      final Color _colorCategory = CupertinoDynamicColor.resolve(
          ThemeColors.catColor[galleryItem.category ?? 'default'] ??
              CupertinoColors.systemBackground,
          context);

      // 获取图片高度
      double? _getHeigth() {
        if ((galleryItem.imgWidth ?? 0) >= constraints.maxWidth) {
          return (galleryItem.imgHeight ?? 0) *
              constraints.maxWidth /
              (galleryItem.imgWidth ?? 0);
        } else {
          return galleryItem.imgHeight;
        }
      }

      final Widget container = Container(
        child: Container(
          decoration: BoxDecoration(
              color: ehTheme.itemBackgroundColor,
              borderRadius: BorderRadius.circular(kRadius), //圆角
              // ignore: prefer_const_literals_to_create_immutables
              boxShadow: [
                //阴影
                BoxShadow(
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey4, context),
                  blurRadius: 10,
                )
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Hero(
                tag: '${galleryItem.gid}_cover_$tabTag',
                child: Container(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(kRadius),
                      topRight: Radius.circular(kRadius),
                    ),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          height: galleryItem.imgWidth != null
                              ? _getHeigth()
                              : null,
                          child: CoverImg(imgUrl: galleryItem.imgUrl!),
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
                        // Positioned(
                        //     bottom: 4, right: 4, child: _buildFavcatIcon()),
                        // Positioned(bottom: 4, left: 4, child: _buildRating()),
                        Container(
                          height: (kHeight + kRadius) / 2,
                          width: (kWidth + kRadius) / 2,
                          alignment: Alignment.center,
                          child: Text(
                            galleryItem.translated ?? '',
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
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildRating(),
                      const Spacer(),
                      _buildFavcatIcon(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildTitle(),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TagListViewBox(
                        simpleTags:
                            _galleryItemController.galleryItem.simpleTags ?? [],
                      ),
                    ),
                  ),
                ],
              ).paddingAll(8.0),
            ],
          ),
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
