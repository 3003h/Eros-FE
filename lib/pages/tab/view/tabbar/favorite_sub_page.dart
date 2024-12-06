import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/tab/controller/favorite/favorite_sublist_controller.dart';
import 'package:eros_fe/pages/tab/controller/favorite/favorite_tabbar_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../comm.dart';
import '../constants.dart';
import '../gallery_base.dart';
import '../list/tab_base.dart';

class FavoriteSubPage extends StatefulWidget {
  const FavoriteSubPage({super.key, required this.favcat, this.pinned = true});

  final String favcat;
  final bool pinned;

  @override
  State<FavoriteSubPage> createState() => _FavoriteSubPageState();
}

class _FavoriteSubPageState extends State<FavoriteSubPage>
    with AutomaticKeepAliveClientMixin {
  late final FavoriteSubListController _favoriteSubListController;
  final EhTabController ehTabController = EhTabController();
  final controller = Get.find<FavoriteTabBarController>();

  @override
  void initState() {
    super.initState();
    _favoriteSubListController =
        Get.find<FavoriteSubListController>(tag: widget.favcat)
          ..heroTag = 'favsub_${widget.favcat}'
          ..favcat = widget.favcat;
    controller.subControllerMap[widget.favcat] = _favoriteSubListController;
    addListen();
  }

  void addListen() {
    _favoriteSubListController.initEhTabController(
      context: context,
      ehTabController: ehTabController,
      tabTag: EHRoutes.favorite,
    );
    // subController.initStateAddPostFrameCallback(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      // cacheExtent: context.height * 2,
      slivers: [
        SliverSafeArea(
          top: widget.pinned,
          bottom: false,
          sliver: _buildRefresh(context),
        ),
        _buildListView(),
        Obx(() {
          return EndIndicator(
            pageState: _favoriteSubListController.pageState,
            loadDataMore: _favoriteSubListController.loadDataMore,
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
          onRefresh: _favoriteSubListController.onRefresh,
        ));
  }

  Widget _buildListView() {
    return SliverSafeArea(
      top: false,
      bottom: false,
      sliver: GetBuilder<FavoriteSubListController>(
        global: false,
        init: _favoriteSubListController,
        id: _favoriteSubListController.listViewId,
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
            SliverFillRemaining(
              child: Container(
                padding: const EdgeInsets.only(bottom: 50),
                child: GalleryErrorPage(
                  onTap: _favoriteSubListController.reLoadDataFirst,
                  error: status.errorMessage,
                ),
              ),
            );
          }

          if (status.isSuccess) {
            return getGallerySliverList(
              _favoriteSubListController.state,
              _favoriteSubListController.heroTag,
              next: logic.next,
              lastComplete: _favoriteSubListController.lastComplete,
              // key: _favoriteSubListController.sliverAnimatedListKey,
              keepPosition: _favoriteSubListController.keepPosition,
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
