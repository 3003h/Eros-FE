import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/pages/gallery/comm.dart';
import 'package:eros_fe/pages/gallery/controller/gallery_page_controller.dart';
import 'package:eros_fe/pages/gallery/controller/gallery_page_state.dart';
import 'package:eros_fe/pages/gallery/view/const.dart';
import 'package:eros_fe/pages/gallery/view/gallery_widget.dart';
import 'package:eros_fe/pages/gallery/view/sliver/gallery_page_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'header_sliver.dart';
import 'slivers.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late final GalleryPageController _controller;
  final _tag = pageCtrlTag;

  GalleryPageState get pageState => _controller.gState;

  @override
  void initState() {
    super.initState();
    // _controller = Get.put(GalleryPageController(), tag: _tag);
    Get.lazyPut<GalleryPageController>(
      () => GalleryPageController(),
      tag: _tag,
      fenix: true,
    );
    _controller = Get.find(tag: _tag);
    initPageController(tag: _tag);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _controller.scrollController = PrimaryScrollController.of(context);
    _controller.scrollController
        ?.addListener(_controller.scrollControllerLister);
  }

  @override
  Widget build(BuildContext context) {
    Widget body = CustomScrollView(
      cacheExtent: 1000,
      controller: GetPlatform.isDesktop ? _controller.scrollController : null,
      slivers: [
        GalleryNavigationBar(controller: _controller),
        EhCupertinoSliverRefreshControl(onRefresh: _controller.handOnRefresh),
        GalleryHeadTile(controller: _controller),
        GalleryBody(controller: _controller),
      ],
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

    return CupertinoPageScaffold(child: body);
  }
}

class GalleryNavigationBar extends StatelessWidget {
  const GalleryNavigationBar({
    super.key,
    required this.controller,
  });
  final GalleryPageController controller;

  GalleryPageState get pageState => controller.gState;

  @override
  Widget build(BuildContext context) {
    final GalleryProvider? provider = pageState.galleryProvider;
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
            curve: Curves.ease,
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
                      await controller.handOnRefresh();
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
              minSize: 38,
              child: const MouseRegionClick(
                child: Icon(CupertinoIcons.tag_circle, size: 28),
              ),
              onPressed: () {
                controller.addTag();
              },
            ),
            CupertinoButton(
              padding: const EdgeInsets.only(bottom: 4),
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

class GalleryHeadTile extends StatelessWidget {
  const GalleryHeadTile({Key? key, required this.controller}) : super(key: key);

  final GalleryPageController controller;

  GalleryPageState get pageState => controller.gState;

  @override
  Widget build(BuildContext context) {
    final GalleryProvider? provider = pageState.galleryProvider;
    final dynamic tabTag = pageState.galleryRepository?.tabTag;
    return MultiSliver(children: [
      if (pageState.fromUrl)
        GallerySliverSafeArea(
          child: GalleryObxSliver(
            (state) => GalleryHeaderSliver(
              initGalleryProvider: state,
              tabTag: tabTag,
            ),
            pageController: controller,
          ),
        )
      else if (provider != null)
        GallerySliverSafeArea(
          child: GalleryHeaderSliver(
            initGalleryProvider: provider,
            tabTag: tabTag,
          ),
        ),
    ]);
  }
}

class GalleryBody extends StatelessWidget {
  const GalleryBody({super.key, required this.controller});

  final GalleryPageController controller;

  EhSettingService get _ehSettingService => Get.find();

  GalleryPageState get pageState => controller.gState;

  @override
  Widget build(BuildContext context) {
    return GalleryObxSliver(
      (GalleryProvider state) {
        return GallerySliverSafeArea(
          child: MultiSliver(children: [
            GalleryActions(controller: controller, provider: state),
            if (_ehSettingService.showGalleryTags) TagTile(provider: state),
            ChapterTile(controller: controller, provider: state),
            if (_ehSettingService.showComments)
              CommentTile(controller: controller, provider: state),
            if (!_ehSettingService.hideGalleryThumbnails)
              ThumbTile(
                controller: controller,
                provider: state,
                horizontal: _ehSettingService.horizontalThumbnails,
              )
            else
              const MorePreviewButton(hasMorePreview: true),
          ]),
        );
      },
      showLoading: true,
      pageController: controller,
    );
  }
}

class TagTile extends StatelessWidget {
  const TagTile({super.key, required this.provider, this.pageController});
  final GalleryProvider provider;
  final GalleryPageController? pageController;

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      MiniTitle(title: L10n.of(context).tags),
      SliverPadding(
        padding: const EdgeInsets.only(
          left: kPadding,
          right: kPadding,
          bottom: 20,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return TagGroupItem(
                  tagGroupData: (provider.tagGroup ?? [])[index]);
            },
            childCount: (provider.tagGroup ?? []).length,
          ),
        ),
      ),
    ]);
  }
}

class ChapterTile extends StatelessWidget {
  const ChapterTile({
    super.key,
    required this.provider,
    required this.controller,
  });

  final GalleryProvider provider;
  final GalleryPageController controller;

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      if (provider.chapter?.isNotEmpty ?? false)
        MiniTitle(title: L10n.of(context).chapter),
      Container(
        padding: EdgeInsets.only(
            bottom: (provider.chapter?.isNotEmpty ?? false) ? 20 : 0),
        child: ChapterGridView(
          controller: controller,
          chapter: provider.chapter,
          maxLine: 3,
        ),
      ),
    ]);
  }
}

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.provider,
    required this.controller,
  });
  final GalleryProvider provider;
  final GalleryPageController controller;

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            Get.toNamed(EHRoutes.galleryComment, id: isLayoutLarge ? 2 : null),
        child: Row(
          children: [
            MiniTitle(title: L10n.of(context).gallery_comments),
            const Spacer(),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.only(
          left: kPadding,
          right: kPadding,
          bottom: 20,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () => Get.toNamed(
            EHRoutes.galleryComment,
            id: isLayoutLarge ? 2 : null,
          ),
          child: Obx(() {
            return TopCommentEx(
              key: ValueKey(
                  controller.gState.comments.map((e) => e.id).join('')),
              comments: controller.gState.comments,
              uploader: controller.gState.galleryProvider?.uploader,
            );
          }),
        ),
      ),
    ]);
  }
}

class ThumbTile extends StatelessWidget {
  const ThumbTile({
    super.key,
    required this.provider,
    required this.controller,
    this.horizontal = false,
  });
  final GalleryProvider provider;
  final GalleryPageController controller;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final pageState = controller.gState;

    if (horizontal) {
      return MultiSliver(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Get.toNamed(
                EHRoutes.galleryAllThumbnails,
                id: isLayoutLarge ? 2 : null,
              );
            },
            child: Row(
              children: [
                MiniTitle(title: L10n.of(context).thumbnails),
                const Spacer(),
              ],
            ),
          ),
          ThumbHorizontalList(
            images: pageState.firstPageImage,
            gid: provider.gid ?? '',
            referer: controller.gState.url,
          ),
        ],
      );
    } else {
      return MultiSliver(children: [
        SliverPadding(
          padding: const EdgeInsets.only(
            left: kPadding,
            right: kPadding,
            bottom: 20,
          ),
          sliver: ThumbSliverGrid(
            images: pageState.firstPageImage,
            gid: provider.gid ?? '',
            referer: controller.gState.url,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: MorePreviewButton(hasMorePreview: pageState.hasMoreImage),
        ),
      ]);
    }
  }
}
