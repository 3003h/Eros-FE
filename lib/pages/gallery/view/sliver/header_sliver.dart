import 'dart:math';

import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_state.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../const.dart';
import '../gallery_favcat.dart';

class GalleryHeaderSliver extends StatelessWidget {
  const GalleryHeaderSliver({
    Key? key,
    required this.initGalleryProvider,
    this.tabTag,
  }) : super(key: key);

  final GalleryProvider initGalleryProvider;
  final Object? tabTag;

  GalleryPageController get _controller =>
      Get.find<GalleryPageController>(tag: pageCtrlTag);

  GalleryPageState get _pageState => _controller.gState;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(kPadding),
      sliver: MultiSliver(
        children: [
          SizedBox(
            height: kHeaderHeight,
            child: Row(
              children: [
                HeroMode(
                  enabled: _pageState.hideNavigationBtn || isLayoutLarge,
                  child: CoverImage(
                    imageUrl: initGalleryProvider.imgUrl!,
                    heroTag: '${initGalleryProvider.gid}_cover_$tabTag',
                  ),
                ),
                Expanded(
                  child: GetBuilder<GalleryPageController>(
                      assignId: true,
                      id: GetIds.PAGE_VIEW_HEADER,
                      tag: pageCtrlTag,
                      builder: (logic) {
                        final _pageState = logic.gState;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 标题
                            GalleryTitle(
                              title: _pageState.title,
                              // title: 'ceui',
                              // title:
                              //     '测试测试测试测试测试测试测试测试测试测试测试测试测试测试试测试测试测试测测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试',
                            ),
                            // 上传用户
                            GalleryUploader(
                                uploader:
                                    _pageState.galleryProvider?.uploader ?? ''),
                            const SizedBox(
                              height: 8,
                            ),

                            // Expanded(
                            //     child: GalleryInfoView(
                            //         pageController: _controller)),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Spacer(),
                                // 收藏按钮
                                const GalleryFavButton(),
                                // 阅读按钮
                                ReadButton(gid: initGalleryProvider.gid ?? '')
                                    .paddingOnly(right: 6),
                              ],
                            ).marginOnly(top: 10),
                          ],
                        );
                      }),
                ),
              ],
            ),
          ),
          // GalleryInfoBar(hearTextStyle: _hearTextStyle),
          GalleryInfoBarSliver(pageController: _controller),
        ],
      ),
    );
  }
}

class GalleryInfoBarSliver extends StatelessWidget {
  const GalleryInfoBarSliver({Key? key, required this.pageController})
      : super(key: key);
  final GalleryPageController pageController;

  GalleryPageState get _pageState => pageController.gState;
  static const paddingRight = 5.0;

