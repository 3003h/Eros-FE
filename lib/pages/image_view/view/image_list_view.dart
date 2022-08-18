import 'package:english_words/english_words.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../controller/view_controller.dart';
import 'eh_flutter_list_view_delegate.dart';
import 'view_image.dart';

class ImageListView extends StatefulWidget {
  const ImageListView({Key? key}) : super(key: key);

  @override
  State<ImageListView> createState() => _ImageListViewState();
}

class _ImageListViewState extends State<ImageListView> {
  final ViewExtController controller = Get.find();

  late Offset downPosition;

  @override
  Widget build(BuildContext context) {
    final vState = controller.vState;

    final words = generateWordPairs().take(500).toList();

    Widget listView = ScrollablePositionedList.builder(
      minCacheExtent: 0.0,
      padding: EdgeInsets.only(
        top: context.mediaQueryPadding.top,
        bottom: context.mediaQueryPadding.bottom,
      ),
      itemScrollController: controller.itemScrollController,
      itemPositionsListener: controller.itemPositionsListener,
      itemCount: vState.filecount,
      itemBuilder: itemBuilder(),
    );

    Widget listView2 = ListView.separated(
      itemBuilder: itemBuilder(),
      separatorBuilder: (context, index) {
        return const Divider();
      },
      itemCount: vState.filecount,
    );

    Widget listView3 = FlutterListView(
      // physics: const BouncingScrollPhysics(),
      // cacheExtent: context.height + 1,
      // controller: controller.flutterListViewController,
      semanticChildCount: vState.filecount,
      delegate: EhFlutterListViewDelegate(
        itemBuilder(),
        childCount: vState.filecount,
      ),
    );

    Widget imageListview = Container(
      // height: context.height,
      // width: context.width,
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: listView,
    );

    // return InteractiveViewer(
    //   child: imageListview,
    // );
    //
    // return imageListview;

    return PhotoViewGallery.builder(
      itemCount: 1,
      builder: (_, __) {
        return PhotoViewGalleryPageOptions.customChild(
          scaleStateController: controller.photoViewScaleStateController,
          initialScale: PhotoViewComputedScale.contained * 1.0,
          minScale: PhotoViewComputedScale.contained * 1.0,
          maxScale: PhotoViewComputedScale.contained * 3.0,
          scaleStateCycle: lisviewScaleStateCycle,
          // child: Center(
          //   child: Container(
          //     width: 100,
          //     height: 100,
          //     color: Colors.amber,
          //     alignment: Alignment.center,
          //     child: Text('AAAAA'),
          //   ),
          // ),
          child: imageListview,
          // onTapDown: (context, details, controllerValue) {
          //   logger.d('${controllerValue.scale}');
          // },
        );
      },
    );
  }

  PhotoViewScaleState lisviewScaleStateCycle(PhotoViewScaleState actual) {
    logger.d('actual $actual');
    switch (actual) {
      case PhotoViewScaleState.initial:
        return PhotoViewScaleState.originalSize;
      default:
        return PhotoViewScaleState.initial;
    }
  }

  Widget Function(BuildContext context, int index) itemBuilder() {
    return (BuildContext context, int index) {
      final int itemSer = index + 1;

      // return Padding(
      //   padding: const EdgeInsets.symmetric(vertical: 100),
      //   child: Text(
      //     '$itemSer',
      //     style: TextStyle(color: Colors.white),
      //   ),
      // );

      return ConstrainedBox(
        key: ValueKey(itemSer),
        constraints: BoxConstraints(
          minWidth: context.width,
        ),
        child: GetBuilder<ViewExtController>(
            id: '$idImageListView$itemSer',
            builder: (logic) {
              loggerSimple.v('builder itemBuilder $itemSer');

              final vState = logic.vState;

              // 计算容器高度
              double? _height = () {
                // 从已下载进入阅读的情况 imageMap 会未初始化
                try {
                  if (vState.imageMap?[itemSer]?.hide ?? false) {
                    return 150.0;
                  }
                } catch (_) {}

                // 如果存在缓存的图片尺寸信息
                if (vState.imageSizeMap[itemSer] != null) {
                  final imageSize = vState.imageSizeMap[itemSer]!;
                  return imageSize.height * (context.width / imageSize.width);
                }

                // 不存在则根据大图进行计算
                try {
                  final _curImage = vState.imageMap?[itemSer];
                  return _curImage!.imageHeight! *
                      (context.width / _curImage.imageWidth!);
                } on Exception catch (_) {
                  // 根据缩略图进行计算
                  final _curImage = vState.imageMap?[itemSer];
                  return _curImage!.thumbHeight! *
                      (context.width / _curImage.thumbWidth!);
                } catch (e) {
                  return null;
                }
              }();

              if (_height != null) {
                _height += vState.showPageInterval ? 8 : 0;
              }

              loggerSimple.v('builder itemBuilder $itemSer $_height');

              return AnimatedContainer(
                padding:
                    EdgeInsets.only(bottom: vState.showPageInterval ? 8 : 0),
                height: _height ?? context.mediaQueryShortestSide,
                duration: const Duration(milliseconds: 200),
                curve: Curves.ease,
                child: ViewImage(
                  imageSer: itemSer,
                  enableDoubleTap: false,
                  mode: ExtendedImageMode.none,
                ),
              );
            }),
      );
    };
  }

  Widget Function(BuildContext context, int index) itemBuilder2() {
    return (BuildContext context, int index) {
      final int itemSer = index + 1;

      return AutoScrollTag(
        key: ValueKey(index),
        controller: controller.autoScrollController,
        index: index,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: context.width,
          ),
          child: GetBuilder<ViewExtController>(
              id: '$idImageListView$itemSer',
              builder: (logic) {
                final vState = logic.vState;
                double? _height = () {
                  try {
                    final _curImage = vState.imageMap?[itemSer];
                    return _curImage!.imageHeight! *
                        (context.width / _curImage.imageWidth!);
                  } on Exception catch (_) {
                    final _curImage = vState.imageMap?[itemSer];
                    return _curImage!.thumbHeight! *
                        (context.width / _curImage.thumbWidth!);
                  } catch (e) {
                    return null;
                  }
                }();

                if (_height != null) {
                  _height += vState.showPageInterval ? 8 : 0;
                }

                return Container(
                  padding:
                      EdgeInsets.only(bottom: vState.showPageInterval ? 8 : 0),
                  height: _height,
                  child: ViewImage(
                    imageSer: itemSer,
                    enableDoubleTap: false,
                    mode: ExtendedImageMode.none,
                  ),
                );
              }),
        ),
      );
    };
  }
}
