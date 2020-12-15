import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/pages/tab/controller/gallery_controller.dart';
import 'package:FEhViewer/pages/tab/view/gallery_base.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import 'tab_base.dart';

class GalleryListTab extends GetView<GalleryController> {
  const GalleryListTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);

  final String tabIndex;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final CustomScrollView customScrollView = CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 4),
          largeTitle: Text(controller.title),
          trailing: Container(
            width: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 搜索按钮
                CupertinoButton(
                  minSize: 40,
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    FontAwesomeIcons.search,
                    size: 20,
                  ),
                  onPressed: () {
                    NavigatorUtil.showSearch();
                  },
                ),
                // 筛选按钮
                CupertinoButton(
                  minSize: 40,
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    FontAwesomeIcons.filter,
                    size: 20,
                  ),
                  onPressed: () {
                    // Global.logger.v('${EHUtils.convNumToCatMap(1)}');
                    GalleryBase()
                        .showFilterSetting(context, showAdevance: true);
                  },
                ),
                // 页码跳转按钮
                CupertinoButton(
                  minSize: 40,
                  padding: const EdgeInsets.only(right: 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                      color: CupertinoColors.activeBlue,
                      child: Obx(() => Text(
                            '${controller.curPage.value + 1}',
                            style:
                                const TextStyle(color: CupertinoColors.white),
                          )),
                    ),
                  ),
                  onPressed: () {
                    controller.jumpToPage();
                  },
                ),
              ],
            ),
          ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await controller.reloadData();
          },
        ),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: _getGalleryList(),
        ),
        SliverToBoxAdapter(
          child: GetX<GalleryController>(builder: (_) {
            return Container(
              padding: const EdgeInsets.only(top: 50, bottom: 100),
              child: controller.isLoadMore.value
                  ? const CupertinoActivityIndicator(
                      radius: 14,
                    )
                  : Container(),
            );
          }),
        ),
      ],
    );

    return CupertinoPageScaffold(
      child: customScrollView,
    );
  }

  Widget _getGalleryList() {
    return controller.obx(
        (state) {
          return getGalleryList(
            state,
            tabIndex,
            maxPage: controller.maxPage,
            curPage: controller.curPage.value,
            loadMord: controller.loadDataMore,
          );
        },
        onLoading: SliverFillRemaining(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 50),
            child: const CupertinoActivityIndicator(
              radius: 14.0,
            ),
          ),
        ),
        onError: (err) {
          Global.logger.e(' $err');
          return SliverFillRemaining(
            child: Container(
              padding: const EdgeInsets.only(bottom: 50),
              child: GalleryErrorPage(
                onTap: controller.reLoadDataFirst,
              ),
            ),
          );
        });
  }
}
