import 'dart:math';

import 'package:blur/blur.dart';
import 'package:eros_fe/common/controller/tag_trans_controller.dart';
import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/filter/filter.dart';
import 'package:eros_fe/pages/gallery/view/gallery_widget.dart';
import 'package:eros_fe/pages/tab/controller/search_page_controller.dart';
import 'package:eros_fe/pages/tab/view/gallery_base.dart';
import 'package:eros_fe/pages/tab/view/list/tab_base.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';

const CupertinoDynamicColor _kClearButtonColor =
    CupertinoDynamicColor.withBrightness(
  color: Color(0xFF636366),
  darkColor: Color(0xFFAEAEB2),
);

const Color _kDefaultNavBarBorderColor = Color(0x4D000000);
const Border _kDefaultNavBarBorder = Border(
  bottom: BorderSide(
    color: _kDefaultNavBarBorderColor,
    width: 0.0, // One physical pixel.
    style: BorderStyle.solid,
  ),
);

enum SearchMenuEnum {
  filter,
  quickSearchList,
  addToQuickSearch,
}

class GallerySearchPage extends StatefulWidget {
  const GallerySearchPage({Key? key}) : super(key: key);

  @override
  _GallerySearchPageState createState() => _GallerySearchPageState();
}

class _GallerySearchPageState extends State<GallerySearchPage> {
  final String _tag = searchPageCtrlTag;
  late SearchPageController controller;

