import 'package:FEhViewer/models/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentItemFull extends StatelessWidget {
  final GalleryComment galleryComment;

  const CommentItemFull({Key key, @required this.galleryComment})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
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
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                child: Text(
                  galleryComment.context,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                galleryComment.time,
                style: TextStyle(
                  fontSize: 10,
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

class CommentList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
