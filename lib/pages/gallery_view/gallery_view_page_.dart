import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class GalleryViewPage extends StatefulWidget {
  final List hrefs;
  final int index;
//  String heroTag;
  final showKey;
  final PageController controller;

  GalleryViewPage({Key key, int index, List hrefs, this.showKey})
      : this.hrefs = hrefs ?? [],
        this.index = index ?? 0,
        this.controller = PageController(initialPage: index),
        super(key: key);

  @override
  _GalleryViewPageState createState() => _GalleryViewPageState();
}

class _GalleryViewPageState extends State<GalleryViewPage> {
  int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    Global.logger.v('build GalleryViewPage ');

    return Scaffold(
      body: Container(
//        color: CupertinoColors.black,
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: widget.hrefs.length,
          builder: (BuildContext context, int index) {
//            return PhotoViewGalleryPageOptions(
//              imageProvider: CachedNetworkImageProvider(widget.images[index]),
//              initialScale: PhotoViewComputedScale.contained,
//              minScale: PhotoViewComputedScale.contained * 0.5,
//              maxScale: PhotoViewComputedScale.covered * 1.1,
//              heroAttributes:
//                  PhotoViewHeroAttributes(tag: widget.images[index]),
//            );
            return PhotoViewGalleryPageOptions.customChild(
              child: Container(
                child: Container(),
//                child: CachedNetworkImage(
//                  imageUrl: widget.hrefs[index],
//              ),
//                child: ExtendedImage.network(
//                  widget.images[index],
//                  fit: BoxFit.contain,
//                  mode: ExtendedImageMode.gesture,
//                  cache: true,
//                ),
              ),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained * 0.5,
              maxScale: PhotoViewComputedScale.covered * 1.1,
            );
          },
//          loadingBuilder: (BuildContext context, progress) {
//            return progress != null
//                ? Container(
//                    child: Center(
//                      child: Text(
//                        '${progress.cumulativeBytesLoaded * 100 ~/ progress.expectedTotalBytes} %',
//                        style: TextStyle(
////                          color: Colors.white,
//                            ),
//                      ),
//                    ),
//                  )
//                : Container(
//                    child: Center(
//                      child: Text(
//                        '获取中',
//                        style: TextStyle(
////                          color: Colors.white,
//                            ),
//                      ),
//                    ),
//                  );
//          },
          backgroundDecoration: null,
          pageController: widget.controller,
          enableRotation: false, // 旋转
          onPageChanged: (index) {
//            Global.logger.v('onPageChanged');
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
