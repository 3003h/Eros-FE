import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_state.dart';
import 'package:fehviewer/pages/gallery/view/archiver_dialog.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:fehviewer/pages/gallery/view/rate_dialog.dart';
import 'package:fehviewer/pages/gallery/view/torrent_dialog.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../const.dart';

class GalleryAtions extends StatelessWidget {
  const GalleryAtions({
    Key? key,
    required this.galleryProvider,
    required this.pageController,
  }) : super(key: key);

  final GalleryProvider galleryProvider;
  final GalleryPageController pageController;

  GalleryPageState get pageStat => pageController.gState;

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
          },
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.only(top: 4, bottom: 14),
      child: Row(
        children: _btns,
      ),
    );
  }
}

class MiniTitle extends StatelessWidget {
  const MiniTitle({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ).paddingSymmetric(horizontal: 2 + kPadding),
        ],
      ),
    );
  }
}

typedef SliverObxChild = Widget Function(GalleryProvider provider);

class GalleryObxSliver extends StatelessWidget {
  const GalleryObxSliver(
    this.onComp, {
    Key? key,
    required this.pageController,
    this.showLoading = false,
  }) : super(key: key);

  final GalleryPageController pageController;
  final SliverObxChild onComp;
  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    return pageController.obx(
      (GalleryProvider? state) {
        return state != null ? onComp(state) : const SliverToBoxAdapter();
      },
      onLoading: showLoading
          ? () {
              return SliverFillRemaining(
                child: Container(
                  height: 200,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 50),
                  child: const CupertinoActivityIndicator(
                    radius: 14.0,
                  ),
                ),
              );
            }()
          : const SliverToBoxAdapter(),
      onError: showLoading
          ? (err) {
              logger.e('$err ');
              return SliverFillRemaining(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
                  child: GalleryErrorPage(
                    error: err,
                  ),
                ),
              );
            }
          : (_) => const SliverToBoxAdapter(),
    );
  }
}
