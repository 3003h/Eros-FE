import 'package:blur/blur.dart';
import 'package:english_words/english_words.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/tab/controller/group/custom_sublist_controller.dart';
import 'package:eros_fe/pages/tab/controller/group/custom_tabbar_controller.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart' hide CupertinoTabBar;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';

import '../../comm.dart';
import '../constants.dart';
import 'custom_sub_page.dart';

class CustomTabbarList extends StatefulWidget {
  const CustomTabbarList({super.key});

  @override
  State<CustomTabbarList> createState() => _CustomTabbarListState();
}

class _CustomTabbarListState extends State<CustomTabbarList> {
  final CustomTabbarController controller = Get.find();

  final EhTabController ehTabController = EhTabController();
  final EhSettingService _ehSettingService = Get.find();

  @override
  void initState() {
    super.initState();
    controller.pageController = PageController(initialPage: controller.index);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hideTopBarOnScroll = _ehSettingService.hideTopBarOnScroll;

      final Widget scrollView =
          buildNestedScrollView(context, hideTopBarOnScroll);

      return CupertinoPageScaffold(
        child: SizeCacheWidget(child: scrollView),
      );

      // return CupertinoPageScaffold(child: scrollView);
    });
  }

  Widget buildNestedScrollView(BuildContext context, bool hideTopBarOnScroll) {
    final headerMaxHeight = context.mediaQueryPadding.top + kHeaderMaxHeight;
    return ExtendedNestedScrollView(
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
                builder: (context, offset, _) => _buildSliverTopBar(
                  context,
                  offset,
                  headerMaxHeight,
                ),
                minHeight: hideTopBarOnScroll
                    ? context.mediaQueryPadding.top + kTopTabbarHeight
                    : headerMaxHeight,
                maxHeight: headerMaxHeight,
              ),
            ),
          ),
        ];
      },
      body: buildSubPages(),
    );
  }

  Builder buildSubPages() {
    return Builder(builder: (context) {
      return GestureDetector(
        onPanDown: (e) {
          // 恢复启用 scrollToItem
          controller.linkScrollBarController.enableScrollToItem();
        },
        child: Obx(() {
          final hideTopBarOnScroll = _ehSettingService.hideTopBarOnScroll;
          return PageView(
            // CustomScrollPhysics对于改善滑动问题没有帮助
            // physics: const CustomScrollPhysics(),
            key: ValueKey(
                controller.profiles.map((e) => '${e.uuid}${e.name}').join()),
            controller: controller.pageController,
            children: controller.profiles.isNotEmpty
                ? [
                    ...controller.profilesShow
                        .map((e) => SubListView<CustomSubListController>(
                              profileUuid: e.uuid,
                              key: ValueKey(e.uuid),
                              pinned: !hideTopBarOnScroll,
                            )),
                  ]
                : [
                    const Center(
                      child: Text(
                        '[ ]',
                        style: TextStyle(fontSize: 40),
                      ),
                    )
                  ],
            onPageChanged: (index) {
              controller.linkScrollBarController.scrollToItem(index);
              controller.onPageChanged(index);
            },
          );
        }),
      );
    });
  }

  Widget _buildSliverTopBar(
    BuildContext context,
    double offset,
    double maxExtentCallBackValue,
  ) {
    return SizedBox(
      height: maxExtentCallBackValue,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 原导航栏
          Expanded(
            child: getNavigationBar(context),
          ),
          // top tabBar
          CustomTabBar(controller: controller),
        ],
      ),
    );
  }

  CupertinoNavigationBar getNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      backgroundColor: kEnableImpeller
          ? CupertinoTheme.of(context).barBackgroundColor.withOpacity(1)
          : null,
      // border: null,
      border: Border(
        bottom: BorderSide(
          color: CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.2),
          width: 0.1, // 0.0 means one physical pixel
        ),
      ),
      padding: const EdgeInsetsDirectional.only(end: 4),
      middle: GestureDetector(
        onTap: () => controller.scrollToTop(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(L10n.of(context).tab_gallery),
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
      leading: controller.getLeading(context),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              CupertinoIcons.search,
              size: 28,
            ),
            onPressed: () {
              NavigatorUtil.goSearchPage();
            },
          ),
          // 页码跳转按钮
          // JumpButton(controller: controller),
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
        ],
      ),
    );
  }
}

