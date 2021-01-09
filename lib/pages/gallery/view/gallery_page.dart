import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:fehviewer/pages/gallery/view/rate_dialog.dart';
import 'package:fehviewer/pages/gallery/view/torrent_dialog.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

import 'archiver_dialog.dart';

const double kHeaderHeight = 200.0 + 52;
const double kPadding = 12.0;
const double kHeaderPaddingTop = 12.0;

class GalleryMainPage extends StatelessWidget {
  const GalleryMainPage({this.tag});

  final String tag;
  @override
  Widget build(BuildContext context) {
    final GalleryPageController controller = Get.find(tag: pageCtrlDepth);
    final GalleryItem _item = controller.galleryItem;
    return CupertinoPageScaffold(
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          // 导航栏
          Obx(() => CupertinoSliverNavigationBar(
                largeTitle: Text(
                  controller.topTitle ?? '',
                  textAlign: TextAlign.left,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                middle: controller.hideNavigationBtn
                    ? null
                    : NavigationBarImage(
                        imageUrl: _item.imgUrl,
                        scrollController: controller.scrollController,
                      ),
                trailing: controller.hideNavigationBtn
                    ? CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        minSize: 0,
                        child: const Icon(
                          CupertinoIcons.share,
                          size: 28,
                        ),
                        onPressed: () {
                          logger.v('share ${_item.url}');
                          Share.share(' ${_item.url}');
                        },
                      )
                    : ReadButton(gid: _item.gid),
              )),
          CupertinoSliverRefreshControl(
            onRefresh: controller.handOnRefresh,
          ),
          const SliverSafeArea(
            top: false,
            bottom: false,
            sliver: GalleryContainer(),
          ),
        ],
      ),
    );
  }
}

// 导航栏封面小图
class NavigationBarImage extends StatelessWidget {
  const NavigationBarImage({
    Key key,
    @required this.imageUrl,
    @required this.scrollController,
  }) : super(key: key);

  final String imageUrl;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final double _statusBarHeight = MediaQuery.of(Get.context).padding.top;
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
class GalleryContainer extends StatelessWidget {
  const GalleryContainer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GalleryPageController controller = Get.find(tag: pageCtrlDepth);

    Widget _getDetail(GalleryItem state) {
      final List _w = <Widget>[
        Expanded(
          child: Obx(() => TextBtn(
                controller.isRatinged
                    ? FontAwesomeIcons.solidStar
                    : FontAwesomeIcons.star,
                title: S.of(context).p_Rate,
                onTap: state.apiuid?.isNotEmpty ?? false
                    ? () {
                        showRateDialog();
                      }
                    : null,
              )),
        ),
        Expanded(
          child: TextBtn(
            FontAwesomeIcons.solidArrowAltCircleDown,
            title: S.of(context).p_Download,
          ),
        ),
        Expanded(
          child: TextBtn(
            FontAwesomeIcons.magnet,
            title: '${S.of(context).p_Torrent}(${state.torrentcount ?? 0})',
            onTap: state.torrents.isNotEmpty
                ? () async {
                    showTorrentDialog();
                  }
                : null,
          ),
        ),
        Expanded(
          child: TextBtn(
            FontAwesomeIcons.solidFileArchive,
            title: S.of(Get.context).p_Archiver,
            onTap: () async {
              showArchiverDialog();
            },
          ),
        ),
        Expanded(
          child: TextBtn(
            FontAwesomeIcons.solidImages,
            title: S.of(context).p_Similar,
            onTap: () {
              final String title = state.englishTitle
                  .replaceAll(RegExp(r'(\[.*?\]|\(.*?\))|{.*?}'), '')
                  .trim()
                  .split('\|')
                  .first;
              logger.i(' search "$title"');
              NavigatorUtil.goGalleryListBySearch(simpleSearch: '"$title"');
              // NavigatorUtil.goGalleryListBySearch(simpleSearch: title);
            },
          ),
        ),
      ];

      return Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _w,
          ),
          Divider(
            height: 0.5,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey4, context),
          ),
          // 标签
          TagBox(listTagGroup: state.tagGroup),
          const TopComment(),
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 0.5,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey4, context),
          ),
          PreviewGrid(
            previews: controller.firstPagePreview,
            gid: state.gid,
          ),
          MorePreviewButton(hasMorePreview: controller.hasMorePreview),
        ],
      );
    }

    Widget fromItem() {
      final GalleryItem galleryItem = controller.galleryItem;
      final Object tabIndex = controller.tabIndex;

      return SliverToBoxAdapter(
        child: Column(
          children: <Widget>[
            GalleryHeader(
              galleryItem: galleryItem,
              tabIndex: tabIndex,
            ),
            Divider(
              height: 0.5,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey4, context),
            ),
            controller.obx(
              (GalleryItem state) {
                return _getDetail(state);
              },
              onLoading: Container(
                // height: Get.size.height - _top * 3 - kHeaderHeight,
                height: 200,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 50),
                child: const CupertinoActivityIndicator(
                  radius: 14.0,
                ),
              ),
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

    Widget fromUrl() {
      return controller.obx(
          (state) {
            return SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  GalleryHeader(
                    galleryItem: state,
                    tabIndex: '',
                  ),
                  Divider(
                    height: 0.5,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey4, context),
                  ),
                  _getDetail(state),
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
          onError: (err) {
            logger.e(' $err');
            return SliverFillRemaining(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 50, top: 50),
                child: GalleryErrorPage(
                  onTap: controller.handOnRefreshAfterErr,
                ),
              ),
            );
          });
    }

    return controller.fromUrl ? fromUrl() : fromItem();
  }
}
