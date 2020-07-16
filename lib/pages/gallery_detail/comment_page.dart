import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/galleryComment.dart';
import 'package:flutter/cupertino.dart';

import 'comment_item.dart';

class CommentPage extends StatelessWidget {
  final List<GalleryComment> galleryComments;

  const CommentPage({Key key, this.galleryComments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(ln.gallery_comments),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
//        padding: const EdgeInsets.only(left: 10, right: 10),
          child: ListView.builder(itemBuilder: (context, index) {
            if (index < galleryComments.length) {
              return CommentItem(
                galleryComment: galleryComments[index],
              );
            } else {
              return null;
            }
          }),
        ),
      ),
    );
  }
}
