import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/tab/controller/popular_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/cust_lib/persistent_header_builder.dart';
import 'package:fehviewer/utils/cust_lib/sliver/sliver_persistent_header.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/widget/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';

import '../comm.dart';

class PopularListTab extends StatefulWidget {
  const PopularListTab({Key? key}) : super(key: key);

  @override
  _PopularListTabState createState() => _PopularListTabState();
}

class _PopularListTabState extends State<PopularListTab> {
  final controller = Get.find<PopularViewController>();
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
    logger.v('build PopularListTab');
    String _title = L10n.of(context).tab_popular;

    final Widget sliverNavigationBar = CupertinoSliverNavigationBar(
      transitionBetweenRoutes: false,
      largeTitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_title),
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
    );

    final Widget navigationBar = CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        padding: const EdgeInsetsDirectional.only(end: 4),
        middle: GestureDetector(
          onTap: () => controller.srcollToTop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_title),
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
        leading: controller.getLeading(context),
        trailing: CupertinoButton(
          minSize: 40,
          padding: const EdgeInsets.all(0),
          child: const Icon(
            FontAwesomeIcons.search,
            size: 22,
          ),
          onPressed: () {
            NavigatorUtil.goSearchPage();
          },
        ));

    final Widget customScrollView = CustomScrollView(
      cacheExtent: 500,
      // controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        // sliverNavigationBar,
        SliverFloatingPinnedPersistentHeader(
          delegate: SliverFloatingPinnedPersistentHeaderBuilder(
            minExtentProtoType: SizedBox(
              height: context.mediaQueryPadding.top,
            ),
            maxExtentProtoType: navigationBar,
            builder: (_, __, ___) => navigationBar,
          ),
        ),
        EhCupertinoSliverRefreshControl(
          onRefresh: controller.onRefresh,
        ),
        SliverSafeArea(
          top: false,
          sliver: _getGalleryList(),
        ),
      ],
    );

    return CupertinoPageScaffold(
      // navigationBar: navigationBar,
      child: CupertinoScrollbar(
        scrollbarOrientation: ScrollbarOrientation.right,
        controller: PrimaryScrollController.of(context),
        child: SizeCacheWidget(child: customScrollView),
      ),
    );
  }

  Widget _getGalleryList() {
    return controller.obx(
        (List<GalleryProvider>? state) {
          // logger.d('state ${state?.length}');
          return getGallerySliverList(
            state,
            controller.heroTag,
            // key: controller.sliverAnimatedListKey,
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
                error: '$err',
              ),
            ),
          );
        });
  }
}
