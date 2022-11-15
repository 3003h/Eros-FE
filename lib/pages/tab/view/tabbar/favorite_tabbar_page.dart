import 'package:blur/blur.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/favorite/favorite_tabbar_controller.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';

import '../../comm.dart';
import '../constants.dart';
import 'favorite_sub_page.dart';

class FavoriteTabTabBarPage extends StatefulWidget {
  const FavoriteTabTabBarPage({Key? key}) : super(key: key);

  @override
  _FavoriteTabTabBarPageState createState() => _FavoriteTabTabBarPageState();
}

class _FavoriteTabTabBarPageState extends State<FavoriteTabTabBarPage> {
  final EhTabController ehTabController = EhTabController();
  final LinkScrollBarController linkScrollBarController =
      LinkScrollBarController();
  final controller = Get.find<FavoriteTabberController>();
  late PageController pageController;

  final EhConfigService _ehConfigService = Get.find();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: controller.index);
  }

  @override
  Widget build(BuildContext context) {
    final headerMaxHeight = context.mediaQueryPadding.top + kHeaderMaxHeight;

    return Obx(() {
      final hideTopBarOnScroll = _ehConfigService.hideTopBarOnScroll;

      final scrollView =
          buildNestedScrollView(headerMaxHeight, hideTopBarOnScroll);

      return CupertinoPageScaffold(
        // navigationBar: navigationBar,
        child: SizeCacheWidget(child: scrollView),
      );
    });
  }

  Widget _buildTopBar(
    BuildContext context,
    double offset,
    double maxExtentCallBackValue,
  ) {
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
              Obx(() {
                // 不要删除这行
                ehTheme.isDarkMode;
                return Blur(
                  blur: 10,
                  blurColor: CupertinoTheme.of(context)
                      .barBackgroundColor
                      .withOpacity(1),
                  colorOpacity: 0.7,
                  child: Container(
                    height: kTopTabbarHeight,
                  ),
                );
              }),
              FavoriteTabBar(
                pageController: pageController,
                linkScrollBarController: linkScrollBarController,
                controller: controller,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildNestedScrollView(
      double headerMaxHeight, bool hideTopBarOnScroll) {
    return ExtendedNestedScrollView(
      floatHeaderSlivers: true,
      onlyOneScrollInBody: true,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: ExtendedNestedScrollView.sliverOverlapAbsorberHandleFor(
                context),
            sliver: SliverPersistentHeader(
              floating: true,
              pinned: true,
              delegate: FooSliverPersistentHeaderDelegate(
                builder: (context, offset, _) => _buildTopBar(
                  context,
                  offset,
                  headerMaxHeight,
                ),
                // minHeight: context.mediaQueryPadding.top + kTopTabbarHeight,
                minHeight: hideTopBarOnScroll
                    ? context.mediaQueryPadding.top + kTopTabbarHeight
                    : headerMaxHeight,
                maxHeight: headerMaxHeight,
              ),
            ),
          )
        ];
      },
      body: buildBody(),
    );
  }

  Builder buildBody() {
    return Builder(builder: (context) {
      return GestureDetector(
        onPanDown: (e) {
          // 恢复启用 scrollToItem
          linkScrollBarController.enableScrollToItem();
        },
        child: Obx(() {
          final hideTopBarOnScroll = _ehConfigService.hideTopBarOnScroll;
          return PageView(
            key: ValueKey(controller.showBarsBtn), // 登录状态变化后能刷新
            controller: pageController,
            children: [
              ...controller.favcatList
                  .map((e) => FavoriteSubPage(
                        favcat: e.favId,
                        pinned: !hideTopBarOnScroll,
                      ))
                  .toList(),
            ],
            onPageChanged: (index) {
              linkScrollBarController.scrollToItem(index);
              controller.onPageChanged(index);
            },
          );
        }),
      );
    });
  }

  Widget getNavigationBar(BuildContext context) {
    return Obx(() {
      return CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        border: Border(
          bottom: BorderSide(
            color:
                CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.2),
            width: 0.1, // 0.0 means one physical pixel
          ),
        ),
        padding: const EdgeInsetsDirectional.only(end: 4),
        middle: GestureDetector(
          onTap: () => controller.scrollToTop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(L10n.of(context).tab_favorite),
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
            // 搜索按钮
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                // FontAwesomeIcons.magnifyingGlass,
                CupertinoIcons.search,
                size: 28,
              ),
              onPressed: () {
                final bool fromTabItem = Get.find<TabHomeController>()
                        .tabMap[controller.heroTag ?? ''] ??
                    false;
                NavigatorUtil.goSearchPage(
                    searchType: SearchType.favorite, fromTabItem: fromTabItem);
              },
            ),
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
                      controller.orderText,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () => controller.setOrder(context),
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
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                CupertinoIcons.arrow_uturn_down_circle,
                size: 28,
              ),
              onPressed: () {
                controller.showJumpDialog(context);
              },
            ),
            // PageSelectorButton(controller: controller),
          ],
        ).paddingOnly(right: 4),
      );
    });
  }
}

