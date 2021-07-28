import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/tab/controller/history_controller.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/utils/cust_lib/persistent_header_builder.dart';
import 'package:fehviewer/utils/cust_lib/sliver/sliver_persistent_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keframe/size_cache_widget.dart';
import 'package:line_icons/line_icons.dart';

class HistoryTab extends GetView<HistoryViewController> {
  const HistoryTab({Key? key, this.tabTag, this.scrollController})
      : super(key: key);
  final String? tabTag;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
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

    final CupertinoNavigationBar navigationBar = CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      middle: Text(_title),
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
    final Widget customScrollView = CustomScrollView(
      cacheExtent: 500,
      controller: scrollController,
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
        // sliverNavigationBar,
        // SliverPadding(
        //   padding: EdgeInsets.only(
        //       top: context.mediaQueryPadding.top +
        //           kMinInteractiveDimensionCupertino),
        //   sliver: CupertinoSliverRefreshControl(
        //     onRefresh: () async {
        //       await controller.reloadData();
        //     },
        //   ),
        // ),
        SliverSafeArea(
            top: false,
            // sliver: _getGalleryList(),
            sliver: GetBuilder<HistoryController>(
              init: HistoryController(),
              builder: (_) {
                return getGalleryList(_.historys, tabTag);
              },
            )
            // sliver: _getGalleryList(),
            ),
      ],
    );

    return CupertinoPageScaffold(
        // navigationBar: navigationBar,
        child: CupertinoScrollbar(
            controller: scrollController,
            child: SizeCacheWidget(child: customScrollView)));
  }
}
