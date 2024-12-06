import 'package:eros_fe/common/controller/block_controller.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/item/controller/galleryitem_controller.dart';
import 'package:eros_fe/pages/item/gallery_item.dart';
import 'package:eros_fe/pages/item/gallery_item_debug_simple.dart';
import 'package:eros_fe/pages/item/gallery_item_placeholder.dart';
import 'package:eros_fe/pages/item/gallery_item_simple.dart';
import 'package:eros_fe/pages/item/gallery_item_simple_placeholder.dart';
import 'package:eros_fe/pages/tab/controller/enum.dart';
import 'package:eros_fe/pages/tab/controller/search_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';

import 'grid.dart';
import 'sliver_list.dart';
import 'waterfall_flow.dart';

// debug测试用的简单布局
SliverPadding buildDebugSimple(
  List<GalleryProvider> galleryProviders,
  dynamic tabTag, {
  String? next,
  VoidCallback? lastComplete,
  Key? key,
  Key? centerKey,
  int? lastTopItemIndex,
}) {
  return SliverPadding(
    padding: const EdgeInsets.all(EHConst.gridCrossAxisSpacing),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (galleryProviders.length - 1 < index) {
            return const SizedBox.shrink();
          }

          if (index == galleryProviders.length - 1 &&
              (next?.isNotEmpty ?? false)) {
            // 加载完成最后一项的回调
            lastComplete?.call();
          }

          final GalleryProvider _provider = galleryProviders[index];
          Get.lazyReplace(() => _provider, tag: _provider.gid, fenix: true);
          Get.lazyReplace(
              () => GalleryItemController(
                  galleryProvider: Get.find(tag: _provider.gid)),
              tag: _provider.gid,
              fenix: true);

          return GalleryItemDebugSimple(
            key:
                index == lastTopItemIndex ? centerKey : ValueKey(_provider.gid),
            galleryProvider: _provider,
            tabTag: tabTag,
          );

          // return FrameSeparateWidget(
          //   index: index,
          //   placeHolder: Container(
          //     width: 60,
          //   ),
          //   child: GalleryItemDebugSimple(
          //     key: index == lastTopitemIndex
          //         ? centerKey
          //         : ValueKey(_provider.gid),
          //     galleryProvider: _provider,
          //     tabTag: tabTag,
          //   ),
          // );
        },
        childCount: galleryProviders.length,
      ),
    ),
  );
}

