import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/widget/rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import 'gallery_item.dart';
import 'item_base.dart';

const int kTitleMaxLines = 3;
const double kRadius = 12.0;
const double kCategoryWidth = 38.0;
const double kCategoryHeight = 28.0;

class GalleryItemFlowLarge extends StatelessWidget {
  const GalleryItemFlowLarge(
      {Key? key, required this.tabTag, required this.galleryProvider})
      : super(key: key);

  final dynamic tabTag;
  final GalleryProvider galleryProvider;

  GalleryItemController get galleryProviderController =>
      Get.find(tag: galleryProvider.gid);

  Widget _buildFavcatIcon() {
    return Obx(() {
      // logger.d('${_galleryProviderController.isFav}');
      return Container(
        child: galleryProviderController.isFav
            ? Icon(
                FontAwesomeIcons.solidHeart,
                size: 12,
                color: ThemeColors
                    .favColor[galleryProviderController.galleryProvider.favcat],
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
            rate: galleryProvider.ratingFallBack ?? 0,
            radiusRatio: 1.5,
            colorLight: ThemeColors
                .colorRatingMap[galleryProvider.colorRating?.trim() ?? 'ir'],
            colorDark: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey3, Get.context!),
          ),
        ),
      ],
    );
  }

  Widget _buildCount({bool blur = false}) {
    final text = Text(
      galleryProviderController.galleryProvider.filecount ?? '',
      style: const TextStyle(
        fontSize: 12,
        color: Color.fromARGB(255, 240, 240, 240),
        height: 1.12,
        // fontStyle: FontStyle.italic,
      ),
    );

    if (blur) {
      return Container(
        padding: const EdgeInsets.only(left: 2),
        child: text.frosted(
          blur: 10,
          frostColor: CupertinoColors.systemGrey.color,
          frostOpacity: 0.0,
          borderRadius: BorderRadius.circular(10),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(left: 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.black38,
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            child: text,
          ),
        ),
      );
    }
  }

  /// 构建标题
  Widget _buildTitle() {
    return Obx(() => Text(
          galleryProviderController.title,
          maxLines: kTitleMaxLines,
          textAlign: TextAlign.left, // 对齐方式
          overflow: TextOverflow.ellipsis, // 超出部分
          style: const TextStyle(
            fontSize: 14,
            // height: 1.3,
            // fontWeight: FontWeight.w500,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final Widget item = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final GalleryProvider galleryProvider =
          galleryProviderController.galleryProvider;

      final Color _colorCategory = CupertinoDynamicColor.resolve(
          ThemeColors.catColor[galleryProvider.category ?? 'default'] ??
              CupertinoColors.systemBackground,
          context);

      // 获取图片高度
      double? _getHeigth() {
        if ((galleryProvider.imgWidth ?? 0) >= constraints.maxWidth) {
          return (galleryProvider.imgHeight ?? 0) *
              constraints.maxWidth /
              (galleryProvider.imgWidth ?? 0);
        } else {
          return galleryProvider.imgHeight;
        }
      }

      final Widget container = Container(
        decoration: BoxDecoration(
          color: ehTheme.itemBackgroundColor,
          borderRadius: BorderRadius.circular(kRadius), //圆角
          boxShadow: ehTheme.isDarkMode
              ? null
              : [
                  BoxShadow(
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey3, Get.context!),
                    blurRadius: 10,
                  )
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /// 画廊封面
            Hero(
              tag: '${galleryProvider.gid}_cover_$tabTag',
              child: Container(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(kRadius),
                    topRight: Radius.circular(kRadius),
                  ),
                  child: Container(
                    foregroundDecoration: RotatedCornerDecoration(
                      color: _colorCategory.withOpacity(0.8),
                      labelInsets:
                          const LabelInsets(baselineShift: 0.5, start: 2),
                      geometry: const BadgeGeometry(
                          width: kCategoryWidth, height: kCategoryHeight),
                      textSpan: TextSpan(
                        text: galleryProvider.translated ?? '',
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    alignment: Alignment.center,
                    height:
                        galleryProvider.imgWidth != null ? _getHeigth() : null,
                    child: CoverImg(imgUrl: galleryProvider.imgUrl!),
                  ),
                ),
              ),
            ),

            /// 画廊信息等
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
                const SizedBox(height: 6),
                _buildTitle(),
                const SizedBox(height: 6),
                // _buildSimpleTagsView(),
                TagWaterfallFlowViewBox(
                  simpleTags: galleryProvider.simpleTags,
                ),
              ],
            ).paddingAll(8.0),
          ],
        ),
      );

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: container,
        onTap: () => galleryProviderController.onTap(tabTag),
        onLongPress: galleryProviderController.onLongPress,
      ).autoCompressKeyboard(context);
    });

    return item;
  }
}
