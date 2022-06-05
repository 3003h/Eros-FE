import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/view/archiver_dialog.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:fehviewer/pages/gallery/view/preview.dart';
import 'package:fehviewer/pages/gallery/view/rate_dialog.dart';
import 'package:fehviewer/pages/gallery/view/torrent_dialog.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../common/controller/download_controller.dart';
import '../controller/gallery_page_state.dart';
import 'const.dart';
import 'header.dart';

// 画廊内容
class GalleryDetail extends StatelessWidget {
  const GalleryDetail({
    Key? key,
    this.tabTag,
    required this.controller,
  }) : super(key: key);

  final dynamic tabTag;
  final GalleryPageController controller;

  GalleryPageController get _controller => Get.find(tag: pageCtrlTag);

  @override
  Widget build(BuildContext context) {
    return _controller.gState.fromUrl
        ? _DetailFromUrl()
        : _DetailFromItem(
            tabTag: tabTag,
            controller: _controller,
          );
  }
}

class _DetailFromUrl extends StatelessWidget {
  final GalleryPageController _controller = Get.find(tag: pageCtrlTag);

  @override
  Widget build(BuildContext context) {
    return _controller.obx(
      (GalleryProvider? state) {
        return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              if (state != null)
                GalleryHeader(
                  initGalleryProvider: state,
                  tabTag: '',
                ),
              if (state != null)
                DetailWidget(
                  galleryProvider: state,
                  pageController: _controller,
                ),
            ],
          ),
        );
      },
      onLoading: SliverFillRemaining(
        child: Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            child: GalleryErrorPage(
              onTap: _controller.handOnRefreshAfterErr,
            ),
          ),
        );
      },
    );
  }
}

class DetailWidget extends StatelessWidget {
  const DetailWidget({
    Key? key,
    required this.galleryProvider,
    required this.pageController,
  }) : super(key: key);

  final GalleryProvider galleryProvider;
  final GalleryPageController pageController;

  GalleryPageState get pageStat => pageController.gState;

  // GalleryPageController get _controller => Get.find(tag: pageCtrlDepth);

  @override
  Widget build(BuildContext context) {
    final List<Widget> _btns = <Widget>[
      // 进行评分
      Expanded(
        child: Obx(() => TextBtn(
              pageStat.isRatinged
                  ? FontAwesomeIcons.solidStar
                  : FontAwesomeIcons.star,
              title: L10n.of(context).p_Rate,
              onTap: galleryProvider.apiuid?.isNotEmpty ?? false
                  ? () {
                      showRateDialog(context);
                    }
                  : null,
            )),
      ),
      // 画廊下载
      Expanded(
        child: Obx(() {
          final defIcon = TextBtn(
            FontAwesomeIcons.solidCircleDown,
            title: L10n.of(context).p_Download,
            onTap: () => pageController.downloadGallery(context),
          );

          final toDownloadPage = () =>
              Get.toNamed(EHRoutes.download, id: isLayoutLarge ? 2 : null);

          final Map<TaskStatus, Widget> iconMap = {
            TaskStatus.complete: TextBtn(
              FontAwesomeIcons.solidCircleCheck,
              title: L10n.of(context).downloaded,
              onTap: toDownloadPage,
              onLongPress: toDownloadPage,
            ),
            TaskStatus.running: TextBtn(
              FontAwesomeIcons.solidCirclePlay,
              title: L10n.of(context).downloading,
              onTap: toDownloadPage,
              onLongPress: toDownloadPage,
            ),
            TaskStatus.paused: TextBtn(
              FontAwesomeIcons.solidCirclePause,
              title: L10n.of(context).paused,
              onTap: toDownloadPage,
              onLongPress: toDownloadPage,
            ),
          };

          return iconMap[pageStat.downloadState] ?? defIcon;
        }),
      ),
      // 种子下载
      Expanded(
        child: TextBtn(
          FontAwesomeIcons.magnet,
          title:
              '${L10n.of(context).p_Torrent}(${galleryProvider.torrentcount ?? 0})',
          onTap: galleryProvider.torrentcount != '0'
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
          FontAwesomeIcons.solidFileZipper,
          title: L10n.of(Get.context!).p_Archiver,
          onTap: () async {
            showArchiverDialog();
          },
        ),
      ),
      // 相似画廊
      Expanded(
        child: TextBtn(
          FontAwesomeIcons.solidImages,
          title: L10n.of(context).p_Similar,
          onTap: () {
            final String title = (galleryProvider.englishTitle ?? '')
                .replaceAll(RegExp(r'(\[.*?\]|\(.*?\))|{.*?}'), '')
                .trim()
                .split('\|')
                .first;
            logger.d('处理后标题 "$title"');
            NavigatorUtil.goSearchPageWithText(simpleSearch: '"$title"');
            // NavigatorUtil.goGalleryListBySearch(simpleSearch: title);
          },
        ),
      ),
    ];

    final Widget columnWhithSpacer = Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: _btns,
        ).paddingSymmetric(vertical: 4),
        const SizedBox(height: 10),
        // 标签
        Row(children: [_getminiTitle(L10n.of(context).tags)]),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TagBox(listTagGroup: galleryProvider.tagGroup ?? []),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _getminiTitle(L10n.of(context).gallery_comments),
            const Spacer(),
            GestureDetector(
              child: Text(
                L10n.of(context).all_comment,
                style: TextStyle(
                    fontSize: 14,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.link, context)),
              ),
              onTap: () => Get.toNamed(
                EHRoutes.galleryComment,
                id: isLayoutLarge ? 2 : null,
              ),
            ).marginOnly(right: 4),
          ],
        ),
        GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () => Get.toNamed(
            EHRoutes.galleryComment,
            id: isLayoutLarge ? 2 : null,
          ),
          child: const TopComment(showBtn: false),
        ),
        const SizedBox(height: 20),
        // 缩略图
        PreviewGrid(
          images: pageStat.firstPageImage,
          gid: galleryProvider.gid ?? '',
        ),
        MorePreviewButton(hasMorePreview: pageStat.hasMoreImage),
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

  final dynamic tabTag;
  final GalleryPageController controller;

  @override
  Widget build(BuildContext context) {
    final GalleryProvider? galleryProvider = controller.gState.galleryProvider;

    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          if (galleryProvider != null)
            GalleryHeader(
              initGalleryProvider: galleryProvider,
              tabTag: tabTag,
            ),
          controller.obx(
            (GalleryProvider? state) {
              return state != null
                  ? DetailWidget(
                      galleryProvider: state,
                      pageController: controller,
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
              logger.e('$err ');
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
                child: GalleryErrorPage(
                  // onTap: controller.handOnRefreshAfterErr,
                  error: err,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
