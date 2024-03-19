import 'package:eros_fe/common/controller/image_block_controller.dart';
import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PHashImageListPage extends GetView<ImageBlockController> {
  const PHashImageListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 12),
        middle: Text(L10n.of(context).phash_block_list),
        trailing: CupertinoButton(
          // 清除按钮
          padding: const EdgeInsets.all(0),
          minSize: 40,
          child: const Icon(
            CupertinoIcons.trash,
            size: 24,
          ),
          onPressed: () {
            controller.customBlockList.clear();
          },
        ),
      ),
      child: CustomScrollView(slivers: [
        SliverSafeArea(
          sliver: Obx(() {
            return SliverCupertinoListSection.insetGrouped(
              additionalDividerMargin: 64,
              itemCount: controller.customBlockList.length,
              itemBuilder: (context, index) {
                final imageHide = controller.customBlockList[index];

                return ImageHideItem(
                  imageHide: imageHide,
                  onDelete: () => controller.customBlockList.removeAt(index),
                );
              },
            );
          }),
        ),
      ]),
    );
  }
}

class ImageHideItem extends StatelessWidget {
  const ImageHideItem({Key? key, required this.imageHide, this.onDelete})
      : super(key: key);
  final ImageHide imageHide;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    child: Container(
                      width: 50,
                      child: EhNetworkImage(imageUrl: imageHide.imageUrl ?? ''),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                Text(
                  imageHide.pHash.toUpperCase(),
                ),
              ],
            ),
          ),
          CupertinoButton(
            // 清除按钮
            child: const Icon(
              CupertinoIcons.xmark_circle,
              color: CupertinoColors.systemRed,
              size: 26,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
