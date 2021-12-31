import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/tab/controller/favorite_controller.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
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

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({Key? key}) : super(key: key);

  @override
  _FavoriteTabState createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  final controller = Get.find<FavoriteViewController>();
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
    // logger.d(' FavoriteTab BuildContext');
    final UserController userController = Get.find();

    // tabPages.scrollControllerMap[controller.tabTag] =
    //     PrimaryScrollController.of(context);

    return Obx(() {
      if (userController.isLogin) {
        if (controller.title.isEmpty) {
          controller.title = L10n.of(context).all_Favorites;
        }
        return _buildNetworkFavView(context);
      } else {
        return _buildLocalFavView(context);
      }
    });
  }

  Widget _buildNetworkFavView(BuildContext context) {
    final Widget sliverNavigationBar = CupertinoSliverNavigationBar(
      transitionBetweenRoutes: false,
      padding: const EdgeInsetsDirectional.only(end: 4),
      largeTitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            controller.title,
          ),
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
          // 搜索按钮
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              LineIcons.search,
              size: 26,
            ),
            onPressed: () {
              final bool fromTabItem =
                  Get.find<TabHomeController>().tabMap[controller.heroTag] ??
                      false;
              NavigatorUtil.goSearchPage(
                  searchType: SearchType.favorite, fromTabItem: fromTabItem);
            },
          ),
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
                    controller.orderText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            onPressed: () => controller.setOrder(context),
          ),
          CupertinoButton(
            padding: const EdgeInsets.all(0),
            minSize: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.activeBlue, context),
                    width: 1.5,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Obx(() => Text(
                    '${controller.curPage + 1}',
                    style: TextStyle(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.activeBlue, context)),
                  )),
            ),
            onPressed: () {
              controller.showJumpToPage();
            },
          ),
          _buildFavcatButton(context),
        ],
      ),
    );

    final Widget navigationBar = Obx(() {
      return CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        padding: const EdgeInsetsDirectional.only(end: 4),
        leading: controller.getLeading(context),
        middle: GestureDetector(
          onTap: () => controller.srcollToTop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                return Text(
                  controller.title,
                );
              }),
              Obx(() {
                if (controller.isBackgroundRefresh) {
                  return const CupertinoActivityIndicator(
                    radius: 10,
                  ).paddingSymmetric(horizontal: 8);
                } else {
                  return const SizedBox();
                }
              }),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 搜索按钮
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                LineIcons.search,
                size: 26,
              ),
              onPressed: () {
                final bool fromTabItem =
                    Get.find<TabHomeController>().tabMap[controller.heroTag] ??
                        false;
                NavigatorUtil.goSearchPage(
                    searchType: SearchType.favorite, fromTabItem: fromTabItem);
              },
            ),
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
                      controller.orderText,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              onPressed: () => controller.setOrder(context),
            ),
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              minSize: 36,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.activeBlue, context),
                      width: 1.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Obx(() => Text(
                      '${controller.curPage + 1}',
                      style: TextStyle(
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.activeBlue, context)),
                    )),
              ),
              onPressed: () {
                controller.showJumpToPage();
              },
            ),
            _buildFavcatButton(context),
          ],
        ),
      );
    });

    return CupertinoPageScaffold(
      // navigationBar: navigationBar,
      child: CupertinoScrollbar(
        scrollbarOrientation: ScrollbarOrientation.right,
        controller: PrimaryScrollController.of(context),
        child: SizeCacheWidget(
          child: CustomScrollView(
            cacheExtent: kTabViewCacheExtent,
            // controller: scrollController,
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
          ),
        ),
      ),
    );
  }

  Widget _buildLocalFavView(BuildContext context) {
    final Widget sliverNavigationBar = CupertinoSliverNavigationBar(
      largeTitle: Text(L10n.of(Get.context!).local_favorite),
      transitionBetweenRoutes: false,
    );

    final CupertinoNavigationBar navigationBar = CupertinoNavigationBar(
      middle: GestureDetector(
        onTap: () => controller.srcollToTop(context),
        child: Text(L10n.of(Get.context!).local_favorite),
      ),
      transitionBetweenRoutes: false,
    );

    return CupertinoPageScaffold(
      // navigationBar: navigationBar,
      child: CupertinoScrollbar(
        scrollbarOrientation: ScrollbarOrientation.right,
        controller: PrimaryScrollController.of(context),
        child: SizeCacheWidget(
          child: CustomScrollView(
            cacheExtent: kTabViewCacheExtent,
            slivers: <Widget>[
              // sliverNavigationBar,
              SliverFloatingPinnedPersistentHeader(
                delegate: SliverFloatingPinnedPersistentHeaderBuilder(
                  minExtentProtoType: const SizedBox(),
                  maxExtentProtoType: navigationBar,
                  builder: (_, __, ___) => navigationBar,
                ),
              ),
              EhCupertinoSliverRefreshControl(
                onRefresh: controller.onRefresh,
              ),
              // todo 可能要设置刷新？
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
          ),
        ),
      ),
    );
  }

  Widget _getGalleryList() {
    return controller.obx(
        (List<GalleryItem>? state) {
          return getGallerySliverList(
            state,
            controller.heroTag,
            maxPage: controller.maxPage,
            curPage: controller.curPage,
            lastComplete: controller.lastComplete,
            centerKey: centerKey,
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

  /// 切换收藏夹
  Widget _buildFavcatButton(BuildContext context) {
    final EhConfigService ehConfigService = Get.find();
    return CupertinoButton(
      minSize: 40,
      padding: const EdgeInsets.only(right: 8),
      child: const Icon(
        LineIcons.star,
        size: 26,
      ),
      onPressed: () async {
        // 跳转收藏夹选择页
        final result = await Get.toNamed(
          EHRoutes.selFavorie,
          id: isLayoutLarge ? 1 : null,
        );
        if (result != null && result is Favcat) {
          final Favcat fav = result;
          if (controller.curFavcat != fav.favId) {
            controller.cancelToken?.cancel(['sel another fav']);
            ehConfigService.lastShowFavcat = fav.favId;
            ehConfigService.lastShowFavTitle = fav.favTitle;
            logger.v('set fav to ${fav.favTitle}  favId ${fav.favId}');
            controller.title = fav.favTitle;
            controller.enableDelayedLoad = false;
            controller.curFavcat = fav.favId;
            controller.reLoadDataFirst();
          } else {
            loggerNoStack.v('未修改favcat');
          }
        }
      },
    );
  }
}
