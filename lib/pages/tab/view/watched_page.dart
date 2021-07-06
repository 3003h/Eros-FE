import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/filter/filter.dart';
import 'package:fehviewer/pages/tab/controller/enum.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/pages/tab/controller/watched_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/cust_lib/persistent_header_builder.dart';
import 'package:fehviewer/utils/cust_lib/sliver/sliver_persistent_header.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keframe/size_cache_widget.dart';
import 'package:line_icons/line_icons.dart';

import 'tab_base.dart';

class WatchedListTab extends GetView<WatchedViewController> {
  const WatchedListTab({
    Key? key,
    this.tabIndex,
    this.scrollController,
  }) : super(key: key);

  final String? tabIndex;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final Widget sliverNavigationBar = CupertinoSliverNavigationBar(
      padding: const EdgeInsetsDirectional.only(end: 4),
      // largeTitle: Text(controller.title),
      largeTitle: Row(
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 搜索按钮
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              LineIcons.search,
              size: 26,
            ),
            onPressed: () {
              final bool fromTabItem =
                  Get.find<TabHomeController>().tabMap[tabIndex] ?? false;
              NavigatorUtil.showSearch(
                  searchType: SearchType.watched, fromTabItem: fromTabItem);
            },
          ),
          // 筛选按钮
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              LineIcons.filter,
              size: 26,
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
                    '${controller.curPage.value + 1}',
                    style: TextStyle(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.activeBlue, context)),
                  )),
            ),
            onPressed: () {
              controller.jumpToPage();
            },
          ),
        ],
      ),
    );

    final CupertinoNavigationBar navigationBar = CupertinoNavigationBar(
      padding: const EdgeInsetsDirectional.only(end: 4),
      // largeTitle: Text(controller.title),
      middle: Row(
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 搜索按钮
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              LineIcons.search,
              size: 26,
            ),
            onPressed: () {
              final bool fromTabItem =
                  Get.find<TabHomeController>().tabMap[tabIndex] ?? false;
              NavigatorUtil.showSearch(
                  searchType: SearchType.watched, fromTabItem: fromTabItem);
            },
          ),
          // 筛选按钮
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              LineIcons.filter,
              size: 26,
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
                    '${controller.curPage.value + 1}',
                    style: TextStyle(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.activeBlue, context)),
                  )),
            ),
            onPressed: () {
              controller.jumpToPage();
            },
          ),
        ],
      ),
    );

    final CustomScrollView customScrollView = CustomScrollView(
      cacheExtent: 500,
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        // sliverNavigationBar,
        SliverFloatingPinnedPersistentHeader(
          delegate: SliverFloatingPinnedPersistentHeaderBuilder(
            minExtentProtoType: const SizedBox(),
            maxExtentProtoType: navigationBar,
            builder: (_, __, ___) => navigationBar,
          ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: controller.onRefresh,
        ),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: _getGalleryList(),
        ),
        _endIndicator(),
      ],
    );

    return CupertinoPageScaffold(
      // navigationBar: navigationBar,
      child: CupertinoScrollbar(
          controller: scrollController,
          child: SizeCacheWidget(child: customScrollView)),
    );
  }

  Widget _endIndicator() {
    return SliverToBoxAdapter(
      child: Obx(() => Container(
            padding: const EdgeInsets.only(top: 50, bottom: 100),
            child: () {
              switch (controller.pageState) {
                case PageState.None:
                  return Container();
                case PageState.Loading:
                  return const CupertinoActivityIndicator(
                    radius: 14,
                  );
                case PageState.LoadingException:
                case PageState.LoadingError:
                  return GestureDetector(
                    onTap: controller.loadDataMore,
                    child: Column(
                      children: <Widget>[
                        const Icon(
                          Icons.error,
                          size: 40,
                          color: CupertinoColors.systemRed,
                        ),
                        Text(
                          S.of(Get.context!).list_load_more_fail,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                default:
                  return Container();
              }
            }(),
          )),
    );
  }

  Widget _getGalleryList() {
    return controller.obx(
        (List<GalleryItem>? state) {
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
