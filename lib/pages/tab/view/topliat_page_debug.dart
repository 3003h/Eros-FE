import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/comm.dart';
import 'package:fehviewer/pages/tab/controller/toplist_controller.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:flutter/cupertino.dart';
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

          return ListView.builder(
            itemBuilder: (context, index) {
              final imageP = logic.state?[index];
              if (imageP == null) {
                return const SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(imageP.englishTitle ?? ''),
              );
            },
            itemCount: logic.state?.length ?? 0,
          );
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