  @override
  Widget build(BuildContext context) {
    final TextStyle _hearTextStyle = TextStyle(
      fontSize: 13,
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
    );

    Widget languageWidget() => _InfoWidget(
          text: _pageState.galleryProvider?.language,
          icon: FontAwesomeIcons.language,
        );

    Widget imageCountWidget() => _InfoWidget(
          text: _pageState.galleryProvider?.filecount,
          icon: FontAwesomeIcons.solidImages,
        );
    Widget fileSizeWidget() => _InfoWidget(
          text: _pageState.galleryProvider?.filesizeText,
          icon: FontAwesomeIcons.fileArrowDown,
        );
    Widget favCountWidget() => _InfoWidget(
          text: _pageState.galleryProvider?.favoritedCount,
          icon: FontAwesomeIcons.solidHeart,
        );
    Widget rateCountWidget() => _InfoWidget(
          text: _pageState.galleryProvider?.ratingCount,
          icon: FontAwesomeIcons.solidStar,
        );
    Widget potTimeWidget() => _InfoWidget(
          text: _pageState.galleryProvider?.postTime,
          icon: FontAwesomeIcons.solidClock,
        );

    // final postTimeTextSize =
    //     getTextSize(_pageState.galleryProvider?.postTime ?? '', _hearTextStyle);
    final postTimeTextSize = getTextSize('0000-00-00 00:00', _hearTextStyle);
    final _maxCrossAxisExtent = max(160.0, postTimeTextSize.width + 60.0);
    logger.v('_maxCrossAxisExtent $_maxCrossAxisExtent  $postTimeTextSize');

    Widget infoWidget() => Container(
          // constraints: const BoxConstraints(maxHeight: 50),
          margin: const EdgeInsets.only(top: 8),
          child: Container(
            // color: CupertinoDynamicColor.resolve(
            //     CupertinoColors.secondarySystemBackground, context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 4,
                    height: 48,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.secondaryLabel, context),
                  ),
                ).paddingOnly(right: 6),
                Expanded(
                  child: GridView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(0),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisExtent: 20,
                      maxCrossAxisExtent: _maxCrossAxisExtent,
                    ),
                    shrinkWrap: true,
                    children: [
                      languageWidget(),
                      imageCountWidget(),
                      fileSizeWidget(),
                      favCountWidget(),
                      rateCountWidget(),
                      potTimeWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.toNamed(
          EHRoutes.galleryInfo,
          id: isLayoutLarge ? 2 : null,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            // color: CupertinoDynamicColor.resolve(
            //     CupertinoColors.systemGrey5, Get.context!),
            child: GetBuilder<GalleryPageController>(
              assignId: true,
              tag: pageCtrlTag,
              id: GetIds.PAGE_VIEW_HEADER,
              builder: (logic) {
                final GalleryPageState _pageState = logic.gState;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 8.0, right: 6),
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
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 4),
                          //   child: Text(
                          //       _pageState.galleryProvider?.ratingCount ?? '',
                          //       style: TextStyle(
                          //         fontSize: 10,
                          //         color: CupertinoDynamicColor.resolve(
                          //             CupertinoColors.secondaryLabel, context),
                          //       )),
                          // ),
                          const Spacer(),
                          // 类型
                          GalleryCategory(
                              category:
                                  _pageState.galleryProvider?.category ?? ''),
                        ],
                      ),
                    ),
                    infoWidget(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoWidget extends StatelessWidget {
  const _InfoWidget({
    Key? key,
    this.icon,
    this.text,
  }) : super(key: key);

  final IconData? icon;
  final String? text;

  static const paddingRight = 5.0;

  @override
  Widget build(BuildContext context) {
    final TextStyle _hearTextStyle = TextStyle(
      fontSize: 13,
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.secondaryLabel, context),
          size: 12,
        ).paddingOnly(right: paddingRight),
        Text(
          text ?? '...',
          style: _hearTextStyle,
        ),
      ],
    );
  }
}

class GalleryInfoView extends StatelessWidget {
  const GalleryInfoView({Key? key, required this.pageController})
      : super(key: key);
  final GalleryPageController pageController;

  GalleryPageState get _pageState => pageController.gState;
  static const paddingRight = 6.0;

  @override
  Widget build(BuildContext context) {
    final TextStyle _hearTextStyle = TextStyle(
      fontSize: 12,
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondaryLabel, context),
    );

    Widget languageWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.language,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel, context),
              size: 12,
            ).paddingOnly(right: paddingRight),
            Text(
              _pageState.galleryProvider?.language ?? '...',
              style: _hearTextStyle,
            ),
          ],
        );

    Widget imageCountWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.solidImages,
              size: 12,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel, context),
            ).paddingOnly(right: paddingRight),
            Text(
              _pageState.galleryProvider?.filecount ?? '...',
              style: _hearTextStyle,
            ),
          ],
        );
    Widget fileSizeWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.fileArrowDown,
              size: 12,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel, context),
            ).paddingOnly(right: paddingRight),
            Text(
              _pageState.galleryProvider?.filesizeText ?? '...',
              style: _hearTextStyle,
            ),
          ],
        );
    Widget favCountWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.solidHeart,
              // color: CupertinoColors.systemRed,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel, context),
              size: 12,
            ).paddingOnly(right: paddingRight),
            Text(_pageState.galleryProvider?.favoritedCount ?? '...',
                style: _hearTextStyle),
          ],
        );
    Widget rateCountWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.solidStar,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel, context),
              size: 12,
            ).paddingOnly(right: paddingRight),
            Text(_pageState.galleryProvider?.ratingCount ?? '...',
                style: _hearTextStyle),
          ],
        );
    Widget potTimeWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.solidClock,
              size: 12,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel, context),
            ).paddingOnly(right: paddingRight),
            Text(
              _pageState.galleryProvider?.postTime ?? '...',
              style: _hearTextStyle,
              maxLines: 2,
            ),
          ],
        );

    Widget infoWidget() => Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                width: 2,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel, context),
              ),
            ).paddingOnly(right: 6),
            Expanded(
              child: ListView(
                // mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.start,
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                children: [
                  languageWidget(),
                  favCountWidget(),
                  // rateCountWidget(),
                  imageCountWidget(),
                  fileSizeWidget(),
                  potTimeWidget(),
                ],
              ),
            ),
          ],
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.toNamed(
          EHRoutes.galleryInfo,
          id: isLayoutLarge ? 2 : null,
        );
      },
      child: infoWidget(),
    );
  }
}
