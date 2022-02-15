import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/all_previews_controller.dart';
import 'package:fehviewer/pages/gallery/view/preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import 'const.dart';

class AllPreviewPage extends StatefulWidget {
  const AllPreviewPage();

  @override
  _AllPreviewPageState createState() => _AllPreviewPageState();
}

class _AllPreviewPageState extends State<AllPreviewPage> {
  final Map<String, bool> _loadComplets = {};

  GlobalKey centerKey = GlobalKey();

  @override
  void dispose() {
    super.dispose();
    if (Get.isRegistered<AllPreviewsPageController>()) {
      Get.delete<AllPreviewsPageController>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AllPreviewsPageController controller =
        Get.put(AllPreviewsPageController());

    final int _count = int.parse(controller.filecount);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: GestureDetector(
          onTap: controller.scrollToTop,
          child: Text(L10n.of(context).all_preview),
        ),
        previousPageTitle: L10n.of(context).back,
        trailing: controller.canShowJumpDialog
            ? GetBuilder<AllPreviewsPageController>(
                id: 'trailing',
                builder: (logic) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (logic.currPage > 1)
                        CupertinoButton(
                          padding: const EdgeInsets.all(0),
                          minSize: 38,
                          child: const Icon(
                            CupertinoIcons.arrow_up_circle,
                            size: 26,
                          ),
                          onPressed: () async {
                            // controller.fetchPriviewsPrevious();
                            logic.fetchPriviewsFromPage(1);
                          },
                        ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        minSize: 38,
                        child: const Icon(
                          CupertinoIcons.arrow_uturn_down_circle,
                          size: 26,
                        ),
                        onPressed: () async {
                          final rult = await controller.showJumpDialog(context);
                          if (rult is int) {
                            logger.d('jump to page $rult');
                            controller.scrollToTop();
                            controller.fetchPriviewsFromPage(rult);
                          }
                        },
                      ),
                    ],
                  );
                },
              )
            : const SizedBox(),
      ),
      child: CupertinoScrollbar(
        controller: controller.scrollController,
        child: controller.obx(
          (Tuple2<List<GalleryImage>, List<GalleryImage>>? state) {
            final previewPreviousList = state?.item1;
            final previewList = state?.item2;
            // logger.d('${previewPreviousList?.length}  ${previewList?.length}');
            if (previewList != null) {
              return CustomScrollView(
                // center: centerKey,
                physics: const AlwaysScrollableScrollPhysics(),
                controller: controller.scrollController,
                slivers: <Widget>[
                  SliverPadding(
                    padding: EdgeInsets.only(
                        top: context.mediaQueryPadding.top +
                            kMinInteractiveDimensionCupertino),
                    sliver: CupertinoSliverRefreshControl(
                      onRefresh: controller.fetchPriviewsPrevious,
                    ),
                  ),

                  // 前一页网格视图
                  if (previewPreviousList!.isNotEmpty)
                    SliverSafeArea(
                      top: false,
                      bottom: false,
                      sliver: SliverPadding(
                        padding:
                            const EdgeInsets.only(top: 4, left: 8, right: 8),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: kMaxCrossAxisExtent,
                                  mainAxisSpacing: kMainAxisSpacing,
                                  crossAxisSpacing: kCrossAxisSpacing,
                                  childAspectRatio: kChildAspectRatio),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Center(
                                child: PreviewContainer(
                                  galleryImageList: previewPreviousList,
                                  index: index,
                                  gid: controller.gid,
                                  onLoadComplet: () {
                                    final thumbUrl =
                                        previewPreviousList[index].thumbUrl ??
                                            '';
                                    Future.delayed(
                                            const Duration(milliseconds: 50))
                                        .then(
                                      (_) {
                                        if (!(_loadComplets[thumbUrl] ??
                                                false) &&
                                            mounted) {
                                          logger.d('onLoadComplet $thumbUrl');
                                          setState(
                                            () {
                                              _loadComplets[thumbUrl] = true;
                                            },
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: previewPreviousList.length,
                          ),
                        ),
                      ),
                    ),

                  // 主网格视图
                  SliverSafeArea(
                    key: centerKey,
                    top: false,
                    sliver: SliverPadding(
                      padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: kMaxCrossAxisExtent,
                                mainAxisSpacing: kMainAxisSpacing, //主轴方向的间距
                                crossAxisSpacing:
                                    kCrossAxisSpacing, //交叉轴方向子元素的间距
                                childAspectRatio: kChildAspectRatio //显示区域宽高比
                                ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            //如果显示到最后一个 获取下一页缩略图
                            if ((index == previewList.length - 1 ||
                                    previewList[index + 1].ser -
                                            previewList[index].ser >
                                        1) &&
                                previewList[index].ser < _count) {
                              controller.fetchPriviewsNext();
                            } else if (previewList[index].ser >= _count) {
                              controller.fetchFinsh();
                            }
                            return Center(
                              key: index == 0 ? controller.globalKey : null,
                              child: PreviewContainer(
                                galleryImageList: previewList,
                                index: index,
                                gid: controller.gid,
                                onLoadComplet: () {
                                  final thumbUrl =
                                      previewList[index].thumbUrl ?? '';
                                  Future.delayed(
                                          const Duration(milliseconds: 50))
                                      .then(
                                    (_) {
                                      if (!(_loadComplets[thumbUrl] ?? false) &&
                                          mounted) {
                                        logger.d('onLoadComplet $thumbUrl');
                                        setState(
                                          () {
                                            _loadComplets[thumbUrl] = true;
                                          },
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          childCount: previewList.length,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 50, top: 10),
                      child: Column(
                        children: <Widget>[
                          if (controller.isLoadingNext)
                            const CupertinoActivityIndicator(
                              radius: 14,
                            )
                          else
                            Container(),
                          if (controller.isLoadFinsh)
                            Container(
                              padding: const EdgeInsets.only(top: 0),
                              child: Text(
                                L10n.of(context).noMorePreviews,
                                style: const TextStyle(fontSize: 14),
                              ),
                            )
                          else
                            Container(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
          onLoading: Container(
            alignment: Alignment.center,
            child: const CupertinoActivityIndicator(
              radius: 18,
            ),
          ),
        ),
      ),
    );
  }
}
