import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../common/service/theme_service.dart';
import 'item_base.dart';

const int kTitleMaxLines = 2;
const double kRadius = 6.0;
const double kCategoryWidth = 32.0;
const double kCategoryHeight = 20.0;
const double kCoverRatio = 1.4;

class GalleryItemGridPlaceHolder extends StatelessWidget {
  const GalleryItemGridPlaceHolder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // 封面高度
      final coverHeight = kCoverRatio * constraints.maxWidth;

      return Container(
        decoration: BoxDecoration(
          color: ehTheme.itemBackgroundColor,
          borderRadius: BorderRadius.circular(kRadius), //圆角
          boxShadow: ehTheme.isDarkMode
              ? null
              : [
                  BoxShadow(
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey3, Get.context!),
                    blurRadius: 10,
                  )
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /// 画廊封面
            Container(
              width: constraints.maxWidth,
              height: coverHeight,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(kRadius),
                  topRight: Radius.circular(kRadius),
                ),
                child: Container(
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey4, context),
                ),
              ),
            ),

            /// 画廊信息等
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Expanded(child: PlaceHolderLine()),
                      ],
                    ),
                  ],
                ).paddingAll(6.0),
              ),
            ),
          ],
        ),
      );
    });
  }
}
