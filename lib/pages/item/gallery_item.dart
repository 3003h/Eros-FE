import 'package:blur/blur.dart';
import 'package:fehviewer/common/exts.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/extension.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/widget/blur_image.dart';
import 'package:fehviewer/widget/eh_network_image.dart';
import 'package:fehviewer/widget/rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'item_base.dart';

const double kPaddingHorizontal = 12.0;
const double kPaddingVertical = 18.0;

const double kCardRadius = 12.0;

const double kFixedHeight = 200.0;

final EhConfigService _ehConfigService = Get.find();

/// 画廊列表项
class GalleryItemWidget extends StatelessWidget {
  const GalleryItemWidget(
      {Key? key, required this.tabTag, required this.galleryProvider})
      : super(key: key);

  final GalleryProvider galleryProvider;
  final dynamic tabTag;

  GalleryItemController get itemController =>
      Get.find(tag: galleryProvider.gid);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: Stack(
          children: [
            _buildCardItem(),
            if (Get.find<EhConfigService>().debugMode)
              Positioned(
                left: 4,
                top: 4,
                child: Text('${galleryProvider.pageOfList ?? ''}',
                    style: const TextStyle(
                        fontSize: 20,
                        color: CupertinoColors.secondarySystemBackground,
                        shadows: <Shadow>[
                          Shadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          )
                        ])),
              ),
          ],
        ),
      ),
      behavior: HitTestBehavior.opaque,
      onTap: () => itemController.onTap(tabTag),
      onTapDown: itemController.onTapDown,
      onTapUp: itemController.onTapUp,
      onTapCancel: itemController.onTapCancel,
      onLongPress: itemController.onLongPress,
    ).autoCompressKeyboard(context);
  }

  Widget _buildCardItem() {
    return Obx(
      () {
        return Container(
          height: _ehConfigService.fixedHeightOfListItems ? kFixedHeight : null,
          decoration: BoxDecoration(
            boxShadow: ehTheme.isDarkMode
                ? null
                : [
                    BoxShadow(
                      color: CupertinoDynamicColor.resolve(
                              CupertinoColors.darkBackgroundGray, Get.context!)
                          .withOpacity(0.11),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0.5, 4),
                    )
                  ],
            color: itemController.colorTap.value,
            borderRadius: BorderRadius.circular(kCardRadius),
          ),
          padding: const EdgeInsets.only(right: kPaddingHorizontal),
          margin: const EdgeInsets.fromLTRB(10, 8, 10, 4),
          child: IntrinsicHeight(
            child: Row(
              children: <Widget>[
                // 封面图片
                Column(
                  children: [
                    Expanded(
                      child: _CoverImage(
                        galleryProviderController: itemController,
                        tabTag: tabTag,
                        cardType: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 6,
                ),
                // 右侧信息
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // 标题 provider
                        _Title(
                          galleryItemController: itemController,
                        ),
                        const SizedBox(height: 6),
                        // 上传者 或 收藏备注
                        Text(
                          (galleryProvider.uploader?.isNotEmpty ?? false)
                              ? galleryProvider.uploader ?? ''
                              : (galleryProvider.favNote?.isNotEmpty ?? false)
                                  ? 'Note: ${galleryProvider.favNote ?? ''}'
                                  : '',
                          style: const TextStyle(
                              fontSize: 12, color: CupertinoColors.systemGrey),
                        ),
                        const Spacer(),
                        const SizedBox(height: 6),
                        // 标签
                        if (_ehConfigService.fixedHeightOfListItems)
                          TagWaterfallFlowViewBox(
                            simpleTags: galleryProvider.simpleTags,
                            crossAxisCount: itemController.tagLine,
                          )
                        else
                          TagBox(
                            simpleTags: galleryProvider.simpleTags ?? [],
                          ),
                        const SizedBox(height: 6),
                        const Spacer(),
                        // 评分行
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            // 评分
                            Expanded(
                              child: Obx(() {
                                return _Rating(
                                  rating: itemController.rating,
                                  ratingFallBack: itemController.ratingFallBack,
                                  colorRating: itemController.colorRating,
                                );
                              }),
                            ),
                            // 收藏图标
                            Obx(() {
                              logger.v(
                                  '${itemController.galleryProvider.gid} favCat ${itemController.favCat}');
                              return _FavcatIcon(
                                favCat: itemController.favCat,
                              );
                            }),
                            // 图片数量
                            _Filecont(
                              translated: galleryProvider.translated,
                              filecount: galleryProvider.filecount,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        // 类型和时间
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // 类型
                            _Category(
                              category: galleryProvider.category,
                            ),

                            // 上传时间
                            Expanded(
                                child: _PostTime(
                              postTime: galleryProvider.postTime,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({
    Key? key,
    required this.galleryProviderController,
    this.tabTag,
    this.cardType = false,
  }) : super(key: key);
  final GalleryItemController galleryProviderController;
  final dynamic tabTag;
  final bool cardType;

  @override
  Widget build(BuildContext context) {
    final EhConfigService ehConfigService = Get.find();
    final GalleryProvider _item = galleryProviderController.galleryProvider;

    // 图片高宽比
    final imageRatio = (_item.imgHeight ?? 0) / (_item.imgWidth ?? 1);

    // 计算图片容器宽度
    final double coverImageWidth = Get.context!.isPhone
        ? Get.context!.mediaQueryShortestSide / 3
        : 0.7 * kFixedHeight;

    // 计算图片容器高度
    late double? coverImageHeigth;

    if (_ehConfigService.fixedHeightOfListItems) {
      coverImageHeigth = kFixedHeight;
    } else {
      if ((_item.imgWidth ?? 0) >= coverImageWidth) {
        // 如果实际宽度大于限制的最大宽度[coverImageWidth] 按照比例计算高度
        coverImageHeigth =
            (_item.imgHeight ?? 0) * coverImageWidth / (_item.imgWidth ?? 0);
      } else {
        // 否者返回实际高度
        coverImageHeigth = _item.imgHeight;
      }
    }

    logger.v('iRatio:$imageRatio\n'
        'w:${_item.imgWidth} h:${_item.imgHeight}\n'
        'cW:$coverImageWidth  cH:$coverImageHeigth');

    final containRatio = (coverImageHeigth ?? 0) / coverImageWidth;

    BoxFit _fit = BoxFit.contain;

    // todo
    if (imageRatio < containRatio && containRatio - imageRatio < 0.5) {
      _fit = BoxFit.fitHeight;
    }

    if (imageRatio > containRatio && imageRatio - containRatio < 1.0) {
      _fit = BoxFit.cover;
    }

    loggerSimple.v('imageRatio:$imageRatio  containRatio:$containRatio  $_fit');

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

    Widget coverBackground(BoxFit fit, bool blurringOfCoverBackground) {
      if (_fit == BoxFit.contain && blurringOfCoverBackground) {
        return getImageBlureFittedBox();
      } else {
        return Container(
          color: CupertinoColors.systemGrey5,
        );
      }
    }

    if (!cardType) {
      image = Container(
        child: HeroMode(
          enabled: !isLayoutLarge,
          child: Hero(
            tag: '${_item.gid}_cover_$tabTag',
            child: image,
          ),
        ),
      );

      image = Container(
        decoration: BoxDecoration(boxShadow: [
          //阴影
          BoxShadow(
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey4, Get.context!),
            blurRadius: 10,
          )
        ]),
        child: ClipRRect(
          // 圆角
          borderRadius: BorderRadius.circular(6),
          child: image,
        ),
      );
    } else {
      // 卡片样式
      image = Stack(
        fit: StackFit.passthrough,
        children: [
          Obx(() {
            return coverBackground(
              _fit,
              ehConfigService.blurringOfCoverBackground,
            );
          }),
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

      image = ClipRRect(
        // 圆角
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(kCardRadius),
          bottomLeft: Radius.circular(kCardRadius),
        ),
        // borderRadius: BorderRadius.circular(kCardRadius),
        child: Container(
          child: image,
          height: coverImageHeigth,
          width: coverImageWidth,
        ),
      );
    }

    return image;
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key, required this.galleryItemController})
      : super(key: key);
  final GalleryItemController galleryItemController;

  @override
  Widget build(BuildContext context) {
    final maxLine = 5 - galleryItemController.tagLine;

    return Obx(() => Text(
          galleryItemController.title,
          maxLines: _ehConfigService.fixedHeightOfListItems ? maxLine : 4,
          textAlign: TextAlign.left, // 对齐方式
          overflow: TextOverflow.ellipsis, // 超出部分省略号
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            // color: CupertinoColors.label,
          ),
        ));
  }
}

class _Filecont extends StatelessWidget {
  const _Filecont({Key? key, this.translated, this.filecount})
      : super(key: key);
  final String? translated;
  final String? filecount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            translated ?? '',
            style: const TextStyle(
                fontSize: 12, color: CupertinoColors.systemGrey),
          ),
        ),
        const Icon(
          Icons.panorama,
          size: 13,
          color: CupertinoColors.systemGrey,
        ),
        Container(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            filecount ?? '',
            style: const TextStyle(
                fontSize: 12, color: CupertinoColors.systemGrey),
          ),
        ),
      ],
    );
  }
}

class _FavcatIcon extends StatelessWidget {
  const _FavcatIcon({Key? key, required this.favCat}) : super(key: key);
  final String favCat;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: favCat.isNotEmpty
          ? Container(
              padding: const EdgeInsets.only(bottom: 2, right: 2, left: 2),
              child: Icon(
                FontAwesomeIcons.solidHeart,
                size: 12,
                color: ThemeColors.favColor[favCat],
              ),
            )
          : Container(),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({
    Key? key,
    this.ratingFallBack,
    this.rating,
    this.colorRating,
  }) : super(key: key);
  final double? ratingFallBack;
  final double? rating;
  final String? colorRating;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
          child: StaticRatingBar(
            size: 16.0,
            rate: ratingFallBack ?? 0,
            radiusRatio: 1.5,
            colorLight: ThemeColors.colorRatingMap[colorRating?.trim() ?? 'ir'],
            colorDark: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey3, Get.context!),
          ),
        ),
        // Text(
        //   rating?.toString() ?? '',
        //   style: TextStyle(
        //     fontSize: 11,
        //     color: CupertinoDynamicColor.resolve(
        //         CupertinoColors.systemGrey, Get.context!),
        //   ),
        // ),
      ],
    ).paddingOnly(right: 4);
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
    ).paddingOnly(left: 8);
  }
}

