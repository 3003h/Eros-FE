import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/controller/image_hide_controller.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/utils/p_hash/phash_base.dart';
import 'package:fehviewer/utils/p_hash/phash_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_compare/image_compare.dart';

class PreviewContainer extends StatelessWidget {
  PreviewContainer({
    Key? key,
    required this.index,
    required this.galleryImageList,
    required this.gid,
    this.onLoadComplet,
    this.referer,
  })  : galleryImage = galleryImageList[index],
        hrefs = List<String>.from(
            galleryImageList.map((GalleryImage e) => e.href).toList()),
        super(key: key);

  final int index;
  final String gid;
  final List<GalleryImage> galleryImageList;
  final List<String> hrefs;
  final GalleryImage galleryImage;
  final VoidCallback? onLoadComplet;
  final String? referer;

  final ImageHideController imageHideController = Get.find();

  @override
  Widget build(BuildContext context) {
    Widget _buildImage() {
      if (galleryImage.largeThumb ?? false) {
        // 缩略大图
        return EhNetworkImage(
          httpHeaders: {if (referer != null) 'Referer': referer!},
          imageUrl: galleryImage.thumbUrl ?? '',
          progressIndicatorBuilder: (_, __, ___) {
            return const CupertinoActivityIndicator();
          },
          checkHide: true,
        );
      } else {
        // 缩略小图 需要切割
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final imageSize =
                Size(galleryImage.thumbWidth!, galleryImage.thumbHeight!);
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final FittedSizes fittedSizes =
                applyBoxFit(BoxFit.contain, imageSize, size);

            return ExtendedImageRect(
              url: galleryImage.thumbUrl!,
              height: fittedSizes.destination.height,
              width: fittedSizes.destination.width,
              onLoadComplet: onLoadComplet,
              sourceRect: Rect.fromLTWH(
                galleryImage.offSet! + 1,
                1.0,
                galleryImage.thumbWidth! - 2,
                galleryImage.thumbHeight! - 2,
              ),
            );
          },
        );
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        NavigatorUtil.goGalleryViewPage(index, gid);
      },
      onLongPress: () {
        if (galleryImage.largeThumb ?? false) {
          pHashHelper.compareLast(galleryImage.thumbUrl ?? '');
          imageHideController.addCustomImageHide(galleryImage.thumbUrl ?? '');
        }
      },
      child: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Hero(
                    tag: '${index + 1}',
                    createRectTween: (Rect? begin, Rect? end) {
                      final tween =
                          MaterialRectCenterArcTween(begin: begin, end: end);
                      return tween;
                    },
                    child: _buildImage(),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${galleryImage.ser}',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey, context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
