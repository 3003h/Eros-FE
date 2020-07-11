import 'dart:io';

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

  List<Widget> _topComment(List<GalleryComment> comments, int max) {
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
    return Container(
      child: Column(
        children: <Widget>[
          // 标签
          TagBox(
            lisTagGroup: _lisTagGroupW,
          ),
          ..._topComment(_galleryItem.galleryComment, 2),
          CupertinoButton(
            child: Text('Comment'),
            onPressed: () {
              NavigatorUtil.goGalleryDetailComment(
                  context, _galleryItem.galleryComment);
            },
          ),
        ],
      ),
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
    var _padding = Platform.isAndroid ? 0.0 : 4.0;
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
