import 'dart:math';

import 'package:blur/blur.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/extension.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/filter/filter.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:fehviewer/pages/tab/controller/enum.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/utils/cust_lib/persistent_header_builder.dart';
import 'package:fehviewer/utils/cust_lib/sliver/sliver_persistent_header.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

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

class GallerySearchPageNew extends StatelessWidget {
  // final _search = Get.arguments;
  final SearchPageController controller = Get.put(
      SearchPageController(
          initSearchText: Get.arguments is String ? Get.arguments : null),
      tag: searchPageCtrlDepth);

  // SearchPageController get controller => Get.find(tag: searchPageCtrlDepth);

  Widget getSearchTextFieldNew() {
    return Obx(() => CupertinoSearchTextField(
          padding: const EdgeInsetsDirectional.fromSTEB(3, 6, 5, 6),
          style: const TextStyle(height: 1.25),
          placeholder: controller.placeholderText,
          placeholderStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            color: CupertinoColors.placeholderText,
            height: 1.25,
          ),
          controller: controller.searchTextController,
          suffixIcon: const Icon(LineIcons.timesCircle),
          onSubmitted: (_) => controller.onEditingComplete(),
          focusNode: controller.searchFocusNode,
        ));
  }

  Widget getSearchTextField({bool multiline = false}) {
    return Obx(() => CupertinoTextField(
          style: const TextStyle(height: 1.25),
          decoration: BoxDecoration(
            color: ehTheme.textFieldBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          ),
          placeholder: controller.placeholderText,
          placeholderStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            color: CupertinoColors.placeholderText,
            height: 1.25,
          ),
          // clearButtonMode: OverlayVisibilityMode.editing,
          prefix: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minSize: 0,
            child: const Icon(
              LineIcons.search,
              color: CupertinoColors.systemGrey,
            ),
            onPressed: () {},
          ),
          suffix: GetBuilder<SearchPageController>(
            id: GetIds.SEARCH_CLEAR_BTN,
            tag: searchPageCtrlDepth,
            builder: (SearchPageController controller) {
              return controller.textIsNotEmpty
                  ? GestureDetector(
                      onTap: controller.clearText,
                      child: Icon(
                        LineIcons.timesCircle,
                        size: 24.0,
                        color: CupertinoDynamicColor.resolve(
                            _kClearButtonColor, Get.context!),
                      ).paddingSymmetric(horizontal: 6),
                    )
                  : const SizedBox();
            },
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(0, 6, 5, 6),
          controller: controller.searchTextController,
          autofocus: controller.autofocus,
          // textInputAction: TextInputAction.search,
          onEditingComplete: controller.onEditingComplete,
          focusNode: controller.searchFocusNode,
          // keyboardType:
          //     multiline ? TextInputType.multiline : TextInputType.text,
          maxLines: multiline ? null : 1,
          textInputAction: TextInputAction.search,
        ));
  }

  Widget getSearchTextFieldIn(
      {bool multiline = false, double iconOpacity = 0.0}) {
    return Obx(() => CupertinoTextField(
          style: const TextStyle(height: 1.25),
          decoration: BoxDecoration(
            color: ehTheme.textFieldBackgroundColor!.withOpacity(0.6),
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          ),
          placeholder: controller.placeholderText,
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
              LineIcons.search,
              color: CupertinoColors.systemGrey.withOpacity(iconOpacity),
            ),
            onPressed: () {},
          ),
          suffix: GetBuilder<SearchPageController>(
            id: GetIds.SEARCH_CLEAR_BTN,
            tag: searchPageCtrlDepth,
            builder: (SearchPageController controller) {
              return controller.textIsNotEmpty
                  ? GestureDetector(
                      onTap: controller.clearText,
                      child: Icon(
                        LineIcons.timesCircle,
                        size: 24.0,
                        color: CupertinoDynamicColor.resolve(
                                _kClearButtonColor, Get.context!)
                            .withOpacity(iconOpacity),
                      ).paddingSymmetric(horizontal: 6),
                    )
                  : const SizedBox();
            },
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(0, 6, 5, 6),
          controller: controller.searchTextController,
          autofocus: controller.autofocus,
          // textInputAction: TextInputAction.search,
          onEditingComplete: controller.onEditingComplete,
          focusNode: controller.searchFocusNode,
          maxLines: multiline ? null : 1,
          textInputAction: TextInputAction.search,
        ));
  }

  CupertinoNavigationBar getNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      padding: const EdgeInsetsDirectional.only(start: 0),
      border: null,
      middle: Text(S.of(context).search),
      // middle: getSearchTextFieldIn(),
      transitionBetweenRoutes: false,
      trailing: _buildTrailing(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget cfp = CupertinoPageScaffold(
      // navigationBar: getNavigationBar(context),
      child: Column(
        children: [
          // getSearchTextFieldIn().paddingOnly(top: 100),
          Expanded(child: _buildSearchRult(context)),
        ],
      ),
    );

    return cfp;
  }

  Widget _buildSearchRult(BuildContext context) {
    // logger.v('_buildSearchRult');
    return CustomScrollView(
      slivers: <Widget>[
        // SliverToBoxAdapter(child: getSearchTextFieldIn().paddingOnly(top: 50)),
        // TODO android上会有一次删除多个字符的问题
        SliverFloatingPinnedPersistentHeader(
          delegate: SliverFloatingPinnedPersistentHeaderBuilder(
            minExtentProtoType: const SizedBox(),
            maxExtentProtoType: _maxExtentProtoTypeBar(context),
            // maxExtentProtoType: SizedBox(height: 150),
            builder: (_, __, maxExtent) => _buildSearchBar(_, __, maxExtent),
          ),
        ),
        Obx(() {
          return CupertinoSliverRefreshControl(
              onRefresh: controller.listType == ListType.gallery
                  ? () => controller.onEditingComplete(clear: false)
                  : null);
        }),
        Obx(() => SliverSafeArea(
              bottom: false,
              top: false,
              sliver: () {
                switch (controller.listType) {
                  case ListType.gallery:
                    return _getGalleryList();
                  case ListType.tag:
                    return _getTagQryList();
                  case ListType.init:
                    return _getInitView();
                }
              }(),
            )),
        Obx(() {
          if (controller.listType != ListType.tag) {
            return SliverToBoxAdapter(
                child: _endIndicator().autoCompressKeyboard(context));
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
                        LineIcons.search,
                        size: 20,
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.inactiveGray, context),
                      ).paddingOnly(right: 4),
                      Expanded(
                        child: Text(
                          '${S.of(context).search} ${controller.searchText}',
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ).paddingSymmetric(vertical: 4, horizontal: 12),
                ).autoCompressKeyboard(context),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildSearchBar(
      BuildContext context, double offset, double maxExtentCallBackValue) {
    // logger.v('offset $offset');
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
                            child: getSearchTextFieldIn(
                                multiline: true, iconOpacity: iconOpacity),
                          ),
                        ),
                      ],
                    ),
                  ).frosted(
                    blur: 5,
                    frostColor: CupertinoTheme.of(context)
                        .barBackgroundColor
                        .withOpacity(1),
                    frostOpacity: 0.75,
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
    // logger.v(' _maxExtentProtoTypeBar');
    return Container(
      child: Column(
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
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                    child: getSearchTextFieldIn(multiline: true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagItem(String text, String? translate) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LineIcons.tag,
                size: 20,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.inactiveGray, Get.context!))
            .paddingOnly(right: 4),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              if (translate != null)
                Text(translate,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.secondaryLabel, Get.context!),
                    )),
            ],
          ),
        ),
      ],
    ).paddingSymmetric(vertical: 8, horizontal: 12);
  }

  // tag搜索结果页面
  Widget _getTagQryList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final _text = controller.qryTags[index].fullTagText ?? '';
          final _translate = controller.isTagTranslat
              ? controller.qryTags[index].fullTagTranslate
              : null;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.addQryTag(index);
            },
            child: _tagItem(_text, _translate),
          );
        },
        childCount: controller.qryTags.length,
      ),
    );
  }

  // 初始化页面
  Widget _getInitView() {
    Future<String?> _getTextTranslate(String text) async {
      final String? tranText = await Get.find<TagTransController>()
          .getTranTagWithNameSpaseSmart(text);
      if (tranText != null && tranText.trim() != text) {
        return tranText;
      } else {
        return null;
      }
    }

    Widget _searchHistoryBtn(
        String text, SearchPageController sPageController) {
      return TagButton(
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
                      child: Text(S.of(Get.context!).cancel),
                    ),
                    CupertinoDialogAction(
                      onPressed: () async {
                        sPageController.removeHistory(text);
                        Get.back();
                      },
                      child: Text(
                        S.of(Get.context!).delete,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.destructiveRed, Get.context!)),
                      ),
                    ),
                  ],
                );
              });
        },
      );
    }

    return GetBuilder<SearchPageController>(
      tag: searchPageCtrlDepth,
      id: GetIds.SEARCH_INIT_VIEW,
      builder: (SearchPageController sPageController) {
        final List<Widget> _btnList = List<Widget>.from(sPageController
            .searchHistory
            .map((String text) => _searchHistoryBtn(text, sPageController))
            .toList());

        final Widget _searchHistory = SliverToBoxAdapter(
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sPageController.searchHistory.isNotEmpty)
                  Text(
                    S.of(Get.context!).search_history,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                Container(
                  child: Wrap(
                    spacing: 8, //主轴上子控件的间距
                    runSpacing: 8, //交叉轴上子控件之间的间距
                    children: _btnList.sublist(
                        0, min<int>(20, _btnList.length)), //要显示的子控件集合
                  ),
                ).paddingSymmetric(vertical: 8.0),
                if (sPageController.searchHistory.isNotEmpty)
                  GestureDetector(
                    onTap: sPageController.clearHistory,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete,
                            size: 17,
                            color: Colors.red,
                          ),
                          Text(
                            S.of(Get.context!).clear_search_history,
                            style: TextStyle(
                              fontSize: 15,
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.secondaryLabel, Get.context!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
        return _searchHistory;
      },
    );
  }

  Widget _endIndicator() {
    return Obx(() => Container(
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
                        S.of(Get.context!).list_load_more_fail,
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
        ));
  }

  Widget _getGalleryList() {
    return controller.obx(
      (List<GalleryItem>? state) {
        return getGalleryList(
          state,
          controller.tabIndex,
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
        ).autoCompressKeyboard(Get.context!),
      ),
      onError: (err) {
        logger.e(' $err');
        return SliverFillRemaining(
          child: Container(
            padding: const EdgeInsets.only(bottom: 50),
            child: GalleryErrorPage(
              onTap: () => controller.onEditingComplete(),
            ),
          ).autoCompressKeyboard(Get.context!),
        );
      },
      onEmpty: SliverFillRemaining(
        child: Container().autoCompressKeyboard(Get.context!),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    Widget _buildListBtns() {
      return GestureDetector(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
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
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                LineIcons.filter,
                size: 26,
              ),
              onPressed: () {
                showFilterSetting();
              },
            ),
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                LineIcons.plusCircle,
                size: 26,
              ),
              onPressed: () {
                controller.addToQuickSearch();
              },
            ),
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                LineIcons.listUl,
                size: 26,
              ),
              onPressed: () {
                controller.quickSearchList();
              },
            ),
          ],
        ),
      );
    }

    return _buildListBtns();
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
