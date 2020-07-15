import 'dart:io';

import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'comment_item.dart';

/// 内容
class GalleryDetailContex extends StatelessWidget {
  const GalleryDetailContex({
    Key key,
    @required List<Widget> lisTagGroupW,
    @required GalleryItem galleryItem,
  })  : _lisTagGroupW = lisTagGroupW,
        _galleryItem = galleryItem,
        super(key: key);

  final List<Widget> _lisTagGroupW;
  final GalleryItem _galleryItem;

  List<Widget> _topComment(List<GalleryComment> comments, {int max = 2}) {
    var _comments = comments.take(max);
    return List<Widget>.from(_comments
        .map((comment) => CommentItem(
              galleryComment: comment,
              simple: true,
            ))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);
    return Container(
      child: Column(
        children: <Widget>[
          // 标签
          TagBox(
            lisTagGroup: _lisTagGroupW,
          ),
          ..._topComment(_galleryItem.galleryComment, max: 2),
          // 评论按钮
          CupertinoButton(
            minSize: 0,
            padding: const EdgeInsets.fromLTRB(4, 4, 0, 0),
            child: Text(ln.all_comment),
            onPressed: () {
              NavigatorUtil.goGalleryDetailComment(
                  context, _galleryItem.galleryComment);
            },
          ),
          ThumbnailBox(
            galleryPreviewList: _galleryItem.galleryPreview,
          ),
        ],
      ),
    );
  }
}

class ThumbnailBox extends StatelessWidget {
  final List<GalleryPreview> galleryPreviewList;

  const ThumbnailBox({Key key, @required this.galleryPreviewList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> thumbnails = List<Widget>.from(galleryPreviewList
        .map((thumb) => PreviewContainer(
              galleryPreview: thumb,
            ))
        .toList());

//    return Container(
//      child: GridView.count(
//        crossAxisCount: 4,
//        childAspectRatio: 0.5,
//        children: <Widget>[...thumbnails],
//      ),
//    );

    return Column(
      children: <Widget>[...thumbnails],
    );
  }
}

class PreviewContainer extends StatelessWidget {
  final GalleryPreview galleryPreview;

  const PreviewContainer({Key key, @required this.galleryPreview})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        galleryPreview.isLarge ?? false
            ? Container(
                child: CachedNetworkImage(
                  imageUrl: galleryPreview.imgUrl,
                ),
              )
            : Container(
                width: galleryPreview.width,
                height: galleryPreview.height,
                child: Stack(
                  fit: StackFit.expand,
                  overflow: Overflow.clip,
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      left: -galleryPreview.offSet,
                      child: CachedNetworkImage(
//                  width: galleryThumbnail.width,
//                  height: galleryThumbnail.height,
                        fit: BoxFit.none,
                        alignment: Alignment.topLeft,
                        imageUrl: galleryPreview.imgUrl,
                      ),
                    ),
                  ],
                ),
              ),
        Container(
          height: 10,
        )
      ],
    );
  }
}

/// 预览图小图裁剪
class PreviewClipper extends CustomClipper<Path> {
  final double offset;

  // 宽高
  final double width;
  final double height;

  /// 构造函数，接收传递过来的宽高
  PreviewClipper(
      {this.offset = 0.0, @required this.width, @required this.height});

  /// 获取剪裁区域的接口
  /// 返回一个矩形 path
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(offset, 0.0);
    path.lineTo(offset + width, 0.0);
    path.lineTo(offset + width, height);
    path.lineTo(offset, height);
    path.close();
    return path;
  }

  /// 接口决定是否重新剪裁
  /// 如果在应用中，剪裁区域始终不会发生变化时应该返回 false，这样就不会触发重新剪裁，避免不必要的性能开销。
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

/// 标签按钮
/// onPressed 回调
class TagButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback _onPressed;

  const TagButton({
    @required this.text,
    color,
    VoidCallback onPressed,
  })  : this.color = color ?? Colors.teal,
        _onPressed = onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1,
        ),
        strutStyle: StrutStyle(height: 1),
      ),
      minSize: 0,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      borderRadius: BorderRadius.circular(50),
      color: color,
      onPressed: _onPressed,
      disabledColor: Colors.blueGrey,
    );
  }
}

/// 包含多个 TagBox
class TagBox extends StatelessWidget {
  final List<Widget> lisTagGroup;

  const TagBox({Key key, this.lisTagGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(children: lisTagGroup),
        ),
        Container(
          height: 0.5,
          color: CupertinoColors.systemGrey4,
        ),
      ],
    );
  }
}

/// 封面小图
class CoveTinyImage extends StatelessWidget {
  final String imgUrl;
  final double statusBarHeight;

  const CoveTinyImage({Key key, this.imgUrl, double statusBarHeight})
      : statusBarHeight = statusBarHeight ?? 44,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var _padding = Platform.isAndroid ? 0.0 : 2.0;
    return Container(
      height: statusBarHeight,
      width: statusBarHeight,
      padding: EdgeInsets.all(_padding),
      child: ClipRRect(
        // 圆角
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: imgUrl,
        ),
      ),
    );
  }
}