  GlobalKey centerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<SearchPageController>(tag: _tag)) {
      logger.d('find SearchPageController $_tag');
      controller = Get.find<SearchPageController>(tag: _tag);
    } else {
      logger.d('put SearchPageController $_tag');
      controller = Get.put(
        SearchPageController(),
        tag: _tag,
      );
    }

    // controller.initStateAddPostFrameCallback(context);
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<SearchPageController>(tag: _tag);
  }

  CupertinoNavigationBar getNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      padding: const EdgeInsetsDirectional.only(end: 10),
      border: null,
      middle: Obx(() {
        return Text(controller.placeholderText);
      }),
      transitionBetweenRoutes: false,
      trailing: _buildTrailing(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget cpf = CupertinoPageScaffold(
      // navigationBar: GetPlatform.isAndroid || GetPlatform.isDesktop
      //     ? getNavigationBar(context)
      //     : null,
      navigationBar: getNavigationBar(context),
      child: Column(
        children: [
          // if (GetPlatform.isAndroid || GetPlatform.isDesktop)
          //   SafeArea(
          //     bottom: false,
          //     child: Container(
          //       decoration: BoxDecoration(
          //         border: _kDefaultNavBarBorder,
          //         color: CupertinoTheme.of(context).barBackgroundColor,
          //       ),
          //       child:
          //           const SearchTextFieldIn(iconOpacity: 1.0, multiline: true)
          //               .paddingSymmetric(horizontal: 12, vertical: 4),
          //     ),
          //   ),
          SafeArea(
            bottom: false,
            child: Container(
              decoration: BoxDecoration(
                border: _kDefaultNavBarBorder,
                color: CupertinoTheme.of(context).barBackgroundColor,
              ),
              child: const SearchTextFieldIn(iconOpacity: 1.0, multiline: true)
                  .paddingSymmetric(horizontal: 12, vertical: 4),
            ),
          ),
          Expanded(child: _buildSearchRult(context)),
        ],
      ),
    );

    return cpf;
  }

  Widget _buildSearchRult(BuildContext context) {
    // logger.t('_buildSearchRult');
    return SizeCacheWidget(
      child: CustomScrollView(
        // cacheExtent: context.height * 2,
        slivers: <Widget>[
          // todo android上会有一次删除多个字符的问题
          // if (GetPlatform.isIOS)
          //   SliverFloatingPinnedPersistentHeader(
          //     delegate: SliverFloatingPinnedPersistentHeaderBuilder(
          //       minExtentProtoType: SizedBox(
          //         height: context.mediaQueryPadding.top,
          //       ),
          //       maxExtentProtoType: _maxExtentProtoTypeBar(context),
          //       builder: (_, __, maxExtent) =>
          //           _buildSearchBar(_, __, maxExtent),
          //     ),
          //   ),
          Obx(() {
            return EhCupertinoSliverRefreshControl(
                onRefresh: controller.listType == ListType.gallery
                    ? () => controller.onEditingComplete(clear: false)
                    : null);
          }),
          SliverPadding(
            padding: EdgeInsets.zero,
            key: centerKey,
          ),
          Obx(() => SliverSafeArea(
                key: UniqueKey(),
                bottom: false,
                top: false,
                sliver: () {
                  switch (controller.listType) {
                    case ListType.gallery:
                      return _buildListView(context);
                    case ListType.tag:
                      logger.d('tag list');
                      return _getTagQryList();
                    case ListType.init:
                      return _getInitView();
                  }
                }(),
              )),
          Obx(() {
            if (controller.listType != ListType.tag) {
              return EndIndicator(
                pageState: controller.pageState,
                loadDataMore: controller.loadDataMore,
              );
            } else {
              return SliverSafeArea(
                bottom: false,
                top: false,
                sliver: SliverToBoxAdapter(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: controller.onEditingComplete,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.magnifyingGlass,
                          size: 20,
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.inactiveGray, context),
                        ).paddingOnly(right: 8),
                        Expanded(
                          child: Text(
                            '${L10n.of(context).search} ${controller.searchText}',
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ).paddingSymmetric(vertical: 10, horizontal: 16),
                  ).autoCompressKeyboard(context),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
      BuildContext context, double offset, double maxExtentCallBackValue) {
    // logger.t('offset $offset');
    double iconOpacity = 0.0;
    final transparentOffset = maxExtentCallBackValue - 60;
    if (offset < transparentOffset) {
      iconOpacity = 1 - offset / transparentOffset;
    }
    final _barHeigth =
        kMinInteractiveDimensionCupertino + context.mediaQueryPadding.top;
    return Container(
      height: maxExtentCallBackValue,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // const SizedBox(),
          Expanded(
            flex: _barHeigth ~/ 1,
            child: getNavigationBar(context),
          ),
          Expanded(
            flex: (maxExtentCallBackValue - _barHeigth) ~/ 1,
            child: Stack(
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
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 4, top: 4, bottom: 4),
                            child: SearchTextFieldIn(
                              multiline: true,
                              iconOpacity: iconOpacity,
                            ),
                            // child: getSearchTextField(
                            //   multiline: true,
                            // ),
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
          ),
        ],
      ),
    );
  }

  Widget _maxExtentProtoTypeBar(BuildContext context) {
    // logger.t(' _maxExtentProtoTypeBar');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(),
        getNavigationBar(context),
        Container(
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
                    ehTheme.themeData!.barBackgroundColor, context)
                .withOpacity(1),
            border: _kDefaultNavBarBorder,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: const <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 4, top: 4, bottom: 4),
                  child: SearchTextFieldIn(multiline: true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tagItem({
    required String input,
    required String text,
    String? translate,
  }) {
    final textStyle = TextStyle(
      fontSize: 16,
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
    );

    final translateStyle = TextStyle(
      fontSize: 14,
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondaryLabel, Get.context!),
    );

    final highLightTextStyle = TextStyle(
      fontSize: 16,
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemBlue, Get.context!),
    );

    final highLightTranslateStyle = TextStyle(
      fontSize: 14,
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemBlue, Get.context!),
    );

    final textSpans = text
        .split(input)
        .map((e) => TextSpan(
              text: e,
              style: textStyle,
            ))
        .separat(
            separator: TextSpan(
          text: input,
          style: highLightTextStyle,
        ));

    final translateTextSpans = translate
        ?.split(input)
        .map((e) => TextSpan(
              text: e,
              style: translateStyle,
            ))
        .separat(
            separator: TextSpan(
          text: input,
          style: highLightTranslateStyle,
        ));

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(FontAwesomeIcons.magnifyingGlass,
                size: 20,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.inactiveGray, Get.context!))
            .paddingOnly(right: 10, top: 4),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: textSpans,
                ),
              ),
              if (translate != null) const SizedBox(height: 6),
              if (translate != null)
                RichText(
                  text: TextSpan(
                    children: translateTextSpans,
                  ),
                ),
            ],
          ),
        ),
      ],
    ).paddingSymmetric(vertical: 12, horizontal: 16);
  }

  /// tag匹配view
  Widget _getTagQryList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final _text = controller.qryTags[index].fullTagText ?? '';
          // 开启tag翻译的是情况才去查询翻译
          final _tagRults = controller.isTagTranslat
              ? controller.qryTags[index].fullTagTranslate
              : null;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.addQryTag(index);
            },
            child: _tagItem(
              input: controller.currQryText,
              text: _text,
              translate: _tagRults,
            ),
          );
        },
        childCount: controller.qryTags.length,
      ),
    );
  }

  Future<String?> _getTextTranslate(String text) async {
    final String? tranText =
        await Get.find<TagTransController>().getTranTagWithNameSpaseAuto(text);
    if (tranText != null && tranText.trim() != text) {
      return tranText;
    } else {
      return null;
    }
  }

  Widget _searchHistoryBtn(String text, VoidCallback removeHistory) {
    return SearchHisTagButton(
      text: text,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      onPressed: () {
        controller.appendTextToSearch(text);
      },
      onLongPress: () async {
        final String? tranText = await _getTextTranslate(text);
        vibrateUtil.light();
        showCupertinoDialog(
          context: Get.overlayContext!,
          barrierDismissible: true,
          builder: (_) {
            return CupertinoAlertDialog(
              content: Column(
                children: [
                  Text(text),
                  if (tranText != null) const SizedBox(height: 12),
                  if (tranText != null) Text(tranText),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () async {
                    Get.back();
                  },
                  child: Text(L10n.of(Get.context!).cancel),
                ),
                CupertinoDialogAction(
                  onPressed: () async {
                    removeHistory();
                    Get.back();
                  },
                  child: Text(
                    L10n.of(Get.context!).delete,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.destructiveRed, Get.context!)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _searchHistoryBtnWithTranslate(
      String text, VoidCallback removeHistory) {
    return FutureBuilder<String?>(
      future: _getTextTranslate(text),
      initialData: '',
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        String? tranText = snapshot.data as String?;
        return SearchHisTagButton(
          text: text,
          desc: tranText,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
          onPressed: () {
            controller.appendTextToSearch(text);
          },
          onLongPress: () {
            vibrateUtil.light();
            showCupertinoDialog(
                context: Get.overlayContext!,
                barrierDismissible: true,
                builder: (_) {
                  return CupertinoAlertDialog(
                    content: Column(
                      children: [
                        Text(text),
                        if (tranText != null) const SizedBox(height: 12),
                        if (tranText != null) Text(tranText),
                      ],
                    ),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () async {
                          Get.back();
                        },
                        child: Text(L10n.of(Get.context!).cancel),
                      ),
                      CupertinoDialogAction(
                        onPressed: () async {
                          removeHistory();
                          Get.back();
                        },
                        child: Text(
                          L10n.of(Get.context!).delete,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.destructiveRed,
                                  Get.context!)),
                        ),
                      ),
                    ],
                  );
                });
          },
        );
      },
    );
  }

  Widget _searchHistoryBtnAnimated(
      String text, VoidCallback removeHistory, bool translate) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      firstCurve: Curves.easeIn,
      secondCurve: Curves.easeOut,
      firstChild: _searchHistoryBtnWithTranslate(text, removeHistory),
      secondChild: _searchHistoryBtn(text, removeHistory),
      crossFadeState:
          translate ? CrossFadeState.showFirst : CrossFadeState.showSecond,
    );
  }

  Widget _getInitView() {
    return GetBuilder<SearchPageController>(
      tag: searchPageCtrlTag,
      id: GetIds.SEARCH_INIT_VIEW,
      builder: (SearchPageController sPageController) {
        final List<Widget> searchHistoryButtonList =
            List<Widget>.from(sPageController.searchHistory
                .map(
                  (String text) => _searchHistoryBtnAnimated(
                    text,
                    () => sPageController.removeHistory(text),
                    sPageController.translateSearchHistory,
                  ),
                )
                .toList());

        final Widget searchHistoryBox = SliverToBoxAdapter(
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sPageController.searchHistory.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        L10n.of(Get.context!).search_history,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (sPageController.isTagTranslat)
                            GestureDetector(
                              onTap: sPageController.switchTranslateHistory,
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                  horizontal: 16,
                                ),
                                child: Icon(
                                  Icons.language,
                                  size: 17,
                                  color: sPageController.translateSearchHistory
                                      ? CupertinoColors.activeBlue
                                      : CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: sPageController.clearHistory,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                                horizontal: 6,
                              ),
                              child: const Icon(
                                Icons.delete,
                                size: 17,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Wrap(
                    spacing: 8, //主轴上子控件的间距
                    runSpacing: 8, //交叉轴上子控件之间的间距
                    children: searchHistoryButtonList.sublist(
                        0,
                        min<int>(
                            30, searchHistoryButtonList.length)), //要显示的子控件集合
                  ),
                ),
              ],
            ),
          ),
        );
        return searchHistoryBox;
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return GetBuilder<SearchPageController>(
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
                onTap: () => controller.onEditingComplete(),
              ),
            ).autoCompressKeyboard(Get.context!),
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

  Widget _buildTrailing(BuildContext context) {
    Widget _buildListBtns() {
      return GestureDetector(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // 页码
            // Obx(() {
            //   if (controller.curPage > -1) {
            //     return Container(
            //       margin: const EdgeInsets.only(left: 8, right: 4),
            //       child: CupertinoButton(
            //         minSize: 36,
            //         padding: const EdgeInsets.all(0),
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(
            //               horizontal: 4, vertical: 0),
            //           constraints: const BoxConstraints(minWidth: 24),
            //           decoration: BoxDecoration(
            //             border: Border.all(
            //               color: CupertinoDynamicColor.resolve(
            //                   CupertinoColors.activeBlue, context),
            //               width: 2.0,
            //             ),
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           child: Obx(() => Text(
            //                 '${controller.curPage + 1}',
            //                 textAlign: TextAlign.center,
            //                 textScaleFactor: 0.85,
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.bold,
            //                   color: CupertinoDynamicColor.resolve(
            //                       CupertinoColors.activeBlue, context),
            //                   // height: 1.2,
            //                   // textBaseline: TextBaseline.ideographic,
            //                 ),
            //                 // strutStyle: const StrutStyle(
            //                 //   leading: 0.2,
            //                 //   height: 1.2,
            //                 //   forceStrutHeight: true,
            //                 // ),
            //               )),
            //         ),
            //         onPressed: () {
            //           controller.showJumpToPage();
            //         },
            //       ),
            //     );
            //   } else {
            //     return const SizedBox.shrink();
            //   }
            // }),
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
              if (controller.next.isNotEmpty) {
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
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.image,
                size: 20,
              ),
              onPressed: () async {
                await Get.toNamed(
                  EHRoutes.searchImage,
                );
              },
            ),
            // 筛选
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.filter,
                size: 20,
              ),
              onPressed: () {
                showFilterSetting();
              },
            ),

            // 添加到快捷搜索
            // CupertinoButton(
            //   minSize: 36,
            //   padding: const EdgeInsets.all(0),
            //   child: const Icon(
            //     LineIcons.plusCircle,
            //     size: 26,
            //   ),
            //   onPressed: () {
            //     controller.addToQuickSearch();
            //   },
            // ),
            // 打开快捷搜索
            // CupertinoButton(
            //   minSize: 36,
            //   padding: const EdgeInsets.all(0),
            //   child: const Icon(
            //     FontAwesomeIcons.listUl,
            //     size: 20,
            //   ),
            //   onPressed: () {
            //     controller.quickSearchList();
            //   },
            // ),
          ],
        ),
      );
    }

    return _buildListBtns();
  }
}

