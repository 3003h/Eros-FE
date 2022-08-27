import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
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
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../const.dart';

class GalleryActions extends StatelessWidget {
  const GalleryActions({
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
            NavigatorUtil.goSearchPageWithParam(simpleSearch: '"$title"');
          },
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.only(top: 0, bottom: 14),
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

class ChapterBox extends StatefulWidget {
  const ChapterBox({
    Key? key,
    required GalleryPageController controller,
    this.chapter,
    this.limit,
  })  : _controller = controller,
        super(key: key);

  final GalleryPageController _controller;
  final List<Chapter>? chapter;
  final int? limit;

  @override
  State<ChapterBox> createState() => _ChapterBoxState();
}

class _ChapterBoxState extends State<ChapterBox> {
  bool showFull = false;

  @override
  void initState() {
    super.initState();
    showFull = false;
  }

  @override
  Widget build(BuildContext context) {
    final _chapter = widget.chapter;
    if (_chapter == null) {
      return const SizedBox.shrink();
    }

    Widget _full = getChapter();

    if ((widget.limit ?? 0) > _chapter.length) {
      return _full;
    }

    Widget _limit = getChapter(limit: widget.limit);

    Widget _animate = AnimatedCrossFade(
      firstChild: _limit,
      secondChild: _full,
      crossFadeState:
          showFull ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
      firstCurve: Curves.ease,
      secondCurve: Curves.ease,
    );

    Widget _icon = AnimatedCrossFade(
      firstChild: const Icon(CupertinoIcons.chevron_down),
      secondChild: const Icon(CupertinoIcons.chevron_up),
      crossFadeState:
          showFull ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _animate,
        CupertinoButton(
          minSize: 0,
          padding: const EdgeInsets.all(0),
          child: Center(child: _icon),
          onPressed: () {
            setState(() {
              showFull = !showFull;
            });
          },
        ),
      ],
    );
  }

  Widget getChapter({int? limit}) {
    final _chapter = widget.chapter!;
    return Container(
      padding: const EdgeInsets.only(left: kPadding, right: kPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _chapter
            .take(limit ?? _chapter.length)
            .map(
              (e) => ChapterItem(
                gid: widget._controller.gState.gid,
                page: e.page,
                author: e.author,
                title: e.title,
              ),
            )
            .toList(),
      ),
    );
  }
}

class ChapterGridView extends StatefulWidget {
  const ChapterGridView({
    Key? key,
    required GalleryPageController controller,
    this.chapter,
    this.maxLine,
  })  : _controller = controller,
        super(key: key);

  final GalleryPageController _controller;
  final List<Chapter>? chapter;
  final int? maxLine;

  @override
  State<ChapterGridView> createState() => _ChapterGridViewState();
}

class _ChapterGridViewState extends State<ChapterGridView> {
  bool showFull = false;

  @override
  void initState() {
    super.initState();
    showFull = false;
  }

  @override
  Widget build(BuildContext context) {
    final _chapter = widget.chapter;
    if (_chapter == null || _chapter.isEmpty) {
      return const SizedBox.shrink();
    }

    const _gridDelegateWithMaxCrossAxisExtent =
        SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 220,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 3,
    );

    // logger.d('context.width ${context.width}');

    Widget _icon = AnimatedCrossFade(
      firstChild: const Icon(CupertinoIcons.chevron_down),
      secondChild: const Icon(CupertinoIcons.chevron_up),
      crossFadeState:
          showFull ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );

    return LayoutBuilder(builder: (context, c) {
      final _sgp = sliverGridDelegateWithMaxToCount(
        c.maxWidth -
            context.mediaQueryPadding.left -
            context.mediaQueryPadding.right -
            2 * kPadding,
        _gridDelegateWithMaxCrossAxisExtent,
      );

      final gridDelegate = _sgp.gridDelegate;
      final _crossAxisCount = gridDelegate.crossAxisCount;

      Widget _full = getChapter(gridDelegate);
      final limit = (widget.maxLine ?? 0) * _crossAxisCount;

      if (limit > _chapter.length) {
        // logger.d('full _chapter');
        return _full;
      }

      Widget _limit = getChapter(gridDelegate, limit: limit);

      Widget _animate = AnimatedCrossFade(
        firstChild: _limit,
        secondChild: _full,
        crossFadeState:
            showFull ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
        firstCurve: Curves.ease,
        secondCurve: Curves.ease,
        sizeCurve: Curves.ease,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _animate,
          CupertinoButton(
            minSize: 0,
            padding: const EdgeInsets.all(0),
            child: Center(child: _icon),
            onPressed: () {
              setState(() {
                showFull = !showFull;
              });
            },
          ),
        ],
      );
    });
  }

  Widget getChapter(SliverGridDelegate gridDelegate, {int? limit}) {
    final _chapter = widget.chapter!;

    return Container(
      padding: const EdgeInsets.only(left: kPadding, right: kPadding),
      child: GridView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: gridDelegate,
        children: _chapter
            .take(limit ?? _chapter.length)
            .map(
              (e) => ChapterItemFlex(
                gid: widget._controller.gState.gid,
                page: e.page,
                author: e.author,
                title: e.title,
              ),
            )
            .toList(),
      ),
    );
  }
}

