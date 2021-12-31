import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/custom_sublist_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabview_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../comm.dart';
import '../../controller/custom_tabbar_controller.dart';
import '../constants.dart';
import '../gallery_base.dart';
import '../tab_base.dart';

class SubListView<T extends CustomSubListController> extends StatefulWidget {
  const SubListView({Key? key, required this.profileName}) : super(key: key);

  final String profileName;

  @override
  _SubListViewState createState() => _SubListViewState<T>();
}

class _SubListViewState<T extends CustomSubListController>
    extends State<SubListView> with AutomaticKeepAliveClientMixin {
  late final CustomSubListController subController;
  final CustomTabbarController controller = Get.find();
  final EhTabController ehTabController = EhTabController();
  final GlobalKey<ExtendedNestedScrollViewState> _key =
      GlobalKey<ExtendedNestedScrollViewState>();

  @override
  void initState() {
    super.initState();
    subController = Get.find<T>(tag: widget.profileName)
      ..heroTag = widget.profileName
      ..profileName = widget.profileName;
    controller.subControllerMap[widget.profileName] = subController;
    addListen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    logger.d('didChangeDependencies');
    controller.heroTag = widget.profileName;
  }

  void addListen() {
    subController.initEhTabController(
      context: context,
      ehTabController: ehTabController,
      tabTag: EHRoutes.customlist,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
            padding: EdgeInsets.only(
                top: context.mediaQueryPadding.top + kTopTabbarHeight),
            sliver: EhCupertinoSliverRefreshControl(
              onRefresh: () => subController.onRefresh(),
            )),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: _getGallerySliverList(),
        ),
        Obx(() {
          return EndIndicator(
            pageState: subController.pageState,
            loadDataMore: subController.loadDataMore,
          );
        }),
      ],
    );
  }

  Widget _getGallerySliverList() {
    return subController.obx(
        (List<GalleryItem>? state) {
          return getGallerySliverList(
            state,
            subController.heroTag,
            maxPage: subController.maxPage,
            curPage: subController.curPage,
            lastComplete: subController.lastComplete,
            key: subController.sliverAnimatedListKey,
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
                onTap: subController.reLoadDataFirst,
              ),
            ),
          );
        });
  }
}
