import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/pages/item/gallery_item.dart';
import 'package:fehviewer/pages/item/gallery_item_flow.dart';
import 'package:fehviewer/pages/item/gallery_item_simple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

SliverPadding buildWaterfallFlow(List<GalleryItem> gallerItemBeans, tabTag,
    {int maxPage, int curPage, VoidCallback loadMord}) {
  const double _padding = EHConst.waterfallFlowCrossAxisSpacing;
  return SliverPadding(
    padding: const EdgeInsets.all(_padding),
    sliver: SliverWaterfallFlow(
      gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: EHConst.waterfallFlowMaxCrossAxisExtent,
        crossAxisSpacing: EHConst.waterfallFlowCrossAxisSpacing,
        mainAxisSpacing: EHConst.waterfallFlowMainAxisSpacing,
        lastChildLayoutTypeBuilder: (int index) =>
            index == gallerItemBeans.length
                ? LastChildLayoutType.foot
                : LastChildLayoutType.none,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (maxPage != null) {
            if (index == gallerItemBeans.length - 1 && curPage < maxPage - 1) {
//            加载更多数据的回调
              loadMord();
            }
          }
          Get.create(() => GalleryItemController.initData(
              gallerItemBeans[index],
              tabTag: tabTag));

          return GalleryItemFlow(
            galleryItem: gallerItemBeans[index],
            tabTag: tabTag,
          );
        },
        childCount: gallerItemBeans.length,
      ),
    ),
  );
}

SliverList buildGallerySliverListView(List<GalleryItem> gallerItemBeans, tabTag,
    {int maxPage, int curPage, VoidCallback loadMord}) {
  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        if (maxPage != null) {
          if (index == gallerItemBeans.length - 1 && curPage < maxPage - 1) {
//            加载更多数据的回调
            loadMord();
          }
        }

        // logger.d('buildGallerySliverListView ');

        return GetBuilder<GalleryItemController>(
            init: GalleryItemController.initData(
              gallerItemBeans[index],
              tabTag: tabTag,
            ),
            tag: gallerItemBeans[index].gid,
            id: gallerItemBeans[index].gid,
            builder: (constoller) {
              return GalleryItemWidget(
                galleryItem: gallerItemBeans[index],
                tabTag: tabTag,
                controller: constoller,
              );
            });
      },
      childCount: gallerItemBeans.length,
    ),
  );
}

SliverFixedExtentList buildGallerySliverListSimpleView(
    List<GalleryItem> gallerItemBeans, tabTag,
    {int maxPage, int curPage, VoidCallback loadMord}) {
  return SliverFixedExtentList(
    delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        if (maxPage != null) {
          if (index == gallerItemBeans.length - 1 && curPage < maxPage - 1) {
//            加载更多数据的回调
            loadMord();
          }
        }
        Get.create(() => GalleryItemController.initData(gallerItemBeans[index],
            tabTag: tabTag));

        return GalleryItemSimpleWidget(
          galleryItem: gallerItemBeans[index],
          tabTag: tabTag,
        );
      },
      childCount: gallerItemBeans.length,
    ),
    itemExtent: kItemWidth + 1,
  );
}

Widget getGalleryList(List<GalleryItem> gallerItemBeans, tabTag,
    {int maxPage, int curPage, VoidCallback loadMord}) {
  final EhConfigService ehConfigService = Get.find();

  // logger.d(' getGalleryList');

  return Obx(() {
    switch (ehConfigService.listMode.value) {
      case ListModeEnum.list:
        return buildGallerySliverListView(gallerItemBeans, tabTag,
            maxPage: maxPage, curPage: curPage, loadMord: loadMord);
        break;
      case ListModeEnum.waterfall:
        return buildWaterfallFlow(gallerItemBeans, tabTag,
            maxPage: maxPage, curPage: curPage, loadMord: loadMord);
        break;
      case ListModeEnum.simpleList:
        return buildGallerySliverListSimpleView(gallerItemBeans, tabTag,
            maxPage: maxPage, curPage: curPage, loadMord: loadMord);
        break;
    }
    return Container();
  });
}
