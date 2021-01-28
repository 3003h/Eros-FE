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
import 'package:fehviewer/utils/cust_lib/selectable_text_s.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SelectableText;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

import 'archiver_dialog.dart';

const double kHeaderHeight = 200.0 + 52;
const double kPadding = 12.0;
const double kHeaderPaddingTop = 12.0;

class GalleryMainPage extends StatelessWidget {
  const GalleryMainPage({this.tabTag});

  final String tabTag;
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
                largeTitle: SelectableText(
                  controller.topTitle ?? '',
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
                          final String _url =
                              '${Api.getBaseUrl()}/g/${_item.gid}/${_item.token}';
                          logger.v('share $_url');
                          Share.share(_url);
                        },
                      )
                    : ReadButton(gid: _item.gid),
              )),
          CupertinoSliverRefreshControl(
            onRefresh: controller.handOnRefresh,
          ),
          SliverSafeArea(
            top: false,
            bottom: false,
            sliver: GalleryContainer(tabTag: tabTag),
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
    this.tabTag,
  }) : super(key: key);

  final String tabTag;

  @override
  Widget build(BuildContext context) {
    final GalleryPageController _controller = Get.find(tag: pageCtrlDepth);

    Widget _getDetail(GalleryItem state) {
      final List<Widget> _w = <Widget>[
        // 进行评分
        Expanded(
          child: Obx(() => TextBtn(
                _controller.isRatinged
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
        // 画廊下载
        Expanded(
          child: TextBtn(
            FontAwesomeIcons.solidArrowAltCircleDown,
            title: S.of(context).p_Download,
            onTap: Global.inDebugMode ? _controller.downloadGallery : null,
          ),
        ),
        // 种子下载
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
        // archiver
        Expanded(
          child: TextBtn(
            FontAwesomeIcons.solidFileArchive,
            title: S.of(Get.context).p_Archiver,
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
            previews: _controller.firstPagePreview,
            gid: state.gid,
          ),
          MorePreviewButton(hasMorePreview: _controller.hasMorePreview),
        ],
      );
    }

    Widget fromItem() {
      final GalleryItem galleryItem = _controller.galleryItem;

      return SliverToBoxAdapter(
        child: Column(
          children: <Widget>[
            GalleryHeader(
              galleryItem: galleryItem,
              tabTag: tabTag,
            ),
            Divider(
              height: 0.5,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey4, context),
            ),
            _controller.obx(
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
                    onTap: _controller.handOnRefreshAfterErr,
                  ),
                );
              },
            )
          ],
        ),
      );
    }

    Widget fromUrl() {
      return _controller.obx(
          (state) {
            return SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  GalleryHeader(
                    galleryItem: state,
                    tabTag: '',
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
                  onTap: _controller.handOnRefreshAfterErr,
                ),
              ),
            );
          });
    }

    return _controller.fromUrl ? fromUrl() : fromItem();
  }
}
