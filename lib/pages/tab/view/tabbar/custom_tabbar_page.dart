import 'package:blur/blur.dart';
import 'package:english_words/english_words.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/tabbar/custom_sublist_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabbar/custom_tabbar_controller.dart';
import 'package:flutter/cupertino.dart' hide CupertinoTabBar;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';

import '../../comm.dart';
import '../constants.dart';
import 'custom_sub_page.dart';

class CustomTabbarList extends StatefulWidget {
  const CustomTabbarList({Key? key}) : super(key: key);

  @override
  State<CustomTabbarList> createState() => _CustomTabbarListState();
}

class _CustomTabbarListState extends State<CustomTabbarList> {
  final CustomTabbarController controller = Get.find();

  final EhTabController ehTabController = EhTabController();

  @override
  void initState() {
    super.initState();
    controller.pageController = PageController(initialPage: controller.index);
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
            controller.linkScrollBarController.enableScrollToItem();
          },
          child: Obx(() {
            return PageView(
              // CustomScrollPhysics对于改善滑动问题没有帮助
              // physics: const CustomScrollPhysics(),
              key: ValueKey(
                  controller.profiles.map((e) => '${e.uuid}${e.name}').join()),
              // key: UniqueKey(),
              controller: controller.pageController,
              children: controller.profiles.isNotEmpty
                  ? [
                      ...controller.profilesShow
                          .map((e) => SubListView<CustomSubListController>(
                                profileUuid: e.uuid,
                                key: ValueKey(e.uuid),
                              ))
                          .toList(),
                      // ...controller.profiles
                      //     .map((e) => Container(
                      //           child: Text(e.uuid),
                      //           alignment: Alignment.center,
                      //         ))
                      //     .toList(),
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
      }),
    );

    return CupertinoPageScaffold(
      // navigationBar: navigationBar,
      child: SizeCacheWidget(child: scrollView),
    );
  }

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
                                    .map((e) =>
                                        LinkTabItem(title: e.name, actinos: [
                                          LinkTabItemAction(
                                            actinoText: '编辑分组',
                                            icon: FontAwesomeIcons.penToSquare,
                                            onTap: () {
                                              controller.toEditPage(
                                                  uuid: e.uuid);
                                            },
                                          ),
                                          LinkTabItemAction(
                                            actinoText: '删除分组',
                                            icon: FontAwesomeIcons.trashCan,
                                            color:
                                                CupertinoDynamicColor.resolve(
                                                    CupertinoColors
                                                        .destructiveRed,
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
                      CupertinoButton(
                        minSize: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: const Icon(
                          FontAwesomeIcons.bars,
                          size: 20,
                        ),
                        onPressed: controller.pressedBar,
                      ),
                    ],
                  ),
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
            Text(L10n.of(context).tab_gallery),
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
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              // FontAwesomeIcons.magnifyingGlass,
              CupertinoIcons.search,
              size: 28,
            ),
            onPressed: () {
              NavigatorUtil.goSearchPage();
            },
          ),
          // 页码跳转按钮
          CupertinoButton(
            minSize: 36,
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              constraints: const BoxConstraints(minWidth: 24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.activeBlue, context),
                  width: 1.8,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
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
      ),
    );
  }
}

class EnglishWordList extends StatefulWidget {
  const EnglishWordList({Key? key}) : super(key: key);

  @override
  _EnglishWordListState createState() => _EnglishWordListState();
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
