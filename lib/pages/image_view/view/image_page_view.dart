import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/pages/image_view/view/view_page.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../common.dart';
import '../controller/view_ext_contorller.dart';
import 'view_image.dart';

class ImagePageView extends GetView<ViewExtController> {
  const ImagePageView({Key? key, this.reverse = false}) : super(key: key);
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return ExtendedImageSlidePage(
      child: GetBuilder<ViewExtController>(
        id: idSlidePage,
        builder: (logic) {
          if (logic.vState.columnMode != ViewColumnMode.single) {
            return PhotoViewGallery.builder(
                backgroundDecoration:
                    const BoxDecoration(color: Colors.transparent),
                pageController: logic.pageController,
                itemCount: logic.vState.pageCount,
                onPageChanged: controller.handOnPageChanged,
                scrollDirection: Axis.horizontal,
                customSize: context.mediaQuery.size,
                scrollPhysics: const CustomScrollPhysics(),
                reverse: reverse,
                builder: (BuildContext context, int pageIndex) {
                  /// 双页
                  return PhotoViewGalleryPageOptions.customChild(
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 5,
                    // scaleStateCycle: lisviewScaleStateCycle,
                    controller: logic.photoViewController,
                    // scaleStateController: logic.photoViewScaleStateController,
                    // disableGestures: true,
                    child: DoublePageView(pageIndex: pageIndex),
                  );
                });
          } else {
            return ExtendedImageGesturePageView.builder(
              controller: logic.pageController,
              itemCount: logic.vState.pageCount,
              onPageChanged: controller.handOnPageChanged,
              scrollDirection: Axis.horizontal,
              physics: const CustomScrollPhysics(),
              reverse: reverse,
              itemBuilder: (BuildContext context, int index) {
                logger.v('pageIndex $index ser ${index + 1}');

                /// 单页
                return ViewImage(
                  imageSer: index + 1,
                  initialScale: logic.vState.showPageInterval ? (1 / 1.1) : 1.0,
                );
              },
            );
          }
        },
      ),
      slideAxis: SlideAxis.vertical,
      slideType: SlideType.wholePage,
      resetPageDuration: const Duration(milliseconds: 300),
      slidePageBackgroundHandler: (Offset offset, Size pageSize) {
        double opacity = 0.0;
        opacity = offset.distance /
            (Offset(pageSize.width, pageSize.height).distance / 2.0);
        return CupertinoColors.systemBackground.darkColor
            .withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
      },
      onSlidingPage: (ExtendedImageSlidePageState state) {
        if (controller.vState.showBar) {
          controller.vState.showBar = !state.isSliding;
          controller.update([idViewBar]);
        }
      },
    );
  }
}
