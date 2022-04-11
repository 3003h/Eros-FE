import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/filter/filter.dart';
import 'package:fehviewer/pages/tab/controller/gallery_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/cust_lib/persistent_header_builder.dart';
import 'package:fehviewer/utils/cust_lib/sliver/sliver_persistent_header.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/widget/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:keframe/size_cache_widget.dart';

import '../comm.dart';
import 'constants.dart';
import 'tab_base.dart';

class GalleryListTab extends StatefulWidget {
  const GalleryListTab({Key? key}) : super(key: key);

  @override
  _GalleryListTabState createState() => _GalleryListTabState();
}

class _GalleryListTabState extends State<GalleryListTab> {
  final controller = Get.find<GalleryViewController>();
  final EhTabController ehTabController = EhTabController();

  GlobalKey centerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    controller.initStateForListPage(
      context: context,
      ehTabController: ehTabController,
    );
  }

  @override
  Widget build(BuildContext context) {
    logger.v('build GalleryListTab');

    Widget getSliverNavigationBar() {
      return CupertinoSliverNavigationBar(
        transitionBetweenRoutes: false,
        padding: const EdgeInsetsDirectional.only(end: 4),
        largeTitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(controller.title),
            Obx(() {
              if (controller.isBackgroundRefresh) {
                return const CupertinoActivityIndicator(
                  radius: 10,
                ).paddingSymmetric(horizontal: 8);
              } else {
                return const SizedBox();
              }
            }),
          ],
        ),
        leading: controller.getLeading(context),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 搜索按钮
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.search,
                size: 22,
              ),
              onPressed: () {
                NavigatorUtil.goSearchPage();
              },
            ),
            // 筛选按钮
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.filter,
                size: 22,
              ),
              onPressed: () {
                // logger.v('${EHUtils.convNumToCatMap(1)}');
                showFilterSetting();
              },
            ),
            // 页码跳转按钮
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.only(right: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.activeBlue, context),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Obx(() => Text(
                      '${controller.curPage + 1}',
                      style: TextStyle(
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.activeBlue, context)),
                    )),
              ),
              onPressed: () {
                controller.showJumpToPage();
              },
            ),
          ],
        ),
      );
    }

    final CupertinoNavigationBar navigationBar = CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      padding: const EdgeInsetsDirectional.only(end: 4),
      middle: GestureDetector(
        onTap: () => controller.srcollToTop(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(controller.title),
            Obx(() {
              if (controller.isBackgroundRefresh)
                return const CupertinoActivityIndicator(
                  radius: 10,
                ).paddingSymmetric(horizontal: 8);
              else
                return const SizedBox();
            }),
          ],
        ),
      ),
      leading: controller.getLeading(context),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 模拟下拉刷新按钮
          // if (kDebugMode)
          //   CupertinoButton(
          //     minSize: 40,
          //     padding: const EdgeInsets.all(0),
          //     child: const Icon(
          //       LineIcons.upload,
          //       size: 26,
          //     ),
          //     onPressed: controller.onRefresh,
          //   ),
          // 搜索按钮
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              FontAwesomeIcons.search,
              size: 22,
            ),
            onPressed: () {
              NavigatorUtil.goSearchPage();
            },
          ),
          // 筛选按钮
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              FontAwesomeIcons.filter,
              size: 22,
            ),
            onPressed: () {
              // logger.v('${EHUtils.convNumToCatMap(1)}');
              showFilterSetting();
            },
          ),
          // 页码跳转按钮
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.activeBlue, context),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() => Text(
                    '${controller.curPage + 1}',
                    style: TextStyle(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.activeBlue, context)),
                  )),
            ),
            onPressed: () {
              controller.showJumpToPage();
            },
          ),
        ],
      ),
    );

    final Widget customScrollView = CustomScrollView(
      cacheExtent: kTabViewCacheExtent,
      physics: const AlwaysScrollableScrollPhysics(),
      // center: centerKey,
      slivers: <Widget>[
        SliverFloatingPinnedPersistentHeader(
          delegate: SliverFloatingPinnedPersistentHeaderBuilder(
            minExtentProtoType: SizedBox(
              height: context.mediaQueryPadding.top,
            ),
            maxExtentProtoType: navigationBar,
            builder: (_, __, ___) => navigationBar,
          ),
        ),
        EhCupertinoSliverRefreshControl(
          onRefresh: () => controller.onRefresh(),
        ),
        // Obx(() {
        //   logger.d('build previousList ${controller.previousList.length}');
        //   if (controller.previousList.isEmpty) {
        //     logger.d('previousList empty');
        //     return const SliverToBoxAdapter(
        //       child: SizedBox(),
        //     );
        //   } else {
        //     logger.d('previousList not empty');
        //     return getGalleryList(
        //       controller.previousList,
        //       controller.tabTag,
        //       curPage: controller.curPage.value,
        //     );
        //   }
        // }),
        SliverPadding(
          padding: EdgeInsets.zero,
          key: centerKey,
        ),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: _getGalleryList(),
        ),
        Obx(() {
          return EndIndicator(
            pageState: controller.pageState,
            loadDataMore: controller.loadDataMore,
          );
        }),
      ],
    );

    // return CupertinoPageScaffold(
    //   // navigationBar: navigationBar,
    //   child: SizeCacheWidget(child: customScrollView),
    // );

    return CupertinoPageScaffold(
      // navigationBar: navigationBar,
      child: CupertinoScrollbar(
        scrollbarOrientation: ScrollbarOrientation.right,
        child: SizeCacheWidget(child: customScrollView),
        controller: PrimaryScrollController.of(context),
      ),
    );
  }

  Widget _getGalleryList() {
    return controller.obx(
        (List<GalleryProvider>? state) {
          return getGallerySliverList(
            state,
            controller.heroTag,
            maxPage: controller.maxPage,
            curPage: controller.curPage,
            lastComplete: controller.lastComplete,
            // key: controller.sliverAnimatedListKey,
            lastTopitemIndex: controller.lastTopitemIndex,
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
          logger.e(' $err');
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

class ItemModel {
  ItemModel(this.title, this.icon);

  String title;
  IconData icon;
}
