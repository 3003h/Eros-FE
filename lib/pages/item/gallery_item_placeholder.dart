import 'package:fehviewer/common/service/theme_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'gallery_item.dart';
import 'item_base.dart';

class GalleryItemPlaceHolder extends StatelessWidget {
  const GalleryItemPlaceHolder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double coverImageWidth =
        Get.context!.isPhone ? Get.context!.mediaQueryShortestSide / 3 : 120;

    return Container(
      height: kFixedHeight,
      decoration: BoxDecoration(
        boxShadow: ehTheme.isDarkMode
            ? null
            : [
                BoxShadow(
                  color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey5, Get.context!)
                      .withOpacity(1.0),
                  blurRadius: 10,
                  // spreadRadius: 2,
                  offset: const Offset(2, 4),
                )
              ],
        borderRadius: BorderRadius.circular(kCardRadius),
        color: ehTheme.itemBackgroundColor,
      ),
      padding: const EdgeInsets.only(right: kPaddingHorizontal),
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            // 封面图片
            Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(kCardRadius),
                    child: Container(
                      width: coverImageWidth,
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey5, context),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 8,
            ),
            // 右侧信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 标题 provider
                  const PlaceHolderLine(),
                  const PlaceHolderLine(),
                  // 上传者
                  const PlaceHolderLine(
                    width: 50,
                  ),
                  const Spacer(),
                  // 标签
                  const Row(
                    children: [
                      Expanded(child: PlaceHolderLine(width: 65)),
                      PlaceHolderLine(width: 50),
                      PlaceHolderLine(width: 50),
                    ],
                  ),
                  const Row(
                    children: [
                      PlaceHolderLine(width: 50),
                      PlaceHolderLine(width: 50),
                      Expanded(child: PlaceHolderLine(width: 65)),
                    ],
                  ),
                  const Spacer(),
                  // 评分行
                  const Expanded(child: PlaceHolderLine(width: 75)),
                  Container(
                    height: 4,
                  ),
                  // 类型和时间
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // 类型
                      PlaceHolderLine(width: 60),
                      Spacer(),
                      // 上传时间
                      PlaceHolderLine(width: 40),
                    ],
                  ),
                ],
              ).paddingSymmetric(vertical: 4),
            ),
          ],
        ),
      ),
    );
  }
}
