import 'package:eros_fe/common/controller/history_controller.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/pages/tab/controller/history_view_controller.dart';
import 'package:eros_fe/pages/tab/controller/tabhome_controller.dart';
import 'package:eros_fe/pages/tab/view/list/tab_base.dart';
import 'package:eros_fe/utils/cust_lib/persistent_header_builder.dart';
import 'package:eros_fe/utils/cust_lib/sliver/sliver_persistent_header.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:eros_fe/widget/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';

import '../comm.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final controller = Get.find<HistoryViewController>();
  final EhTabController ehTabController = EhTabController();

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
    logger.t('build Historyview');
    final String _title = L10n.of(context).tab_history;

    bool isRefresh = false;
    final navigationBar = CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      padding: const EdgeInsetsDirectional.only(end: 4),
      leading: controller.getLeading(context),
      middle: GestureDetector(
          onTap: () => controller.scrollToTop(context), child: Text(_title)),
      trailing: Row(
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
    );
    final Widget customScrollView = CustomScrollView(
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
        // CupertinoSliverNavigationBar(
        //   largeTitle: GestureDetector(
        //       onTap: () => controller.scrollToTop(context),
        //       child: Text(_title)),
        // ),
        EhCupertinoSliverRefreshControl(
          onRefresh: controller.syncHistory,
        ),
        SliverSafeArea(
          top: false,
          sliver: GetBuilder<HistoryController>(
            init: HistoryController(),
            builder: (logic) {
              return getGallerySliverList(
                logic.histories,
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
