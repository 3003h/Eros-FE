import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/models/gallery_provider.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_state.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:fehviewer/route/routes.dart';
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
    final TextStyle _hearTextStyle = TextStyle(
      fontSize: 13,
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
    );

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
                            ),
                            // 上传用户
                            GalleryUploader(
                                uploader:
                                    _pageState.galleryProvider?.uploader ?? ''),
                            const SizedBox(
                              height: 12,
                            ),
                            // Expanded(
                            //     child: GalleryInfoGridView(
                            //         pageController: _controller)),
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
  static const paddingRight = 6.0;

  @override
  Widget build(BuildContext context) {
    final TextStyle _hearTextStyle = TextStyle(
      fontSize: 13,
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
    );

    Widget languageWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pageState.galleryProvider?.language != null)
              Icon(
                FontAwesomeIcons.language,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel, context),
                size: 12,
              ).paddingOnly(right: paddingRight),
            Text(
              _pageState.galleryProvider?.language ?? '',
              style: _hearTextStyle,
            ),
          ],
        );

    Widget imageCountWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pageState.galleryProvider?.filecount != null)
              Icon(
                FontAwesomeIcons.solidImages,
                size: 12,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel, context),
              ).paddingOnly(right: paddingRight),
            Text(
              _pageState.galleryProvider?.filecount ?? '',
              style: _hearTextStyle,
            ),
          ],
        );
    Widget fileSizeWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pageState.galleryProvider?.filesizeText != null)
              Icon(
                FontAwesomeIcons.fileArrowDown,
                size: 12,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel, context),
              ).paddingOnly(right: paddingRight),
            Text(
              _pageState.galleryProvider?.filesizeText ?? '',
              style: _hearTextStyle,
            ),
          ],
        );
    Widget favCountWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pageState.galleryProvider?.favoritedCount != null)
              Icon(
                FontAwesomeIcons.solidHeart,
                // color: CupertinoColors.systemRed,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel, context),
                size: 12,
              ).paddingOnly(right: paddingRight),
            Text(_pageState.galleryProvider?.favoritedCount ?? '',
                style: _hearTextStyle),
          ],
        );
    Widget rateCountWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pageState.galleryProvider?.ratingCount != null)
              Icon(
                FontAwesomeIcons.solidStar,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel, context),
                size: 12,
              ).paddingOnly(right: paddingRight),
            Text(_pageState.galleryProvider?.ratingCount ?? '',
                style: _hearTextStyle),
          ],
        );
    Widget potTimeWidget() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pageState.galleryProvider?.postTime != null)
              Icon(
                FontAwesomeIcons.solidClock,
                size: 12,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel, context),
              ).paddingOnly(right: paddingRight),
            Text(
              _pageState.galleryProvider?.postTime ?? '',
              style: _hearTextStyle,
            ),
          ],
        );

    Widget infoWidget() => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SingleChildScrollView(
            child: Container(
              // color: CupertinoDynamicColor.resolve(
              //     CupertinoColors.secondarySystemBackground, context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 4,
                    height: 48,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.secondaryLabel, context),
                  ).paddingOnly(right: 8),
                  Expanded(
                    child: GridView(
                      padding: const EdgeInsets.all(0),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        mainAxisExtent: 20,
                        maxCrossAxisExtent: 160,
                      ),
                      shrinkWrap: true,
                      children: [
                        languageWidget(),
                        fileSizeWidget(),
                        imageCountWidget(),
                        favCountWidget(),
                        rateCountWidget(),
                        potTimeWidget(),
                      ],
                    ),
                  ),
                ],
              ),
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

class GalleryInfoGridView extends StatelessWidget {
  const GalleryInfoGridView({Key? key, required this.pageController})
      : super(key: key);
  final GalleryPageController pageController;

  GalleryPageState get _pageState => pageController.gState;
  static const paddingRight = 6.0;

  @override
  Widget build(BuildContext context) {
    final TextStyle _hearTextStyle = TextStyle(
      fontSize: 13,
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
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
              _pageState.galleryProvider?.language ?? '',
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
              _pageState.galleryProvider?.filecount ?? '',
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
              _pageState.galleryProvider?.filesizeText ?? '',
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
            Text(_pageState.galleryProvider?.favoritedCount ?? '',
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
            Text(_pageState.galleryProvider?.ratingCount ?? '',
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
              _pageState.galleryProvider?.postTime ?? '',
              style: _hearTextStyle,
            ),
          ],
        );

    Widget infoWidget() => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            // color: CupertinoDynamicColor.resolve(
            //     CupertinoColors.secondarySystemBackground, context),
            child: GridView(
              padding: const EdgeInsets.all(0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisExtent: 20,
                maxCrossAxisExtent: 240,
              ),
              shrinkWrap: true,
              children: [
                languageWidget(),
                fileSizeWidget(),
                imageCountWidget(),
                favCountWidget(),
                rateCountWidget(),
                potTimeWidget(),
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
      child: infoWidget(),
    );
  }
}
