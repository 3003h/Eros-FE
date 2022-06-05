import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/widget/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

import '../comm.dart';
import '../controller/gallery_page_state.dart';
import 'detail.dart';

// const double kHeaderHeight = 200.0 + 52;

class GalleryMainPage extends StatefulWidget {
  @override
  _GalleryMainPageState createState() => _GalleryMainPageState();
}

class _GalleryMainPageState extends State<GalleryMainPage> {
  late final GalleryPageController _controller;
  final _tag = pageCtrlTag;

  GalleryPageState get _pageState => _controller.gState;

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
          .addListener(_controller.scrollControllerLister);
    });
  }

  @override
  void dispose() {
    super.dispose();
    // deletePageController(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final dynamic tabTag = _pageState.galleryRepository?.tabTag;
    final GalleryProvider? _item = _pageState.galleryProvider;

    return CupertinoPageScaffold(
      child: CupertinoScrollbar(
        controller: PrimaryScrollController.of(context),
        child: EasyRefresh(
          enableControlFinishRefresh: false,
          enableControlFinishLoad: false,
          onLoad: () async {
            if (_pageState.images.isNotEmpty) {
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
              CupertinoSliverNavigationBar(
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
                  () => _pageState.hideNavigationBtn
                      ? const SizedBox()
                      : GetBuilder<GalleryPageController>(
                          id: GetIds.PAGE_VIEW_HEADER,
                          tag: pageCtrlTag,
                          builder: (logic) {
                            return NavigationBarImage(
                              imageUrl:
                                  logic.gState.galleryProvider?.imgUrl ?? '',
                              scrollController: logic.scrollController,
                            );
                          },
                        ),
                ),
                trailing: Obx(() => _pageState.hideNavigationBtn
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            minSize: 38,
                            child: const MouseRegionClick(
                              child: Icon(
                                FontAwesomeIcons.tags,
                                size: 22,
                              ),
                            ),
                            onPressed: () {
                              _controller.addTag();
                            },
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            minSize: 38,
                            child: const MouseRegionClick(
                              child: Icon(
                                FontAwesomeIcons.share,
                                size: 22,
                              ),
                            ),
                            onPressed: () {
                              if (_item == null) {
                                return;
                              }
                              final String _url =
                                  '${Api.getBaseUrl()}/g/${_item.gid}/${_item.token}';
                              logger.v('share $_url');
                              Share.share(_url);
                            },
                          ),
                        ],
                      )
                    : ReadButton(gid: _item?.gid ?? '0').paddingOnly(right: 4)),
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
      ),
    );
  }
}
