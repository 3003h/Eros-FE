import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../common/service/ehconfig_service.dart';
import '../../common/service/layout_service.dart';
import '../../common/service/theme_service.dart';
import '../../const/theme_colors.dart';
import '../../fehviewer.dart';
import '../../widget/rating_bar.dart';
import 'controller/galleryitem_controller.dart';
import 'gallery_clipper.dart';
import 'gallery_item.dart';

const int kTitleMaxLines = 2;
const double kRadius = 6.0;
const double kCategoryWidth = 32.0;
const double kCategoryHeight = 20.0;
const double kCoverRatio = 1.33;

final EhConfigService _ehConfigService = Get.find();

class GalleryItemGrid extends StatelessWidget {
  const GalleryItemGrid({Key? key, this.tabTag, required this.galleryItem})
      : super(key: key);

  final dynamic tabTag;
  final GalleryItem galleryItem;

  GalleryItemController get galleryItemController =>
      Get.find(tag: galleryItem.gid);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final Color _colorCategory = CupertinoDynamicColor.resolve(
          ThemeColors.catColor[galleryItem.category ?? 'default'] ??
              CupertinoColors.systemBackground,
          context);

      // 获取图片高度
      final coverHeight = kCoverRatio * constraints.maxWidth;

      final Widget container = Container(
        decoration: BoxDecoration(
          color: ehTheme.itemBackgroundColor,
          borderRadius: BorderRadius.circular(kRadius), //圆角
          boxShadow: ehTheme.isDarkMode
              ? null
              : [
                  BoxShadow(
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey4, Get.context!),
                    blurRadius: 10,
                  )
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /// 画廊封面
            Container(
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
                      height: coverHeight,
                      child: Column(
                        children: [
                          Expanded(
                            child: _CoverImage(
                              galleryItemController: galleryItemController,
                              tabTag: tabTag,
                              coverImageHeigth: coverHeight,
                              coverImageWidth: constraints.maxWidth,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ClipPath(
                      clipper: CategoryClipper(
                          width: kCategoryWidth, height: kCategoryHeight),
                      child: Container(
                        width: kCategoryWidth,
                        height: kCategoryHeight,
                        color: _colorCategory.withOpacity(0.8),
                      ),
                    ),
                    // Positioned(bottom: 4, left: 4, child: _buildRating()),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Row(
                        children: [
                          _buildFavcatIcon(),
                          _buildCount(),
                        ],
                      ),
                    ),
                    Container(
                      height: (kCategoryHeight + kRadius * 0.8) / 2,
                      width: (kCategoryWidth + kRadius * 0.8) / 2,
                      alignment: Alignment.center,
                      child: Text(
                        galleryItem.translated ?? '',
                        style: const TextStyle(
                            fontSize: 7.5,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 画廊信息等
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTitle()),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _PostTime(
                      postTime: galleryItemController.galleryItem.postTime,
                    )
                  ],
                ).paddingAll(6.0),
              ),
            ),
          ],
        ),
      );

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: container,
        onTap: () => galleryItemController.onTap(tabTag),
        onLongPress: galleryItemController.onLongPress,
      ).autoCompressKeyboard(context);
    });
  }

  Widget _buildFavcatIcon({bool blur = false}) {
    return Obx(() {
      Widget icon = Icon(
        FontAwesomeIcons.solidHeart,
        size: 12,
        color: ThemeColors.favColor[galleryItemController.galleryItem.favcat],
      );

      if (blur) {
        icon = icon.frosted(
          blur: 10,
          frostColor: CupertinoColors.systemGrey.color,
          frostOpacity: 0.0,
          borderRadius: BorderRadius.circular(10),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
        );
      } else {
        icon = ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.black38,
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            child: icon,
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.only(left: 2),
        child: galleryItemController.isFav ? icon : const SizedBox(),
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
            rate: galleryItemController.galleryItem.ratingFallBack ?? 0,
            radiusRatio: 1.5,
            colorLight: ThemeColors.colorRatingMap[
                galleryItemController.galleryItem.colorRating?.trim() ?? 'ir'],
            colorDark: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey3, Get.context!),
          ),
        ),
      ],
    );
  }

  Widget _buildCount({bool blur = false}) {
    final text = Text(
      galleryItemController.galleryItem.filecount ?? '',
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
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            child: text,
          ),
        ),
      );
    }
  }

  /// 构建标题
  Widget _buildTitle() {
    return Obx(() => Text(
          galleryItemController.title,
          maxLines: kTitleMaxLines,
          textAlign: TextAlign.left, // 对齐方式
          overflow: TextOverflow.ellipsis, // 超出部分
          style: const TextStyle(
            fontSize: 12,
            // height: 1.3,
            // fontWeight: FontWeight.w500,
          ),
        ));
  }
}

class _PostTime extends StatelessWidget {
  const _PostTime({Key? key, this.postTime}) : super(key: key);
  final String? postTime;

  @override
  Widget build(BuildContext context) {
    return Text(
      postTime ?? '',
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({
    Key? key,
    required this.galleryItemController,
    this.tabTag,
    required this.coverImageWidth,
    required this.coverImageHeigth,
  }) : super(key: key);
  final GalleryItemController galleryItemController;
  final dynamic tabTag;
  final double coverImageWidth;
  final double coverImageHeigth;

  @override
  Widget build(BuildContext context) {
    final GalleryItem _item = galleryItemController.galleryItem;

    // 图片高宽比
    final ratio = (_item.imgHeight ?? 0) / (_item.imgWidth ?? 1);

    logger.v('iRatio:$ratio\n'
        'w:${_item.imgWidth} h:${_item.imgHeight}\n'
        'cW:$coverImageWidth  cH:$coverImageHeigth');

    final containRatio = coverImageHeigth / coverImageWidth;

    BoxFit _fit = BoxFit.contain;

    // todo
    if (ratio < containRatio && ratio > 1) {
      _fit = BoxFit.fitHeight;
    }

    if (ratio > containRatio && ratio < 2) {
      _fit = BoxFit.cover;
    }

    Widget image = CoverImg(
      imgUrl: _item.imgUrl ?? '',
      width: _item.imgWidth,
      height: _item.imgHeight,
      fit: _fit,
    );

    Widget getImageBlureFittedBox() {
      Widget imageBlureFittedBox = CoverImg(
        imgUrl: _item.imgUrl ?? '',
        width: coverImageWidth,
        fit: BoxFit.contain,
      );

      imageBlureFittedBox = FittedBox(
        fit: BoxFit.cover,
        child: imageBlureFittedBox.blurred(
          blur: 10,
          colorOpacity: ehTheme.isDarkMode ? 0.5 : 0.1,
          blurColor:
              CupertinoTheme.of(context).barBackgroundColor.withOpacity(1),
        ),
      );

      return imageBlureFittedBox;
    }

    image = Stack(
      fit: StackFit.passthrough,
      children: [
        // if (_fit == BoxFit.contain) getImageBlureFittedBox(),
        Container(
          width: coverImageWidth,
          height: coverImageHeigth,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey6, context),
        ),
        Center(
          child: HeroMode(
            enabled: !isLayoutLarge,
            child: Hero(
              tag: '${_item.gid}_cover_$tabTag',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: image,
              ),
            ),
          ),
        ),
      ],
    );
    return image;
  }
}
