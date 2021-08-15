import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/tab/controller/enum.dart';
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

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({Key? key}) : super(key: key);

  @override
  _FavoriteTabState createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  final controller = Get.find<FavoriteViewController>();
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
                  Get.find<TabHomeController>().tabMap[controller.tabTag] ??
                      false;
              NavigatorUtil.showSearch(
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
          // onTap: () {
          //   PrimaryScrollController.of(context)?.animateTo(0.0,
          //       duration: Duration(milliseconds: 500), curve: Curves.ease);
          // },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                return Text(
                  controller.title,
                );
              }),
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
                    Get.find<TabHomeController>().tabMap[controller.tabTag] ??
                        false;
                NavigatorUtil.showSearch(
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
            _buildFavcatButton(context),
          ],
        ),
      );
    });

    return CupertinoPageScaffold(
      // navigationBar: navigationBar,
      child: CupertinoScrollbar(
        controller: PrimaryScrollController.of(context),
        child: SizeCacheWidget(
          child: CustomScrollView(
            cacheExtent: 500,
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
                sliver: _getGalleryList(),
              ),
              _endIndicator(),
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
        controller: PrimaryScrollController.of(context),
        child: SizeCacheWidget(
          child: CustomScrollView(
            cacheExtent: 500,
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
                sliver: _getGalleryList(),
              ),
              _endIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _endIndicator() {
    return SliverToBoxAdapter(
      child: Obx(() => Container(
            padding: const EdgeInsets.only(top: 50, bottom: 100),
            child: () {
              switch (controller.pageState) {
                case PageState.None:
                  return Container();
                case PageState.Loading:
                  return const CupertinoActivityIndicator(
                    radius: 14,
                  );
                case PageState.LoadingException:
                case PageState.LoadingError:
                  return GestureDetector(
                    onTap: controller.loadDataMore,
                    child: Column(
                      children: <Widget>[
                        const Icon(
                          Icons.error,
                          size: 40,
                          color: CupertinoColors.systemRed,
                        ),
                        Text(
                          L10n.of(Get.context!).list_load_more_fail,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                default:
                  return Container();
              }
            }(),
          )),
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
            loadMord: controller.loadDataMore,
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