class SearchTextFieldIn extends StatelessWidget {
  const SearchTextFieldIn({
    Key? key,
    this.multiline = false,
    this.iconOpacity = 0.0,
  }) : super(key: key);

  // SearchPageController get controller => Get.find(tag: searchPageCtrlTag);
  final bool multiline;
  final double iconOpacity;

  @override
  Widget build(BuildContext context) {
    SearchPageController controller;
    if (Get.isRegistered(tag: searchPageCtrlTag)) {
      controller = Get.find(tag: searchPageCtrlTag);
    } else {
      controller = Get.put(
        SearchPageController(),
        tag: searchPageCtrlTag,
      );
    }

    return Obx(() {
      ehTheme.isDarkMode;
      return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
        return CupertinoTextField(
          style: const TextStyle(height: 1.25),
          decoration: BoxDecoration(
            color: ehTheme.textFieldBackgroundColor!.withOpacity(0.6),
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          ),
          placeholder: L10n.of(context).search,
          placeholderStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            color: CupertinoColors.placeholderText,
            height: 1.25,
          ),
          // clearButtonMode: OverlayVisibilityMode.editing,
          prefix: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minSize: 0,
            child: Icon(
              FontAwesomeIcons.magnifyingGlass,
              size: 20.0,
              color: CupertinoColors.systemGrey.withOpacity(iconOpacity),
            ),
            onPressed: () {},
          ),
          suffix: GetBuilder<SearchPageController>(
            id: GetIds.SEARCH_CLEAR_BTN,
            tag: searchPageCtrlTag,
            builder: (SearchPageController controller) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (GetPlatform.isDesktop)
                    Builder(builder: (context) {
                      bool isRefresh = false;
                      return StatefulBuilder(builder: (context, setState) {
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              isRefresh = true;
                            });
                            await controller.reloadData();
                            setState(() {
                              isRefresh = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: isRefresh
                                ? const CupertinoActivityIndicator(radius: 8)
                                : Icon(
                                    FontAwesomeIcons.rotateRight,
                                    size: 18.0,
                                    color: CupertinoDynamicColor.resolve(
                                            _kClearButtonColor, Get.context!)
                                        .withOpacity(iconOpacity),
                                  ),
                          ),
                        );
                      });
                    }),
                  if (controller.textIsGalleryUrl)
                    GestureDetector(
                      onTap: controller.jumpToGallery,
                      child: Icon(
                        FontAwesomeIcons.circleArrowRight,
                        size: 20.0,
                        color: CupertinoDynamicColor.resolve(
                                _kClearButtonColor, Get.context!)
                            .withOpacity(iconOpacity),
                      ).paddingSymmetric(horizontal: 6),
                    ),
                  if (controller.textIsNotEmpty && !controller.textIsGalleryUrl)
                    GestureDetector(
                      onTap: controller.addToQuickSearch,
                      child: Icon(
                        FontAwesomeIcons.circlePlus,
                        size: 20.0,
                        color: CupertinoDynamicColor.resolve(
                                _kClearButtonColor, Get.context!)
                            .withOpacity(iconOpacity),
                      ).paddingSymmetric(horizontal: 4),
                    ),
                  if (controller.textIsNotEmpty)
                    GestureDetector(
                      onTap: controller.clearText,
                      child: Icon(
                        FontAwesomeIcons.circleXmark,
                        size: 20.0,
                        color: CupertinoDynamicColor.resolve(
                                _kClearButtonColor, Get.context!)
                            .withOpacity(iconOpacity),
                      ).paddingSymmetric(horizontal: 6),
                    ),
                  GestureDetector(
                    onTap: controller.quickSearchList,
                    child: Icon(
                      FontAwesomeIcons.listUl,
                      size: 18.0,
                      color: CupertinoDynamicColor.resolve(
                              _kClearButtonColor, Get.context!)
                          .withOpacity(iconOpacity),
                    ).paddingOnly(right: 10, left: 6),
                  ),
                ],
              );
            },
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(0, 6, 5, 6),
          controller: controller.searchTextController,
          autofocus: controller.autofocus,
          onEditingComplete: controller.onEditingComplete,
          focusNode: controller.searchFocusNode,
          maxLines: (isKeyboardVisible && multiline) ? null : 1,
          textInputAction: TextInputAction.search,
        );
      });
    });
  }
}

class SearchSliverPinnedPersistentHeaderDelegate
    extends SliverPinnedPersistentHeaderDelegate {
  SearchSliverPinnedPersistentHeaderDelegate(
      {required this.child,
      required Widget minExtentProtoType,
      required Widget maxExtentProtoType})
      : super(
            minExtentProtoType: minExtentProtoType,
            maxExtentProtoType: maxExtentProtoType);
  final Widget child;

  @override
  Widget build(BuildContext context, double shrinkOffset, double? minExtent,
      double maxExtent, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(
      covariant SliverPinnedPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
