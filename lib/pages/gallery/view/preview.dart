import 'package:fehviewer/common/controller/image_hide_controller.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/utils/p_hash/phash_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreviewContainer extends StatelessWidget {
  PreviewContainer({
    Key? key,
    required this.index,
    required List<GalleryImage> galleryImageList,
    required this.gid,
    this.onLoadComplet,
    this.referer,
  })  : galleryImage = galleryImageList[index],
        hrefs = List<String>.from(
            galleryImageList.map((GalleryImage e) => e.href).toList()),
        super(key: key);

  final int index;
  final String gid;
  final List<String> hrefs;
  final GalleryImage galleryImage;
  final VoidCallback? onLoadComplet;
  final String? referer;

  final ImageHideController imageHideController = Get.find();
  final _galleryPageController =
      Get.find<GalleryPageController>(tag: pageCtrlTag);

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
          onHideFlagChanged: (val) {
            if (val) {
              logger.d('hide ser: ${galleryImage.ser} val:$val');
            }
            _galleryPageController.uptImageBySer(
              ser: galleryImage.ser,
              image: galleryImage.copyWith(
                hide: val,
              ),
            );
          },
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
          if (!kReleaseMode)
            pHashHelper.compareLast(galleryImage.thumbUrl ?? '');
          // imageHideController.addCustomImageHide(galleryImage.thumbUrl ?? '');
          showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return CupertinoActionSheet(
                  message: Column(
                    children: [
                      // Text(galleryImage.thumbUrl ?? ''),
                      FutureBuilder<BigInt>(
                          future: imageHideController
                              .calculatePHash(galleryImage.thumbUrl ?? ''),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                !snapshot.hasError &&
                                snapshot.data != null) {
                              return SelectableText(
                                  'hash: ${snapshot.data!.toRadixString(16)}');
                            } else {
                              return const CupertinoActivityIndicator();
                            }
                          }),
                    ],
                  ),
                  title: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: EhNetworkImage(
                            imageUrl: galleryImage.thumbUrl ?? ''),
                      ),
                    ),
                  ),
                  cancelButton: CupertinoActionSheetAction(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(L10n.of(context).cancel)),
                  actions: [
                    CupertinoActionSheetAction(
                      onPressed: () {
                        imageHideController
                            .addCustomImageHide(galleryImage.thumbUrl ?? '');
                        Get.back();
                      },
                      child: Text('Hide'),
                    ),
                  ],
                );
              });
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
