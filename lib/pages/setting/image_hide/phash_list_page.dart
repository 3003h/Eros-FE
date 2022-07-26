import 'package:fehviewer/common/controller/image_hide_controller.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class PHashImageListPage extends GetView<ImageHideController> {
  const PHashImageListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String _title = L10n.of(context).mange_hidden_images;
    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 12),
          middle: Text(_title),
          trailing: CupertinoButton(
            // 清除按钮
            child: const Icon(
              FontAwesomeIcons.trashCan,
              size: 22,
            ),
            onPressed: () {
              controller.customHideList.clear();
            },
          ),
        ),
        child: SafeArea(
          bottom: false,
          top: false,
          child: Container(
            child: ListView.separated(
              itemCount: controller.customHideList.length,
              itemBuilder: (context, index) {
                final imageHide = controller.customHideList[index];
                return ImageHideItem(
                  imageHide: imageHide,
                  onDelete: () => controller.customHideList.removeAt(index),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  indent: 12,
                  thickness: 1.0,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey4, context),
                );
              },
            ),
          ),
        ),
      );
    });
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    borderRadius: BorderRadius.circular(6.0),
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
              FontAwesomeIcons.circleXmark,
              size: 22,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
