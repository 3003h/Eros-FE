import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/view/gallery_favcat.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'const.dart';
import 'gallery_widget.dart';

class GalleryHeader extends StatelessWidget {
  const GalleryHeader({
    Key? key,
    required this.initGalleryItem,
    this.tabTag,
  }) : super(key: key);

  final GalleryItem initGalleryItem;
  final Object? tabTag;

  @override
  Widget build(BuildContext context) {
    final TextStyle _hearTextStyle = TextStyle(
      fontSize: 13,
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
    );

    return Container(
      padding: const EdgeInsets.all(kPadding),
      child: Column(
        children: <Widget>[
          Container(
            height: kHeaderHeight,
            child: Row(
              children: <Widget>[
                // 封面
                CoverImage(
                  imageUrl: initGalleryItem.imgUrl!,
                  heroTag: '${initGalleryItem.gid}_cover_$tabTag',
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 标题
                      const GalleryTitle(),
                      // 上传用户
                      GalleryUploader(uploader: initGalleryItem.uploader ?? ''),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          // 阅读按钮
                          ReadButton(gid: initGalleryItem.gid ?? ''),
                          const Spacer(),
                          // 收藏按钮
                          const GalleryFavButton(),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          GalleryInfoBar(hearTextStyle: _hearTextStyle),
        ],
      ),
    );
  }
}

class GalleryInfoBar extends StatefulWidget {
  const GalleryInfoBar({
    Key? key,
    required TextStyle hearTextStyle,
  })  : _hearTextStyle = hearTextStyle,
        super(key: key);

  final TextStyle _hearTextStyle;

  @override
  _GalleryInfoBarState createState() => _GalleryInfoBarState();
}

class _GalleryInfoBarState extends State<GalleryInfoBar> {
  Color? _itemColor;

  void _updateNormalColor() {
    setState(() {
      _itemColor = null;
    });
  }

  void _updatePressedColor() {
    setState(() {
      _itemColor = CupertinoDynamicColor.resolve(
          CupertinoColors.systemGrey5, Get.context!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GalleryPageController>(
        // init: GalleryPageController(),
        tag: pageCtrlDepth,
        id: GetIds.PAGE_VIEW_HEADER,
        builder: (GalleryPageController controller) {
          // logger.d(
          //     'GalleryPageController GetBuilder GetIds.PAGE_VIEW_HEADER');
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Get.toNamed(EHRoutes.galleryInfo);
            },
            onTapDown: (_) {
              _updatePressedColor();
            },
            onTapUp: (_) {
              Future<void>.delayed(const Duration(milliseconds: 100), () {
                _updateNormalColor();
              });
            },
            onTapCancel: () {
              Future<void>.delayed(const Duration(milliseconds: 100), () {
                _updateNormalColor();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  color: _itemColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          // ignore: prefer_const_literals_to_create_immutables
                          children: <Widget>[
                            // 评分
                            GalleryRating(
                              rating: controller.galleryItem.rating ?? 0,
                              ratingFB:
                                  controller.galleryItem.ratingFallBack ?? 0,
                              color: ThemeColors.colorRatingMap[
                                  controller.galleryItem.colorRating?.trim() ??
                                      'ir']!,
                            ),
                            // 评分人次
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child:
                                  Text(controller.galleryItem.ratingCount ?? '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: CupertinoDynamicColor.resolve(
                                            CupertinoColors.secondaryLabel,
                                            context),
                                      )),
                            ),
                            const Spacer(),
                            // 类型
                            GalleryCategory(
                                category:
                                    controller.galleryItem.category ?? ''),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.language,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, context),
                            size: 13,
                          ).paddingOnly(right: 8),
                          Text(
                            controller.galleryItem.language ?? '',
                            style: widget._hearTextStyle,
                          ),
                          const Spacer(),
                          Icon(
                            FontAwesomeIcons.images,
                            size: 13,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, context),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            controller.galleryItem.filecount ?? '',
                            style: widget._hearTextStyle,
                          ),
                          const Spacer(),
                          Text(
                            controller.galleryItem.filesizeText ?? '',
                            style: widget._hearTextStyle,
                          ),
                        ],
                      ).marginSymmetric(vertical: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // const Text('❤️', style: TextStyle(fontSize: 13)),
                          const Icon(
                            FontAwesomeIcons.solidHeart,
                            color: CupertinoColors.systemRed,
                            size: 13,
                          ),
                          GetBuilder(
                              // init: GalleryPageController(),
                              tag: pageCtrlDepth,
                              id: GetIds.PAGE_VIEW_HEADER,
                              builder: (GalleryPageController controller) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                      controller.galleryItem.favoritedCount ??
                                          '',
                                      style: widget._hearTextStyle),
                                );
                              }),
                          const Spacer(),
                          Text(
                            controller.galleryItem.postTime ?? '',
                            style: widget._hearTextStyle,
                          ),
                        ],
                      ),
                      // const Text('...'),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
