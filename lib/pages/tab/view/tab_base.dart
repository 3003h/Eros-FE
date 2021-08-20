import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/pages/item/gallery_item.dart';
import 'package:fehviewer/pages/item/gallery_item_flow.dart';
import 'package:fehviewer/pages/item/gallery_item_flow_large.dart';
import 'package:fehviewer/pages/item/gallery_item_simple.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keframe/frame_separate_widget.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

SliverPadding buildWaterfallFlow(
  List<GalleryItem> gallerItemBeans,
  dynamic tabTag, {
  int? maxPage,
  required int curPage,
  VoidCallback? loadMord,
  bool large = false,
}) {
  final double _padding = large
      ? EHConst.waterfallFlowLargeCrossAxisSpacing
      : EHConst.waterfallFlowCrossAxisSpacing;
  return SliverPadding(
    padding: EdgeInsets.all(_padding),
    sliver: SliverWaterfallFlow(
      gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: large
            ? EHConst.waterfallFlowLargeMaxCrossAxisExtent
            : (!Get.context!.isPhone
                ? EHConst.waterfallFlowMaxCrossAxisExtentTablet
                : EHConst.waterfallFlowMaxCrossAxisExtent),
        crossAxisSpacing: large
            ? EHConst.waterfallFlowLargeCrossAxisSpacing
            : EHConst.waterfallFlowCrossAxisSpacing,
        mainAxisSpacing: large
            ? EHConst.waterfallFlowLargeMainAxisSpacing
            : EHConst.waterfallFlowMainAxisSpacing,
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
              loadMord?.call();
            }
          }

          return large
              ? GalleryItemFlowLarge(
                  key: UniqueKey(),
                  galleryItem: gallerItemBeans[index],
                  tabTag: tabTag,
                )
              : GalleryItemFlow(
                  key: UniqueKey(),
                  galleryItem: gallerItemBeans[index],
                  tabTag: tabTag,
                );
        },
        childCount: gallerItemBeans.length,
      ),
    ),
  );
}

Widget buildGallerySliverListItem(
    GalleryItem _item, int index, Animation<double> _animation,
    {dynamic tabTag}) {
  return FadeTransition(
    opacity: _animation.drive(CurveTween(curve: Curves.easeIn)),
    child: SizeTransition(
      sizeFactor: _animation.drive(CurveTween(curve: Curves.easeIn)),
      child: GalleryItemWidget(
        key: ValueKey(_item.gid),
        galleryItem: _item,
        tabTag: tabTag,
      ),
    ),
  );
}

Widget buildDelGallerySliverListItem(
    GalleryItem _item, int index, Animation<double> _animation,
    {dynamic tabTag}) {
  return FadeTransition(
    opacity: _animation
        .drive(CurveTween(curve: Interval(0.0, 1.0, curve: Curves.easeOut))),
    child: SizeTransition(
      sizeFactor: _animation
          .drive(CurveTween(curve: Interval(0.0, 1.0, curve: Curves.easeOut))),
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(1, 0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _animation,
                curve: Interval(0.4, 1.0, curve: Curves.easeOut))),
        child: GalleryItemWidget(
          key: ValueKey(_item.gid),
          galleryItem: _item,
          tabTag: tabTag,
        ),
      ),
    ),
  );
}

Widget buildGallerySliverListView(
  List<GalleryItem> gallerItemBeans,
  dynamic tabTag, {
  int? maxPage,
  int curPage = 0,
  VoidCallback? loadMord,
  Key? key,
}) {
  return SliverAnimatedList(
    key: key,
    initialItemCount: gallerItemBeans.length,
    itemBuilder:
        (BuildContext context, int index, Animation<double> animation) {
      if (maxPage != null) {
        if (index == gallerItemBeans.length - 1 && curPage < maxPage - 1) {
          logger.v('$index ${gallerItemBeans.length}');
//            加载更多数据的回调
          loadMord?.call();
        }
      }
      final GalleryItem _item = gallerItemBeans[index];
      return buildGallerySliverListItem(_item, index, animation,
          tabTag: tabTag);
    },
  );

  if (false)
    return SliverList(
      key: key,
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (maxPage != null) {
            if (index == gallerItemBeans.length - 1 && curPage < maxPage - 1) {
              logger.v('$index ${gallerItemBeans.length}');
//            加载更多数据的回调
              loadMord?.call();
            }
          }

          final GalleryItem _item = gallerItemBeans[index];

          return FrameSeparateWidget(
            index: index,
            placeHolder: const GalleryItemPlaceHolder(),
            child: Obx(
              () {
                return Stack(
                  children: [
                    GalleryItemWidget(
                      key: UniqueKey(),
                      galleryItem: _item,
                      tabTag: tabTag,
                    ),
                    if (Get.find<EhConfigService>().debugMode)
                      Positioned(
                        right: 12,
                        top: 4,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: CupertinoColors.secondarySystemBackground,
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.black,
                                offset: Offset(1, 1),
                                blurRadius: 2.5,
                              )
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
        childCount: gallerItemBeans.length,
      ),
    );
}

SliverFixedExtentList buildGallerySliverListSimpleView(
  List<GalleryItem> gallerItemBeans,
  tabTag, {
  int? maxPage,
  required int curPage,
  VoidCallback? loadMord,
  Key? key,
}) {
  return SliverFixedExtentList(
    key: key,
    delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        if (maxPage != null) {
          if (index == gallerItemBeans.length - 1 && curPage < maxPage - 1) {
//            加载更多数据的回调
            loadMord?.call();
          }
        }

        return GalleryItemSimpleWidget(
          key: UniqueKey(),
          galleryItem: gallerItemBeans[index],
          tabTag: tabTag,
        );
      },
      childCount: gallerItemBeans.length,
    ),
    itemExtent: kItemWidth + 1,
  );
}

Widget getGalleryList(
  List<GalleryItem>? gallerItemBeans,
  tabTag, {
  int? maxPage,
  int? curPage,
  VoidCallback? loadMord,
  Key? key,
}) {
  final EhConfigService ehConfigService = Get.find();

  // logger.d(' getGalleryList');

  return Obx(() {
    // ignore: missing_enum_constant_in_switch
    switch (ehConfigService.listMode.value) {
      case ListModeEnum.list:
        return buildGallerySliverListView(
          gallerItemBeans ?? [],
          tabTag,
          maxPage: maxPage,
          curPage: curPage ?? 0,
          loadMord: loadMord,
          key: key,
        );
      case ListModeEnum.waterfall:
        return buildWaterfallFlow(
          gallerItemBeans ?? [],
          tabTag,
          maxPage: maxPage,
          curPage: curPage ?? 0,
          loadMord: loadMord,
        );
      case ListModeEnum.waterfallLarge:
        return buildWaterfallFlow(
          gallerItemBeans ?? [],
          tabTag,
          maxPage: maxPage,
          curPage: curPage ?? 0,
          loadMord: loadMord,
          large: true,
        );
      case ListModeEnum.simpleList:
        return buildGallerySliverListSimpleView(
          gallerItemBeans ?? [],
          tabTag,
          maxPage: maxPage,
          curPage: curPage ?? 0,
          loadMord: loadMord,
          key: key,
        );
    }
  });
}

class SearchRepository {
  SearchRepository({this.searchText, this.searchType = SearchType.normal});

  final String? searchText;
  final SearchType searchType;
}
