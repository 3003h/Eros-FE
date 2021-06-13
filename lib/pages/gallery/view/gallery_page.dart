import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:fehviewer/pages/gallery/view/rate_dialog.dart';
import 'package:fehviewer/pages/gallery/view/torrent_dialog.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
// import 'package:fehviewer/utils/cust_lib/selectable_text.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
// import 'package:flutter/material.dart' hide SelectableText;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:share/share.dart';

import 'all_preview_page.dart';
import 'archiver_dialog.dart';

const double kHeaderHeight = 200.0 + 52;
const double kPadding = 12.0;
const double kHeaderPaddingTop = 12.0;

class GalleryRepository {
  GalleryRepository({this.tabTag, this.item, this.url});

  final String? tabTag;
  final GalleryItem? item;
  final String? url;
}

class GalleryMainPage extends StatelessWidget {
  const GalleryMainPage({this.galleryRepository});

  // GalleryPageController get _controller => Get.find(tag: pageCtrlDepth);
  // late final GalleryPageController _controller;

  final GalleryRepository? galleryRepository;

  @override
  Widget build(BuildContext context) {
    GalleryRepository? _galleryRepository() {
      if (galleryRepository != null) {
        return galleryRepository;
      }

      GalleryRepository? repository;
      try {
        repository = Get.find<GalleryRepository>(tag: pageCtrlDepth);
      } catch (_) {}

      return galleryRepository ?? repository;
    }

    final GalleryPageController _controller = Get.put(
        GalleryPageController(galleryRepository: _galleryRepository()),
        tag: pageCtrlDepth);

    final String? tabTag = _controller.galleryRepository?.tabTag;

    final GalleryItem _item = _controller.galleryItem;

    return CupertinoPageScaffold(
      child: EasyRefresh(
        enableControlFinishRefresh: false,
        enableControlFinishLoad: false,
        onLoad: () async {
          if (_controller.previews.isNotEmpty) {
            Get.to(
              () => AllPreviewPage(),
              transition: Transition.cupertino,
            );
          }
        },
        footer: BezierBounceFooter(
          backgroundColor: Colors.transparent,
          color: CupertinoColors.inactiveGray,
        ),
        child: CustomScrollView(
          controller: _controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            // 导航栏
            Obx(() => CupertinoSliverNavigationBar(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  largeTitle: SelectableText(
                    _controller.topTitle,
                    textAlign: TextAlign.left,
                    maxLines: 3,
                    minLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.secondaryLabel, context),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  middle: _controller.hideNavigationBtn
                      ? null
                      : (_item.imgUrl?.isNotEmpty ?? false
                          ? NavigationBarImage(
                              imageUrl: _item.imgUrl ?? '',
                              scrollController: _controller.scrollController,
                            )
                          : null),
                  trailing: _controller.hideNavigationBtn
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CupertinoButton(
                              padding: const EdgeInsets.all(0),
                              minSize: 38,
                              child: const Icon(
                                LineIcons.tags,
                                size: 26,
                              ),
                              onPressed: () {
                                _controller.addTag();
                              },
                            ),
                            CupertinoButton(
                              padding: const EdgeInsets.all(0),
                              minSize: 38,
                              child: const Icon(
                                LineIcons.share,
                                size: 26,
                              ),
                              onPressed: () {
                                final String _url =
                                    '${Api.getBaseUrl()}/g/${_item.gid}/${_item.token}';
                                logger.v('share $_url');
                                Share.share(_url);
                              },
                            ),
                          ],
                        )
                      : ReadButton(gid: _item.gid ?? '').paddingOnly(right: 4),
                )),
            CupertinoSliverRefreshControl(
              onRefresh: _controller.handOnRefresh,
            ),
            SliverSafeArea(
              top: false,
              bottom: false,
              sliver: GalleryDetail(
                tabTag: tabTag,
                controller: _controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 导航栏封面小图
class NavigationBarImage extends StatelessWidget {
  const NavigationBarImage({
    Key? key,
    required this.imageUrl,
    required this.scrollController,
  }) : super(key: key);

  final String imageUrl;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final double _statusBarHeight = MediaQuery.of(Get.context!).padding.top;
    return GestureDetector(
      onTap: () {
        scrollController.animateTo(0,
            duration: const Duration(milliseconds: 500), curve: Curves.ease);
      },
      child: Container(
        child: CoveTinyImage(
          imgUrl: imageUrl,
          statusBarHeight: _statusBarHeight,
        ),
      ),
    );
  }
}

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
                _DatailWidget(
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

class _DatailWidget extends StatelessWidget {
  const _DatailWidget({
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
          onTap: Global.inDebugMode ? controller.downloadGallery : null,
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
            logger.i('处理后标题 "$title"');
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
        PreviewGrid(
          previews: controller.firstPagePreview,
          gid: state.gid ?? '',
        ),
        MorePreviewButton(hasMorePreview: controller.hasMorePreview),
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
        const SizedBox(height: 26),
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
        const TopComment(showBtn: false),
        const SizedBox(height: 30),
        // Row(children: [_getminiTitle(S.of(context).previews)]),
        PreviewGrid(
          previews: controller.firstPagePreview,
          gid: state.gid ?? '',
        ),
        MorePreviewButton(hasMorePreview: controller.hasMorePreview),
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
                  ? _DatailWidget(
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
