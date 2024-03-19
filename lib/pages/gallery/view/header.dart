import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/const/theme_colors.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/gallery/controller/gallery_page_controller.dart';
import 'package:eros_fe/pages/gallery/view/gallery_favcat.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../controller/gallery_page_state.dart';
import 'const.dart';
import 'gallery_widget.dart';

class GalleryHeader extends StatelessWidget {
  GalleryHeader({
    Key? key,
    required this.initGalleryProvider,
    this.tabTag,
  }) : super(key: key);

  final GalleryProvider initGalleryProvider;
  final Object? tabTag;

  final _controller = Get.find<GalleryPageController>(tag: pageCtrlTag);

  GalleryPageState get _pageState => _controller.gState;

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
                Obx(() {
                  return HeroMode(
                    enabled: _pageState.hideNavigationBtn || isLayoutLarge,
                    child: CoverImage(
                      imageUrl: initGalleryProvider.imgUrl!,
                      heroTag: '${initGalleryProvider.gid}_cover_$tabTag',
                    ),
                  );
                }),
                // EhCachedNetworkImage(imageUrl: initGalleryProvider.imgUrl!),
                Expanded(
                  child: GetBuilder<GalleryPageController>(
                    assignId: true,
                    id: GetIds.PAGE_VIEW_HEADER,
                    tag: pageCtrlTag,
                    builder: (logic) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // 标题
                          GalleryTitle(
                            title: logic.gState.mainTitle,
                          ),
                          // 上传用户
                          GalleryUploader(
                              uploader:
                                  logic.gState.galleryProvider?.uploader ?? ''),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              // 阅读按钮
                              ReadButton(gid: initGalleryProvider.gid ?? ''),
                              const Spacer(),
                              // 收藏按钮
                              const GalleryFavButton(),
                            ],
                          )
                        ],
                      );
                    },
                  ),
                ),
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
        tag: pageCtrlTag,
        id: GetIds.PAGE_VIEW_HEADER,
        builder: (GalleryPageController controller) {
          final GalleryPageState _pageState = controller.gState;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Get.toNamed(
                EHRoutes.galleryInfo,
                id: isLayoutLarge ? 2 : null,
              );
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
              child: Container(
                decoration: BoxDecoration(
                  color: _itemColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                            rating: _pageState.galleryProvider?.rating ?? 0,
                            ratingFB:
                                _pageState.galleryProvider?.ratingFallBack ?? 0,
                            color: ThemeColors.colorRatingMap[_pageState
                                    .galleryProvider?.colorRating
                                    ?.trim() ??
                                'ir'],
                          ),
                          // 评分人次
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                                _pageState.galleryProvider?.ratingCount ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: CupertinoDynamicColor.resolve(
                                      CupertinoColors.secondaryLabel, context),
                                )),
                          ),
                          const Spacer(),
                          // 类型
                          GalleryCategory(
                              category:
                                  _pageState.galleryProvider?.category ?? ''),
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
                          _pageState.galleryProvider?.language ?? '',
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
                          _pageState.galleryProvider?.filecount ?? '',
                          style: widget._hearTextStyle,
                        ),
                        const Spacer(),
                        Text(
                          _pageState.galleryProvider?.filesizeText ?? '',
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
                            tag: pageCtrlTag,
                            id: GetIds.PAGE_VIEW_HEADER,
                            builder: (GalleryPageController controller) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                    controller.gState.galleryProvider
                                            ?.favoritedCount ??
                                        '',
                                    style: widget._hearTextStyle),
                              );
                            }),
                        const Spacer(),
                        Text(
                          _pageState.galleryProvider?.postTime ?? '',
                          style: widget._hearTextStyle,
                        ),
                      ],
                    ),
                    // const Text('...'),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