// class PageSelectorButton extends StatelessWidget {
//   const PageSelectorButton({
//     Key? key,
//     required this.controller,
//   }) : super(key: key);
//
//   final FavoriteTabberController controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoButton(
//       padding: const EdgeInsets.all(0),
//       minSize: 36,
//       child: Container(
//         alignment: Alignment.center,
//         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
//         constraints: const BoxConstraints(minWidth: 24, maxHeight: 26),
//         decoration: BoxDecoration(
//             border: Border.all(
//               color: CupertinoDynamicColor.resolve(
//                   CupertinoColors.activeBlue, context),
//               width: 1.8,
//             ),
//             borderRadius: const BorderRadius.all(Radius.circular(8))),
//         child: Obx(() => Text(
//               '${max(1, controller.curPage + 1)}',
//               textAlign: TextAlign.center,
//               textScaleFactor: 0.9,
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   height: 1.25,
//                   color: CupertinoDynamicColor.resolve(
//                       CupertinoColors.activeBlue, context)),
//             )),
//       ),
//       onPressed: () {
//         controller.showJumpToPage();
//       },
//     );
//   }
// }

class FavoriteTabBar extends StatelessWidget {
  const FavoriteTabBar({
    Key? key,
    required this.pageController,
    required this.linkScrollBarController,
    required this.controller,
  }) : super(key: key);

  final PageController pageController;
  final LinkScrollBarController linkScrollBarController;
  final FavoriteTabberController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: kDefaultNavBarBorder,
      ),
      padding: EdgeInsets.only(
        left: context.mediaQueryPadding.left,
        right: context.mediaQueryPadding.right,
      ),
      child: Container(
        height: kTopTabbarHeight,
        child: Obx(() {
          return Row(
            children: [
              Expanded(
                child: LinkScrollBar(
                  pageController: pageController,
                  controller: linkScrollBarController,
                  items: controller.favcatList
                      .map((e) => LinkTabItem(
                            title: e.favTitle,
                            // icon: LineIcons.dotCircleAlt,
                          ))
                      .toList(),
                  itemPadding: const EdgeInsets.symmetric(horizontal: 8),
                  initIndex: controller.index,
                  onItemChange: (index) => pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 刷新按钮
                    if (GetPlatform.isDesktop)
                      Builder(builder: (context) {
                        bool isRefresh = false;
                        return StatefulBuilder(builder: (context, setState) {
                          return CupertinoButton(
                            minSize: 40,
                            padding: const EdgeInsets.all(0),
                            child: isRefresh
                                ? const CupertinoActivityIndicator(radius: 10)
                                : const Icon(
                                    FontAwesomeIcons.rotateRight,
                                    size: 20,
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
                        });
                      }),
                    if (controller.showBarsBtn)
                      CupertinoButton(
                        minSize: 40,
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          FontAwesomeIcons.bars,
                          size: 20,
                        ),
                        onPressed: () async {
                          // 跳转收藏夹选择页
                          final result = await Get.toNamed(
                            EHRoutes.selFavorie,
                            id: isLayoutLarge ? 1 : null,
                          );
                          if (result != null && result is Favcat) {
                            final index = controller.favcatList.indexWhere(
                                (element) => element.favId == result.favId);
                            pageController.jumpToPage(index);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
