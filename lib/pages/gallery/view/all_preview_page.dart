import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery/controller/all_previews_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'gallery_widget.dart';

const double kMaxCrossAxisExtent = 135.0;
const double kMainAxisSpacing = 0; //主轴方向的间距
const double kCrossAxisSpacing = 4; //交叉轴方向子元素的间距
const double kChildAspectRatio = 0.55; //显示区域宽高比

class AllPreviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AllPreviewsPageController controller =
        Get.put(AllPreviewsPageController());

    final int _count = int.parse(controller.filecount);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: GestureDetector(
          onTap: controller.scrollToTop,
          child: Text(S.of(context).all_preview),
        ),
        previousPageTitle: S.of(context).back,
      ),
      child: CupertinoScrollbar(
        controller: controller.scrollController,
        child: controller.obx((List<GalleryPreview>? state) {
          if (state != null) {
            return CustomScrollView(
              controller: controller.scrollController,
              slivers: <Widget>[
                SliverSafeArea(
                  sliver: SliverPadding(
                    padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: kMaxCrossAxisExtent,
                              mainAxisSpacing: kMainAxisSpacing, //主轴方向的间距
                              crossAxisSpacing: kCrossAxisSpacing, //交叉轴方向子元素的间距
                              childAspectRatio: kChildAspectRatio //显示区域宽高比
                              ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          //如果显示到最后一个 获取下一页缩略图
                          if ((index == state.length - 1 ||
                                  state[index + 1].ser - state[index].ser >
                                      1) &&
                              index < _count - 1) {
                            controller.fetchPriviews();
                          } else if (index >= _count - 1) {
                            controller.fetchFinsh();
                          }
                          return Center(
                            key: index == 0 ? controller.globalKey : null,
                            child: PreviewContainer(
                              galleryPreviewList: state,
                              index: index,
                              gid: controller.gid,
                            ),
                          );
                        },
                        childCount: state.length,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 50, top: 10),
                    child: Column(
                      children: <Widget>[
                        if (controller.isLoading)
                          const CupertinoActivityIndicator(
                            radius: 14,
                          )
                        else
                          Container(),
                        if (controller.isLoadFinsh)
                          Container(
                            padding: const EdgeInsets.only(top: 0),
                            child: Text(
                              S.of(context).noMorePreviews,
                              style: const TextStyle(fontSize: 14),
                            ),
                          )
                        else
                          Container(),
                      ],
                    ),
                  ),
                )
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        }, onLoading: const SizedBox.shrink()),
      ),
    );
  }
}
