import 'dart:math';

import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:fehviewer/pages/image_view/view/view_widget.dart';
import 'package:fehviewer/widget/eh_image.dart';
import 'package:fehviewer/widget/preload_photo_view_gallery.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePhotoView extends GetView<ViewExtController> {
  const ImagePhotoView({Key? key, this.reverse = false}) : super(key: key);
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: GetBuilder<ViewExtController>(
        assignId: true,
        id: idSlidePage,
        builder: (logic) {
          final int gid = int.tryParse(logic.vState.gid ?? '') ?? 0;
          return PreloadPhotoViewGallery.builder(
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
                max(0, logic.vState.ehConfigService.preloadImage.value),
            // preloadPagesCount: 0,
            // gaplessPlayback: true,
            // wantKeepAlive: true,

            builder: (BuildContext context, int pageIndex) {
              final EhPageInfo pageInfo =
                  EhPageInfo(gid: gid, ser: pageIndex + 1);
              return PhotoViewGalleryPageOptions(
                imageProvider: EhImageProvider(pageInfo),
                filterQuality: FilterQuality.medium,
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: 2.0,
                // controller: logic.photoViewController,
              );
            },
            loadingBuilder: (context, event) {
              if (event is EhImageChunkEvent && event.ser != null) {
                return Center(
                  child: ViewLoading(
                    ser: event.ser!,
                    progress: event.cumulativeBytesLoaded > 0
                        ? (event.cumulativeBytesLoaded) /
                            (event.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              } else {
                return const Center(
                  child: ViewLoading(),
                );
              }
            },
          );
        },
      ),
    );
  }
}
