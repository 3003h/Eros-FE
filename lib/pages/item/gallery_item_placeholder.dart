import 'package:fehviewer/common/service/theme_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'gallery_item.dart';

class GalleryItemPlaceHolder extends StatelessWidget {
  const GalleryItemPlaceHolder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double coverImageWidth =
        Get.context!.isPhone ? Get.context!.mediaQueryShortestSide / 3 : 120;

    final _line = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color:
            CupertinoDynamicColor.resolve(CupertinoColors.systemGrey5, context),
        height: 16,
      ),
    ).paddingSymmetric(vertical: 4);

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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _line,
                          _line,
                          Container(width: 70, child: _line),
                          const SizedBox(height: 4),
                          _line,
                          Container(width: 70, child: _line),

                          // 评分行
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              // 评分
                              Container(width: 50, child: _line),
                              // 占位
                              const Spacer(),
                              Container(width: 50, child: _line),
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
