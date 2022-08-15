import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/pages/gallery/comm.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_state.dart';
import 'package:fehviewer/pages/gallery/view/const.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:fehviewer/pages/gallery/view/sliver/slivers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:share/share.dart';

import 'header_sliver.dart';

const double kHeaderHeight = 200.0 + 52;

class GallerySliverPage extends StatefulWidget {
  @override
  _GallerySliverPageState createState() => _GallerySliverPageState();
}

class _GallerySliverPageState extends State<GallerySliverPage> {
  late final GalleryPageController _controller;
  final _tag = pageCtrlTag;

  GalleryPageState get pageState => _controller.gState;

  @override
  void initState() {
    super.initState();
    logger.v('initState pageCtrlTag:$pageCtrlTag');
    initPageController(tag: _tag);
    _controller = Get.put(GalleryPageController(), tag: _tag);

    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      _controller.scrollController =
          PrimaryScrollController.of(context) ?? ScrollController();
      _controller.scrollController
          ?.addListener(_controller.scrollControllerLister);
    });
  }

  @override
  void dispose() {
    super.dispose();
    // deletePageController(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final dynamic tabTag = pageState.galleryRepository?.tabTag;
    final GalleryProvider? galleryProvider = pageState.galleryProvider;

    Widget body = SizeCacheWidget(
      child: EasyRefresh(
        enableControlFinishRefresh: false,
        enableControlFinishLoad: false,
        onLoad: () async {
          if (pageState.images.isNotEmpty) {
            Get.toNamed(
              EHRoutes.galleryAllPreviews,
              id: isLayoutLarge ? 2 : null,
            );
          }
        },
        footer: BezierBounceFooter(
          backgroundColor: Colors.transparent,
          color: CupertinoColors.inactiveGray,
        ),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            // 导航栏
            buildCupertinoSliverNavigationBar(context, galleryProvider),
            // 下拉刷新
            EhCupertinoSliverRefreshControl(
              onRefresh: _controller.handOnRefresh,
            ),
            // 头部
            if (pageState.fromUrl)
              GalleryObxSliver(
                (state) => GalleryHeaderSliver(
                  initGalleryProvider: state,
                  tabTag: tabTag,
                ),
                pageController: _controller,
              )
            else if (galleryProvider != null)
              GalleryHeaderSliver(
                initGalleryProvider: galleryProvider,
                tabTag: tabTag,
              ),

            GalleryObxSliver(
              (state) => SliverToBoxAdapter(
                child: GalleryAtions(
                  galleryProvider: state,
                  pageController: _controller,
                ),
              ),
              pageController: _controller,
              showLoading: true,
            ),
            // tag 标题
            SliverToBoxAdapter(child: MiniTitle(title: L10n.of(context).tags)),
            // tag
            GalleryObxSliver(
              (state) => SliverPadding(
                padding: const EdgeInsets.only(
                    left: kPadding, right: kPadding, bottom: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return TagGroupItem(
                          tagGroupData: (state.tagGroup ?? [])[index]);
                      // return FrameSeparateWidget(
                      //   index: index,
                      //   placeHolder: const TagGroupPpaceHolder(),
                      //   child: TagGroupItem(
                      //       tagGroupData: (state.tagGroup ?? [])[index]),
                      //   // child: TagGroupPpaceHolder(),
                      // );
                    },
                    childCount: (state.tagGroup ?? []).length,
                  ),
                ),
              ),
              pageController: _controller,
            ),
            // 章节 小标题
            GalleryObxSliver(
              (state) => SliverToBoxAdapter(
                child: (state.chapter?.isNotEmpty ?? false)
                    ? MiniTitle(title: L10n.of(context).chapter)
                    : const SizedBox.shrink(),
              ),
              pageController: _controller,
            ),

            // 章节
            GalleryObxSliver(
              (state) {
                return SliverToBoxAdapter(
                  child: ChapterGridView(
                    controller: _controller,
                    chapter: state.chapter,
                    maxLine: 3,
                  ).paddingOnly(
                      bottom:
                          (state.chapter != null && state.chapter!.isNotEmpty)
                              ? 20
                              : 0),
                );
              },
              pageController: _controller,
            ),

            // 最上面的部分评论 小标题
            SliverToBoxAdapter(
              child: Row(
                children: [
                  MiniTitle(title: L10n.of(context).gallery_comments),
                  const Spacer(),
                ],
              ),
            ),
            // 最上面的部分评论 评论内容 (一点点性能问题)
            GalleryObxSliver(
              (state) {
                return SliverPadding(
                  padding: const EdgeInsets.only(
                      left: kPadding, right: kPadding, bottom: 20),
                  sliver: SliverToBoxAdapter(
                    child: GestureDetector(
                      behavior: HitTestBehavior.deferToChild,
                      onTap: () => Get.toNamed(
                        EHRoutes.galleryComment,
                        id: isLayoutLarge ? 2 : null,
                      ),
                      // child: const TopComment(showBtn: false),
                      child: Obx(() {
                        return TopCommentEx(
                          key: ValueKey(_controller.gState.comments
                              .map((e) => e.id)
                              .join('')),
                          comments: _controller.gState.comments,
                        );
                      }),
                    ),
                  ),
                );
              },
              pageController: _controller,
            ),
            // 缩略图
            GalleryObxSliver(
              (state) => SliverPadding(
                padding: const EdgeInsets.only(
                  bottom: 20,
                  left: kPadding,
                  right: kPadding,
                ),
                sliver: PreviewSliverGrid(
                  images: pageState.firstPageImage,
                  gid: state.gid ?? '',
                  referer: _controller.gState.url,
                ),
              ),
              pageController: _controller,
            ),
            GalleryObxSliver(
              (state) => SliverPadding(
                padding: const EdgeInsets.only(bottom: 20),
                sliver: SliverToBoxAdapter(
                  child:
                      MorePreviewButton(hasMorePreview: pageState.hasMoreImage),
                ),
              ),
              pageController: _controller,
            ),
          ],
        ),
      ),
    );

    return CupertinoPageScaffold(
      child: CupertinoScrollbar(
        controller: PrimaryScrollController.of(context),
        child: body,
      ),
    );
  }

  CupertinoSliverNavigationBar buildCupertinoSliverNavigationBar(
      BuildContext context, GalleryProvider? provider) {
    return CupertinoSliverNavigationBar(
      padding: const EdgeInsetsDirectional.only(end: 10),
      largeTitle: GetBuilder<GalleryPageController>(
        id: GetIds.PAGE_VIEW_HEADER,
        tag: pageCtrlTag,
        builder: (logic) {
          return SelectableText(
            logic.gState.topTitle,
            textAlign: TextAlign.start,
            maxLines: 3,
            minLines: 1,
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel, context),
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.italic,
            ),
          );
        },
      ),
      middle: Obx(
        () {
          Widget coverOpacity = AnimatedOpacity(
            opacity: pageState.hideNavigationBtn ? 0.0 : 1.0,
            duration: 300.milliseconds,
            child: GetBuilder<GalleryPageController>(
              id: GetIds.PAGE_VIEW_HEADER,
              tag: pageCtrlTag,
              builder: (logic) {
                return NavigationBarImage(
                  imageUrl: logic.gState.galleryProvider?.imgUrl ?? '',
                  scrollController: logic.scrollController,
                );
              },
            ),
            curve: Curves.ease,
          );

          return coverOpacity;
        },
      ),
      trailing: Obx(() {
        Widget readButtonOpacity = AnimatedOpacity(
          opacity: pageState.hideNavigationBtn ? 0.0 : 1.0,
          duration: 300.milliseconds,
          child: ReadButton(gid: provider?.gid ?? '0').paddingOnly(right: 4),
          curve: Curves.ease,
        );

        Widget buttons = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              minSize: 40,
              child: const MouseRegionClick(
                child: Icon(CupertinoIcons.tags, size: 24),
              ),
              onPressed: () {
                _controller.addTag();
              },
            ),
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              minSize: 38,
              child: const MouseRegionClick(
                child: Icon(CupertinoIcons.share, size: 26),
              ),
              onPressed: () {
                if (provider == null) {
                  return;
                }
                final String _url =
                    '${Api.getBaseUrl()}/g/${provider.gid}/${provider.token}';
                logger.d('share $_url');
                Share.share(_url);
              },
            ),
          ],
        );

        Widget trailingFade = AnimatedCrossFade(
          firstChild: buttons,
          secondChild: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReadButton(gid: provider?.gid ?? '0').paddingOnly(right: 4),
            ],
          ),
          crossFadeState: pageState.hideNavigationBtn
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: 300.milliseconds,
        );

        Widget gt = GalleryTrailing(
          firstChild: buttons,
          secondChild: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReadButton(gid: provider?.gid ?? '0').paddingOnly(right: 4),
            ],
          ),
          crossFadeState: pageState.hideNavigationBtn
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: 300.milliseconds,
        );

        return gt;
      }),
    );
  }
}

