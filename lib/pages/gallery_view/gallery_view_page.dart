import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryViewPage extends StatefulWidget {
  final List images;
  final int index;
//  String heroTag;
  final PageController controller;

  GalleryViewPage({Key key, int index, List images})
      : this.images = images ?? [],
        this.index = index ?? 0,
        this.controller = PageController(initialPage: index),
        super(key: key);

  @override
  _GalleryViewPageState createState() => _GalleryViewPageState();
}

class _GalleryViewPageState extends State<GalleryViewPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: CupertinoColors.black,
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: widget.images.length,
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(widget.images[index]),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained * 0.5,
              maxScale: PhotoViewComputedScale.covered * 1.1,
              heroAttributes:
                  PhotoViewHeroAttributes(tag: widget.images[index]),
            );
          },
          loadingBuilder: (BuildContext context, progress) {
            return progress != null
                ? Container(
                    child: Center(
                      child: Text(
                        '${progress.cumulativeBytesLoaded * 100 ~/ progress.expectedTotalBytes} %',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : Container(
                    child: Center(
                      child: Text(
                        '获取中',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
          },
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
