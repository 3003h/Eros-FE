import 'package:FEhViewer/models/galleryComment.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'comment_item.dart';

class CommentPage extends StatelessWidget {
  const CommentPage({Key key, this.galleryComments}) : super(key: key);
  final List<GalleryComment> galleryComments;

  @override
  Widget build(BuildContext context) {
    final Widget commSliverList = CustomScrollView(
      slivers: <Widget>[
        SliverSafeArea(
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext contex, int index) {
                if (index < galleryComments.length) {
                  return CommentItem(
                    galleryComment: galleryComments[index],
                  );
                } else {
                  return Container(height: 20);
                }
              },
              childCount: galleryComments.length + 1,
            ),
          ),
        )
      ],
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('gallery_comments'.tr),
      ),
      child: commSliverList,
    );
  }
}
