import 'dart:ui';

import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/widget/rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'gallery_clipper.dart';
import 'gallery_item.dart';

const int kTitleMaxLines = 3;
const double kRadius = 6.0;
const double kWidth = 28.0;
const double kHeight = 18.0;

class GalleryItemFlowLarge extends StatelessWidget {
  const GalleryItemFlowLarge(
      {Key? key, required this.tabTag, required this.galleryItem})
      : super(key: key);

  final dynamic tabTag;
  final GalleryItem galleryItem;

  GalleryItemController get galleryItemController =>
      Get.find(tag: galleryItem.gid);

  Widget _buildFavcatIcon() {
    return Obx(() {
      // logger.d('${_galleryItemController.isFav}');
      return Container(
        child: galleryItemController.isFav
            ? Icon(
                FontAwesomeIcons.solidHeart,
                size: 12,
                color: ThemeColors
                    .favColor[galleryItemController.galleryItem.favcat],
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

  /// 构建标题
  Widget _buildTitle() {
    return Obx(() => Text(
          galleryItemController.title,
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
      final GalleryItem galleryItem = galleryItemController.galleryItem;

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
              tag: '${galleryItem.gid}_cover_$tabTag',
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: CupertinoDynamicColor.resolve(
                            CupertinoColors.systemGrey5, Get.context!)
                        .withOpacity(1.0),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]),
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
                        height:
                            galleryItem.imgWidth != null ? _getHeigth() : null,
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
                const SizedBox(height: 4),
                _buildTitle(),
                _buildSimpleTagsView(),
              ],
            ).paddingAll(8.0),
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

    return item;
  }

  Container _buildSimpleTagsView() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: (galleryItemController.galleryItem.simpleTags?.length ?? 0) >= 5
            ? TagWaterfallFlowViewBox(
                simpleTags: galleryItemController.galleryItem.simpleTags ?? [],
              )
            : TagListViewBox(
                simpleTags: galleryItemController.galleryItem.simpleTags ?? [],
              ),
      ),
    );
  }
}

class TagListViewBox extends StatelessWidget {
  const TagListViewBox({Key? key, this.simpleTags}) : super(key: key);

  final List<SimpleTag>? simpleTags;

  @override
  Widget build(BuildContext context) {
    final EhConfigService _ehConfigService = Get.find();
    return simpleTags != null && simpleTags!.isNotEmpty
        ? Obx(() => SizedBox(
              height: 18,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    List<Widget>.from(simpleTags!.map((SimpleTag _simpleTag) {
                  final String? _text = _ehConfigService.isTagTranslat
                      ? _simpleTag.translat
                      : _simpleTag.text;
                  return TagItem(
                    text: _text,
                    color: ColorsUtil.getTagColor(_simpleTag.color),
                    backgrondColor:
                        ColorsUtil.getTagColor(_simpleTag.backgrondColor),
                  ).paddingOnly(right: 4.0);
                }).toList()), //要显示的子控件集合
              ),
            ))
        : Container();
  }
}

class TagWaterfallFlowViewBox extends StatelessWidget {
  const TagWaterfallFlowViewBox({Key? key, this.simpleTags}) : super(key: key);

  final List<SimpleTag>? simpleTags;

  @override
  Widget build(BuildContext context) {
    final EhConfigService _ehConfigService = Get.find();
    if (simpleTags == null || (simpleTags?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: WaterfallFlow.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: simpleTags?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          return Obx(() {
            final _simpleTag = simpleTags![index];
            final String? _text = _ehConfigService.isTagTranslat
                ? _simpleTag.translat
                : _simpleTag.text;
            return TagItem(
              text: _text,
              color: ColorsUtil.getTagColor(_simpleTag.color),
              backgrondColor: ColorsUtil.getTagColor(_simpleTag.backgrondColor),
            );
          });
        },
      ),
    );
  }
}
