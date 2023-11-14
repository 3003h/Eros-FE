import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import 'gallery_item.dart';

const double kRadius = 6.0;
const double kCategoryWidth = 28.0;
const double kCategoryHeight = 22.0;

class GalleryItemFlow extends StatelessWidget {
  const GalleryItemFlow(
      {Key? key, required this.tabTag, required this.galleryProvider})
      : super(key: key);

  final dynamic tabTag;
  final GalleryProvider galleryProvider;

  GalleryItemController get galleryProviderController =>
      Get.find(tag: galleryProvider.gid);

  Widget _buildFavcatIcon() {
    return Obx(() {
      // logger.d('${_galleryProviderController.isFav}');
      return Container(
        child: galleryProviderController.isFav
            ? Container(
                child: Icon(
                  FontAwesomeIcons.solidHeart,
                  size: 12,
                  color: ThemeColors.favColor[
                      galleryProviderController.galleryProvider.favcat],
                ),
              )
            : Container(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget item = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final GalleryProvider galleryProvider =
          galleryProviderController.galleryProvider;

      final Color _colorCategory = CupertinoDynamicColor.resolve(
          ThemeColors.catColor[galleryProvider.category ?? 'default'] ??
              CupertinoColors.systemBackground,
          context);

      // 获取图片高度
      int? _getHeight() {
        if ((galleryProvider.imgWidth ?? 0) >= constraints.maxWidth) {
          return (galleryProvider.imgHeight ?? 0) *
              constraints.maxWidth ~/
              (galleryProvider.imgWidth ?? 0);
        } else {
          return galleryProvider.imgHeight;
        }
      }

      final Widget container = Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: '${galleryProvider.gid}_cover_${tabTag}',
              child: Container(
                decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(kRadius), //圆角
                    // ignore: prefer_const_literals_to_create_immutables
                    boxShadow: [
                      //阴影
                      BoxShadow(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.systemGrey6, context),
                        blurRadius: 5,
                      )
                    ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kRadius),
                  child: Container(
                    foregroundDecoration: RotatedCornerDecoration.withColor(
                      color: _colorCategory.withOpacity(0.8),
                      // labelInsets:
                      //     const LabelInsets(baselineShift: 0.2, start: 2),
                      // geometry: const BadgeGeometry(
                      //     width: kCategoryWidth, height: kCategoryHeight),
                      spanBaselineShift: 0.2,
                      spanHorizontalOffset: 2,
                      badgeSize: const Size(kCategoryWidth, kCategoryHeight),
                      textSpan: TextSpan(
                        text: galleryProvider.translated ?? '',
                        style: const TextStyle(
                            fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                    alignment: Alignment.center,
                    height: galleryProvider.imgWidth != null
                        ? _getHeight()?.toDouble()
                        : null,
                    child: CoverImg(imgUrl: galleryProvider.imgUrl!),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: container,
        onTap: () => galleryProviderController.onTap(tabTag),
        onLongPress: galleryProviderController.onLongPress,
      ).autoCompressKeyboard(context);
    });

    return item;
  }
}
