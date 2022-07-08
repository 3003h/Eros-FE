import 'package:fehviewer/common/controller/image_hide_controller.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../fehviewer.dart';

class ImageHidePage extends GetView<ImageHideController> {
  const ImageHidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String _title = 'Image hide';
    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(start: 0),
          middle: Text(_title),
          trailing: CupertinoButton(
            // 清除按钮
            child: const Icon(
              FontAwesomeIcons.trashCan,
              size: 22,
            ),
            onPressed: () {},
          ),
        ),
        child: SafeArea(
          bottom: false,
          top: false,
          child: Container(
            child: ListView.separated(
              itemCount: controller.customHides.length,
              itemBuilder: (context, index) {
                final imageHide = controller.customHides[index];
                return ImageHideItem(imageHide: imageHide);
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
  const ImageHideItem({Key? key, required this.imageHide}) : super(key: key);
  final ImageHide imageHide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 80,
      child: Row(
        children: [
          Container(
              width: 50,
              margin: const EdgeInsets.only(right: 12),
              child: EhNetworkImage(imageUrl: imageHide.imageUrl ?? '')),
          Text(imageHide.pHash),
        ],
      ),
    );
  }
}
