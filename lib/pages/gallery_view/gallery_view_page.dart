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
                child: GalleryImage(
//                  href: widget.hrefs[index],
//                  showKey: widget.showKey,
                  index: widget.index,
                ),
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

class GalleryViewPageE extends StatefulWidget {
  final int index;
  final PageController controller;

  GalleryViewPageE({Key key, int index})
      : this.index = index ?? 0,
        this.controller = PageController(initialPage: index),
        super(key: key);

  @override
  _GalleryViewPageEState createState() => _GalleryViewPageEState();
}

class _GalleryViewPageEState extends State<GalleryViewPageE> {
  int currentIndex;
  Map urlMap = {};

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
//      backgroundColor: CupertinoColors.black,
      child: Selector<GalleryModel, List<GalleryPreview>>(
          selector: (context, galleryModel) =>
              galleryModel.galleryItem.galleryPreview,
          shouldRebuild: (pre, next) => false,
          builder: (context, List<GalleryPreview> listPreview, child) {
            return Container(
              child: ExtendedImageGesturePageView.builder(
                itemBuilder: (BuildContext context, int index) {
                  Widget image = GalleryImage(
                    index: index,
                  );
                  if (index == currentIndex) {
                    return Hero(
                      tag: listPreview[index].href + index.toString(),
                      child: image,
                    );
                  } else {
                    return image;
                  }
                },
                itemCount: listPreview.length,
                onPageChanged: (int index) {
                  currentIndex = index;
                },
                controller: widget.controller,
                scrollDirection: Axis.horizontal,
              ),
            );
          }),
    );
  }
}

class GalleryImage extends StatefulWidget {
  GalleryImage({
    Key key,
    @required this.index,
  }) : super(key: key);

  @override
  _GalleryImageState createState() => _GalleryImageState();
  final index;
}

class _GalleryImageState extends State<GalleryImage> {
  GalleryModel _galleryModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final galleryModel = Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != this._galleryModel) {
      this._galleryModel = galleryModel;
    }
  }

  Future<String> getImageUrl() async {
    return Api.getShowInfo(
        _galleryModel.galleryItem.galleryPreview[widget.index].href,
        _galleryModel.showKey,
        index: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    var _currentPreview =
        _galleryModel.galleryItem.galleryPreview[widget.index];
    return FutureBuilder<String>(
        future: getImageUrl(),
        builder: (context, snapshot) {
          if (_currentPreview.largeImageUrl == null) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                _currentPreview.largeImageUrl = snapshot.data;
//                Global.logger.v(widget.urlMap);
                return ExtendedImage.network(
                  snapshot.data,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.gesture,
                  cache: true,
                );
              }
            } else {
              return Center(
//                child: CircularProgressIndicator(),
                child: Container(
                  height: 100,
                  child: Column(
                    children: [
                      Text(
                        '${widget.index + 1}',
                        style: TextStyle(fontSize: 50),
                      ),
                      Text('获取中...'),
                    ],
                  ),
                ),
              );
            }
          } else {
            var url = _currentPreview.largeImageUrl;
            return ExtendedImage.network(
              url,
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
              cache: true,
            );
          }
        });
  }
}
