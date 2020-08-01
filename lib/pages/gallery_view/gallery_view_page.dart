import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  int _currentIndex = 0;

  GalleryModel _galleryModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final galleryModel = Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != this._galleryModel) {
      this._galleryModel = galleryModel;
      _precache(_galleryModel.previews, widget.index, 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
//      backgroundColor: CupertinoColors.black,
      child: Selector<GalleryModel, List<GalleryPreview>>(
          selector: (context, galleryModel) =>
              galleryModel.galleryItem.galleryPreview,
          shouldRebuild: (pre, next) => true,
          builder: (context, List<GalleryPreview> previews, child) {
//            Global.logger.v('build GalleryViewPageE');
            return Stack(
              children: [
                Container(
                  child: ExtendedImageGesturePageView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      Widget image = GalleryImage(
                        index: index,
                      );
                      if (index == _currentIndex) {
                        return Hero(
                          tag: previews[index].href + index.toString(),
                          child: image,
                        );
                      } else {
                        return image;
                      }
                    },
                    itemCount: previews.length,
                    onPageChanged: (int index) {
                      // 预载
                      _precache(previews, index, 5);
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    controller: widget.controller,
                    scrollDirection: Axis.horizontal,
                  ),
                ),
                Positioned(
                  child: Container(
                      height: 40,
                      child: Text('${_currentIndex + 1}/${previews.length}')),
                ),
              ],
            );
          }),
    );
  }

  _precache(List<GalleryPreview> previews, int index, int max) async {
    final _galleryModel = Provider.of<GalleryModel>(context, listen: false);

    for (int add = 0; add < max; add++) {
      int _index = index + add + 1;

      String _url = '';
      if (_galleryModel.previews[_index].largeImageUrl?.isEmpty ?? true) {
        _url = await Api.getShowInfo(
            previews[_index].href, _galleryModel.showKey,
            index: _index);
        _galleryModel.previews[_index].largeImageUrl = _url;
      }

      _url = _galleryModel.previews[_index].largeImageUrl;

//      Global.logger.v('$_index : $_url');

      precacheImage(
          ExtendedNetworkImageProvider(
            _url,
            cache: true,
          ),
          context);
    }
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

  _getAllImageHref() async {
    if (_galleryModel.isGetAllImageHref) {
      return;
    }
    _galleryModel.isGetAllImageHref = true;
    var _filecount = int.parse(_galleryModel.galleryItem.filecount);

    // 获取画廊所有图片页面的href
    while (_galleryModel.previews.length < _filecount) {
      _galleryModel.currentPreviewPageAdd();

      var _moreGalleryPreviewList = await Api.getGalleryPreview(
        _galleryModel.galleryItem.url,
        page: _galleryModel.currentPreviewPage,
      );

      _galleryModel.addAllPreview(_moreGalleryPreviewList);
    }
    _galleryModel.isGetAllImageHref = false;
  }

  Future<String> _getImageUrl() async {
    // 数据获取处理
    try {
      _getAllImageHref();
    } catch (e) {
      Global.logger.v('$e');
    }

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
        future: _getImageUrl(),
        builder: (context, snapshot) {
          if (_currentPreview.largeImageUrl == null) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
//                throw snapshot.error;
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                _currentPreview.largeImageUrl = snapshot.data;
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
