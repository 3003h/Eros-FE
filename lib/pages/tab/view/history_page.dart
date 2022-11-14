import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/tab/controller/history_view_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
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

class HistoryTab extends StatefulWidget {
  const HistoryTab({Key? key}) : super(key: key);

  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final controller = Get.find<HistoryViewController>();
  final EhTabController ehTabController = EhTabController();
  final EhConfigService _ehConfigService = Get.find();

  @override
  void initState() {
    super.initState();

    ehTabController.scrollToTopCall = () => controller.scrollToTop(context);
    ehTabController.scrollToTopRefreshCall =
        () => controller.scrollToTopRefresh(context);
    if (controller.heroTag != null) {
      tabPages.scrollControllerMap[controller.heroTag!] = ehTabController;
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.v('build Historyview');
    final String _title = L10n.of(context).tab_history;

    bool isRefresh = false;
    final navigationBar = CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      padding: const EdgeInsetsDirectional.only(end: 4),
      leading: controller.getLeading(context),
      middle: GestureDetector(
          onTap: () => controller.scrollToTop(context), child: Text(_title)),
      trailing: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (GetPlatform.isDesktop)
              StatefulBuilder(builder: (context, setState) {
                return CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  minSize: 40,
                  child: isRefresh
                      ? const CupertinoActivityIndicator(
                          radius: 10,
                        )
                      : const Icon(
                          CupertinoIcons.arrow_clockwise,
                          size: 24,
                        ),
                  onPressed: () async {
                    setState(() {
                      isRefresh = true;
                    });
                    try {
                      await controller.reloadData();
                    } finally {
                      setState(() {
                        isRefresh = false;
                      });
                    }
                  },
                );
              }),
            // 清除按钮
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.solidTrashCan,
                size: 20,
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
      // cacheExtent: 500,
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
              return getGallerySliverList(
                logic.historys,
                controller.heroTag,
                key: controller.sliverAnimatedListKey,
              );
            },
          ),
        ),
      ],
    );

    return CupertinoPageScaffold(
      child: SizeCacheWidget(child: customScrollView),
    );
  }
}
