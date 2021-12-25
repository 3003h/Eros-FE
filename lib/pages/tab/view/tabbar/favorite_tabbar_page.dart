import 'package:blur/blur.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/favorite_tabbar_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:keframe/size_cache_widget.dart';

import '../../comm.dart';
import '../constants.dart';

class FavoriteTabTabBarPage extends StatefulWidget {
  const FavoriteTabTabBarPage({Key? key}) : super(key: key);

  @override
  _FavoriteTabTabBarPageState createState() => _FavoriteTabTabBarPageState();
}

class _FavoriteTabTabBarPageState extends State<FavoriteTabTabBarPage> {
  final EhTabController ehTabController = EhTabController();
  final LinkScrollBarController linkScrollBarController =
      LinkScrollBarController();
  final PageController pageController = PageController();
  final controller = Get.find<FavoriteTabberController>();

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
              Blur(
                blur: 10,
                blurColor: CupertinoTheme.of(context)
                    .barBackgroundColor
                    .withOpacity(1),
                colorOpacity: 0.7,
                child: Container(
                  height: kTopTabbarHeight,
                ),
              ),
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
                    return LinkScrollBar(
                      pageController: pageController,
                      width: context.mediaQuery.size.width,
                      controller: linkScrollBarController,
                      titleList:
                          controller.favcatList.map((e) => e.favTitle).toList(),
                      initIndex: 0,
                      onItemChange: (index) => pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease),
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

  CupertinoNavigationBar getNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      // backgroundColor:
      //     CupertinoTheme.of(context).barBackgroundColor.withOpacity(1),
      // border: null,
      border: Border(
        bottom: BorderSide(
          color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.2),
          width: 0.1, // 0.0 means one physical pixel
        ),
      ),
      padding: const EdgeInsetsDirectional.only(end: 4),
      middle: GestureDetector(
        onTap: () => controller.srcollToTop(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(L10n.of(context).favcat),
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
    );
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
          child: PageView(
            controller: pageController,
            children: [
              ...controller.favcatList
                  .map((e) => Center(
                        child: Text(e.favTitle),
                      ))
                  .toList(),
            ],
            onPageChanged: (index) {
              linkScrollBarController.scrollToItem(index);
            },
          ),
        );
      }),
    );

    return CupertinoPageScaffold(
      // navigationBar: navigationBar,
      child: SizeCacheWidget(child: scrollView),
    );
  }
}
