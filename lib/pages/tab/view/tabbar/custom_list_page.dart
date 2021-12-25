import 'package:blur/blur.dart';
import 'package:english_words/english_words.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/custom_list_controller.dart';
import 'package:fehviewer/pages/tab/controller/sublist_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/widget/refresh.dart';
import 'package:flutter/cupertino.dart' hide CupertinoTabBar;
import 'package:get/get.dart';
import 'package:keframe/size_cache_widget.dart';

import '../../comm.dart';
import '../constants.dart';
import '../tab_base.dart';

class CustomList extends StatefulWidget {
  const CustomList({Key? key}) : super(key: key);

  @override
  State<CustomList> createState() => _CustomListState();
}

class _CustomListState extends State<CustomList> {
  final CustomListController controller = Get.find();

  final EhTabController ehTabController = EhTabController();
  final LinkScrollBarController linkScrollBarController =
      LinkScrollBarController();
  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    linkScrollBarController.dispose();
    super.dispose();
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
              // 画廊列表测试
              ...controller.titles
                  .take(3)
                  .map((e) => _SubListView(
                        costomListTag: e,
                      ))
                  .toList(),
              // 单词列表测试
              const EnglishWordList(),
              ...controller.titles
                  .map((e) => Center(
                        child: Text(e),
                      ))
                  .toList()
                ..removeAt(0)
                ..removeAt(0)
                ..removeAt(0)
                ..removeAt(0)
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
              ClipRect(
                child: Container(
                  decoration: const BoxDecoration(
                    border: kDefaultNavBarBorder,
                  ),
                  padding: EdgeInsets.only(
                    left: context.mediaQueryPadding.left,
                    right: context.mediaQueryPadding.right,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: kTopTabbarHeight,
                          child: LinkScrollBar(
                            width: context.mediaQuery.size.width,
                            controller: linkScrollBarController,
                            pageController: pageController,
                            titleList: titleList,
                            initIndex: 0,
                            onItemChange: (index) =>
                                pageController.animateToPage(index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease),
                          ),
                          // color: CupertinoColors.systemBlue,
                        ),
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
            Text('自定义'),
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
}

class EnglishWordList extends StatefulWidget {
  const EnglishWordList({Key? key}) : super(key: key);

  @override
  _EnglishWordListState createState() => _EnglishWordListState();
}

class _EnglishWordListState extends State<EnglishWordList>
    with AutomaticKeepAliveClientMixin {
  final CustomListController controller = Get.find();
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

class _SubListView extends StatefulWidget {
  const _SubListView({Key? key, this.costomListTag}) : super(key: key);

  final String? costomListTag;

  @override
  _SubListViewState createState() => _SubListViewState();
}

class _SubListViewState extends State<_SubListView>
    with AutomaticKeepAliveClientMixin {
  late final SubListController subController;
  final EhTabController ehTabController = EhTabController();
  final GlobalKey<ExtendedNestedScrollViewState> _key =
      GlobalKey<ExtendedNestedScrollViewState>();

  @override
  void initState() {
    super.initState();
    subController = Get.find<SubListController>(tag: widget.costomListTag)
      ..tabTag = widget.costomListTag ?? '';
    addListen();
  }

  void addListen() {
    subController.initEhTabController(
      context: context,
      ehTabController: ehTabController,
      tabTag: EHRoutes.coutomlist,
    );
    // subController.initStateAddPostFrameCallback(context);
  }

  @override
  bool get wantKeepAlive => true;

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
              onRefresh: () => subController.onRefresh(),
            )),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: _getGallerySliverList(),
          // sliver: _getTabbar(),
        ),
        Obx(() {
          return EndIndicator(
            pageState: subController.pageState,
            loadDataMore: subController.loadDataMore,
          );
        }),
      ],
    );
  }

  Widget _getGallerySliverList() {
    return subController.obx(
        (List<GalleryItem>? state) {
          return getGallerySliverList(
            state,
            subController.tabTag,
            maxPage: subController.maxPage,
            curPage: subController.curPage.value,
            lastComplete: subController.lastComplete,
            key: subController.sliverAnimatedListKey,
            lastTopitemIndex: subController.lastTopitemIndex,
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
                onTap: subController.reLoadDataFirst,
              ),
            ),
          );
        });
  }
}
