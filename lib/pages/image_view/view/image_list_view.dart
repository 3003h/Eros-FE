import 'package:english_words/english_words.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../controller/view_controller.dart';
import 'view_image.dart';

class ImageListView extends GetView<ViewExtController> {
  const ImageListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageListview = Container(
      height: context.height,
      width: context.width,
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: GetBuilder<ViewExtController>(
        id: idImageListView,
        builder: (logic) {
          final vState = logic.vState;

          return ScrollablePositionedList.builder(
            minCacheExtent: 0.0,
            padding: EdgeInsets.only(
              top: context.mediaQueryPadding.top,
              bottom: context.mediaQueryPadding.bottom,
            ),
            itemScrollController: logic.itemScrollController,
            itemPositionsListener: logic.itemPositionsListener,
            itemCount: vState.filecount,
            itemBuilder: itemBuilder(),
          );
        },
      ),
    );

    Widget imageListview2 = Container(
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: GetBuilder<ViewExtController>(
        id: idImageListView,
        builder: (logic) {
          final vState = logic.vState;

          return ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: vState.filecount,
            itemBuilder: itemBuilder(),
          );
        },
      ),
    );

    Widget imageListview3 = Container(
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: GetBuilder<ViewExtController>(
        id: idImageListView,
        builder: (logic) {
          final vState = logic.vState;

          return ListView.builder(
            controller: controller.autoScrollController,
            padding: const EdgeInsets.all(0),
            itemCount: vState.filecount,
            itemBuilder: itemBuilder2(),
          );
        },
      ),
    );

    final _list = generateWordPairs().take(700).toList();
    Widget wordlist = Container(
      color: Colors.blueGrey,
      child: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (_, index) {
          final w = _list[index];
          return Text('$w', style: const TextStyle(color: Colors.white));
        },
      ),
    );

    Widget wordlist2 = Container(
      color: Colors.blueGrey,
      child: GetBuilder<ViewExtController>(
        id: idImageListView,
        builder: (logic) {
          return ListView.builder(
            itemCount: _list.length,
            itemBuilder: (_, index) {
              final w = _list[index];
              return AutoScrollTag(
                  key: ValueKey(index),
                  controller: logic.autoScrollController,
                  index: index,
                  child:
                      Text('$w', style: const TextStyle(color: Colors.white)));
            },
          );
        },
      ),
    );

    if (false)
      return Zoom(
        maxZoomWidth: context.width * 2,
        maxZoomHeight: context.height * 2,
        enableScroll: false,
        child: Center(child: imageListview),
      );

    if (false)
      return Zoom(
        maxZoomWidth: context.width * 0.5,
        maxZoomHeight: context.height * 0.5,
        enableScroll: false,
        child: wordlist,
      );

    if (false)
      return Container(
        height: context.height,
        width: context.width,
        color: Colors.grey.withAlpha(150),
        child: InteractiveViewer(
          // boundaryMargin: EdgeInsets.all(400),
          minScale: 1.0,
          maxScale: 2.0,
          panEnabled: true,
          scaleEnabled: true,
          // child: Container(
          //   child: Image.asset('assets/40.png'),
          // ),
          child: imageListview3,
        ),
      );

    if (false)
      return PhotoView.customChild(
        initialScale: 1.0,
        customSize: context.mediaQuery.size,
        minScale: PhotoViewComputedScale.contained * 1.0,
        maxScale: 5.0,
        tightMode: true,
        child: imageListview,
      );

    // if (false)
    return PhotoViewGallery.builder(
      itemCount: 1,
      builder: (_, __) {
        return PhotoViewGalleryPageOptions.customChild(
          scaleStateController: controller.photoViewScaleStateController,
          initialScale: 1.0,
          minScale: PhotoViewComputedScale.contained * 1.0,
          maxScale: 5.0,
          // scaleStateCycle: lisviewScaleStateCycle,
          child: imageListview,
        );
      },
    );
  }

  Widget Function(BuildContext context, int index) itemBuilder() {
    return (BuildContext context, int index) {
      final int itemSer = index + 1;

      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: context.width,
        ),
        child: GetBuilder<ViewExtController>(
            id: '$idImageListView$itemSer',
            builder: (logic) {
              loggerSimple.v('builder itemBuilder $itemSer');

              final vState = logic.vState;
              double? _height = () {
                if (vState.imageSizeMap[itemSer] != null) {
                  final imageSize = vState.imageSizeMap[itemSer]!;
                  return imageSize.height * (context.width / imageSize.width);
                }

                try {
                  final _curImage = vState.imageMap[itemSer];
                  return _curImage!.imageHeight! *
                      (context.width / _curImage.imageWidth!);
                } on Exception catch (_) {
                  final _curImage = vState.imageMap[itemSer];
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
                // height: _height ?? context.mediaQueryShortestSide * 4 / 3,
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
                    final _curImage = vState.imageMap[itemSer];
                    return _curImage!.imageHeight! *
                        (context.width / _curImage.imageWidth!);
                  } on Exception catch (_) {
                    final _curImage = vState.imageMap[itemSer];
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
