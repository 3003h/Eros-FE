import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/gallery/controller/all_thumbnails_controller.dart';
import 'package:eros_fe/pages/gallery/view/thumb_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'const.dart';

class AllThumbnailsPage extends StatefulWidget {
  const AllThumbnailsPage();

  @override
  _AllThumbnailsPageState createState() => _AllThumbnailsPageState();
}

class _AllThumbnailsPageState extends State<AllThumbnailsPage> {
  final Map<String, bool> _loadComplets = {};

  GlobalKey centerKey = GlobalKey();

  @override
  void dispose() {
    super.dispose();
    if (Get.isRegistered<AllThumbnailsPageController>()) {
      Get.delete<AllThumbnailsPageController>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AllThumbnailsPageController controller =
        Get.put(AllThumbnailsPageController());

    final int _count = int.parse(controller.fileCount);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: GestureDetector(
          onTap: controller.scrollToTop,
          child: Text(L10n.of(context).all_thumbnails),
        ),
        previousPageTitle: L10n.of(context).back,
        trailing: controller.canShowJumpDialog
            ? GetBuilder<AllThumbnailsPageController>(
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
                            logic.fetchThumbnailsFromPage(1);
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
                            controller.fetchThumbnailsFromPage(rult);
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
          ((List<GalleryImage>, List<GalleryImage>)? state) {
            final previewPreviousList = state?.$1;
            final previewList = state?.$2;
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
                                child: ThumbBox(
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
                              controller.fetchThumbnailsNext();
                            } else if (previewList[index].ser >= _count) {
                              controller.fetchFinsh();
                            }
                            return Center(
                              key: index == 0 ? controller.globalKey : null,
                              child: ThumbBox(
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
                                L10n.of(context).no_more_thumbnails,
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
