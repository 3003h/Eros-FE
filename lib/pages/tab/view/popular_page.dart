import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/tab/controller/popular_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularListTab extends GetView<PopularViewController> {
  const PopularListTab({
    Key? key,
    this.tabTag,
    this.scrollController,
  }) : super(key: key);
  final String? tabTag;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final String _title = S.of(context).tab_popular;

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

    final CupertinoNavigationBar navigationBar = CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      middle: Row(
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

    final Widget customScrollView = CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        // sliverNavigationBar,
        SliverPadding(
          padding: EdgeInsets.only(
              top: context.mediaQueryPadding.top +
                  kMinInteractiveDimensionCupertino),
          sliver: CupertinoSliverRefreshControl(
            onRefresh: controller.onRefresh,
          ),
        ),
        SliverSafeArea(
          top: false,
          sliver: _getGalleryList(),
        ),
      ],
    );

    return CupertinoPageScaffold(
      navigationBar: navigationBar,
      child: SafeArea(
        top: false,
        bottom: false,
        child: CupertinoScrollbar(
          controller: scrollController,
          child: customScrollView,
        ),
      ),
    );
  }

  Widget _getGalleryList() {
    return controller
        .obx((List<GalleryItem>? state) => getGalleryList(state, tabTag),
            onLoading: SliverFillRemaining(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 50),
                child: const CupertinoActivityIndicator(
                  radius: 14.0,
                ),
              ),
            ), onError: (err) {
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
