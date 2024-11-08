import 'package:eros_fe/common/controller/image_block_controller.dart';
import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/gallery/controller/gallery_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThumbBox extends StatefulWidget {
  ThumbBox({
    super.key,
    required this.index,
    required List<GalleryImage> galleryImageList,
    required this.gid,
    this.onLoadComplete,
    this.referer,
  })  : galleryImage = galleryImageList[index],
        hrefs = List<String>.from(
            galleryImageList.map((GalleryImage e) => e.href).toList());

  final int index;
  final String gid;
  final List<String> hrefs;
  final GalleryImage galleryImage;
  final VoidCallback? onLoadComplete;
  final String? referer;

  @override
  State<ThumbBox> createState() => _ThumbBoxState();
}

class _ThumbBoxState extends State<ThumbBox> {
  final ImageBlockController imageHideController = Get.find();

  final _galleryPageController =
      Get.find<GalleryPageController>(tag: pageCtrlTag);

  @override
  Widget build(BuildContext context) {
    Widget buildImage() {
      Widget image = EhNetworkImage(
        httpHeaders: {if (widget.referer != null) 'Referer': widget.referer!},
        imageUrl: widget.galleryImage.thumbUrl ?? '',
        progressIndicatorBuilder: (_, __, ___) {
          return const CupertinoActivityIndicator();
        },
        fit: BoxFit.cover,
        checkHide: true,
        onHideFlagChanged: (isHideImage) {
          if (isHideImage) {
            logger.d('hide ser: ${widget.galleryImage.ser} val:$isHideImage');
          }
          _galleryPageController.uptImageBySer(
            ser: widget.galleryImage.ser,
            imageCallback: (image) => image.copyWith(hide: isHideImage.oN),
          );
        },
        sourceRect: widget.galleryImage.offSet != null
            ? Rect.fromLTWH(
                widget.galleryImage.offSet! + 1,
                1.0,
                widget.galleryImage.thumbWidth! - 2,
                widget.galleryImage.thumbHeight! - 2,
              )
            : null,
      );

      return AspectRatio(
          aspectRatio: (widget.galleryImage.thumbWidth ??
                  widget.galleryImage.oriWidth ??
                  300) /
              (widget.galleryImage.thumbHeight ??
                  widget.galleryImage.oriHeight ??
                  400),
          child: image);
    }

    Widget buildImageOld() {
      if (widget.galleryImage.largeThumb ?? false) {
        logger.t('ser: ${widget.galleryImage.ser} largeThumb');
        // 缩略大图
        Widget image = EhNetworkImage(
          httpHeaders: {if (widget.referer != null) 'Referer': widget.referer!},
          imageUrl: widget.galleryImage.thumbUrl ?? '',
          progressIndicatorBuilder: (_, __, ___) {
            return const CupertinoActivityIndicator();
          },
          fit: BoxFit.cover,
          checkHide: true,
          onHideFlagChanged: (isHideImage) {
            if (isHideImage) {
              logger.d('hide ser: ${widget.galleryImage.ser} val:$isHideImage');
            }
            _galleryPageController.uptImageBySer(
              ser: widget.galleryImage.ser,
              imageCallback: (image) => image.copyWith(hide: isHideImage.oN),
            );
          },
        );

        return AspectRatio(
            aspectRatio: (widget.galleryImage.oriWidth ?? 300) /
                (widget.galleryImage.oriHeight ?? 400),
            child: image);
      } else {
        // logger.d('ser: ${widget.galleryImage.ser} smallThumb');
        // 缩略连续图 需要切割
        Widget image = EhNetworkImage(
          httpHeaders: {if (widget.referer != null) 'Referer': widget.referer!},
          imageUrl: widget.galleryImage.thumbUrl ?? '',
          progressIndicatorBuilder: (_, __, ___) {
            return const CupertinoActivityIndicator();
          },
          fit: BoxFit.cover,
          checkHide: true,
          onHideFlagChanged: (isHideImage) {
            if (isHideImage) {
              logger.d('hide ser: ${widget.galleryImage.ser} val:$isHideImage');
            }
            _galleryPageController.uptImageBySer(
              ser: widget.galleryImage.ser,
              imageCallback: (image) => image.copyWith(hide: isHideImage.oN),
            );
          },
          sourceRect: Rect.fromLTWH(
            widget.galleryImage.offSet! + 1,
            1.0,
            widget.galleryImage.thumbWidth! - 2,
            widget.galleryImage.thumbHeight! - 2,
          ),
        );

        return AspectRatio(
            aspectRatio: (widget.galleryImage.thumbWidth ?? 300) /
                (widget.galleryImage.thumbHeight ?? 400),
            child: image);

        return AspectRatio(
          aspectRatio: (widget.galleryImage.thumbWidth ?? 300) /
              (widget.galleryImage.thumbHeight ?? 400),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final imageSize = Size(widget.galleryImage.thumbWidth!,
                  widget.galleryImage.thumbHeight!);
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final FittedSizes fittedSizes =
                  applyBoxFit(BoxFit.contain, imageSize, size);

              return ExtendedImageRect(
                httpHeaders: {
                  if (widget.referer != null) 'Referer': widget.referer!
                },
                url: widget.galleryImage.thumbUrl!,
                height: fittedSizes.destination.height,
                width: fittedSizes.destination.width,
                onLoadComplete: widget.onLoadComplete,
                sourceRect: Rect.fromLTWH(
                  widget.galleryImage.offSet! + 1,
                  1.0,
                  widget.galleryImage.thumbWidth! - 2,
                  widget.galleryImage.thumbHeight! - 2,
                ),
              );
            },
          ),
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
        Rect? sourceRect;
        if (widget.galleryImage.offSet != null) {
          sourceRect = Rect.fromLTWH(
            widget.galleryImage.offSet! + 1,
            1.0,
            widget.galleryImage.thumbWidth! - 2,
            widget.galleryImage.thumbHeight! - 2,
          );
        }
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
                message: Column(
                  children: [
                    // Text(galleryImage.thumbUrl ?? ''),
                    FutureBuilder<BigInt>(
                        future: imageHideController.calculatePHash(
                          widget.galleryImage.thumbUrl ?? '',
                          sourceRect: sourceRect,
                        ),
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
                        imageUrl: widget.galleryImage.thumbUrl ?? '',
                        sourceRect: sourceRect,
                      ),
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
                        widget.galleryImage.thumbUrl ?? '',
                        sourceRect: sourceRect,
                      );
                      setState(() {});
                    },
                    child: Text(L10n.of(context).add_to_phash_block_list),
                  ),
                ],
              );
            });
      },
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
                  child: buildImage(),
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
    );
  }
}
