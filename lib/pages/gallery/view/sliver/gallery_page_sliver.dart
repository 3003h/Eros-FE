import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/pages/gallery/comm.dart';
import 'package:eros_fe/pages/gallery/controller/gallery_page_controller.dart';
import 'package:eros_fe/pages/gallery/controller/gallery_page_state.dart';
import 'package:eros_fe/pages/gallery/view/const.dart';
import 'package:eros_fe/pages/gallery/view/gallery_widget.dart';
import 'package:eros_fe/pages/gallery/view/sliver/slivers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:share_plus/share_plus.dart';

import 'header_sliver.dart';

const double kHeaderHeight = 200.0 + 52;

class GallerySliverPage extends StatefulWidget {
  const GallerySliverPage({Key? key}) : super(key: key);
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
    logger.t('initState pageCtrlTag:$pageCtrlTag');
    initPageController(tag: _tag);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _controller = Get.put(GalleryPageController(), tag: _tag);

    Get.lazyPut<GalleryPageController>(
      () => GalleryPageController(),
      tag: _tag,
      fenix: true,
    );
    _controller = Get.find(tag: _tag);

    _controller.scrollController = PrimaryScrollController.of(context);
    _controller.scrollController
        ?.addListener(_controller.scrollControllerLister);
  }

  @override
  Widget build(BuildContext context) {
    final dynamic tabTag = pageState.galleryRepository?.tabTag;
    final GalleryProvider? galleryProvider = pageState.galleryProvider;

    final sliversW = <Widget>[
      // 导航栏
      buildCupertinoSliverNavigationBar(context, galleryProvider),
      // 下拉刷新
      EhCupertinoSliverRefreshControl(
        onRefresh: _controller.handOnRefresh,
      ),
      // 头部
      if (pageState.fromUrl)
        GallerySliverSafeArea(
          child: GalleryObxSliver(
            (state) => GalleryHeaderSliver(
              initGalleryProvider: state,
              tabTag: tabTag,
            ),
            pageController: _controller,
          ),
        )
      else if (galleryProvider != null)
        GallerySliverSafeArea(
          child: GalleryHeaderSliver(
            initGalleryProvider: galleryProvider,
            tabTag: tabTag,
          ),
        ),

      GalleryObxSliver(
        (state) => GallerySliverSafeArea(
          child: SliverToBoxAdapter(
            child: GalleryActions(
              provider: state,
              controller: _controller,
            ),
          ),
        ),
        pageController: _controller,
        showLoading: true,
      ),
      // tag 标题
      GallerySliverSafeArea(
          child: SliverToBoxAdapter(
              child: MiniTitle(title: L10n.of(context).tags))),
      // tag
      GalleryObxSliver(
        (state) => GallerySliverSafeArea(
          child: SliverPadding(
            padding: const EdgeInsets.only(
              left: kPadding,
              right: kPadding,
              bottom: 20,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return TagGroupItem(
                      tagGroupData: (state.tagGroup ?? [])[index]);
                },
                childCount: (state.tagGroup ?? []).length,
              ),
            ),
          ),
        ),
        pageController: _controller,
      ),
      // 章节 小标题
      GalleryObxSliver(
        (state) => GallerySliverSafeArea(
          child: SliverToBoxAdapter(
            child: (state.chapter?.isNotEmpty ?? false)
                ? MiniTitle(title: L10n.of(context).chapter)
                : const SizedBox.shrink(),
          ),
        ),
        pageController: _controller,
      ),

      // 章节
      GalleryObxSliver(
        (state) {
          return GallerySliverSafeArea(
            child: SliverToBoxAdapter(
              child: ChapterGridView(
                controller: _controller,
                chapter: state.chapter,
                maxLine: 3,
              ).paddingOnly(
                  bottom: (state.chapter != null && state.chapter!.isNotEmpty)
                      ? 20
                      : 0),
            ),
          );
        },
        pageController: _controller,
      ),

      // 最上面的部分评论 小标题
      GallerySliverSafeArea(
        child: SliverToBoxAdapter(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.toNamed(
              EHRoutes.galleryComment,
              id: isLayoutLarge ? 2 : null,
            ),
            child: Row(
              children: [
                MiniTitle(title: L10n.of(context).gallery_comments),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
      // 最上面的部分评论 评论内容 (一点点性能问题)
      GalleryObxSliver(
        (state) {
          return GallerySliverSafeArea(
            child: SliverPadding(
              padding: const EdgeInsets.only(
                  left: kPadding, right: kPadding, bottom: 20),
              sliver: SliverToBoxAdapter(
                child: GestureDetector(
                  behavior: HitTestBehavior.deferToChild,
                  onTap: () => Get.toNamed(
                    EHRoutes.galleryComment,
                    id: isLayoutLarge ? 2 : null,
                  ),
                  child: Obx(() {
                    return TopCommentEx(
                      key: ValueKey(_controller.gState.comments
                          .map((e) => e.id)
                          .join('')),
                      comments: _controller.gState.comments,
                      uploader: _controller.gState.galleryProvider?.uploader,
                    );
                  }),
                ),
              ),
            ),
          );
        },
        pageController: _controller,
      ),
      // 缩略图
      GalleryObxSliver(
        (state) => GallerySliverSafeArea(
          child: SliverPadding(
            padding: const EdgeInsets.only(
              bottom: 20,
              left: kPadding,
              right: kPadding,
            ),
            sliver: ThumbSliverGrid(
              images: pageState.firstPageImage,
              gid: state.gid ?? '',
              referer: _controller.gState.url,
            ),
          ),
        ),
        pageController: _controller,
      ),
      GalleryObxSliver(
        (state) => GallerySliverSafeArea(
          child: SliverPadding(
            padding: const EdgeInsets.only(bottom: 20),
            sliver: SliverToBoxAdapter(
              child: MorePreviewButton(hasMorePreview: pageState.hasMoreImage),
            ),
          ),
        ),
        pageController: _controller,
      ),
    ];

    Widget body = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: GetPlatform.isDesktop ? _controller.scrollController : null,
      slivers: sliversW,
    );

    body = SizeCacheWidget(
      child: EasyRefresh(
        enableControlFinishRefresh: false,
        enableControlFinishLoad: false,
        onLoad: () async {
          if (pageState.images.isNotEmpty) {
            Get.toNamed(
              EHRoutes.galleryAllThumbnails,
              id: isLayoutLarge ? 2 : null,
            );
          }
        },
        footer: BezierBounceFooter(
          backgroundColor: Colors.transparent,
          color: CupertinoColors.inactiveGray,
        ),
        child: body,
      ),
    );

    body = CupertinoPageScaffold(child: body);

    return body;
  }

  CupertinoSliverNavigationBar buildCupertinoSliverNavigationBar(
    BuildContext context,
    GalleryProvider? provider,
  ) {
    return CupertinoSliverNavigationBar(
      padding: const EdgeInsetsDirectional.only(end: 10),
      largeTitle: GetBuilder<GalleryPageController>(
        id: GetIds.PAGE_VIEW_HEADER,
        tag: pageCtrlTag,
        builder: (logic) {
          return SelectableText(
            logic.gState.subTitle,
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
        bool isRefresh = false;
        Widget buttons = Row(
          key: const ValueKey('buttons'),
          mainAxisSize: MainAxisSize.min,
          children: [
            // Refresh button
            if (GetPlatform.isDesktop)
              StatefulBuilder(builder: (context, setState) {
                return CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  minSize: 40,
                  child: isRefresh
                      ? const CupertinoActivityIndicator(
                          radius: 12,
                        )
                      : const MouseRegionClick(
                          child: Icon(
                            CupertinoIcons.arrow_clockwise,
                            size: 24,
                          ),
                        ),
                  onPressed: () async {
                    setState(() {
                      isRefresh = true;
                    });
                    try {
                      await _controller.handOnRefresh();
                    } finally {
                      setState(() {
                        isRefresh = false;
                      });
                    }
                  },
                );
              }),

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

        Widget readButtonOpacity = AnimatedOpacity(
          opacity: pageState.hideNavigationBtn ? 0.0 : 1.0,
          duration: 300.milliseconds,
          child: ReadButton(gid: provider?.gid ?? '0').paddingOnly(right: 4),
          curve: Curves.ease,
        );
        Widget buttonsOpacity = AnimatedOpacity(
          opacity: pageState.hideNavigationBtn ? 1.0 : 0.0,
          duration: 300.milliseconds,
          child: buttons,
          curve: Curves.ease,
        );

        // todo error
        Widget trailingSwitcher = TrailingSwitcher(
          hideNavigationBtn: pageState.hideNavigationBtn,
          firstChild: buttons.paddingOnly(right: 4),
          secondChild: ReadButton(
                  key: const ValueKey('ReadButton'), gid: provider?.gid ?? '0')
              .paddingOnly(right: 4),
          duration: 300.milliseconds,
        );

        Widget gt = GalleryTrailing(
          firstChild: buttons,
          secondChild: Row(
            key: const ValueKey('ReadButton'),
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

class GallerySliverSafeArea extends StatelessWidget {
  const GallerySliverSafeArea({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverSafeArea(
      top: false,
      bottom: false,
      left: !isLayoutLarge,
      sliver: child,
    );
  }
}

class TrailingSwitcher extends StatefulWidget {
  const TrailingSwitcher(
      {Key? key,
      required this.hideNavigationBtn,
      required this.firstChild,
      required this.secondChild,
      required this.duration,
      this.curve})
      : super(key: key);
  final bool hideNavigationBtn;
  final Widget firstChild;
  final Widget secondChild;
  final Duration duration;
  final Curve? curve;

  @override
  State<TrailingSwitcher> createState() => _TrailingSwitcherState();
}

class _TrailingSwitcherState extends State<TrailingSwitcher> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      child: widget.hideNavigationBtn ? widget.firstChild : widget.secondChild,
      duration: widget.duration,
      transitionBuilder: (child, animation) {
        return FadeTransition(child: child, opacity: animation);
      },
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
            IgnorePointer(
              ignoring: widget.crossFadeState != CrossFadeState.showSecond,
              child: FadeTransition(
                opacity: animation,
                child: widget.secondChild,
              ),
            ),
            IgnorePointer(
              ignoring: widget.crossFadeState != CrossFadeState.showFirst,
              child: FadeTransition(
                opacity: animation.drive(Tween<double>(begin: 1.0, end: 0.0)),
                child: widget.firstChild,
              ),
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
