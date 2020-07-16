import 'dart:io';

import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'comment_item.dart';
import 'gallery_preview_clipper.dart';

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
          PreviewBox(
            galleryPreviewList: _galleryItem.galleryPreview,
          ),
        ],
      ),
    );
  }
}

class PreviewBox extends StatelessWidget {
  final List<GalleryPreview> galleryPreviewList;

  const PreviewBox({Key key, @required this.galleryPreviewList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> previews = List<Widget>.from(galleryPreviewList
        .map((preview) => PreviewContainer(
              galleryPreview: preview,
            ))
        .toList());

//    return Container(
//      child: GridView.count(
//        crossAxisCount: 4,
////        childAspectRatio: 0.5,
//        children: <Widget>[...previews],
//      ),
//    );

//    return Container(
//      child: Column(
//        children: <Widget>[...previews],
//      ),
//    );

    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Wrap(
        spacing: 15.0, // 主轴(水平)方向间距
        runSpacing: 10.0, // 纵轴（垂直）方向间距
        alignment: WrapAlignment.center, //沿主轴方向居中
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[...previews],
      ),
    );
  }
}

class PreviewContainer extends StatelessWidget {
  final GalleryPreview galleryPreview;

  const PreviewContainer({Key key, @required this.galleryPreview})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var image = galleryPreview.isLarge ?? false
        ? Container(
            child: CachedNetworkImage(
              imageUrl: galleryPreview.imgUrl,
            ),
          )
        : Container(
            child: PreviewImageClipper(
              imgUrl: galleryPreview.imgUrl,
              offset: galleryPreview.offSet,
              height: galleryPreview.height,
              width: galleryPreview.width,
            ),
          );

    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
              //阴影
//            boxShadow: [
//              BoxShadow(
//                color: CupertinoColors.systemGrey,
//                offset: Offset(0.0, 0.0),
//                blurRadius: 4.0,
//              ),
//            ],
              ),
          child: Container(
            child: image,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            '${galleryPreview.ser ?? ''}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
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

class TagButtonB extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color color;
  final VoidCallback _onPressed;

  const TagButtonB({
    @required this.text,
    color,
    backgroundColor,
    VoidCallback onPressed,
  })  : this.textColor = color ?? Colors.black54,
        this.color = backgroundColor ?? const Color(0xffeeeeee),
        _onPressed = onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 3, 6, 4),
        color: color,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            height: 1.3,
          ),
          strutStyle: StrutStyle(height: 1),
        ),
      ),
    );

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
      color: textColor,
      onPressed: _onPressed,
      disabledColor: Colors.blueGrey,
    );
  }
}

/// 包含多个 TagGroup
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
