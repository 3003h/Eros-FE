import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
// import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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

              // 计算容器高度
              double? _height = () {
                final _curImage = vState.imageMap[itemSer];
                if (_curImage?.hide ?? false) {
                  return 150.0;
                }

                // 如果存在缓存的图片尺寸信息
                if (vState.imageSizeMap[itemSer] != null) {
                  final imageSize = vState.imageSizeMap[itemSer]!;
                  return imageSize.height * (context.width / imageSize.width);
                }

                // 不存在则根据大图进行计算
                try {
                  return _curImage!.imageHeight! *
                      (context.width / _curImage.imageWidth!);
                } on Exception catch (_) {
                  // 根据缩略图进行计算
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
}
