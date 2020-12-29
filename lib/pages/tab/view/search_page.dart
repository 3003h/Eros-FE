import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/utils/cust_lib/popup_menu.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

enum SearchMenuEnum {
  filter,
  quickSearchList,
  addToQuickSearch,
}

class GallerySearchPage extends GetView<SearchPageController> {
  @override
  Widget build(BuildContext context) {
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
            SliverSafeArea(
              // top: false,
              // bottom: false,
              sliver: _getGalleryList(),
            ),
            _endIndicator(),
          ],
        ),
      ),
    );

    return cfp;
  }

  Widget _endIndicator() {
    return SliverToBoxAdapter(
      child: Obx(() => Container(
            padding: const EdgeInsets.only(top: 50, bottom: 100),
            child: controller.isLoadMore
                ? const CupertinoActivityIndicator(
                    radius: 14,
                  )
                : Container(),
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
          curPage: controller.curPage,
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
    PopupMenu.context = context;
    final TextStyle _menuTextStyle = TextStyle(
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
      fontSize: 12,
    );
    final PopupMenu _menu = PopupMenu(
      maxColumn: 2,
      lineColor: CupertinoDynamicColor.resolve(
          CupertinoColors.systemBackground, context),
      backgroundColor:
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey6, context),
      // highlightColor:
      //     CupertinoDynamicColor.resolve(CupertinoColors.label, context),
      items: <MenuItemProvider>[
        MenuItem(
            title: '筛选',
            itemKey: SearchMenuEnum.filter,
            textStyle: _menuTextStyle,
            image: const Icon(
              FontAwesomeIcons.filter,
              size: 20,
            )),
        MenuItem(
            title: '添加',
            itemKey: SearchMenuEnum.addToQuickSearch,
            textStyle: _menuTextStyle,
            image: const Icon(
              FontAwesomeIcons.plusCircle,
              size: 20,
            )),
        MenuItem(
            title: '列表',
            itemKey: SearchMenuEnum.quickSearchList,
            textStyle: _menuTextStyle,
            image: const Icon(
              FontAwesomeIcons.alignJustify,
              size: 20,
            )),
      ],
      onClickMenu: (MenuItemProvider item) {
        logger.v('${item.menuKey}');
        switch (item.menuKey) {
          case SearchMenuEnum.filter:
            showFilterSetting();
            break;
          case SearchMenuEnum.addToQuickSearch:
            controller.addToQuickSearch();
            break;
          case SearchMenuEnum.quickSearchList:
            controller.quickSearchList();
            break;
        }
      },
    );

    Widget _buildListBtns() {
      return GestureDetector(
        onLongPress: () {
          controller.isSearchBarComp = true;
          VibrateUtil.heavy();
        },
        child: Container(
          width: 165,
          child: Row(
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
        ),
      );
    }

    Widget _buildPopMenuBtn() {
      return GestureDetector(
        onLongPress: () {
          controller.isSearchBarComp = false;
          VibrateUtil.heavy();
        },
        child: Container(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CupertinoButton(
                minSize: 40,
                padding: const EdgeInsets.all(0),
                child: Text(S.of(context).cancel),
                onPressed: () {
                  Get.back();
                },
              ),
              CupertinoButton(
                key: controller.searchMenukey,
                minSize: 40,
                padding: const EdgeInsets.only(right: 4),
                child: const Icon(
                  FontAwesomeIcons.th,
                  size: 20,
                ),
                onPressed: () {
                  _menu.show(widgetKey: controller.searchMenukey);
                },
              ),
            ],
          ),
        ),
      );
    }

    return Obx(() {
      final Size size = MediaQuery.of(context).size;
      final double width = size.width;
      // logger.v(width);
      if (width > 450) {
        return _buildListBtns();
      } else {
        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 0),
            child: controller.isSearchBarComp
                ? Container(key: UniqueKey(), child: _buildPopMenuBtn())
                : Container(key: UniqueKey(), child: _buildListBtns()));
      }
    });
  }
}
