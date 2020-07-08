import 'package:FEhViewer/models/index.dart';
import 'package:flutter/cupertino.dart';

class CommentItemFull extends StatelessWidget {
  final GalleryComment galleryComment;

  const CommentItemFull({Key key, @required this.galleryComment})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Text(galleryComment.name),
              Spacer(),
              Text(galleryComment.time),
            ],
          ),
          Container(
            child: Text(galleryComment.context),
          ),
          Container(
            height: 1,
            color: CupertinoColors.systemGrey4,
          ),
        ],
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
