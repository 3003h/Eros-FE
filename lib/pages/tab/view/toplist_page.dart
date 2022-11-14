import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/tab/controller/toplist_controller.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/utils/cust_lib/persistent_header_builder.dart';
import 'package:fehviewer/utils/cust_lib/sliver/sliver_persistent_header.dart';
import 'package:fehviewer/widget/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';

import '../comm.dart';
import 'gallery_base.dart';

class ToplistTab extends StatefulWidget {
  const ToplistTab({Key? key}) : super(key: key);

  @override
  _ToplistTabState createState() => _ToplistTabState();
}

class _ToplistTabState extends State<ToplistTab> {
  final controller = Get.find<TopListViewController>();
  final EhTabController ehTabController = EhTabController();
  final EhConfigService _ehConfigService = Get.find();

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
    bool isRefresh = false;

    final navigationBar = CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      padding: const EdgeInsetsDirectional.only(end: 4),
      leading: controller.getLeading(context),
      middle: Obx(() {
        return GestureDetector(
          onTap: () => controller.scrollToTop(context),
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
        );
      }),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
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
          CupertinoButton(
            padding: const EdgeInsets.all(0.0),
            minSize: 40,
            child: Stack(
              alignment: Alignment.centerRight,
              // mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                Icon(
                  CupertinoIcons.sort_down,
                  size: 28,
                ),
              ],
            ),
            onPressed: () => controller.setToplist(context),
          ),
          Obx(() {
            if (controller.afterJump) {
              return CupertinoButton(
                minSize: 40,
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  CupertinoIcons.arrow_up_circle,
                  size: 28,
                ),
                onPressed: () {
                  controller.jumpToTop();
                },
              );
            } else {
              return const SizedBox();
            }
          }),
          Obx(() {
            if (controller.nextGid.isNotEmpty) {
              return CupertinoButton(
                minSize: 40,
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  CupertinoIcons.arrow_uturn_down_circle,
                  size: 28,
                ),
                onPressed: () {
                  controller.showJumpDialog(context);
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          // 页码跳转按钮
          // CupertinoButton(
          //   minSize: 40,
          //   padding: const EdgeInsets.only(right: 6),
          //   child: Container(
          //     alignment: Alignment.center,
          //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          //     constraints: const BoxConstraints(minWidth: 24, maxHeight: 26),
          //     decoration: BoxDecoration(
          //       border: Border.all(
          //         color: CupertinoDynamicColor.resolve(
          //             CupertinoColors.activeBlue, context),
          //         width: 1.8,
          //       ),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Obx(() => Text(
          //           '${max(1, controller.curPage + 1)}',
          //           textScaleFactor: 0.9,
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //               height: 1.25,
          //               color: CupertinoDynamicColor.resolve(
          //                   CupertinoColors.activeBlue, context)),
          //         )),
          //   ),
          //   onPressed: () {
          //     controller.showJumpToPage();
          //   },
          // ),
        ],
      ),
    );

    final customScrollView = Obx(() {
      final hideTopBarOnScroll = _ehConfigService.hideTopBarOnScroll;
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          // sliverNavigationBar,

          if (hideTopBarOnScroll)
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
            top: !hideTopBarOnScroll,
            bottom: false,
            sliver: _buildListView(context),
          ),
          Obx(() {
            return EndIndicator(
              pageState: controller.pageState,
              loadDataMore: controller.loadDataMore,
            );
          }),
        ],
      );
    });

    return Obx(() {
      final hideTopBarOnScroll = _ehConfigService.hideTopBarOnScroll;
      return CupertinoPageScaffold(
        navigationBar: hideTopBarOnScroll ? null : navigationBar,
        child: SizeCacheWidget(child: customScrollView),
      );
    });
  }

  Widget _buildListView(
    BuildContext context,
  ) {
    return GetBuilder<TopListViewController>(
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
            next: logic.next,
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
    );
  }
}
