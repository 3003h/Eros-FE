import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/extension.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/pages/item/gallery_item.dart';
import 'package:fehviewer/pages/item/gallery_item_flow.dart';
import 'package:fehviewer/pages/item/gallery_item_flow_large.dart';
import 'package:fehviewer/pages/item/gallery_item_placeholder.dart';
import 'package:fehviewer/pages/item/gallery_item_simple.dart';
import 'package:fehviewer/pages/item/gallery_item_simple_placeholder.dart';
import 'package:fehviewer/pages/tab/controller/enum.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keframe/frame_separate_widget.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../item/gallery_item_grid.dart';
import '../../item/gallery_item_grid_placeholder.dart';

SliverPadding buildWaterfallFlow(
  List<GalleryItem> gallerItemBeans,
  dynamic tabTag, {
  int? maxPage,
  required int curPage,
  VoidCallback? lastComplete,
  bool large = false,
  Key? key,
  Key? centerKey,
  int? lastTopitemIndex,
}) {
  final double _padding = large
      ? EHConst.waterfallFlowLargeCrossAxisSpacing
      : EHConst.waterfallFlowCrossAxisSpacing;
  return SliverPadding(
    padding: EdgeInsets.all(_padding),
    sliver: SliverWaterfallFlow(
      key: key,
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
          if (gallerItemBeans.length - 1 < index) {
            return const SizedBox.shrink();
          }
          if (maxPage != null) {
            if (index == gallerItemBeans.length - 1 && curPage < maxPage - 1) {
              // 加载完成最后一项的回调
              lastComplete?.call();
            }
          }

          final GalleryItem _item = gallerItemBeans[index];
          Get.lazyReplace(() => GalleryItemController(_item),
              tag: _item.gid, fenix: true);

          return large
              ? FrameSeparateWidget(
                  index: index,
                  child: GalleryItemFlowLarge(
                    key: index == lastTopitemIndex
                        ? centerKey
                        : ValueKey(_item.gid),
                    galleryItem: _item,
                    tabTag: tabTag,
                  ),
                )
              : GalleryItemFlow(
                  key: index == lastTopitemIndex
                      ? centerKey
                      : ValueKey(_item.gid),
                  galleryItem: _item,
                  tabTag: tabTag,
                );
        },
        childCount: gallerItemBeans.length,
      ),
    ),
  );
}

SliverPadding buildGrid(
  List<GalleryItem> gallerItemBeans,
  dynamic tabTag, {
  int? maxPage,
  required int curPage,
  VoidCallback? lastComplete,
  Key? key,
  Key? centerKey,
  int? lastTopitemIndex,
}) {
  return SliverPadding(
    padding: const EdgeInsets.all(EHConst.gridCrossAxisSpacing),
    sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: EHConst.gridMaxCrossAxisExtent,
        crossAxisSpacing: EHConst.gridCrossAxisSpacing,
        mainAxisSpacing: EHConst.gridMainAxisSpacing,
        childAspectRatio: EHConst.gridChildAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (gallerItemBeans.length - 1 < index) {
            return const SizedBox.shrink();
          }
          if (maxPage != null) {
            if (index == gallerItemBeans.length - 1 && curPage < maxPage - 1) {
              // 加载完成最后一项的回调
              lastComplete?.call();
            }
          }

          final GalleryItem _item = gallerItemBeans[index];
          Get.lazyReplace(() => GalleryItemController(_item),
              tag: _item.gid, fenix: true);

          return FrameSeparateWidget(
            index: index,
            placeHolder: const GalleryItemGridPlaceHolder(),
            child: GalleryItemGrid(
              key: index == lastTopitemIndex ? centerKey : ValueKey(_item.gid),
              galleryItem: _item,
              tabTag: tabTag,
            ),
          );
        },
        childCount: gallerItemBeans.length,
      ),
    ),
  );
}

Widget _listItemWiget(
  GalleryItem _item, {
  dynamic tabTag,
  Key? centerKey,
  ListModeEnum? listMode,
}) {
  switch (listMode) {
    case ListModeEnum.list:
      return GalleryItemWidget(
        key: centerKey ?? ValueKey(_item.gid),
        galleryItem: _item,
        tabTag: tabTag,
      );
    case ListModeEnum.simpleList:
      return GalleryItemSimpleWidget(
        key: centerKey ?? ValueKey(_item.gid),
        galleryItem: _item,
        tabTag: tabTag,
      );
    default:
      return const SizedBox.shrink();
  }
}

