import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/widget/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:share/share.dart';

import '../comm.dart';
import 'detail.dart';

const double kHeaderHeight = 200.0 + 52;
const double kPadding = 12.0;
const double kHeaderPaddingTop = 12.0;

class GalleryRepository {
  GalleryRepository({
    this.tabTag,
    this.item,
    this.url,
    this.jumpSer,
  });

  final dynamic tabTag;
  final GalleryItem? item;
  final String? url;
  final int? jumpSer;
}

class GalleryMainPage extends StatefulWidget {
  @override
  _GalleryMainPageState createState() => _GalleryMainPageState();
}

class _GalleryMainPageState extends State<GalleryMainPage> {
  late final GalleryPageController _controller;
  final _tag = pageCtrlDepth;

  @override
  void initState() {
    super.initState();
    logger.d('initState pageCtrlDepth:$pageCtrlDepth');
    initPageController(tag: _tag);
    _controller = Get.put(GalleryPageController(), tag: _tag);
  }

  @override
  void dispose() {
    super.dispose();
    deletePageController(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final dynamic tabTag = _controller.galleryRepository?.tabTag;

    final GalleryItem _item = _controller.galleryItem;

    return CupertinoPageScaffold(
      child: EasyRefresh(
        enableControlFinishRefresh: false,
        enableControlFinishLoad: false,
        onLoad: () async {
          if (_controller.images.isNotEmpty) {
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
          controller: _controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            // 导航栏
            CupertinoSliverNavigationBar(
              padding: const EdgeInsetsDirectional.only(end: 10),
              largeTitle: Obx(() => SelectableText(
                    _controller.topTitle,
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    minLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.secondaryLabel, context),
                      fontWeight: FontWeight.normal,
                    ),
                  )),
              middle: Obx(() => _controller.hideNavigationBtn
                  ? const SizedBox()
                  : (_item.imgUrl?.isNotEmpty ?? false
                      ? NavigationBarImage(
                          imageUrl: _item.imgUrl ?? '',
                          scrollController: _controller.scrollController,
                        )
                      : const SizedBox())),
              trailing: Obx(() => _controller.hideNavigationBtn
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
                  : ReadButton(gid: _item.gid ?? '').paddingOnly(right: 4)),
            ),
            EhCupertinoSliverRefreshControl(
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
