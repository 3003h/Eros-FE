import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/view/archiver_dialog.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:fehviewer/pages/gallery/view/rate_dialog.dart';
import 'package:fehviewer/pages/gallery/view/torrent_dialog.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'const.dart';
import 'header.dart';

// 画廊内容
class GalleryDetail extends StatelessWidget {
  const GalleryDetail({
    Key? key,
    this.tabTag,
    required this.controller,
  }) : super(key: key);

  final String? tabTag;
  final GalleryPageController controller;

  GalleryPageController get _controller => Get.find(tag: pageCtrlDepth);

  @override
  Widget build(BuildContext context) {
    return _controller.fromUrl
        ? _DetailFromUrl()
        : _DetailFromItem(
            tabTag: tabTag,
            controller: _controller,
          );
  }
}

class _DetailFromUrl extends StatelessWidget {
  final GalleryPageController _controller = Get.find(tag: pageCtrlDepth);

  @override
  Widget build(BuildContext context) {
    return _controller.obx(
      (GalleryItem? state) {
        return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              if (state != null)
                GalleryHeader(
                  initGalleryItem: state,
                  tabTag: '',
                ),
              // Divider(
              //   height: 0.5,
              //   color: CupertinoDynamicColor.resolve(
              //       CupertinoColors.systemGrey4, context),
              // ),
              if (state != null)
                _DetailWidget(
                  state: state,
                  controller: _controller,
                ),
            ],
          ),
        );
      },
      onLoading: SliverFillRemaining(
        child: Container(
          // height: Get.size.height - 200,
          // height: 200,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 50),
          child: const CupertinoActivityIndicator(
            radius: 14.0,
          ),
        ),
      ),
      onError: (String? err) {
        logger.e(' $err');
        return SliverFillRemaining(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 50, top: 50),
            child: GalleryErrorPage(
              onTap: _controller.handOnRefreshAfterErr,
            ),
          ),
        );
      },
    );
  }
}

class _DetailWidget extends StatelessWidget {
  const _DetailWidget({
    Key? key,
    required this.state,
    required this.controller,
  }) : super(key: key);

  final GalleryItem state;
  final GalleryPageController controller;

  // GalleryPageController get _controller => Get.find(tag: pageCtrlDepth);

  @override
  Widget build(BuildContext context) {
    final List<Widget> _btns = <Widget>[
      // 进行评分
      Expanded(
        child: Obx(() => TextBtn(
              controller.isRatinged
                  ? FontAwesomeIcons.solidStar
                  : FontAwesomeIcons.star,
              title: S.of(context).p_Rate,
              onTap: state.apiuid?.isNotEmpty ?? false
                  ? () {
                      showRateDialog(context);
                    }
                  : null,
            )),
      ),
      // 画廊下载
      Expanded(
        child: TextBtn(
          FontAwesomeIcons.solidArrowAltCircleDown,
          title: S.of(context).p_Download,
          // onTap: Get.find<EhConfigService>().debugMode
          //     ? controller.downloadGallery
          //     : null,
          onTap: controller.downloadGallery,
        ),
      ),
      // 种子下载
      Expanded(
        child: TextBtn(
          FontAwesomeIcons.magnet,
          title: '${S.of(context).p_Torrent}(${state.torrentcount ?? 0})',
          onTap: state.torrentcount != '0'
              ? () async {
                  showTorrentDialog();
                  // showTorrentModal();
                }
              : null,
        ),
      ),
      // archiver
      Expanded(
        child: TextBtn(
          FontAwesomeIcons.solidFileArchive,
          title: S.of(Get.context!).p_Archiver,
          onTap: () async {
            showArchiverDialog();
          },
        ),
      ),
      // 相似画廊
      Expanded(
        child: TextBtn(
          FontAwesomeIcons.solidImages,
          title: S.of(context).p_Similar,
          onTap: () {
            final String title = (state.englishTitle ?? '')
                .replaceAll(RegExp(r'(\[.*?\]|\(.*?\))|{.*?}'), '')
                .trim()
                .split('\|')
                .first;
            logger.d('处理后标题 "$title"');
            NavigatorUtil.goGalleryListBySearch(simpleSearch: '"$title"');
            // NavigatorUtil.goGalleryListBySearch(simpleSearch: title);
          },
        ),
      ),
    ];
    final Widget columnWhithDivider = Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: _btns,
        ),
        Divider(
          height: 0.5,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey4, context),
        ),
        // 标签
        TagBox(listTagGroup: state.tagGroup!),
        const TopComment(),
        Container(
          margin: const EdgeInsets.only(top: 4),
          height: 0.5,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey4, context),
        ),
        // 缩略图
        PreviewGrid(
          images: controller.firstPageImage,
          gid: state.gid ?? '',
        ),
        MorePreviewButton(hasMorePreview: controller.hasMoreImage),
      ],
    );

    final Widget columnWhithSpacer = Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: _btns,
        ).paddingSymmetric(vertical: 4),
        const SizedBox(height: 10),
        // 标签
        Row(children: [_getminiTitle(S.of(context).tags)]),
        TagBox(listTagGroup: state.tagGroup!).paddingSymmetric(vertical: 4),
        const SizedBox(height: 20),
        Row(
          children: [
            _getminiTitle(S.of(context).gallery_comments),
            const Spacer(),
            GestureDetector(
              child: Text(
                S.of(context).all_comment,
                style: TextStyle(
                    fontSize: 14,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.link, context)),
              ),
              onTap: () => Get.toNamed(EHRoutes.galleryComment),
            ).marginOnly(right: 4),
          ],
        ),
        GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () => Get.toNamed(EHRoutes.galleryComment),
          child: const TopComment(showBtn: false),
        ),
        const SizedBox(height: 20),
        PreviewGrid(
          images: controller.firstPageImage,
          gid: state.gid ?? '',
        ),
        MorePreviewButton(hasMorePreview: controller.hasMoreImage),
      ],
    ).paddingSymmetric(horizontal: kPadding);

    return columnWhithSpacer;
  }

  Widget _getminiTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ).paddingSymmetric(horizontal: 2);
  }
}

class _DetailFromItem extends StatelessWidget {
  const _DetailFromItem({Key? key, this.tabTag, required this.controller})
      : super(key: key);

  final String? tabTag;
  final GalleryPageController controller;

  // GalleryPageController get _controller => Get.find(tag: pageCtrlDepth);

  @override
  Widget build(BuildContext context) {
    final GalleryItem galleryItem = controller.galleryItem;

    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          GalleryHeader(
            initGalleryItem: galleryItem,
            tabTag: tabTag,
          ),
          // Divider(
          //   height: 0.5,
          //   color: CupertinoDynamicColor.resolve(
          //       CupertinoColors.systemGrey4, context),
          // ),
          controller.obx(
            (GalleryItem? state) {
              return state != null
                  ? _DetailWidget(
                      state: state,
                      controller: controller,
                    )
                  : const SizedBox.shrink();
            },
            onLoading: () {
              return Container(
                // height: Get.size.height - _top * 3 - kHeaderHeight,
                height: 200,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 50),
                child: const CupertinoActivityIndicator(
                  radius: 14.0,
                ),
              );
            }(),
            onError: (err) {
              logger.e(' $err');
              return Container(
                padding: const EdgeInsets.only(bottom: 50, top: 50),
                child: GalleryErrorPage(
                  onTap: controller.handOnRefreshAfterErr,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