Widget _buildSliverAnimatedListItem(
  Animation<double> _animation, {
  required Widget child,
}) {
  return FadeTransition(
    opacity: _animation.drive(CurveTween(curve: Curves.easeIn)),
    child: SizeTransition(
      sizeFactor: _animation.drive(CurveTween(curve: Curves.easeIn)),
      child: child,
    ),
  );
}

Widget _buildDelSliverAnimatedListItem(
  Animation<double> _animation, {
  required Widget child,
}) {
  return FadeTransition(
    opacity: _animation.drive(
        CurveTween(curve: const Interval(0.0, 1.0, curve: Curves.easeOut))),
    child: SizeTransition(
      sizeFactor: _animation.drive(
          CurveTween(curve: const Interval(0.0, 1.0, curve: Curves.easeOut))),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _animation,
                curve: const Interval(0.4, 1.0, curve: Curves.easeOut))),
        child: child,
      ),
    ),
  );
}

Widget buildGallerySliverListItem(
  GalleryItem _item,
  int index,
  Animation<double> _animation, {
  dynamic tabTag,
  int? oriFirstIndex,
  Key? centerKey,
  ListModeEnum? listMode,
}) {
  return _buildSliverAnimatedListItem(
    _animation,
    child: _listItemWiget(
      _item,
      tabTag: tabTag,
      centerKey: index == oriFirstIndex ? centerKey : null,
      listMode: listMode,
    ),
  );
}

Widget buildDelGallerySliverListItem(
  GalleryItem _item,
  int index,
  Animation<double> _animation, {
  dynamic tabTag,
  ListModeEnum? listMode,
}) {
  return _buildDelSliverAnimatedListItem(
    _animation,
    child: _listItemWiget(_item, tabTag: tabTag, listMode: listMode),
  );
}

Widget buildGallerySliverListView(
  List<GalleryItem> gallerItemBeans,
  dynamic tabTag, {
  int? maxPage,
  int curPage = 0,
  VoidCallback? lastComplete,
  Key? key,
  Key? centerKey,
  int? lastTopitemIndex,
}) {
  return SliverAnimatedList(
    key: key,
    initialItemCount: gallerItemBeans.length,
    itemBuilder:
        (BuildContext context, int index, Animation<double> animation) {
      if (gallerItemBeans.length - 1 < index) {
        return const SizedBox.shrink();
      }

      if (maxPage != null) {
        if (index == gallerItemBeans.length - 1 && curPage < maxPage - 1) {
          // 加载完成最后一项的回调
          lastComplete?.call();
        }
      }

      final GalleryItem _itemInfo = gallerItemBeans[index];
      Get.lazyReplace(() => GalleryItemController(_itemInfo),
          tag: _itemInfo.gid, fenix: true);
      final itemWidget = buildGallerySliverListItem(
        _itemInfo,
        index,
        animation,
        tabTag: tabTag,
        centerKey: centerKey,
        oriFirstIndex: lastTopitemIndex,
        listMode: ListModeEnum.list,
      );

      // if (index < 2) {
      //   return const GalleryItemPlaceHolder();
      // }

      if (tabTag == EHRoutes.history) {
        return itemWidget;
      } else {
        // return itemWidget;
        return FrameSeparateWidget(
          index: index,
          placeHolder: const GalleryItemPlaceHolder(),
          child: itemWidget,
        );
      }
    },
  );
}

Widget buildGallerySliverListSimpleView(
  List<GalleryItem> gallerItemBeans,
  tabTag, {
  int? maxPage,
  required int curPage,
  VoidCallback? lastComplete,
  Key? key,
  Key? centerKey,
  int? lastTopitemIndex,
}) {
  logger.d('buildGallerySliverListSimpleView');

  return SliverAnimatedList(
    key: key,
    initialItemCount: gallerItemBeans.length,
    itemBuilder:
        (BuildContext context, int index, Animation<double> animation) {
      if (gallerItemBeans.length - 1 < index) {
        return const SizedBox.shrink();
      }

      if (maxPage != null) {
        if (index == gallerItemBeans.length - 1 && curPage < maxPage - 1) {
          // 加载完成最后一项的回调
          lastComplete?.call();
        }
      }

      final GalleryItem _item = gallerItemBeans[index];
      // Get.replace(GalleryItemController(_item), tag: _item.gid);
      Get.lazyReplace(() => GalleryItemController(_item),
          tag: _item.gid, fenix: true);
      // if (index < 5) {
      //   return const GalleryItemSimplePlaceHolder();
      // }
      return FrameSeparateWidget(
        placeHolder: const GalleryItemSimplePlaceHolder(),
        child: buildGallerySliverListItem(
          _item,
          index,
          animation,
          tabTag: tabTag,
          centerKey: centerKey,
          oriFirstIndex: lastTopitemIndex,
          listMode: ListModeEnum.simpleList,
        ),
      );
    },
  );
}

