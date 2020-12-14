import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/pages/tab/controller/popular_controller.dart';
import 'package:FEhViewer/pages/tab/view/gallery_base.dart';
import 'package:FEhViewer/pages/tab/view/tab_base.dart';
import 'package:FEhViewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularListTab extends StatelessWidget {
  PopularListTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
  final String tabIndex;
  final ScrollController scrollController;

  final PopularController controller = Get.put(PopularController());

  @override
  Widget build(BuildContext context) {
    final String _title = 'tab_popular'.tr;
    final CustomScrollView customScrollView = CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: TabPageTitle(
            title: _title,
            isLoading: false,
          ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await controller.reloadData();
          },
        ),
        SliverSafeArea(
          top: false,
          sliver: _getGalleryList(),
        ),
      ],
    );

    return CupertinoPageScaffold(child: customScrollView);
  }

  Widget _getGalleryList() {
    return GetX<PopularController>(builder: (PopularController controller) {
      return FutureBuilder<List<GalleryItem>>(
        future: controller.futureBuilderFuture.value,
        builder:
            (BuildContext context, AsyncSnapshot<List<GalleryItem>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return controller.lastListWidget ??
                  SliverFillRemaining(
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: const CupertinoActivityIndicator(
                        radius: 14.0,
                      ),
                    ),
                  );
            case ConnectionState.done:
              if (snapshot.hasError) {
                Global.logger.e('${snapshot.error}');
                return SliverFillRemaining(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: GalleryErrorPage(
                      onTap: controller.reLoadDataFirst,
                    ),
                  ),
                );
              } else {
                controller.lastListWidget =
                    getGalleryList(snapshot.data, tabIndex);
                return controller.lastListWidget;
              }
          }
          return null;
        },
      );
    });
  }
}
