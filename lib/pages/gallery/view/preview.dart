import 'package:fehviewer/common/controller/image_hide_controller.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreviewContainer extends StatefulWidget {
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

  @override
  State<PreviewContainer> createState() => _PreviewContainerState();
}

class _PreviewContainerState extends State<PreviewContainer> {
  final ImageHideController imageHideController = Get.find();

  final _galleryPageController =
      Get.find<GalleryPageController>(tag: pageCtrlTag);

  @override
  Widget build(BuildContext context) {
    Widget _buildImage() {
      if (widget.galleryImage.largeThumb ?? false) {
        // 缩略大图
        return EhNetworkImage(
          httpHeaders: {if (widget.referer != null) 'Referer': widget.referer!},
          imageUrl: widget.galleryImage.thumbUrl ?? '',
          progressIndicatorBuilder: (_, __, ___) {
            return const CupertinoActivityIndicator();
          },
          checkHide: true,
          onHideFlagChanged: (isHideImage) {
            if (isHideImage) {
              logger.d('hide ser: ${widget.galleryImage.ser} val:$isHideImage');
            }
            _galleryPageController.uptImageBySer(
              ser: widget.galleryImage.ser,
              imageCallback: (image) => image.copyWith(hide: isHideImage),
            );
          },
        );
      } else {
        // 缩略小图 需要切割
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final imageSize = Size(widget.galleryImage.thumbWidth!,
                widget.galleryImage.thumbHeight!);
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final FittedSizes fittedSizes =
                applyBoxFit(BoxFit.contain, imageSize, size);

            return ExtendedImageRect(
              url: widget.galleryImage.thumbUrl!,
              height: fittedSizes.destination.height,
              width: fittedSizes.destination.width,
              onLoadComplet: widget.onLoadComplet,
              sourceRect: Rect.fromLTWH(
                widget.galleryImage.offSet! + 1,
                1.0,
                widget.galleryImage.thumbWidth! - 2,
                widget.galleryImage.thumbHeight! - 2,
              ),
            );
          },
        );
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        NavigatorUtil.goGalleryViewPage(
            widget.galleryImage.ser - 1, widget.gid);
      },
      onLongPress: () {
        if (widget.galleryImage.largeThumb ?? false) {
          // if (!kReleaseMode) {
          //   pHashHelper.compareLast(galleryImage.thumbUrl ?? '');
          // }

          showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return CupertinoActionSheet(
                  message: Column(
                    children: [
                      // Text(galleryImage.thumbUrl ?? ''),
                      FutureBuilder<BigInt>(
                          future: imageHideController.calculatePHash(
                              widget.galleryImage.thumbUrl ?? ''),
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
                            imageUrl: widget.galleryImage.thumbUrl ?? ''),
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
                      onPressed: () async {
                        Get.back();
                        await imageHideController.addCustomImageHide(
                            widget.galleryImage.thumbUrl ?? '');
                        setState(() {});
                      },
                      child: Text(L10n.of(context).hide),
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
                    tag: '${widget.index + 1}',
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
                '${widget.galleryImage.ser}',
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