class GalleryTrailing extends StatefulWidget {
  const GalleryTrailing({
    Key? key,
    required this.firstChild,
    required this.secondChild,
    required this.crossFadeState,
    required this.duration,
    this.curve = Curves.linear,
  }) : super(key: key);

  final Widget firstChild;

  final Widget secondChild;

  final CrossFadeState crossFadeState;

  final Duration duration;

  final Curve curve;

  @override
  State<GalleryTrailing> createState() => _GalleryTrailingState();
}

class _GalleryTrailingState extends State<GalleryTrailing>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    if (widget.crossFadeState == CrossFadeState.showSecond) {
      _controller.value = 1.0;
    }

    animation = _controller.drive(CurveTween(curve: widget.curve));

    _controller.addStatusListener((AnimationStatus status) {
      setState(() {
        // Trigger a rebuild because it depends on _isTransitioning, which
        // changes its value together with animation status.
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GalleryTrailing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.crossFadeState != oldWidget.crossFadeState) {
      switch (widget.crossFadeState) {
        case CrossFadeState.showFirst:
          _controller.reverse();
          break;
        case CrossFadeState.showSecond:
          _controller.forward();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          alignment: Alignment.centerRight,
          children: [
            FadeTransition(
              opacity: animation,
              child: widget.secondChild,
            ),
            FadeTransition(
              opacity: animation.drive(Tween<double>(begin: 1.0, end: 0.0)),
              child: widget.firstChild,
            ),
          ],
        );
      },
    );
  }
}

class TagGroupPpaceHolder extends StatelessWidget {
  const TagGroupPpaceHolder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TagGroupItem(
      tagGroupData: TagGroup(tagType: '　　', galleryTags: [
        GalleryTag(type: '　　', tagTranslat: '　　　', title: '　　　'),
        GalleryTag(type: '　　', tagTranslat: '　　　', title: '　　　'),
        GalleryTag(type: '　　', tagTranslat: '　　　', title: '　　　'),
        GalleryTag(type: '　　', tagTranslat: '　　　', title: '　　　'),
      ]),
    );
  }
}