Widget _listItemWidget(
  GalleryProvider _provider, {
  dynamic tabTag,
  Key? centerKey,
  ListModeEnum? listMode,
}) {
  switch (listMode) {
    case ListModeEnum.list:
      return GalleryItemWidget(
        key: centerKey ??
            ValueKey('${_provider.gid}_${_provider.ratingFallBack}'),
        galleryProvider: _provider,
        tabTag: tabTag,
      );
    case ListModeEnum.simpleList:
      return GalleryItemSimpleWidget(
        key: centerKey ?? ValueKey(_provider.gid),
        galleryProvider: _provider,
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
  GalleryProvider _item,
  int index,
  Animation<double> _animation, {
  dynamic tabTag,
  int? oriFirstIndex,
  Key? centerKey,
  ListModeEnum? listMode,
}) {
  return _buildSliverAnimatedListItem(
    _animation,
    child: _listItemWidget(
      _item,
      tabTag: tabTag,
      centerKey: index == oriFirstIndex ? centerKey : null,
      listMode: listMode,
    ),
  );
}

Widget buildDelGallerySliverListItem(
  GalleryProvider _item,
  int index,
  Animation<double> _animation, {
  dynamic tabTag,
  ListModeEnum? listMode,
}) {
  return _buildDelSliverAnimatedListItem(
    _animation,
    child: _listItemWidget(_item, tabTag: tabTag, listMode: listMode),
  );
}

Widget buildAnimatedGallerySliverListView(
  List<GalleryProvider> galleryProviders,
  dynamic tabTag, {
  String? next,
  VoidCallback? lastComplete,
  Key? key,
  Key? centerKey,
  int? lastTopitemIndex,
}) {
  logger.t('buildAnimatedGallerySliverListView');
  return SliverAnimatedList(
    key: key,
    initialItemCount: galleryProviders.length,
    itemBuilder:
        (BuildContext context, int index, Animation<double> animation) {
      if (galleryProviders.length - 1 < index) {
        return const SizedBox.shrink();
      }

      if (index == galleryProviders.length - 1 && (next?.isNotEmpty ?? false)) {
        // 加载完成最后一项的回调
        lastComplete?.call();
      }

      final GalleryProvider _itemInfo = galleryProviders[index];
      Get.lazyReplace(() => _itemInfo, tag: _itemInfo.gid, fenix: true);
      Get.lazyReplace(
        () => GalleryItemController(
            galleryProvider: Get.find(tag: _itemInfo.gid)),
        tag: _itemInfo.gid,
        fenix: true,
      );

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

Widget buildAnimatedGallerySliverListSimpleView(
  List<GalleryProvider> galleryProviders,
  tabTag, {
  String? next,
  VoidCallback? lastComplete,
  Key? key,
  Key? centerKey,
  int? lastTopitemIndex,
}) {
  logger.t('buildGallerySliverListSimpleView');

  return SliverAnimatedList(
    key: key,
    initialItemCount: galleryProviders.length,
    itemBuilder:
        (BuildContext context, int index, Animation<double> animation) {
      if (galleryProviders.length - 1 < index) {
        return const SizedBox.shrink();
      }

      if (index == galleryProviders.length - 1 && (next?.isNotEmpty ?? false)) {
        // 加载完成最后一项的回调
        lastComplete?.call();
      }

      final GalleryProvider _provider = galleryProviders[index];
      Get.lazyReplace(() => _provider, tag: _provider.gid, fenix: true);
      Get.lazyReplace(
          () => GalleryItemController(
              galleryProvider: Get.find(tag: _provider.gid)),
          tag: _provider.gid,
          fenix: true);
      return FrameSeparateWidget(
        placeHolder: const GalleryItemSimplePlaceHolder(),
        child: buildGallerySliverListItem(
          _provider,
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

Widget buildGallerySliverListSimpleView(
  List<GalleryProvider> galleryProviders,
  dynamic tabTag, {
  String? next,
  VoidCallback? lastComplete,
  Key? key,
  Key? centerKey,
  int? lastTopItemIndex,
  bool keepPosition = false,
}) {
  logger.t('buildGallerySliverListSimpleView');

  return FlutterSliverList(
    delegate: FlutterListViewDelegate(
      (context, index) {
        if (galleryProviders.length - 1 < index) {
          return const SizedBox.shrink();
        }

        if (index == galleryProviders.length - 1 &&
            (next?.isNotEmpty ?? false)) {
          // 加载完成最后一项的回调
          SchedulerBinding.instance
              .addPostFrameCallback((_) => lastComplete?.call());
        }

        final GalleryProvider _provider = galleryProviders[index];
        Get.lazyReplace(() => _provider, tag: _provider.gid, fenix: true);
        Get.lazyReplace(
          () => GalleryItemController(
              galleryProvider: Get.find(tag: _provider.gid)),
          tag: _provider.gid,
          fenix: true,
        );

        return FrameSeparateWidget(
          index: index,
          placeHolder: const GalleryItemSimplePlaceHolder(),
          child: GalleryItemSimpleWidget(
            galleryProvider: _provider,
            tabTag: tabTag,
          ),
        );
      },
      onItemKey: (index) => galleryProviders[index].gid ?? '',
      childCount: galleryProviders.length,
      keepPosition: keepPosition,
    ),
  );
}

Widget getGallerySliverList(
  List<GalleryProvider>? galleryProviders,
  tabTag, {
  String? next,
  VoidCallback? lastComplete,
  Key? key,
  Key? centerKey,
  int? lastTopItemIndex,
  Rx<ListModeEnum>? listMode,
  bool keepPosition = false,
}) {
  final EhSettingService ehSettingService = Get.find();
  final _key = key ?? ValueKey(galleryProviders.hashCode);

  final BlockController blockController = Get.find();

  galleryProviders = galleryProviders?.where((GalleryProvider element) {
    return !blockController.matchRule(
          blockType: BlockType.title,
          text: element.englishTitle,
        ) &&
        !blockController.matchRule(
          blockType: BlockType.title,
          text: element.japaneseTitle,
        ) &&
        !blockController.matchRule(
          blockType: BlockType.uploader,
          text: element.uploader,
        );
  }).toList();

  // logger.d('next $next');

  return Obx(() {
    final mod = listMode?.value != ListModeEnum.global
        ? listMode?.value ?? ehSettingService.listMode.value
        : ehSettingService.listMode.value;
    logger.t('mod $mod');

    switch (mod) {
      case ListModeEnum.list:
        return EhSliverList(
          galleryProviders ?? [],
          tabTag,
          next: next,
          lastComplete: lastComplete,
          centerKey: centerKey,
          lastTopItemIndex: lastTopItemIndex,
          keepPosition: keepPosition,
        );
      case ListModeEnum.waterfall:
        return EhWaterfallFlow(
          galleryProviders ?? [],
          tabTag,
          next: next,
          lastComplete: lastComplete,
          centerKey: centerKey,
          lastTopItemIndex: lastTopItemIndex,
        );
      case ListModeEnum.waterfallLarge:
        return EhWaterfallFlow(
          galleryProviders ?? [],
          tabTag,
          next: next,
          lastComplete: lastComplete,
          large: true,
          centerKey: centerKey,
          lastTopItemIndex: lastTopItemIndex,
        );
      case ListModeEnum.simpleList:
        return buildGallerySliverListSimpleView(
          galleryProviders ?? [],
          tabTag,
          next: next,
          lastComplete: lastComplete,
          centerKey: centerKey,
          lastTopItemIndex: lastTopItemIndex,
          keepPosition: keepPosition,
        );
      case ListModeEnum.grid:
        return EhGridView(
          galleryProviders ?? [],
          tabTag,
          next: next,
          lastComplete: lastComplete,
          centerKey: centerKey,
          lastTopItemIndex: lastTopItemIndex,
        );
      case ListModeEnum.debugSimple:
        return buildDebugSimple(
          galleryProviders ?? [],
          tabTag,
          next: next,
          lastComplete: lastComplete,
          centerKey: centerKey,
          lastTopItemIndex: lastTopItemIndex,
        );
      case ListModeEnum.global:
        return const SliverFillRemaining(
          child: SizedBox(),
        );
    }
  });
}

class SearchRepository {
  SearchRepository({
    this.searchText,
    this.searchType = SearchType.normal,
    this.advanceSearch,
  });

  final String? searchText;
  final SearchType searchType;
  final AdvanceSearch? advanceSearch;
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
                  top: 50, bottom: 100.0 + context.mediaQueryPadding.bottom),
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
