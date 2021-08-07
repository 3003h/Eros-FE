import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/tab/controller/enum.dart';
import 'package:fehviewer/pages/tab/controller/toplist_controller.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/utils/cust_lib/persistent_header_builder.dart';
import 'package:fehviewer/utils/cust_lib/sliver/sliver_persistent_header.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keframe/size_cache_widget.dart';
import 'package:line_icons/line_icons.dart';

import 'gallery_base.dart';

class ToplistTab extends GetView<TopListViewController> {
  const ToplistTab({
    Key? key,
    this.tabTag,
    this.scrollController,
  }) : super(key: key);
  final String? tabTag;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    // String _title = L10n.of(context).tab_toplist;

    final navigationBar = Obx(() {
      return CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        padding: const EdgeInsetsDirectional.only(end: 4),
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(controller.getTopListTitle),
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
            CupertinoButton(
              padding: const EdgeInsets.all(0.0),
              minSize: 36,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    LineIcons.sortAmountDown,
                    size: 26,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      controller.toplistText,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              onPressed: () => controller.setToplist(context),
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
    });

    final Widget customScrollView = CustomScrollView(
      cacheExtent: 500,
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        // sliverNavigationBar,
        SliverFloatingPinnedPersistentHeader(
          delegate: SliverFloatingPinnedPersistentHeaderBuilder(
            minExtentProtoType: SizedBox(
              height: context.mediaQueryPadding.top,
            ),
            maxExtentProtoType: navigationBar,
            builder: (_, __, ___) => navigationBar,
          ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: controller.onRefresh,
        ),
        SliverSafeArea(
          top: false,
          sliver: _getTopList(),
        ),
        _endIndicator(),
      ],
    );

    return CupertinoPageScaffold(
      child: CupertinoScrollbar(
        controller: scrollController,
        child: SizeCacheWidget(child: customScrollView),
      ),
    );
  }

  Widget _getTopList() {
    return controller.obx(
      (List<GalleryItem>? state) => getGalleryList(
        state,
        tabTag,
        maxPage: controller.maxPage,
        curPage: controller.curPage.value,
        loadMord: controller.loadDataMore,
      ),
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
      },
    );
  }

  Widget _endIndicator() {
    return SliverToBoxAdapter(
      child: Obx(() => Container(
          alignment: Alignment.center,
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
                        L10n.of(Get.context!).list_load_more_fail,
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
          }())),
    );
  }
}
