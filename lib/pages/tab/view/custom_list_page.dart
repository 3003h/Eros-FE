import 'package:blur/blur.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/tab/controller/custom_list_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/utils/cust_lib/persistent_header_builder.dart';
import 'package:fehviewer/utils/cust_lib/sliver/sliver_persistent_header.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/widget/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keframe/size_cache_widget.dart';

import '../comm.dart';
import 'constants.dart';
import 'tab_base.dart';

const Color _kDefaultNavBarBorderColor = Color(0x4D000000);
const Border _kDefaultNavBarBorder = Border(
  bottom: BorderSide(
    color: _kDefaultNavBarBorderColor,
    width: 0.0, // One physical pixel.
    style: BorderStyle.solid,
  ),
);

const double kTopTabbarHeight = 44.0;

class CustomList extends StatefulWidget {
  const CustomList({Key? key, this.costomListTag}) : super(key: key);

  final String? costomListTag;

  @override
  State<CustomList> createState() => _CustomListState();
}

class _CustomListState extends State<CustomList> {
  late final CustomListController controller;
  final EhTabController ehTabController = EhTabController();

  @override
  void initState() {
    super.initState();

    controller = Get.find<CustomListController>(tag: widget.costomListTag);

    controller.initStateForListPage(
      context: context,
      ehTabController: ehTabController,
    );
  }

  Widget _buildTopBar(
      BuildContext context, double offset, double maxExtentCallBackValue) {
    // logger.v('offset $offset');
    double iconOpacity = 0.0;
    final transparentOffset = maxExtentCallBackValue - 60;
    if (offset < transparentOffset) {
      iconOpacity = 1 - offset / transparentOffset;
    }

    return Container(
      height: maxExtentCallBackValue,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: getNavigationBar(context),
          ),
          Stack(
            // fit: StackFit.expand,
            alignment: Alignment.topCenter,
            children: [
              ClipRect(
                child: Container(
                  decoration: const BoxDecoration(
                    border: _kDefaultNavBarBorder,
                  ),
                  padding: EdgeInsets.only(
                    left: 8 + context.mediaQueryPadding.left,
                    right: 8 + context.mediaQueryPadding.right,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding:
                              const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                          height: kTopTabbarHeight,
                          // color: CupertinoColors.systemBlue,
                        ),
                      ),
                    ],
                  ),
                ).frosted(
                  blur: 8,
                  frostColor: CupertinoTheme.of(context)
                      .barBackgroundColor
                      .withOpacity(1),
                  frostOpacity: 0.55,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  CupertinoNavigationBar getNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      border: null,
      padding: const EdgeInsetsDirectional.only(end: 4),
      middle: GestureDetector(
        onTap: () => controller.srcollToTop(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Costom List'),
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
      leading: controller.getLeading(context),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
  }

  @override
  Widget build(BuildContext context) {
    final Widget customScrollView = CustomScrollView(
      cacheExtent: kTabViewCacheExtent,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverFloatingPinnedPersistentHeader(
          delegate: SliverFloatingPinnedPersistentHeaderBuilder(
            minExtentProtoType: SizedBox(
              height: context.mediaQueryPadding.top + kTopTabbarHeight,
            ),
            maxExtentProtoType: SizedBox(
                height: kMinInteractiveDimensionCupertino +
                    context.mediaQueryPadding.top +
                    kTopTabbarHeight),
            builder: _buildTopBar,
          ),
        ),
        EhCupertinoSliverRefreshControl(
          onRefresh: () => controller.onRefresh(),
        ),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: _getGalleryList(),
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
      // navigationBar: navigationBar,
      child: CupertinoScrollbar(
        scrollbarOrientation: ScrollbarOrientation.right,
        child: SizeCacheWidget(child: customScrollView),
        controller: PrimaryScrollController.of(context),
      ),
    );
  }

  Widget _getGalleryList() {
    return controller.obx(
        (List<GalleryItem>? state) {
          return getGalleryList(
            state,
            controller.tabTag,
            maxPage: controller.maxPage,
            curPage: controller.curPage.value,
            lastComplete: controller.lastComplete,
            key: controller.sliverAnimatedListKey,
            lastTopitemIndex: controller.lastTopitemIndex,
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