Widget getGallerySliverList(
  List<GalleryItem>? gallerItemBeans,
  tabTag, {
  int? maxPage,
  int? curPage,
  VoidCallback? lastComplete,
  Key? key,
  Key? centerKey,
  int? lastTopitemIndex,
  Rx<ListModeEnum>? listMode,
}) {
  final EhConfigService ehConfigService = Get.find();
  final _key = key ?? ValueKey(gallerItemBeans.hashCode);
  // logger.d('_key $_key');

  logger.v('lastTopitemIndex $lastTopitemIndex');

  return Obx(() {
    final mod = listMode?.value != ListModeEnum.global
        ? listMode?.value ?? ehConfigService.listMode.value
        : ehConfigService.listMode.value;
    logger.v('mod $mod');

    switch (mod) {
      case ListModeEnum.list:
        return buildGallerySliverListView(
          gallerItemBeans ?? [],
          tabTag,
          maxPage: maxPage,
          curPage: curPage ?? 0,
          lastComplete: lastComplete,
          key: _key,
          centerKey: centerKey,
          lastTopitemIndex: lastTopitemIndex,
        );
      case ListModeEnum.waterfall:
        return buildWaterfallFlow(
          gallerItemBeans ?? [],
          tabTag,
          maxPage: maxPage,
          curPage: curPage ?? 0,
          lastComplete: lastComplete,
          key: _key,
          centerKey: centerKey,
          lastTopitemIndex: lastTopitemIndex,
        );
      case ListModeEnum.waterfallLarge:
        return buildWaterfallFlow(
          gallerItemBeans ?? [],
          tabTag,
          maxPage: maxPage,
          curPage: curPage ?? 0,
          lastComplete: lastComplete,
          large: true,
          key: _key,
          centerKey: centerKey,
          lastTopitemIndex: lastTopitemIndex,
        );
      case ListModeEnum.simpleList:
        return buildGallerySliverListSimpleView(
          gallerItemBeans ?? [],
          tabTag,
          maxPage: maxPage,
          curPage: curPage ?? 0,
          lastComplete: lastComplete,
          key: _key,
          centerKey: centerKey,
          lastTopitemIndex: lastTopitemIndex,
        );

      case ListModeEnum.grid:
        return buildGrid(
          gallerItemBeans ?? [],
          tabTag,
          maxPage: maxPage,
          curPage: curPage ?? 0,
          lastComplete: lastComplete,
          key: _key,
          centerKey: centerKey,
          lastTopitemIndex: lastTopitemIndex,
        );
      case ListModeEnum.global:
        return const SliverFillRemaining(
          child: SizedBox(),
        );
    }
  });
}

class SearchRepository {
  SearchRepository({this.searchText, this.searchType = SearchType.normal});

  final String? searchText;
  final SearchType searchType;
}

class EndIndicator extends StatelessWidget {
  const EndIndicator({Key? key, required this.pageState, this.loadDataMore})
      : super(key: key);

  final PageState pageState;
  final VoidCallback? loadDataMore;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      // key: centerKey,
      child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                  top: 50, bottom: 50.0 + context.mediaQueryPadding.bottom),
              child: () {
                switch (pageState) {
                  case PageState.None:
                    return Container();
                  case PageState.LoadingMore:
                    return const CupertinoActivityIndicator(
                      radius: 14,
                    );
                  case PageState.LoadingException:
                  case PageState.LoadingError:
                    return GestureDetector(
                      onTap: loadDataMore,
                      child: Column(
                        children: <Widget>[
                          const Icon(
                            Icons.error,
                            size: 40,
                            color: CupertinoColors.systemRed,
                          ),
                          Text(
                            L10n.of(Get.context!).list_load_more_fail,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  default:
                    return Container();
                }
              }())
          .autoCompressKeyboard(context),
    );
  }
}
