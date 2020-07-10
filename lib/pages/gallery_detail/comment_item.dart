import 'package:FEhViewer/models/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const kMaxline = 4;

class CommentItem extends StatelessWidget {
  final GalleryComment galleryComment;
  final bool simple;

  const CommentItem(
      {Key key, @required this.galleryComment, this.simple = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
//      height: 50,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ClipRRect(
        // 圆角
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: CupertinoColors.systemGrey6,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    galleryComment.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                  Spacer(),
                  Text(
                    galleryComment.score,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                child: simple
                    ? Text(
                        galleryComment.context,
                        maxLines: kMaxline,
                        softWrap: true,
                        textAlign: TextAlign.left, // 对齐方式
                        overflow: TextOverflow.ellipsis, // 超出部分省略号
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      )
                    : Text(
                        galleryComment.context,
                        softWrap: true,
                        textAlign: TextAlign.left, // 对齐方式
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
              ),
              Text(
                galleryComment.time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54,
                ),
              ),
//          Container(
//            height: 1,
//            color: CupertinoColors.systemGrey4,
//          ),
            ],
          ),
        ),
      ),
    );
  }
}