class JumpButton extends StatelessWidget {
  const JumpButton({
    super.key,
    required this.controller,
  });

  final CustomTabbarController controller;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 36,
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        constraints: const BoxConstraints(minWidth: 24, maxHeight: 26),
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.activeBlue, context),
            width: 1.8,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Obx(() => Text(
              // '${max(1, controller.curPage + 1)}',
              '1',
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(0.9),
              // textScaler: const TextScaler.linear(0.9),
              style: TextStyle(
                  height: 1.3,
                  fontWeight: FontWeight.bold,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.activeBlue, context)),
            )),
      ),
      onPressed: () {
        controller.showJumpDialog(context);
      },
    );
  }
}

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.controller,
  });

  final CustomTabbarController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // fit: StackFit.expand,
      alignment: Alignment.topCenter,
      children: [
        Obx(() {
          // 不要删除这行
          ehTheme.isDarkMode;
          return Blur(
            blur: 10,
            blurColor:
                CupertinoTheme.of(context).barBackgroundColor.withOpacity(1),
            colorOpacity: kEnableImpeller ? 1.0 : 0.7,
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
          child: SizedBox(
            height: kTopTabbarHeight,
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return LinkScrollBar(
                      key: ValueKey(controller.profiles
                          .map((e) => '${e.uuid}${e.name}')
                          .join()),
                      controller: controller.linkScrollBarController,
                      pageController: controller.pageController,
                      items: controller.profiles.isNotEmpty
                          ? controller.profiles
                              .map((e) => LinkTabItem(title: e.name, actinos: [
                                    LinkTabItemAction(
                                      actinoText: '编辑分组',
                                      icon: FontAwesomeIcons.penToSquare,
                                      onTap: () {
                                        controller.toEditPage(uuid: e.uuid);
                                      },
                                    ),
                                    LinkTabItemAction(
                                      actinoText: '删除分组',
                                      icon: FontAwesomeIcons.trashCan,
                                      color: CupertinoDynamicColor.resolve(
                                          CupertinoColors.destructiveRed,
                                          context),
                                      onTap: () {
                                        controller
                                            .showDeleteGroupModalBottomSheet(
                                                e.uuid, context);
                                      },
                                    ),
                                  ]))
                              .toList()
                          : [LinkTabItem(title: '+++')],
                      initIndex: controller.index,
                      onItemChange: (index) => controller.pageController
                          .animateToPage(index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease),
                    );
                  }),
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
                      CupertinoButton(
                        minSize: 40,
                        padding: const EdgeInsets.all(0),
                        onPressed: controller.pressedBar,
                        child: const Icon(
                          FontAwesomeIcons.bars,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EnglishWordList extends StatefulWidget {
  const EnglishWordList({super.key});

  @override
  State<EnglishWordList> createState() => _EnglishWordListState();
}

class _EnglishWordListState extends State<EnglishWordList>
    with AutomaticKeepAliveClientMixin {
  final CustomTabbarController controller = Get.find();
  final List<WordPair> wordList = [];

  @override
  void initState() {
    super.initState();
    wordList.addAll(generateWordPairs().take(100).toList());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
            padding: EdgeInsets.only(
                top: context.mediaQueryPadding.top + kTopTabbarHeight),
            sliver: EhCupertinoSliverRefreshControl(
              onRefresh: () async {
                await 1.seconds.delay();
                wordList.clear();
                wordList.addAll(generateWordPairs().take(100).toList());
                setState(() {});
              },
            )),
        SliverFixedExtentList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Text(wordList[index].asString);
            }, childCount: wordList.length),
            itemExtent: 50.0),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
