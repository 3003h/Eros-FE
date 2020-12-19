import 'package:fehviewer/common/controller/ehconfig_controller.dart';
import 'package:fehviewer/common/states/gallery_model.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/item/gallery_item.dart';
import 'package:fehviewer/pages/item/gallery_item_flow.dart';
import 'package:fehviewer/pages/item/gallery_item_simple.dart';
import 'package:fehviewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

SliverPadding buildWaterfallFlow(List<GalleryItem> gallerItemBeans, tabIndex,
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

          return ChangeNotifierProvider<GalleryModel>.value(
            value: GalleryModel()
              ..initData(gallerItemBeans[index], tabIndex: tabIndex),
            child: GalleryItemFlow(),
          );
        },
        childCount: gallerItemBeans.length,
      ),
    ),
  );
}

SliverList buildGallerySliverListView(
    List<GalleryItem> gallerItemBeans, tabIndex,
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

        return ChangeNotifierProvider<GalleryModel>.value(
          value: GalleryModel()
            ..initData(gallerItemBeans[index], tabIndex: tabIndex),
          child: GalleryItemWidget(
            galleryItem: gallerItemBeans[index],
            tabIndex: tabIndex,
          ),
        );
      },
      childCount: gallerItemBeans.length,
    ),
  );
}

SliverFixedExtentList buildGallerySliverListSimpleView(
    List<GalleryItem> gallerItemBeans, tabIndex,
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

        return ChangeNotifierProvider<GalleryModel>.value(
          value: GalleryModel()
            ..initData(gallerItemBeans[index], tabIndex: tabIndex),
          child: GalleryItemSimpleWidget(
            galleryItem: gallerItemBeans[index],
            tabIndex: tabIndex,
          ),
        );
      },
      childCount: gallerItemBeans.length,
    ),
    itemExtent: kItemWidth + 1,
  );
}

Widget getGalleryList(List<GalleryItem> gallerItemBeans, tabIndex,
    {int maxPage, int curPage, VoidCallback loadMord}) {
  final EhConfigController ehConfigController = Get.find();
  return Obx(() {
    switch (ehConfigController.listMode.value) {
      case ListModeEnum.list:
        return buildGallerySliverListView(gallerItemBeans, tabIndex,
            maxPage: maxPage, curPage: curPage, loadMord: loadMord);
        break;
      case ListModeEnum.waterfall:
        return buildWaterfallFlow(gallerItemBeans, tabIndex,
            maxPage: maxPage, curPage: curPage, loadMord: loadMord);
        break;
      case ListModeEnum.simpleList:
        return buildGallerySliverListSimpleView(gallerItemBeans, tabIndex,
            maxPage: maxPage, curPage: curPage, loadMord: loadMord);
        break;
    }
    return Container();
  });
}
