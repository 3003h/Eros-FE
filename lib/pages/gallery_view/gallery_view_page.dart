import 'dart:io';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class GalleryViewPageE extends StatefulWidget {
  GalleryViewPageE({Key key, int index})
      : index = index ?? 0,
        controller = PageController(initialPage: index),
        super(key: key);

  final int index;
  final PageController controller;

  @override
  _GalleryViewPageEState createState() => _GalleryViewPageEState();
}

class _GalleryViewPageEState extends State<GalleryViewPageE> {
  int _currentIndex = 0;

  GalleryModel _galleryModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;
      // 预载后面5张图
      _precache(_galleryModel.previews, widget.index, 5);
    }
    _currentIndex = widget.index;
  }

  /// 画廊图片大图浏览
  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.dark,
        // barBackgroundColor: CupertinoColors.white,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: CupertinoPageScaffold(
          // backgroundColor: CupertinoColors.black,
          child: Selector<GalleryModel, List<GalleryPreview>>(
              selector: (context, galleryModel) =>
                  galleryModel.galleryItem.galleryPreview,
              shouldRebuild: (pre, next) => true,
              builder: (context, List<GalleryPreview> previews, child) {
//            Global.logger.v('build GalleryViewPageE');
                return SafeArea(
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        child: ExtendedImageGesturePageView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            final Widget image = GalleryImage(
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
                          // canMovePage: (_) => false,
                          // canScrollPage: (_) => false,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: Container(
                            child: Text(
                          '${_currentIndex + 1}/${previews.length}',
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
                            Api.shareImage(
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
                );
              }),
        ),
      ),
    );
  }

  // 一个很傻的预载功能 需要优化
  Future<void> _precache(
      List<GalleryPreview> previews, int index, int max) async {
    final GalleryModel _galleryModel =
        Provider.of<GalleryModel>(context, listen: false);

    for (int add = 0; add < max; add++) {
      final int _index = index + add + 1;
      if (_index > _galleryModel.previews.length - 1) {
        return;
      }
      final GalleryPreview _preview = _galleryModel.previews[_index];

      String _url = '';
      if (_preview.largeImageUrl?.isEmpty ?? true) {
        _url = await Api.getShowInfo(
            previews[_index].href, _galleryModel.showKey,
            index: _index);
        _galleryModel.previews[_index].largeImageUrl = _url;
      }

      _url = _galleryModel.previews[_index].largeImageUrl;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;
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
    final GalleryPreview _currentPreview =
        _galleryModel.galleryItem.galleryPreview[widget.index];
    return FutureBuilder<String>(
        future: _getImageUrl(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (_currentPreview.largeImageUrl == null) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
//                throw snapshot.error;
                return Center(child: Text('Error: ${snapshot.error}'));
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