class ChapterItem extends StatelessWidget {
  const ChapterItem({
    Key? key,
    required this.page,
    this.author,
    this.title,
    required this.gid,
  }) : super(key: key);

  final int page;
  final String gid;
  final String? author;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final _pageStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    final _authStyle = TextStyle(
        fontSize: 12, color: title != null ? ehTheme.commitIconColor : null);
    final _titleStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
    );

    return GestureDetector(
      onTap: () {
        NavigatorUtil.goGalleryViewPage(page - 1, gid);
      },
      child: Container(
        // height: 40,
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey6, context),
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: BoxConstraints(
            // maxWidth: context.width-16,
            // minHeight: 32,
            ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$page. $author', style: _authStyle),
            if (title != null)
              Text(
                '$title',
                style: _titleStyle,
              ),
          ],
        ),
      ),
    );
  }
}

class ChapterItemFlex extends StatelessWidget {
  const ChapterItemFlex({
    Key? key,
    required this.page,
    this.author,
    this.title,
    required this.gid,
  }) : super(key: key);

  final int page;
  final String gid;
  final String? author;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final _pageStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    final _authStyle = TextStyle(
      fontSize: title != null ? 11 : 13,
      color: title != null
          ? ehTheme.commitIconColor
          : CupertinoDynamicColor.resolve(CupertinoColors.label, context),
    );
    final _titleStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
    );

    return Tooltip(
      richMessage: TextSpan(
        children: [
          if (title != null) TextSpan(text: '$title\n', style: _titleStyle),
          TextSpan(text: author, style: _authStyle),
        ],
      ),
      showDuration: const Duration(seconds: 2),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: CupertinoDynamicColor.resolve(
                    CupertinoColors.darkBackgroundGray, context)
                .withOpacity(0.4),
            offset: const Offset(0, 0),
            blurRadius: 20, //阴影模糊程度
            spreadRadius: 4, //阴影扩散程度
          ),
        ],
        border: ehTheme.isDarkMode
            ? Border.all(
                width: 1,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey4, context))
            : null,
        borderRadius: BorderRadius.circular(10),
        color:
            CupertinoDynamicColor.resolve(CupertinoColors.systemGrey6, context),
      ),
      child: GestureDetector(
        onTap: () {
          NavigatorUtil.goGalleryViewPage(page - 1, gid);
        },
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey6, context),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Expanded(
                  child: Text(
                    '$title',
                    style: _titleStyle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$author',
                      style: _authStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: title != null ? null : 2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('$page', style: _pageStyle),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SGDelegatePack {
  SGDelegatePack(this.gridDelegate, this.size);
  SliverGridDelegateWithFixedCrossAxisCount gridDelegate;
  Size size;
}

SGDelegatePack sliverGridDelegateWithMaxToCount(
    double width, SliverGridDelegateWithMaxCrossAxisExtent sliverGridDelegate,
    [double extendHeight = 0]) {
  int crossAxisCount = (width /
          (sliverGridDelegate.maxCrossAxisExtent +
              sliverGridDelegate.crossAxisSpacing))
      .ceil();
  final double usableCrossAxisExtent =
      width - sliverGridDelegate.crossAxisSpacing * (crossAxisCount - 1);
  if (crossAxisCount < 1) {
    crossAxisCount = 1;
  }
  final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
  double childMainAxisExtent =
      childCrossAxisExtent / sliverGridDelegate.childAspectRatio;
  childMainAxisExtent += extendHeight;
  final childAspectRatio = childCrossAxisExtent / childMainAxisExtent;
  return SGDelegatePack(
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: sliverGridDelegate.mainAxisSpacing,
        crossAxisSpacing: sliverGridDelegate.crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      Size(childCrossAxisExtent, childMainAxisExtent));
}
