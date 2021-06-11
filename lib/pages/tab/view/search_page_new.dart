import 'dart:math';

import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/extension.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/filter/filter.dart';
import 'package:fehviewer/pages/gallery/view/gallery_widget.dart';
import 'package:fehviewer/pages/tab/controller/enum.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
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
  SearchPageController get controller => Get.find(tag: searchPageCtrlDepth);

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
          focusNode: controller.focusNode,
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
          focusNode: controller.focusNode,
          // keyboardType:
          //     multiline ? TextInputType.multiline : TextInputType.text,
          maxLines: multiline ? null : 1,
          textInputAction: TextInputAction.search,
        ));
  }

  Widget getSearchTextFieldIn({bool multiline = false}) {
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
          focusNode: controller.focusNode,
          // keyboardType:
          //     multiline ? TextInputType.multiline : TextInputType.text,
          maxLines: multiline ? null : 1,
          textInputAction: TextInputAction.search,
        ));
  }

  CupertinoNavigationBar getNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      padding: const EdgeInsetsDirectional.only(start: 0),
      border: null,
      // middle: getSearchTextField(),
      // middle: searchTextField,
      transitionBetweenRoutes: false,
      // leading: const SizedBox.shrink(),
      trailing: _buildTrailing(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget cfp = CupertinoPageScaffold(
      navigationBar: getNavigationBar(context),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildTrailing(context).paddingSymmetric(horizontal: 12),
            _buildSearchBar(context),
            Expanded(
              child: _buildSearchRult(context),
            ),
          ],
        ),
      ),
    );

    return cfp;
  }

  Widget _buildSearchRult(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 触摸收起键盘
        FocusScope.of(context).requestFocus(FocusNode());
      },
      onPanDown: (DragDownDetails details) {
        // 滑动收起键盘
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: CustomScrollView(
        slivers: <Widget>[
          Obx(() {
            return CupertinoSliverRefreshControl(
                onRefresh: controller.listType == ListType.gallery
                    ? () => controller.onEditingComplete(clear: false)
                    : null);
          }),
          Obx(() => SliverSafeArea(
                bottom: false,
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
              return _endIndicator();
            } else {
              return SliverToBoxAdapter(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: controller.onEditingComplete,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LineIcons.search,
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
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final _showbar = false;
    return Container(
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
          if (_showbar)
            GetBuilder<SearchPageController>(
              id: GetIds.SEARCH_CLEAR_BTN,
              tag: searchPageCtrlDepth,
              builder: (SearchPageController sPageController) {
                return sPageController.textIsNotEmpty
                    ? CupertinoButton(
                        minSize: 36,
                        padding: const EdgeInsets.all(0),
                        onPressed: sPageController.clearText,
                        child: const Icon(
                          LineIcons.timesCircle,
                          size: 26.0,
                        ),
                      )
                    : CupertinoButton(
                        minSize: 36,
                        padding: const EdgeInsets.all(0),
                        onPressed: () => Get.back(),
                        child: const Icon(
                          LineIcons.arrowLeft,
                          size: 26,
                        ),
                      );
              },
            ),
        ],
      ),
    );
  }

  Widget _tagItem(String text, String translate) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          LineIcons.tag,
        ).paddingOnly(right: 4),
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
    ).paddingSymmetric(vertical: 4, horizontal: 12);
  }

  // tag搜索结果页面
  Widget _getTagQryList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final _text =
              '${controller.qryTags[index].namespace.shortName}:${controller.qryTags[index].key}';
          final _translate =
              '${EHConst.translateTagType[controller.qryTags[index].namespace] ?? controller.qryTags[index].namespace}:${controller.qryTags[index].nameNotMD}';
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
      final String? tranText =
          await Get.find<TagTransController>().getTranTagWithNameSpase(text);
      if (tranText != null && tranText.trim() != text) {
        return tranText;
      } else {
        return null;
      }
    }

    Widget _btn(String text) {
      return TagButton(
        text: text,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        onPressed: () {
          controller.appendTextToSearch(text);
        },
        onLongPress: () async {
          final String? tranText = await _getTextTranslate(text);
          if (tranText != null) {
            vibrateUtil.medium();
            showCupertinoDialog(
                context: Get.overlayContext!,
                barrierDismissible: true,
                builder: (_) {
                  return CupertinoAlertDialog(
                    content: Text(tranText),
                  );
                });
          }
        },
      );
    }

    return GetBuilder<SearchPageController>(
      tag: searchPageCtrlDepth,
      id: GetIds.SEARCH_INIT_VIEW,
      builder: (SearchPageController sPageController) {
        final List<Widget> _btnList = List<Widget>.from(sPageController
            .searchHistory
            .map((String text) => _btn(text))
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
          )),
    );
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
        ),
      ),
      onError: (err) {
        logger.e(' $err');
        return SliverFillRemaining(
          child: Container(
            padding: const EdgeInsets.only(bottom: 50),
            child: GalleryErrorPage(
              onTap: controller.refresh,
            ),
          ),
        );
      },
      onEmpty: SliverFillRemaining(
        child: Container(),
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
