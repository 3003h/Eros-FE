import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/pages/item/gallery_item.dart';
import 'package:fehviewer/pages/tab/comm.dart';
import 'package:fehviewer/pages/tab/controller/toplist_controller.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'gallery_base.dart';

class ToplistTabDebug extends StatefulWidget {
  const ToplistTabDebug({Key? key}) : super(key: key);

  @override
  State<ToplistTabDebug> createState() => _ToplistTabDebugState();
}

class _ToplistTabDebugState extends State<ToplistTabDebug> {
  final controller = Get.find<TopListViewController>();
  final EhTabController ehTabController = EhTabController();
  bool _isSliver = true;

  @override
  void initState() {
    super.initState();

    controller.initStateForListPage(
      context: context,
      ehTabController: ehTabController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 4),
        transitionBetweenRoutes: false,
        leading: controller.getLeading(context),
        middle: GestureDetector(
          onTap: () => controller.srcollToTop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.getTopListTitle),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CupertinoSwitch(
                value: _isSliver,
                onChanged: (val) {
                  setState(() {
                    _isSliver = val;
                  });
                }),
            CupertinoButton(
              padding: const EdgeInsets.all(0.0),
              minSize: 40,
              child: const Icon(
                CupertinoIcons.refresh,
                size: 28,
              ),
              onPressed: () => controller.reloadData,
            ),
            CupertinoButton(
              padding: const EdgeInsets.all(0.0),
              minSize: 40,
              child: Stack(
                alignment: Alignment.centerRight,
                // mainAxisSize: MainAxisSize.min,
                children: const <Widget>[
                  Icon(
                    CupertinoIcons.sort_down,
                    size: 28,
                  ),
                ],
              ),
              onPressed: () => controller.setToplist(context),
            ),
            // 页码跳转按钮
            CupertinoButton(
              minSize: 40,
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
                      textScaleFactor: 0.9,
                      textAlign: TextAlign.center,
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
      ),
      child: Container(
        child: _buildListView(context),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return GetBuilder<TopListViewController>(
      global: false,
      init: controller,
      id: controller.listViewId,
      builder: (logic) {
        final status = logic.status;

        if (status.isLoading) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 50),
            child: const CupertinoActivityIndicator(
              radius: 14.0,
            ),
          );
        }

        if (status.isError) {
          return Container(
            padding: const EdgeInsets.only(bottom: 50),
            child: GalleryErrorPage(
              onTap: logic.reLoadDataFirst,
              error: status.errorMessage,
            ),
          );
        }

        if (status.isSuccess) {
          if (_isSliver) {
            return CustomScrollView(
              slivers: [
                EhCupertinoSliverRefreshControl(
                  onRefresh: controller.onRefresh,
                ),
                SliverSafeArea(
                  top: true,
                  bottom: false,
                  sliver: Builder(
                    builder: (_) {
                      return getGallerySliverList(
                        logic.state,
                        controller.heroTag,
                        maxPage: controller.maxPage,
                        curPage: controller.curPage,
                        lastComplete: controller.lastComplete,
                        // key: controller.sliverAnimatedListKey,
                        // lastTopitemIndex: controller.lastTopitemIndex,
                      );
                    },
                  ),
                ),
                Obx(() {
                  return EndIndicator(
                    pageState: controller.pageState,
                    loadDataMore: controller.loadDataMore,
                  );
                }),
              ],
            );
          } else {
            final gallerylist = logic.state ?? [];
            return ListView.builder(
              itemBuilder: (context, index) {
                if (gallerylist.length - 1 < index) {
                  return const SizedBox.shrink();
                }

                if (index == gallerylist.length - 1 &&
                    controller.curPage < controller.maxPage - 1) {
                  // 加载完成最后一项的回调
                  SchedulerBinding.instance.addPostFrameCallback(
                      (_) => controller.lastComplete.call());
                }

                final GalleryProvider _provider = gallerylist[index];
                Get.lazyReplace(() => _provider,
                    tag: _provider.gid, fenix: true);
                Get.lazyReplace(
                  () => GalleryItemController(
                      galleryProvider: Get.find(tag: _provider.gid)),
                  tag: _provider.gid,
                  fenix: true,
                );

                return GalleryItemWidget(
                  galleryProvider: _provider,
                  tabTag: controller.heroTag,
                );
              },
              itemCount: logic.state?.length ?? 0,
            );
          }
        }

        return Container(
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
        ).autoCompressKeyboard(context);
      },
    );
  }
}
