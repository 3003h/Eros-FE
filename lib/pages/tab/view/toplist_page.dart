import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/tab/controller/toplist_controller.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/utils/cust_lib/persistent_header_builder.dart';
import 'package:fehviewer/utils/cust_lib/sliver/sliver_persistent_header.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/widget/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';

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
              minSize: 40,
              child: Stack(
                alignment: Alignment.centerRight,
                // mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // const Icon(
                  //   FontAwesomeIcons.arrowDownWideShort,
                  //   size: 20,
                  // ),
                  const Icon(
                    CupertinoIcons.sort_down,
                    size: 28,
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
                constraints: const BoxConstraints(minWidth: 24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.activeBlue, context),
                    width: 1.8,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Obx(() => Text(
                      '${controller.curPage + 1}',
                      textScaleFactor: 0.9,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
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
        _buildListView(context),
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
        scrollbarOrientation: ScrollbarOrientation.right,
        controller: PrimaryScrollController.of(context),
        child: SizeCacheWidget(child: customScrollView),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return SliverSafeArea(
      top: false,
      bottom: false,
      sliver: GetBuilder<TopListViewController>(
        global: false,
        init: controller,
        id: controller.listViewId,
        builder: (logic) {
          final status = logic.status;

          if (status.isLoading) {
            return SliverFillRemaining(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 50),
                child: const CupertinoActivityIndicator(
                  radius: 14.0,
                ),
              ),
            );
          }

          if (status.isError) {
            return SliverFillRemaining(
              child: Container(
                padding: const EdgeInsets.only(bottom: 50),
                child: GalleryErrorPage(
                  onTap: logic.reLoadDataFirst,
                  error: status.errorMessage,
                ),
              ),
            );
          }

          if (status.isSuccess) {
            return getGallerySliverList(
              logic.state,
              controller.heroTag,
              maxPage: controller.maxPage,
              curPage: controller.curPage,
              lastComplete: controller.lastComplete,
              centerKey: centerKey,
              key: controller.sliverAnimatedListKey,
              lastTopitemIndex: controller.lastTopitemIndex,
            );
          }

          return SliverFillRemaining(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.hippo,
                    size: 100,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey, context),
                  ),
                  Text(''),
                ],
              ),
            ).autoCompressKeyboard(context),
          );
        },
      ),
    );
  }
}
