import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/tab/controller/toplist_controller.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/utils/cust_lib/persistent_header_builder.dart';
import 'package:fehviewer/utils/cust_lib/sliver/sliver_persistent_header.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/widget/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keframe/size_cache_widget.dart';
import 'package:line_icons/line_icons.dart';

import '../comm.dart';
import 'constants.dart';
import 'gallery_base.dart';

class ToplistTab extends StatefulWidget {
  const ToplistTab({Key? key}) : super(key: key);

  @override
  _ToplistTabState createState() => _ToplistTabState();
}

class _ToplistTabState extends State<ToplistTab> {
  final controller = Get.find<TopListViewController>();
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
    final navigationBar = Obx(() {
      return CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        padding: const EdgeInsetsDirectional.only(end: 4),
        leading: controller.getLeading(context),
        middle: GestureDetector(
          onTap: () => controller.srcollToTop(context),
          child: Row(
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
      cacheExtent: kTabViewCacheExtent,
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
        EhCupertinoSliverRefreshControl(
          onRefresh: controller.onRefresh,
        ),
        SliverSafeArea(
          top: false,
          sliver: _getTopList(),
        ),
        Obx(() {
          return EndIndicator(
            pageState: controller.pageState,
            loadDataMore: controller.loadDataMore,
          );
        }),
      ],
    );

    return CupertinoPageScaffold(
      child: CupertinoScrollbar(
        controller: PrimaryScrollController.of(context),
        child: SizeCacheWidget(child: customScrollView),
      ),
    );
  }

  Widget _getTopList() {
    return controller.obx(
      (List<GalleryItem>? state) => getGalleryList(
        state,
        controller.tabTag,
        maxPage: controller.maxPage,
        curPage: controller.curPage.value,
        lastComplete: controller.lastComplete,
        centerKey: centerKey,
        key: controller.sliverAnimatedListKey,
        lastTopitemIndex: controller.lastTopitemIndex,
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
}
