import 'dart:math';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

const BorderSide _kDefaultRoundedBorderSide = BorderSide(
  color: CupertinoDynamicColor.withBrightness(
    color: Color(0x33000000),
    darkColor: Color(0x33FFFFFF),
  ),
  style: BorderStyle.solid,
  width: 0.0,
);
const Border _kDefaultRoundedBorder = Border(
  top: _kDefaultRoundedBorderSide,
  bottom: _kDefaultRoundedBorderSide,
  left: _kDefaultRoundedBorderSide,
  right: _kDefaultRoundedBorderSide,
);

enum SearchMenuEnum {
  filter,
  quickSearchList,
  addToQuickSearch,
}

class GallerySearchPage extends StatelessWidget {
  SearchPageController get controller => Get.find(tag: searchPageCtrlDepth);

  @override
  Widget build(BuildContext context) {
    final Widget cfp = CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(start: 0),
//        border: null,

        middle: CupertinoTextField(
          style: const TextStyle(
            height: 1,
            textBaseline: TextBaseline.alphabetic,
          ),
          decoration: const BoxDecoration(
            color: CupertinoDynamicColor.withBrightness(
              color: CupertinoColors.white,
              darkColor: CupertinoColors.black,
            ),
            border: _kDefaultRoundedBorder,
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          clearButtonMode: OverlayVisibilityMode.editing,
          padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
          controller: controller.searchTextController,
          autofocus: controller.autofocus,
          textInputAction: TextInputAction.search,
          onEditingComplete: controller.onEditingComplete,
          focusNode: controller.focusNode,
        ),
        transitionBetweenRoutes: false,
        leading: Container(
          width: 0,
        ),
        trailing: _buildTrailing(context),
      ),
      child: GestureDetector(
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
            Obx(() => SliverSafeArea(
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
            _endIndicator(),
          ],
        ),
      ),
    );

    return cfp;
  }

  Widget _getTagQryList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.addQryTag(index);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${controller.qryTags[index].namespace.shortName}:${controller.qryTags[index].key}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(controller.qryTags[index].name,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.secondaryLabel, Get.context),
                    )),
              ],
            ).paddingSymmetric(vertical: 4, horizontal: 20),
          );
        },
        childCount: controller.qryTags.length,
      ),
    );
  }

  Widget _getInitView() {
    return GetBuilder<SearchPageController>(
      tag: searchPageCtrlDepth,
      id: 'InitView',
      builder: (controller) {
        final List<Widget> _btnList = List<Widget>.from(controller.seaechHistory
            .map((e) => TagButton(
                  text: e,
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  onPressed: () {
                    controller.appendTextToSearch(e);
                  },
                ))
            .toList());

        return SliverToBoxAdapter(
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search History',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  child: Wrap(
                    spacing: 8, //主轴上子控件的间距
                    runSpacing: 10, //交叉轴上子控件之间的间距
                    children: _btnList.sublist(
                        0, min<int>(20, _btnList.length)), //要显示的子控件集合
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: controller.clearHistory,
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
                          'Clear search history',
                          style: TextStyle(
                            fontSize: 15,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, Get.context),
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
                          S.of(Get.context).list_load_more_fail,
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
      (List<GalleryItem> state) {
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
        onLongPress: () {
          controller.isSearchBarComp = true;
          VibrateUtil.heavy();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.only(left: 4),
              child: Text(S.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.only(right: 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.activeBlue, context),
                  child: Obx(() => Text(
                        '${controller.curPage + 1}',
                        style: TextStyle(
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondarySystemBackground,
                                context)),
                      )),
                ),
              ),
              onPressed: () {
                controller.jumpToPage();
              },
            ),
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
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.plusCircle,
                size: 20,
              ),
              onPressed: () {
                controller.addToQuickSearch();
              },
            ),
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.alignJustify,
                size: 20,
              ),
              onPressed: () {
                controller.quickSearchList();
              },
            ),
          ],
        ),
      );
    }

    Widget _menuItem({IconData icon, String title, VoidCallback onTap}) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          VibrateUtil.light();
          controller.customPopupMenuController.hideMenu();
          onTap();
        },
        child: Container(
          padding:
              const EdgeInsets.only(left: 14, right: 18, top: 5, bottom: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 20,
                // color: CupertinoDynamicColor.resolve(
                //     CupertinoColors.secondaryLabel, Get.context),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    title ?? '',
                    style: TextStyle(
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.label, Get.context),
                      // fontWeight: FontWeight.w500,
                      // fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildMenu() {
      final Color _color =
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey6, context)
              .withOpacity(0.95);
      return CustomPopupMenu(
        child: Container(
          padding: const EdgeInsets.only(right: 14, left: 4),
          child: const Icon(
            FontAwesomeIcons.ellipsisH,
            size: 20,
          ),
        ),
        arrowColor: _color,
        showArrow: false,
        menuBuilder: () {
          VibrateUtil.light();
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: _color,
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _menuItem(
                      icon: FontAwesomeIcons.filter,
                      title: S.of(context).show_filter,
                      onTap: showFilterSetting,
                    ),
                    _menuItem(
                      icon: FontAwesomeIcons.plusCircle,
                      title: S.of(context).add_quick_search,
                      onTap: controller.addToQuickSearch,
                    ),
                    _menuItem(
                      icon: FontAwesomeIcons.alignJustify,
                      title: S.of(context).quick_search,
                      onTap: controller.quickSearchList,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        pressType: PressType.singleClick,
        controller: controller.customPopupMenuController,
      );
    }

    Widget _buildPopMenuBtn() {
      return GestureDetector(
        onLongPress: () {
          controller.isSearchBarComp = false;
          VibrateUtil.heavy();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.only(left: 4),
              child: Text(S.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoButton(
              minSize: 36,
              padding: const EdgeInsets.only(right: 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.activeBlue, context),
                  child: Obx(() => Text(
                        '${controller.curPage.value + 1}',
                        style: TextStyle(
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondarySystemBackground,
                                context)),
                      )),
                ),
              ),
              onPressed: () {
                controller.jumpToPage();
              },
            ),
            _buildMenu(),
          ],
        ),
      );
    }

    return Obx(() {
      final Size size = MediaQuery.of(context).size;
      final double width = size.width;
      final bool _isSearchBarComp = controller.isSearchBarComp;
      if (width > 450) {
        return _buildListBtns();
      } else {
        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 0),
            child: _isSearchBarComp
                ? Container(key: UniqueKey(), child: _buildPopMenuBtn())
                : Container(key: UniqueKey(), child: _buildListBtns()));
      }
    });
  }
}
