import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
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
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import 'tab_base.dart';

class GalleryListTab extends GetView<GalleryViewController> {
  const GalleryListTab({Key? key, this.tabTag, this.scrollController})
      : super(key: key);

  final String? tabTag;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    // logger.d(' GalleryListTab BuildContext');
    final CustomScrollView customScrollView = CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          transitionBetweenRoutes: false,
          padding: const EdgeInsetsDirectional.only(end: 4),
          largeTitle: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.title),
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
          leading: controller.enablePopupMenu &&
                  (!(Get.find<EhConfigService>().isSafeMode.value ?? false))
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
                  LineIcons.search,
                  size: 26,
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
                  LineIcons.filter,
                  size: 26,
                ),
                onPressed: () {
                  // logger.v('${EHUtils.convNumToCatMap(1)}');
                  showFilterSetting();
                },
              ),
              // 页码跳转按钮
              CupertinoButton(
                minSize: 40,
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
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

    // CustomPopupMenu 更新改用了inkwell 要包一层Scaffold 否则会报错。 并且更新偏移值
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        alignment: Alignment.centerLeft,
        child: CustomPopupMenu(
          child: Container(
            padding: const EdgeInsets.only(left: 14, bottom: 2),
            child: const Icon(
              // LineIcons.horizontalEllipsis,
              CupertinoIcons.ellipsis_circle,
              size: 26,
            ),
          ),
          arrowColor: _color,
          showArrow: false,
          menuBuilder: () {
            vibrateUtil.light();
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
          verticalMargin: 8,
          horizontalMargin: 8,
          controller: controller.customPopupMenuController,
        ),
      ),
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
          }())),
    );
  }

  Widget _getGalleryList() {
    return controller.obx(
        (List<GalleryItem>? state) {
          return getGalleryList(
            state,
            tabTag,
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
  ItemModel(this.title, this.icon);
  String title;
  IconData icon;
}
