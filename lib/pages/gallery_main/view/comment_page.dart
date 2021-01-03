import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/gallery_main/controller/comment_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'comment_item.dart';

class CommentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CommentController controller = Get.find(tag: pageCtrlDepth);
    final Widget commSliverList = CustomScrollView(
      slivers: <Widget>[
        SliverSafeArea(
          sliver: controller.obx(
              (state) => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext contex, int index) {
                        if (index < state.length) {
                          return CommentItem(
                            galleryComment: state[index],
                          );
                        } else {
                          return Container(height: 20);
                        }
                      },
                      childCount: state.length + 1,
                    ),
                  ),
              onLoading: SliverFillRemaining(
                child: Container(),
              )),
        )
      ],
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(S.of(context).gallery_comments),
      ),
      child: commSliverList,
    );
  }
}
