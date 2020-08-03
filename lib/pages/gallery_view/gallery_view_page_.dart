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

class GalleryViewPageLoad extends StatelessWidget {
  final index;

  const GalleryViewPageLoad({Key key, this.index}) : super(key: key);

  _getAllImageHref(GalleryModel _galleryModel) async {
    if (!_galleryModel.isGetAllImageHref) {
      _galleryModel.isGetAllImageHref = true;
      var _filecount = int.parse(_galleryModel.galleryItem.filecount);

      // 获取画廊所有图片页面的href
      while (_galleryModel.previews.length < _filecount) {
        _galleryModel.currentPreviewPageAdd();

        var _moreGalleryPreviewList = await Api.getGalleryPreview(
          _galleryModel.galleryItem.url,
          page: _galleryModel.currentPreviewPage,
        );

        Global.logger.v('len ${_moreGalleryPreviewList.length}');

        _galleryModel.addAllPreview(_moreGalleryPreviewList);
      }
      _galleryModel.isGetAllImageHref = false;
    }
  }

  Future<String> _getImageUrl(context, int index) async {
    final _galleryModel = Provider.of<GalleryModel>(context, listen: false);

    // 数据获取处理
    try {
      _getAllImageHref(_galleryModel);
    } catch (e) {
      Global.logger.v('$e');
    }

    final _preview = _galleryModel.galleryItem.galleryPreview[index];

    if (_preview.largeImageUrl?.isNotEmpty ?? false) {
      return Future.value(_preview.largeImageUrl);
    } else {
      return Api.getShowInfo(_preview.href, _galleryModel.showKey,
          index: index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _galleryModel = Provider.of<GalleryModel>(context, listen: false);

    return FutureBuilder<String>(
        future: _getImageUrl(context, index),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
              Global.logger.v('active');
              return null;
            case ConnectionState.waiting:
              Global.logger.v('waiting');
              return Container(
                color: CupertinoColors.white,
                child: CupertinoActivityIndicator(),
              );
            case ConnectionState.done:
              Global.logger.v('done');
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                _galleryModel.previews[index].largeImageUrl = snapshot.data;
                return GalleryViewPage(
                  index: index,
                );
                return Container(
                  color: CupertinoColors.white,
                  child: Center(
                    child: Text(snapshot.data),
                  ),
                );
              }
          }
          return null;
        });
  }
}

class GalleryViewPage extends StatefulWidget {
  final int index;
//  String heroTag;
  final PageController controller;

  GalleryViewPage({Key key, int index})
      : this.index = index ?? 0,
        this.controller = PageController(initialPage: index),
        super(key: key);

  @override
  _GalleryViewPageState createState() => _GalleryViewPageState();
}

class _GalleryViewPageState extends State<GalleryViewPage> {
  int _currentIndex;
  GalleryModel _galleryModel;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final galleryModel = Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != this._galleryModel) {
      this._galleryModel = galleryModel;

      // 预载后面5张图
      _precache(_galleryModel.previews, widget.index, 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    Global.logger.v('build GalleryViewPage ');

    return Scaffold(
      body: Container(
//        color: CupertinoColors.black,
        child: PhotoViewGallery.builder(
//          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: _galleryModel.previews.length,
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: ExtendedNetworkImageProvider(
                  _galleryModel.previews[index].largeImageUrl),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained * 0.5,
              maxScale: PhotoViewComputedScale.covered * 1,
            );
            return PhotoViewGalleryPageOptions.customChild(
              child: Container(
//                child: Container(),
//                child: CachedNetworkImage(
//                  imageUrl: _galleryModel.previews[index].largeImageUrl,
//                ),
                child: ExtendedImage.network(
                  _galleryModel.previews[index].largeImageUrl,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.gesture,
                  cache: true,
                ),
              ),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained * 0.5,
              maxScale: PhotoViewComputedScale.covered * 1.1,
            );
          },
          loadingBuilder: (BuildContext context, progress) {
            return progress != null
                ? Container(
                    child: Center(
                      child: Text(
                        '${progress.cumulativeBytesLoaded * 100 ~/ progress.expectedTotalBytes} %',
                        style: TextStyle(
//                          color: Colors.white,
                            ),
                      ),
                    ),
                  )
                : Container(
                    child: Center(
                      child: Text(
                        '获取中 ${_currentIndex + 1}',
                        style: TextStyle(
//                          color: Colors.white,
                            ),
                      ),
                    ),
                  );
          },
          backgroundDecoration: null,
          pageController: widget.controller,
          enableRotation: false, // 旋转
          onPageChanged: (index) {
//            Global.logger.v('onPageChanged');
            _precache(_galleryModel.previews, index, 5);
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  // 一个很傻的预载功能 需要优化
  _precache(List<GalleryPreview> previews, int index, int max) async {
    final _galleryModel = Provider.of<GalleryModel>(context, listen: false);

    for (int add = 0; add < max; add++) {
      int _index = index + add + 1;
      if (_index > _galleryModel.previews.length - 1) {
        return;
      }
      final _preview = _galleryModel.previews[_index];

      String _url = '';
      if (_preview.largeImageUrl?.isEmpty ?? true) {
        _url = await Api.getShowInfo(
            previews[_index].href, _galleryModel.showKey,
            index: _index);
        _galleryModel.previews[_index].largeImageUrl = _url;
      } else {
        _url = _galleryModel.previews[_index].largeImageUrl;
      }

      if (!(_preview?.isCache ?? false)) {
        Global.logger.v('$_index : $_url');
        precacheImage(
                ExtendedNetworkImageProvider(
                  _url,
                  cache: true,
                ),
                context)
            .then((_) => {_galleryModel.previews[_index].isCache = true});
      }
    }
  }
}
