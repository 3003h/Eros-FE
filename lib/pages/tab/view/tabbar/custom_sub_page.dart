import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/group/custom_sublist_controller.dart';
import 'package:fehviewer/pages/tab/controller/group/custom_tabbar_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../comm.dart';
import '../constants.dart';
import '../gallery_base.dart';
import '../list/tab_base.dart';

class SubListView<T extends CustomSubListController> extends StatefulWidget {
  const SubListView({
    super.key,
    required this.profileUuid,
    this.pinned = true,
  });

  final String profileUuid;
  final bool pinned;

  @override
  State<SubListView> createState() => _SubListViewState<T>();
}

class _SubListViewState<T extends CustomSubListController>
    extends State<SubListView> with AutomaticKeepAliveClientMixin {
  late final CustomSubListController subController;
  final CustomTabbarController controller = Get.find();
  final EhTabController ehTabController = EhTabController();

  @override
  void initState() {
    super.initState();
    logger.t('Get.find ${T.runtimeType} tag:${widget.profileUuid}');
    subController = Get.find<T>(tag: widget.profileUuid)
      ..heroTag = widget.profileUuid;
    controller.subControllerMap[widget.profileUuid] = subController;
    subController.listMode =
        subController.profile?.listMode ?? ListModeEnum.global;
    addListen();
  }

  void addListen() {
    subController.initEhTabController(
      context: context,
      ehTabController: ehTabController,
      tabTag: EHRoutes.gallery,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      cacheExtent: kTabViewCacheExtent,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverSafeArea(
          top: widget.pinned,
          bottom: false,
          sliver: _buildRefresh(context),
        ),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: _buildListView(),
        ),
        Obx(() {
          return SliverSafeArea(
            sliver: EndIndicator(
              pageState: subController.pageState,
              loadDataMore: subController.loadDataMore,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRefresh(BuildContext context) {
    return SliverPadding(
        padding: widget.pinned
            ? const EdgeInsets.only(top: kHeaderMaxHeight)
            : EdgeInsets.only(
                top: context.mediaQueryPadding.top + kTopTabbarHeight),
        sliver: EhCupertinoSliverRefreshControl(
          onRefresh: subController.onRefresh,
        ));
  }

  Widget _buildListView() {
    return GetBuilder<CustomSubListController>(
      global: false,
      init: subController,
      id: subController.listViewId,
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
                onTap: subController.reLoadDataFirst,
                error: status.errorMessage,
              ),
            ),
          );
        }

        if (status.isSuccess) {
          return getGallerySliverList(
            logic.state,
            subController.heroTag,
            next: logic.next,
            lastComplete: subController.lastComplete,
            // key: subController.sliverAnimatedListKey,
            listMode: subController.listModeObs,
            // centerKey: subController.galleryGroupKey,
            keepPosition: subController.keepPosition,
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
          ).autoCompressKeyboard(Get.context!),
        );
      },
    );
  }
}
