import 'dart:math';

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
  const GalleryItemFlowLarge({
    super.key,
    required this.tabTag,
    required this.galleryProvider,
  });

  final dynamic tabTag;
  final GalleryProvider galleryProvider;

  GalleryItemController get galleryProviderController =>
      Get.find(tag: galleryProvider.gid);

  Widget _buildFavCatIcon() {
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

  /// 构建标题
  Widget _buildTitle() {
    return Text(
      galleryProviderController.title,
      maxLines: kTitleMaxLines,
      textAlign: TextAlign.left, // 对齐方式
      overflow: TextOverflow.ellipsis, // 超出部分
      style: const TextStyle(
        fontSize: 14,
        // height: 1.3,
        // fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GalleryProvider galleryProvider =
        galleryProviderController.galleryProvider;

    final Color _colorCategory = CupertinoDynamicColor.resolve(
        ThemeColors.catColor[galleryProvider.category ?? 'default'] ??
            CupertinoColors.systemBackground,
        context);

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
          // 画廊封面
          _CoverWidget(
            imgUrl: galleryProvider.imgUrl,
            colorCategory: _colorCategory,
            gid: galleryProvider.gid ?? '',
            tabTag: tabTag,
            imgWidth: galleryProvider.imgWidth ?? 0,
            imgHeight: galleryProvider.imgHeight ?? 0,
            translated: galleryProvider.translated,
            fileCount: galleryProvider.filecount,
          ),

          // 画廊信息等
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildRating(),
                    const Spacer(),
                    _buildFavCatIcon(),
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
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: container,
      onTap: () => galleryProviderController.onTap(tabTag),
      onLongPress: galleryProviderController.onLongPress,
    ).autoCompressKeyboard(context);
  }
}

class _CoverWidget extends StatelessWidget {
  const _CoverWidget({
    super.key,
    this.imgUrl,
    required this.colorCategory,
    required this.gid,
    required this.tabTag,
    required this.imgWidth,
    required this.imgHeight,
    this.translated,
    this.fileCount,
  });

  final String? translated;
  final String? imgUrl;
  final Color colorCategory;
  final String gid;
  final dynamic tabTag;
  final int imgWidth;
  final int imgHeight;
  final String? fileCount;

  @override
  Widget build(BuildContext context) {
    const _borderRadius = BorderRadius.only(
      topLeft: Radius.circular(kRadius),
      topRight: Radius.circular(kRadius),
    );

    return Hero(
      tag: '${gid}_cover_$tabTag',
      child: AspectRatio(
        aspectRatio: max(imgWidth / imgHeight, 1 / 2),
        child: ClipRRect(
          borderRadius: _borderRadius,
          child: Container(
            foregroundDecoration: RotatedCornerDecoration.withColor(
              color: colorCategory.withOpacity(0.8),
              spanBaselineShift: 0.5,
              spanHorizontalOffset: 2,
              badgeSize: const Size(kCategoryWidth, kCategoryHeight),
              textSpan: TextSpan(
                text: translated ?? '',
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CoverImg(
                  imgUrl: imgUrl ?? '',
                ),
                Positioned(
                    bottom: 4,
                    right: 4,
                    child: _CountWidget(
                      fileCount: fileCount,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountWidget extends StatelessWidget {
  const _CountWidget({super.key, this.fileCount, this.blur = false});

  final String? fileCount;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      fileCount ?? '',
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
}
