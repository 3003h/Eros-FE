import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_main/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery_main/view/gallery_widget.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

const double kHeaderHeight = 200.0 + 52;
const double kPadding = 12.0;
const double kHeaderPaddingTop = 12.0;

class GalleryPage extends StatelessWidget {
  const GalleryPage({this.tag});

  final String tag;
  @override
  Widget build(BuildContext context) {
    final GalleryPageController controller =
        Get.find(tag: '${Get.find<DepthService>().pageCtrlDepth}');
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
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                        minSize: 0,
                        child: const Icon(
                          FontAwesomeIcons.share,
                          size: 26,
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
            sliver: SliverToBoxAdapter(
              child: GalleryContainer(),
            ),
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
    final GalleryPageController controller =
        Get.find(tag: '${Get.find<DepthService>().pageCtrlDepth}');

    Widget fromItem() {
      final GalleryItem galleryItem = controller.galleryItem;
      final Object tabIndex = controller.tabIndex;
      return Container(
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
                return Column(
                  children: <Widget>[
                    // 标签
                    TagBox(listTagGroup: state.tagGroup),
                    TopComment(comment: state.galleryComment),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 0.5,
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey4, context),
                    ),
                    PreviewGrid(
                      previews: controller.firstPagePreview,
                      gid: galleryItem.gid,
                    ),
                    MorePreviewButton(
                        hasMorePreview: controller.hasMorePreview),
                  ],
                );
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
            )
          ],
        ),
      );
    }

    Widget fromUrl() {
      return Container(
        child: controller.obx((state) {
          return Column(
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
              Column(
                children: <Widget>[
                  // 标签
                  TagBox(listTagGroup: state.tagGroup),
                  TopComment(comment: state.galleryComment),
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
              ),
            ],
          );
        },
            onLoading: Container(
              height: Get.size.height - 200,
              // height: 200,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 50),
              child: const CupertinoActivityIndicator(
                radius: 14.0,
              ),
            )),
      );
    }

    return controller.fromUrl ? fromUrl() : fromItem();
  }
}
