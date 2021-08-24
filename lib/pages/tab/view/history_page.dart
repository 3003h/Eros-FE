import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/tab/controller/history_view_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
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

class HistoryTab extends StatefulWidget {
  const HistoryTab({Key? key}) : super(key: key);

  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final controller = Get.find<HistoryViewController>();
  final EhTabController ehTabController = EhTabController();

  @override
  void initState() {
    super.initState();

    ehTabController.scrollToTopCall = () => controller.srcollToTop(context);
    ehTabController.scrollToTopRefreshCall =
        () => controller.srcollToTopRefresh(context);
    tabPages.scrollControllerMap[controller.tabTag] = ehTabController;
  }

  @override
  Widget build(BuildContext context) {
    logger.v('build Historyview');
    final String _title = L10n.of(context).tab_history;

    final Widget sliverNavigationBar = CupertinoSliverNavigationBar(
      transitionBetweenRoutes: false,
      largeTitle: Text(_title),
      trailing: Container(
        width: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 清除按钮
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                LineIcons.alternateTrash,
                size: 26,
              ),
              onPressed: () {
                controller.clearHistory();
              },
            ),
          ],
        ),
      ),
    );

    final Widget navigationBar = CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      padding: const EdgeInsetsDirectional.only(end: 4),
      leading: controller.getLeading(context),
      middle: GestureDetector(
          onTap: () => controller.srcollToTop(context), child: Text(_title)),
      trailing: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 清除按钮
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                LineIcons.alternateTrash,
                size: 26,
              ),
              onPressed: () {
                controller.clearHistory();
              },
            ),
          ],
        ),
      ),
    );
    final Widget customScrollView = CustomScrollView(
      cacheExtent: 500,
      // controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
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
          onRefresh: controller.syncHistory,
        ),
        SliverSafeArea(
          top: false,
          sliver: GetBuilder<HistoryController>(
            init: HistoryController(),
            builder: (logic) {
              return getGalleryList(
                logic.historys,
                controller.tabTag,
                key: controller.sliverAnimatedListKey,
              );
            },
          ),
        ),
      ],
    );

    return CupertinoPageScaffold(
        // navigationBar: navigationBar,
        child: CupertinoScrollbar(
            controller: PrimaryScrollController.of(context),
            child: customScrollView));
  }
}
