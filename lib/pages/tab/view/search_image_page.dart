import 'dart:io';

import 'package:blur/blur.dart';
import 'package:eros_fe/pages/tab/view/list/tab_base.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../index.dart';
import '../controller/search_image_controller.dart';
import '../controller/search_page_controller.dart';
import 'gallery_base.dart';

const Color _kDefaultNavBarBorderColor = Color(0x4D000000);
const Border _kDefaultNavBarBorder = Border(
  bottom: BorderSide(
    color: _kDefaultNavBarBorderColor,
    width: 0.0, // One physical pixel.
    style: BorderStyle.solid,
  ),
);

class SearchImagePage extends GetView<SearchImageController> {
  SearchImagePage({Key? key}) : super(key: key);

  // 色彩数据
  final List<Color> data = List.generate(24, (i) => Color(0xFF0000FF - 24 * i));

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Search image'),
      ),
      child: Container(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: ImagePersistentHeaderDelegate(),
              // pinned: true,
              floating: true,
            ),
            EhCupertinoSliverRefreshControl(
              onRefresh: () async {
                await controller.reloadData();
              },
            ),
            // _buildSliverList(),
            Obx(() {
              // logger.d('listType ${controller.listType}');
              if (controller.listType == ListType.gallery) {
                return _buildListView(context);
              }

              return _getInitView();
            }),
            // _getGallerySliverList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return SliverSafeArea(
      top: false,
      bottom: false,
      sliver: GetBuilder<SearchImageController>(
        global: false,
        init: controller,
        id: controller.listViewId,
        builder: (logic) {
          final status = logic.status;

          if (status.isLoading) {
            return SliverFillRemaining(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 50),
                child: const CupertinoActivityIndicator(
                  radius: 14.0,
                ),
              ),
            );
          }

          if (status.isError) {
            return SliverFillRemaining(
              child: Container(
                padding: const EdgeInsets.only(bottom: 50),
                child: GalleryErrorPage(
                  onTap: logic.reLoadDataFirst,
                  error: status.errorMessage,
                ),
              ),
            );
          }

          if (status.isSuccess) {
            return getGallerySliverList(
              logic.state,
              controller.tabIndex,
              next: logic.next,
              lastComplete: controller.lastComplete,
              // centerKey: centerKey,
              key: controller.sliverAnimatedListKey,
              lastTopitemIndex: controller.lastTopitemIndex,
            );
          }

          return SliverFillRemaining(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.hippo,
                    size: 100,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey, context),
                  ),
                  Text(''),
                ],
              ),
            ).autoCompressKeyboard(context),
          );
        },
      ),
    );
  }

  Widget _getInitView() {
    return SliverToBoxAdapter(child: Container());
  }

  // 构建颜色列表
  Widget _buildSliverList() => SliverList(
        delegate: SliverChildBuilderDelegate(
            (_, int index) => _buildColorItem(data[index]),
            childCount: data.length),
      );

  // 构建颜色列表item
  Widget _buildColorItem(Color color) => Card(
        child: Container(
          alignment: Alignment.center,
          width: 100,
          height: 60,
          color: color,
          child: Text(
            colorString(color),
            style: const TextStyle(color: Colors.white, shadows: [
              Shadow(color: Colors.black, offset: Offset(.5, .5), blurRadius: 2)
            ]),
          ),
        ),
      );

  // 颜色转换为文字
  String colorString(Color color) =>
      "#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}";
}

class ImagePersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final SearchImageController searchImageController = Get.find();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // print(
    //     '=====shrinkOffset:$shrinkOffset======overlapsContent:$overlapsContent====');
    final String info = 'shrinkOffset:${shrinkOffset.toStringAsFixed(1)}'
        '\noverlapsContent:$overlapsContent';

    final paddingTop = context.mediaQueryPadding.top;

    return Container(
      decoration: BoxDecoration(
        border: _kDefaultNavBarBorder,
      ),
      padding: EdgeInsets.only(top: paddingTop),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.all(0.0),
              onPressed: () {
                logger.d('onPressed selImage');
                searchImageController.selectSearchImage(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: CupertinoColors.systemGrey3,
                ),
                margin:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                // color: CupertinoColors.systemGrey3,
                child: Obx(() {
                  return searchImageController.imagePath.isEmpty
                      ? Center(
                          child: Icon(
                            FontAwesomeIcons.circlePlus,
                            // color: CupertinoColors.systemGrey2,
                            color:
                                CupertinoTheme.of(context).barBackgroundColor,
                            size: 40,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: ExtendedImage.file(
                            File(searchImageController.imagePath),
                          ),
                        );
                }),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxHeight: 80),
            child: CupertinoButton(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  color: CupertinoColors.activeBlue,
                ),
                margin: const EdgeInsets.only(right: 12),
                // color: CupertinoColors.systemGrey3,
                child: Center(
                  child: Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: CupertinoTheme.of(context).barBackgroundColor,
                    size: 40,
                  ),
                ),
              ),
              onPressed: () {
                logger.d('onPressSearch');
                searchImageController.startSearch();
              },
            ),
          ),
        ],
      ).frosted(
        blur: 8,
        frostColor:
            CupertinoTheme.of(context).barBackgroundColor.withOpacity(1),
        frostOpacity: 0.55,
      ),
    );
  }

  @override
  double get maxExtent => 300;

  @override
  double get minExtent => 200;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
