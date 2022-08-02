import 'package:blur/blur.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/favorite_tabbar_controller.dart';
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

  Widget _buildTopBar(
      BuildContext context, double offset, double maxExtentCallBackValue) {
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
              Container(
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
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            initIndex: controller.index,
                            onItemChange: (index) =>
                                pageController.animateToPage(index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease),
                          ),
                        ),
                        if (controller.showBarsBtn)
                          CupertinoButton(
                            minSize: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
          onTap: () => controller.srcollToTop(context),
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
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              minSize: 36,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                constraints: const BoxConstraints(minWidth: 24),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.activeBlue, context),
                      width: 1.8,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Obx(() => Text(
                      '${controller.curPage + 1}',
                      textAlign: TextAlign.center,
                      textScaleFactor: 0.9,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.activeBlue, context)),
                    )),
              ),
              onPressed: () {
                controller.showJumpToPage();
              },
            ),
          ],
        ).paddingOnly(right: 4),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: controller.index);
  }

  @override
  Widget build(BuildContext context) {
    final headerMaxHeight = kMinInteractiveDimensionCupertino +
        context.mediaQueryPadding.top +
        kTopTabbarHeight;

    final Widget scrollView = ExtendedNestedScrollView(
      floatHeaderSlivers: true,
      onlyOneScrollInBody: true,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
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
                minHeight: context.mediaQueryPadding.top + kTopTabbarHeight,
                maxHeight: headerMaxHeight,
              ),
            ),
          )
        ];
      },
      body: Builder(builder: (context) {
        return GestureDetector(
          onPanDown: (e) {
            // 恢复启用 scrollToItem
            linkScrollBarController.enableScrollToItem();
          },
          child: Obx(() {
            return PageView(
              key: ValueKey(controller.showBarsBtn), // 登录状态变化后能刷新
              controller: pageController,
              children: [
                ...controller.favcatList
                    .map((e) => FavoriteSubPage(
                          favcat: e.favId,
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
      }),
    );

    return CupertinoPageScaffold(
      // navigationBar: navigationBar,
      child: SizeCacheWidget(child: scrollView),
    );
  }
}
