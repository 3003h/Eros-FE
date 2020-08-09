import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/galleryComment.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';

import 'comment_item.dart';

class CommentPage extends StatelessWidget {
  const CommentPage({Key key, this.galleryComments}) : super(key: key);
  final List<GalleryComment> galleryComments;

  @override
  Widget build(BuildContext context) {
    final S ln = S.of(context);

    final Widget commSliverList = CustomScrollView(
      slivers: <Widget>[
        SliverSafeArea(
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (contex, index) {
                return CommentItem(
                  galleryComment: galleryComments[index],
                );
              },
              childCount: galleryComments.length,
            ),
          ),
        )
      ],
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: ThemeColors.navigationBarBackground,
        middle: Text(ln.gallery_comments),
      ),
      child: commSliverList,
    );
  }
}
