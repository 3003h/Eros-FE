import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/favorite_sublist_controller.dart';
import 'package:fehviewer/pages/tab/controller/favorite_tabbar_controller.dart';
import 'package:fehviewer/widget/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../comm.dart';
import '../constants.dart';
import '../gallery_base.dart';
import '../tab_base.dart';

class FavoriteSubPage extends StatefulWidget {
  const FavoriteSubPage({Key? key, required this.favcat}) : super(key: key);

  final String favcat;

  @override
  _FavoriteSubPageState createState() => _FavoriteSubPageState();
}

class _FavoriteSubPageState extends State<FavoriteSubPage>
    with AutomaticKeepAliveClientMixin {
  late final FavoriteSubListController _favoriteSubListController;
  final EhTabController ehTabController = EhTabController();
  final controller = Get.find<FavoriteTabberController>();

  @override
  void initState() {
    super.initState();
    _favoriteSubListController =
        Get.find<FavoriteSubListController>(tag: widget.favcat)
          ..tabTag = 'favsub_${widget.favcat}'
          ..favcat = widget.favcat;
    controller.subControllerMap[widget.favcat] = _favoriteSubListController;
    addListen();
  }

  void addListen() {
    _favoriteSubListController.initEhTabController(
      context: context,
      ehTabController: ehTabController,
      tabTag: EHRoutes.favoriteTabbar,
    );
    // subController.initStateAddPostFrameCallback(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
            padding: EdgeInsets.only(
                top: context.mediaQueryPadding.top + kTopTabbarHeight),
            sliver: EhCupertinoSliverRefreshControl(
              onRefresh: _favoriteSubListController.onRefresh,
            )),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: _getGallerySliverList(),
        ),
        Obx(() {
          return EndIndicator(
            pageState: _favoriteSubListController.pageState,
            loadDataMore: _favoriteSubListController.loadDataMore,
          );
        }),
      ],
    );
  }

  Widget _getGallerySliverList() {
    return _favoriteSubListController.obx(
        (List<GalleryItem>? state) {
          return getGallerySliverList(
            state,
            _favoriteSubListController.tabTag,
            maxPage: _favoriteSubListController.maxPage,
            curPage: _favoriteSubListController.curPage,
            lastComplete: _favoriteSubListController.lastComplete,
            key: _favoriteSubListController.sliverAnimatedListKey,
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
                onTap: _favoriteSubListController.reLoadDataFirst,
              ),
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