class _Category extends StatelessWidget {
  const _Category({Key? key, required this.category}) : super(key: key);
  final String? category;

  @override
  Widget build(BuildContext context) {
    final Color _colorCategory = CupertinoDynamicColor.resolve(
        ThemeColors.catColor[category ?? 'default'] ??
            CupertinoColors.systemBackground,
        Get.context!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
        color: _colorCategory,
        child: Text(
          category ?? '',
          style: const TextStyle(
            fontSize: 14,
            height: 1,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}

class TagItem extends StatelessWidget {
  const TagItem({
    Key? key,
    this.text,
    this.color,
    this.backgrondColor,
  }) : super(key: key);

  final String? text;
  final Color? color;
  final Color? backgrondColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        // height: 18,
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
        color: backgrondColor ??
            CupertinoDynamicColor.resolve(ThemeColors.tagBackground, context),
        child: Text(
          text ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1,
            fontWeight:
                backgrondColor == null ? FontWeight.w400 : FontWeight.w500,
            color: color ??
                CupertinoDynamicColor.resolve(ThemeColors.tagText, context),
          ),
          strutStyle: const StrutStyle(height: 1),
        ),
      ),
    );
  }
}

/// 传入原始标签和翻译标签
/// 用于设置切换的时候变更
class TagBox extends StatelessWidget {
  const TagBox({Key? key, this.simpleTags}) : super(key: key);

