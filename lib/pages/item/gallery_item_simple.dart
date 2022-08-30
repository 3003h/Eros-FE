import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/widget/blur_image.dart';
import 'package:fehviewer/widget/eh_network_image.dart';
import 'package:fehviewer/widget/rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'item_base.dart';

const double kCoverImageWidth = 90.0;
const double kItemHeight = 134.0;
const double kPaddingLeft = 8.0;

/// 画廊列表项
/// 简单模式 精简显示信息 固定高度
class GalleryItemSimpleWidget extends StatelessWidget {
  const GalleryItemSimpleWidget({
    Key? key,
    required this.galleryProvider,
    required this.tabTag,
    this.showTag = true,
  }) : super(key: key);

  final GalleryProvider galleryProvider;
  final dynamic tabTag;
  final bool showTag;

  GalleryItemController get galleryProviderController =>
      Get.find(tag: galleryProvider.gid);

  @override
  Widget build(BuildContext context) {
    final Widget containerGallery = Container(
      color: galleryProviderController.colorTap.value,
      height: showTag ? kItemHeight + 10 : kItemHeight,
      padding: const EdgeInsets.fromLTRB(kPaddingLeft, 10, 8, 10),
      child: Row(children: <Widget>[
        // 封面图片
        _buildCoverImage(),
        const SizedBox(width: 8),
        // 右侧信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 标题
              _buildTitle(),
              const SizedBox(height: 4),
              // 上传者
              Text(
                galleryProvider.uploader ?? '',
                style: const TextStyle(
                    fontSize: 12, color: CupertinoColors.systemGrey),
              ),
              // tag
              const Spacer(),
              if (showTag)
                // TagListViewBox(
                //   simpleTags:
                //       galleryProviderController.galleryProvider.simpleTags ?? [],
                // ),
                TagWaterfallFlowViewBox(
                  simpleTags: galleryProvider.simpleTags ?? [],
                  crossAxisCount: 1,
                ),
              const Spacer(),
              // 评分行
              GetBuilder(
                init: galleryProviderController,
                tag: galleryProviderController.galleryProvider.gid,
                builder: (_) => Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    // 评分
                    _buildRating(),
                    // 占位
                    const Spacer(),
                    // 收藏图标
                    _buildFavcatIcon(),
                    // 图片数量
                    _buildFilecontWidget(),
                  ],
                ),
              ),
              Container(
                height: 4,
              ),
              // 类型和时间
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  // 类型
                  _buildCategory(),
                  const Spacer(),
                  // 上传时间
                  PostTime(
                    postTime:
                        galleryProviderController.galleryProvider.postTime ??
                            '',
                    expunged:
                        galleryProviderController.galleryProvider.expunged,
                    fontSize: 11,
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );

    return GestureDetector(
      child: Column(
        children: <Widget>[
          containerGallery,
          Divider(
            height: 0.5,
            indent: kPaddingLeft,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey4, context),
          ),
        ],
      ),
      // 不可见区域点击有效
      behavior: HitTestBehavior.opaque,
      onTap: () => galleryProviderController.onTap(tabTag),
      onTapDown: galleryProviderController.onTapDown,
      onTapUp: galleryProviderController.onTapUp,
      onTapCancel: galleryProviderController.onTapCancel,
      onLongPress: galleryProviderController.onLongPress,
    ).autoCompressKeyboard(context);
  }

  /// 构建标题
  Widget _buildTitle() {
    return Obx(() => Text(
          galleryProviderController.title,
          maxLines: 2,
          textAlign: TextAlign.left, // 对齐方式
          overflow: TextOverflow.ellipsis, // 超出部分省略号
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  /// 构建封面图片
  Widget _buildCoverImage() {
    final GalleryProvider _item = galleryProviderController.galleryProvider;

    return Container(
      width: kCoverImageWidth,
      height: kItemHeight,
      child: Center(
        child: Hero(
          tag: '${_item.gid}_cover_${tabTag}',
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                //阴影
                BoxShadow(
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey5, Get.context!),
                  blurRadius: 10,
                )
              ],
            ),
            child: ClipRRect(
              // 圆角
              borderRadius: BorderRadius.circular(6),
              child: CoverImg(
                  height: _item.imgHeight,
                  width: _item.imgWidth,
                  imgUrl:
                      galleryProviderController.galleryProvider.imgUrl ?? ''),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
          child: StaticRatingBar(
            size: 12.0,
            rate: galleryProviderController.galleryProvider.ratingFallBack ?? 0,
            radiusRatio: 1.5,
            colorLight: ThemeColors.colorRatingMap[
                galleryProviderController.galleryProvider.colorRating?.trim() ??
                    'ir'],
            colorDark: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey3, Get.context!),
          ),
        ),
        Text(
          galleryProviderController.galleryProvider.rating?.toString() ?? '',
          style: TextStyle(
            fontSize: 11,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey, Get.context!),
          ),
        ),
      ],
    );
  }

  Widget _buildFilecontWidget() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            galleryProviderController.galleryProvider.translated ?? '',
            style: const TextStyle(
                fontSize: 11, color: CupertinoColors.systemGrey),
          ),
        ),
        const Icon(
          Icons.panorama,
          size: 12,
          color: CupertinoColors.systemGrey,
        ),
        Container(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            galleryProviderController.galleryProvider.filecount ?? '',
            style: const TextStyle(
                fontSize: 11, color: CupertinoColors.systemGrey),
          ),
        ),
      ],
    );
  }

  Widget _buildFavcatIcon() {
    return Container(
      child: galleryProviderController.galleryProvider.favTitle?.isNotEmpty ??
              false
          ? Container(
              padding: const EdgeInsets.only(bottom: 2.5, right: 8),
              child: Icon(
                FontAwesomeIcons.solidHeart,
                size: 11,
                color: ThemeColors
                    .favColor[galleryProviderController.galleryProvider.favcat],
              ),
            )
          : Container(),
    );
  }

  Widget _buildPostTime() {
    return Text(
      galleryProviderController.galleryProvider.postTime ?? '',
      style: const TextStyle(fontSize: 11, color: CupertinoColors.systemGrey),
    );
  }

  Widget _buildCategory() {
    final Color _colorCategory = CupertinoDynamicColor.resolve(
        ThemeColors.catColor[
                galleryProviderController.galleryProvider.category ??
                    'default'] ??
            CupertinoColors.systemBackground,
        Get.context!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 4),
        color: _colorCategory,
        child: Text(
          galleryProviderController.galleryProvider.category ?? '',
          style: const TextStyle(
            fontSize: 10,
            height: 1.1,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}

/// 封面图片Widget
class CoverImg extends StatelessWidget {
  const CoverImg({
    Key? key,
    required this.imgUrl,
    this.height,
    this.width,
  }) : super(key: key);

  final String imgUrl;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final EhConfigService _ehConfigService = Get.find();
    if (imgUrl.isNotEmpty) {
      return Obx(() {
        final bool _isBlur = _ehConfigService.isGalleryImgBlur.value;
        return LayoutBuilder(
          builder: (context, constraints) {
            return BlurImage(
              isBlur: _isBlur,
              child: EhNetworkImage(
                placeholder: (_, __) {
                  return Container(
                    alignment: Alignment.center,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey5, context),
                    child: const CupertinoActivityIndicator(),
                  );
                },
                height: (height ?? 0) * constraints.maxWidth / (width ?? 0),
                // width: constraints.maxWidth,
                imageUrl: imgUrl,
                fit: BoxFit.contain,
              ),
            );
          },
        );
      });
    } else {
      return Container();
    }
  }
}
