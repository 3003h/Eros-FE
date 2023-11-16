import 'dart:math';

import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:fehviewer/pages/image_view/controller/view_state.dart';
import 'package:fehviewer/pages/image_view/view/view_widget.dart';
import 'package:fehviewer/widget/preload_photo_view_gallery.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePhotoView extends GetView<ViewExtController> {
  const ImagePhotoView({Key? key, this.reverse = false}) : super(key: key);
  final bool reverse;

  ViewExtState get vState => controller.vState;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewExtController>(
      id: idImagePageView,
      builder: (logic) {
        logger.d('build ImagePhotoView...');
        Widget imageView = Container(
          color: Colors.black,
          child: GetBuilder<ViewExtController>(
            assignId: true,
            id: idSlidePage,
            builder: (logic) {
              final int gid = int.tryParse(logic.vState.gid ?? '') ?? 0;
              logger.d('gid $gid');
              final itemSer = logic.vState.currentItemIndex + 1;
              final galleryPageController = vState.galleryPageController;
              final image = galleryPageController?.gState.imageMap[itemSer];
              String key = '$gid/$itemSer/${image?.sourceId ?? ''}';
              logger.d('key $key');
              return PreloadPhotoViewGallery.builder(
                key: ValueKey(key),
                backgroundDecoration:
                    const BoxDecoration(color: Colors.transparent),
                pageController: logic.preloadPageController,
                itemCount: logic.vState.pageCount,
                onPageChanged: controller.handOnPageChanged,
                scrollDirection: Axis.horizontal,
                customSize: context.mediaQuery.size,
                // scrollPhysics: const CustomScrollPhysics(),
                reverse: reverse,
                preloadPagesCount:
                    max(0, logic.vState.ehSettingService.preloadImage.value),
                // preloadPagesCount: 0,
                // gaplessPlayback: true,
                // wantKeepAlive: true,

                builder: (BuildContext context, int pageIndex) {
                  final ser = pageIndex + 1;
                  return PhotoViewGalleryPageOptions(
                    imageProvider:
                        getEhImageProvider('${gid}_${ser}_$key', ser: ser),
                    filterQuality: FilterQuality.medium,
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: 2.0,
                    // controller: logic.photoViewController,
                  );
                },
                loadingBuilder: (context, event) {
                  return const Center(
                    child: ViewLoading(),
                  );

                  // // logger.d('loadingBuilder ${event.runtimeType}');
                  // if (event is ImageChunkEvent) {
                  //   return Center(
                  //     child: ViewLoading(
                  //       ser: event is EhImageChunkEvent ? event.ser! : null,
                  //       progress: event.cumulativeBytesLoaded > 0
                  //           ? (event.cumulativeBytesLoaded) /
                  //               (event.expectedTotalBytes ?? 1)
                  //           : null,
                  //     ),
                  //   );
                  // } else {
                  //   return const Center(
                  //     child: ViewLoading(),
                  //   );
                  // }
                },
              );
            },
          ),
        );

        imageView = GestureDetector(
          onLongPress: () async {
            logger.t('long press');
            vibrateUtil.medium();
            final imageSer = vState.currentItemIndex + 1;
            final GalleryImage? _currentImage =
                vState.pageState?.imageMap[imageSer];
            showImageSheet(
              context,
              () async {
                await controller.reloadImage(imageSer, changeSource: true);
                // controller.photoViewController.reset();
              },
              imageUrl: _currentImage?.imageUrl ?? '',
              filePath: _currentImage?.filePath,
              origImageUrl: _currentImage?.originImageUrl,
              title: '${vState.pageState?.mainTitle} [$imageSer]',
              gid: vState.gid,
              ser: imageSer,
              filename: _currentImage?.filename,
              isLocal: vState.loadFrom == LoadFrom.download ||
                  vState.loadFrom == LoadFrom.archiver,
            );
          },
          child: imageView,
        );

        return imageView;
      },
    );
  }
}
