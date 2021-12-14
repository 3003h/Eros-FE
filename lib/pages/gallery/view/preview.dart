import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keframe/size_cache_widget.dart';

import 'const.dart';

class PreviewGrid extends StatefulWidget {
  const PreviewGrid({Key? key, required this.images, required this.gid})
      : super(key: key);
  final List<GalleryImage> images;
  final String gid;

  @override
  _PreviewGridState createState() => _PreviewGridState();
}

class _PreviewGridState extends State<PreviewGrid> {
  final Map<String, bool> _loadComplets = {};

  @override
  Widget build(BuildContext context) {
    return SizeCacheWidget(
      estimateCount: widget.images.length,
      child: GridView.builder(
          padding: const EdgeInsets.only(top: 0),
          shrinkWrap: true,
          //解决无限高度问题
          physics: const NeverScrollableScrollPhysics(),
          //禁用滑动事件
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: kMaxCrossAxisExtent,
              mainAxisSpacing: kMainAxisSpacing, //主轴方向的间距
              crossAxisSpacing: kCrossAxisSpacing, //交叉轴方向子元素的间距
              childAspectRatio: kChildAspectRatio //显示区域宽高
              ),
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            return Center(
              child: PreviewContainer(
                galleryImageList: widget.images,
                index: index,
                gid: widget.gid,
                onLoadComplet: () {
                  final thumbUrl = widget.images[index].thumbUrl ?? '';
                  Future.delayed(const Duration(milliseconds: 50)).then(
                    (_) {
                      if (!(_loadComplets[thumbUrl] ?? false) && mounted) {
                        logger.v('onLoadComplet $thumbUrl');
                        setState(() {
                          _loadComplets[thumbUrl] = true;
                        });
                      }
                    },
                  );
                },
              ),
            );
          }),
    );
  }
}

class PreviewContainer extends StatelessWidget {
  PreviewContainer({
    Key? key,
    required this.index,
    required this.galleryImageList,
    required this.gid,
    this.onLoadComplet,
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

  @override
  Widget build(BuildContext context) {
    Widget _buildImage() {
      if (galleryImage.largeThumb ?? false) {
        // 缩略大图
        return EhNetworkImage(
          imageUrl: galleryImage.thumbUrl ?? '',
          progressIndicatorBuilder: (_, __, ___) {
            return const CupertinoActivityIndicator();
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
      child: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  // child: Hero(
                  //   tag: '${index + 1}',
                  //   createRectTween: (Rect? begin, Rect? end) {
                  //     final tween =
                  //         MaterialRectCenterArcTween(begin: begin, end: end);
                  //     logger.d('begin $begin\n end $end');
                  //     return tween;
                  //   },
                  //   child: Container(
                  //     child: _buildImage(),
                  //   ),
                  // ),
                  child: Hero(
                    tag: '${index + 1}',
                    createRectTween: (Rect? begin, Rect? end) {
                      final tween =
                          MaterialRectCenterArcTween(begin: begin, end: end);
                      // logger.d('begin $begin\n end $end');
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