  final List<SimpleTag>? simpleTags;

  @override
  Widget build(BuildContext context) {
    final EhConfigService _ehConfigService = Get.find();

    return Obx(() {
      List<SimpleTag>? _simpleTags =
          getLimitSimpleTags(simpleTags, _ehConfigService.listViewTagLimit);

      if (_simpleTags == null || (_simpleTags.isEmpty ?? true)) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
        child: Wrap(
          spacing: 4, //主轴上子控件的间距
          runSpacing: 4, //交叉轴上子控件之间的间距
          children: List<Widget>.from(_simpleTags.map((SimpleTag _simpleTag) {
            final String? _text = _ehConfigService.isTagTranslat
                ? _simpleTag.translat
                : _simpleTag.text;
            return TagItem(
              text: _text,
              color: ColorsUtil.getTagColor(_simpleTag.color),
              backgrondColor: ColorsUtil.getTagColor(_simpleTag.backgrondColor),
            );
          }).toList()), //要显示的子控件集合
        ),
      );
    });
  }
}

/// 封面图片Widget
class CoverImg extends StatelessWidget {
  const CoverImg({
    Key? key,
    required this.imgUrl,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  final String imgUrl;
  final double? height;
  final double? width;

  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final EhConfigService ehConfigService = Get.find();

    Widget image() {
      if (imgUrl.isNotEmpty) {
        return EhNetworkImage(
          placeholder: (_, __) {
            return Container(
              alignment: Alignment.center,
              child: const CupertinoActivityIndicator(),
            );
          },
          width: width,
          height: height,
          // httpHeaders: _httpHeaders,
          imageUrl: imgUrl.dfUrl,
          fit: fit, //
        );
      } else {
        return Container();
      }
    }

    return Obx(
      () => BlurImage(
        child: image(),
        isBlur: ehConfigService.isGalleryImgBlur.value,
      ),
    );
  }
}
