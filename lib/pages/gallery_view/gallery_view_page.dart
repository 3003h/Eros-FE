import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

import 'gallery_view_base.dart';

class GalleryViewPageE extends StatefulWidget {
  GalleryViewPageE({Key key, int index})
      : index = index ?? 0,
        controller = PageController(initialPage: index, viewportFraction: 1.1),
        super(key: key);

  final int index;
  final PageController controller;

  @override
  _GalleryViewPageEState createState() => _GalleryViewPageEState();
}

class _GalleryViewPageEState extends State<GalleryViewPageE> {
  int _currentIndex;
  GalleryModel _galleryModel;
  double _currPageValue;

  @override
  void initState() {
    super.initState();
    // widget.controller.addListener(() {
    //   setState(() {
    //     _currPageValue = widget.controller.page;
    //     Global.logger.v('$_currPageValue');
    //   });
    // });
    _currentIndex = 0;
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;
      // 预载后面5张图
      Global.logger.v('预载后面5张图 didChangeDependencies');
      GalleryPrecache.instance.precache(
        context,
        _galleryModel,
        previews: _galleryModel.previews,
        index: widget.index,
        max: 5,
      );
    }
    _currentIndex = widget.index;
  }

  /// 画廊图片大图浏览
  @override
  Widget build(BuildContext context) {
    // Global.logger.v('bbb');
    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.dark,
        // barBackgroundColor: CupertinoColors.white,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: CupertinoPageScaffold(
          // backgroundColor: CupertinoColors.black,
          child: Selector<GalleryModel, int>(
              selector: (context, galleryModel) => galleryModel.previews.length,
              shouldRebuild: (pre, next) {
                // Global.logger.v('${pre}  ${next}');
                return pre != next && next > pre;
              },
              builder: (context, int len, child) {
                final List<GalleryPreview> previews = _galleryModel.previews;
                return Stack(
                  children: <Widget>[
                    Container(
                      child: _buildPhotoViewGallery(),
                    ),
                    SafeArea(
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            child: Container(
                                child: Text(
                              '${_currentIndex + 1}/${_galleryModel.galleryItem.filecount}',
                              style: const TextStyle(
                                  color: CupertinoColors.systemGrey6),
                            )),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: GestureDetector(
                              // 不可见区域点击有效
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Global.logger.v('back');
                                NavigatorUtil.goBack(context);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  FontAwesomeIcons.chevronLeft,
                                  color: CupertinoColors.systemGrey6,
                                  // size: 24,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              // 不可见区域点击有效
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Global.logger.v('tap share');
                                _showShareDialog(context,
                                    previews[_currentIndex].largeImageUrl);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  FontAwesomeIcons.share,
                                  color: CupertinoColors.systemGrey6,
                                  // size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget _buildExtendedImageGesturePageView() {
    final List<GalleryPreview> previews = _galleryModel.previews;
    return ExtendedImageGesturePageView.builder(
      itemBuilder: (BuildContext context, int index) {
        final Widget image = GalleryImage(index: index);
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
        GalleryPrecache.instance.precache(
          context,
          _galleryModel,
          previews: _galleryModel.previews,
          index: index,
          max: 5,
        );
        setState(() {
          _currentIndex = index;
        });
      },
      controller: widget.controller,
      scrollDirection: Axis.horizontal,
    );
  }

  Widget _buildPhotoViewGallery() {
    return PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      itemCount: _galleryModel.previews.length,
      customSize: MediaQuery.of(context).size,
      backgroundDecoration: const BoxDecoration(
        color: null,
      ),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions.customChild(
          child: Container(
            child: GalleryImage(index: index),
          ),
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      },
      loadingBuilder: (BuildContext context, progress) {
        return progress != null
            ? Container(
                child: Center(
                  child: Text(
                    '${progress.cumulativeBytesLoaded * 100 ~/ progress.expectedTotalBytes} %',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : Container(
                child: Center(
                  child: Text(
                    '获取中 ${_currentIndex + 1}',
                    style: const TextStyle(
//                          color: Colors.white,
                        ),
                  ),
                ),
              );
      },
      // backgroundDecoration: null,
      pageController: widget.controller,
      enableRotation: false,
      // 旋转
      onPageChanged: (int index) {
//            Global.logger.v('onPageChanged');
        GalleryPrecache.instance.precache(
          context,
          _galleryModel,
          previews: _galleryModel.previews,
          index: index,
          max: 5,
        );
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}

Future<void> _showShareDialog(BuildContext context, String imageUrl) {
  return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final CupertinoActionSheet dialog = CupertinoActionSheet(
          // title: const Text('分享方式'),
          cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消')),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  Global.logger.v('保存到相册');
                  Api.saveImage(context, imageUrl).then((rult) {
                    Navigator.pop(context);
                    if (rult != null && rult) {
                      showToast('保存成功');
                    }
                  }).catchError((e) {
                    showToast(e);
                  });
                },
                child: const Text('保存到相册')),
            CupertinoActionSheetAction(
                onPressed: () {
                  Global.logger.v('系统分享');
                  Api.shareImage(imageUrl);
                },
                child: const Text('系统分享')),
          ],
        );
        return dialog;
      });
}

class GalleryImage extends StatefulWidget {
  const GalleryImage({
    Key key,
    @required this.index,
  }) : super(key: key);

  @override
  _GalleryImageState createState() => _GalleryImageState();
  final index;
}

class _GalleryImageState extends State<GalleryImage> {
  GalleryModel _galleryModel;
  Future<String> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;
      _future = _getImageUrl();
    }
  }

  Future<void> _getAllImageHref() async {
    if (_galleryModel.isGetAllImageHref) {
      return;
    }
    _galleryModel.isGetAllImageHref = true;
    final int _filecount = int.parse(_galleryModel.galleryItem.filecount);

    // 获取画廊所有图片页面的href
    while (_galleryModel.previews.length < _filecount) {
      _galleryModel.currentPreviewPageAdd();

      final List<GalleryPreview> _moreGalleryPreviewList =
          await Api.getGalleryPreview(
        _galleryModel.galleryItem.url,
        page: _galleryModel.currentPreviewPage,
      );

      // 避免重复添加
      if (_moreGalleryPreviewList.first.ser > _galleryModel.previews.last.ser) {
        _galleryModel.addAllPreview(_moreGalleryPreviewList);
      }
    }
    _galleryModel.isGetAllImageHref = false;
  }

  Future<String> _getImageUrl() {
    // 数据获取处理
    _getAllImageHref().catchError((e) {
      Global.logger.v('$e');
    });

    final String _largeImageUrl =
        _galleryModel.galleryItem.galleryPreview[widget.index].largeImageUrl;
    if (_largeImageUrl != null && _largeImageUrl.isNotEmpty) {
      return Future<String>.value(_largeImageUrl);
    } else {
      return GalleryPrecache.instance.getImageLageUrl(
          _galleryModel.galleryItem.galleryPreview[widget.index].href,
          _galleryModel.showKey,
          index: widget.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final GalleryPreview _currentPreview =
        _galleryModel.galleryItem.galleryPreview[widget.index];
    return FutureBuilder<String>(
        future: _future,
        builder: (_, AsyncSnapshot<String> snapshot) {
          if (_currentPreview.largeImageUrl == null) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
//                throw snapshot.error;
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                _currentPreview.largeImageUrl = snapshot.data;
                // Global.logger.v('${snapshot.data}');
                return ExtendedImage.network(
                  snapshot.data,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.gesture,
                  cache: true,
                );
              }
            } else {
              return Center(
                child: Container(
                  height: 100,
                  child: Column(
                    children: <Widget>[
                      Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                          fontSize: 50,
                          color: CupertinoColors.systemGrey6,
                        ),
                      ),
                      const Text(
                        '获取中...',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey6,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          } else {
            final String url = _currentPreview.largeImageUrl;
            return Container(
              // margin: const EdgeInsets.all(1.0),
              child: ExtendedImage.network(
                url,
                fit: BoxFit.contain,
                mode: ExtendedImageMode.gesture,
                cache: true,
              ),
            );
          }
        });
  }
}
