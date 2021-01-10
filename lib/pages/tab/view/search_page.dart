import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/filter/filter.dart';
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
  // final SearchPageController controller = Get.find(tag: searchPageCtrlDepth);
  @override
  Widget build(BuildContext context) {
    final SearchPageController controller = Get.find(tag: searchPageCtrlDepth);

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
    final SearchPageController controller = Get.find(tag: searchPageCtrlDepth);
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
    final SearchPageController controller = Get.find(tag: searchPageCtrlDepth);
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
    final SearchPageController controller = Get.find(tag: searchPageCtrlDepth);

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
