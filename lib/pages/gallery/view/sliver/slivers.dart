import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_state.dart';
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
import 'package:keframe/keframe.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

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
        child: DownloadGalleryButton(
          pageController: pageController,
        ),
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

class DownloadGalleryButton extends StatelessWidget {
  const DownloadGalleryButton({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  final GalleryPageController pageController;

  DownloadController get _downloadController => Get.find();

  GalleryPageState get pageStat => pageController.gState;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final defIcon = TextBtn(
        FontAwesomeIcons.solidCircleDown,
        title: L10n.of(context).p_Download,
        onTap: () => pageController.downloadGallery(context),
      );

      final toDownloadPage =
          () => Get.toNamed(EHRoutes.download, id: isLayoutLarge ? 1 : null);

      final Map<TaskStatus, Widget> iconMap = {
        // 下载完成
        TaskStatus.complete: TextBtn(
          FontAwesomeIcons.solidCircleCheck,
          title: L10n.of(context).downloaded,
          onTap: () {},
          color: CupertinoColors.activeGreen,
          // onTap: toDownloadPage,
          // onLongPress: toDownloadPage,
        ),
        // 下载中
        TaskStatus.running: TextBtn(
          FontAwesomeIcons.play,
          iconPadding: const EdgeInsets.only(left: 2.5),
          iconSize: 16,
          title: L10n.of(context).downloading,
          onTap: () =>
              _downloadController.galleryTaskPaused(int.parse(pageStat.gid)),
          // onLongPress: toDownloadPage,
        ),
        // 下载暂停
        TaskStatus.paused: TextBtn(
          FontAwesomeIcons.pause,
          iconSize: 16,
          title: L10n.of(context).paused,
          onTap: () =>
              _downloadController.galleryTaskResume(int.parse(pageStat.gid)),
          // onTap: toDownloadPage,
          // onLongPress: toDownloadPage,
        ),
      };

      final _dlWidget = Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            child: Obx(() {
              return SleekCircularSlider(
                appearance: CircularSliderAppearance(
                  infoProperties: InfoProperties(
                    mainLabelStyle:
                        const TextStyle(color: CupertinoColors.systemGrey6),
                    modifier: (_) => '',
                  ),
                  size: 31,
                  customWidths: CustomSliderWidths(progressBarWidth: 4),
                  customColors: CustomSliderColors(
                    trackColor: CupertinoColors.systemGrey,
                    progressBarColor: CupertinoColors.activeGreen,
                    dotColor: CupertinoColors.activeGreen,
                    hideShadow: true,
                  ),
                  startAngle: 270.0,
                  angleRange: 360.0,
                ),
                min: 0,
                max: 100,
                initialValue: pageStat.downloadProcess,
              );
            }),
            padding: const EdgeInsets.only(bottom: 19),
          ),
          iconMap[pageStat.downloadState] ?? const SizedBox(),
        ],
      );

      return iconMap.keys.contains(pageStat.downloadState)
          ? _dlWidget
          : defIcon;
    });
  }
}

class MiniTitle extends StatelessWidget {
  const MiniTitle({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ).paddingSymmetric(horizontal: 2 + kPadding);
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

class PreviewSliverGrid extends StatelessWidget {
  const PreviewSliverGrid({
    Key? key,
    required this.images,
    required this.gid,
    this.referer,
  }) : super(key: key);
  final List<GalleryImage> images;
  final String gid;
  final String? referer;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: kMaxCrossAxisExtent,
          mainAxisSpacing: kMainAxisSpacing, //主轴方向的间距
          crossAxisSpacing: kCrossAxisSpacing, //交叉轴方向子元素的间距
          childAspectRatio: kChildAspectRatio //显示区域宽高
          ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return PreviewContainer(
            galleryImageList: images,
            index: index,
            gid: gid,
            onLoadComplet: () {
              final thumbUrl = images[index].thumbUrl ?? '';
            },
            referer: referer,
          );
        },
        childCount: images.length,
      ),
    );
  }
}
