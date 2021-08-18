import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/tab/controller/history_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/utils/cust_lib/persistent_header_builder.dart';
import 'package:fehviewer/utils/cust_lib/sliver/sliver_persistent_header.dart';
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
            // 同步按钮
            // CupertinoButton(
            //   minSize: 40,
            //   padding: const EdgeInsets.all(0),
            //   child: const Icon(
            //     LineIcons.alternateSync,
            //     size: 26,
            //   ),
            //   onPressed: () {
            //     controller.syncHistory();
            //   },
            // ),
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
        // sliverNavigationBar,
        // SliverPadding(
        //   padding: EdgeInsets.only(
        //       top: context.mediaQueryPadding.top +
        //           kMinInteractiveDimensionCupertino),
        //   sliver: EhCupertinoSliverRefreshControl(
        //     onRefresh: () async {
        //       await controller.reloadData();
        //     },
        //   ),
        // ),
        EhCupertinoSliverRefreshControl(
          onRefresh: controller.syncHistory,
        ),
        SliverSafeArea(
            top: false,
            // sliver: _getGalleryList(),
            sliver: GetBuilder<HistoryController>(
              init: HistoryController(),
              builder: (_) {
                return getGalleryList(_.historys, controller.tabTag);
              },
            )
            // sliver: _getGalleryList(),
            ),
      ],
    );

    return CupertinoPageScaffold(
        // navigationBar: navigationBar,
        child: CupertinoScrollbar(
            controller: PrimaryScrollController.of(context),
            child: SizeCacheWidget(child: customScrollView)));
  }
}
