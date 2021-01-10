import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/filter/filter.dart';
import 'package:fehviewer/pages/tab/controller/enum.dart';
import 'package:fehviewer/pages/tab/controller/gallery_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'tab_base.dart';

class GalleryListTab extends GetView<GalleryViewController> {
  const GalleryListTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);

  final String tabIndex;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final CustomScrollView customScrollView = CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 4),
          largeTitle: Text(controller.title),
          leading: controller.enablePopupMenu &&
                  (!Get.find<EhConfigService>().isSafeMode.value)
              ? _buildLeading(context)
              : const SizedBox(),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 搜索按钮
              CupertinoButton(
                minSize: 40,
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.search,
                  size: 20,
                ),
                onPressed: () {
                  NavigatorUtil.showSearch();
                },
              ),
              // 筛选按钮
              CupertinoButton(
                minSize: 40,
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.filter,
                  size: 20,
                ),
                onPressed: () {
                  // logger.v('${EHUtils.convNumToCatMap(1)}');
                  showFilterSetting();
                },
              ),
              // 页码跳转按钮
              CupertinoButton(
                minSize: 40,
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
            ],
          ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: controller.onRefresh,
        ),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: _getGalleryList(),
        ),
        _endIndicator(),
      ],
    );

    return CupertinoPageScaffold(
      child: customScrollView,
    );
  }

  Widget _buildLeading(BuildContext context) {
    final Color _color =
        CupertinoDynamicColor.resolve(CupertinoColors.systemGrey5, context)
            .withOpacity(0.98);
    return CustomPopupMenu(
      child: Container(
        padding: const EdgeInsets.only(left: 14),
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
              child: controller.popupMenu,
            ),
          ),
        );
      },
      pressType: PressType.singleClick,
      verticalMargin: -5,
      horizontalMargin: 5,
      controller: controller.customPopupMenuController,
    );
  }

  Widget _endIndicator() {
    return SliverToBoxAdapter(
      child: Obx(() => Container(
          alignment: Alignment.center,
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
                    children: const <Widget>[
                      Icon(
                        Icons.error,
                        size: 40,
                        color: CupertinoColors.systemRed,
                      ),
                      Text(
                        'Load failed, tap to retry',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              default:
                return Container();
            }
          }())),
    );
  }

  Widget _getGalleryList() {
    return controller.obx(
        (List<GalleryItem> state) {
          return getGalleryList(
            state,
            tabIndex,
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
                onTap: controller.reLoadDataFirst,
              ),
            ),
          );
        });
  }
}

class ItemModel {
  String title;
  IconData icon;
  ItemModel(this.title, this.icon);
}
