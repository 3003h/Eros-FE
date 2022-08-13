import 'package:fehviewer/common/service/theme_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                  Row(
                    children: const [
                      Expanded(child: PlaceHolderLine(width: 65)),
                      PlaceHolderLine(width: 50),
                      PlaceHolderLine(width: 50),
                    ],
                  ),
                  Row(
                    children: const [
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
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

    return Column(
      children: <Widget>[
        Container(
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
            color: ehTheme.itemBackgroundColor,
            borderRadius: BorderRadius.circular(kCardRadius),
          ),
          padding: const EdgeInsets.only(right: kPaddingHorizontal),
          margin: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  // 封面图片
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      constraints:
                          const BoxConstraints(maxHeight: 280, minHeight: 100),
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey5, context),
                      width: coverImageWidth,
                      child: const SizedBox(
                        height: 150,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  // 右侧信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const PlaceHolderLine(),
                        const PlaceHolderLine(),
                        Container(width: 70, child: const PlaceHolderLine()),
                        const SizedBox(height: 4),
                        const PlaceHolderLine(),
                        Container(width: 70, child: const PlaceHolderLine()),

                        // 评分行
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            // 评分
                            Container(
                                width: 50, child: const PlaceHolderLine()),
                            // 占位
                            const Spacer(),
                            Container(
                                width: 50, child: const PlaceHolderLine()),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        // 类型和时间
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            // 类型
                            // _buildCategory(),
                            const Spacer(),
                            // 上传时间
                            // _buildPostTime(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(
          height: 0.5,
          indent: kPaddingHorizontal,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey4, Get.context!),
        ),
      ],
    );
  }
}
