import 'package:cached_network_image/cached_network_image.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/widget/blur_image.dart';
import 'package:fehviewer/widget/rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

const double kCoverImageWidth = 70.0;
const double kItemWidth = 115.0;
const double kPaddingLeft = 8.0;

/// 画廊列表项
/// 简单模式 精简显示信息 固定高度
class GalleryItemSimpleWidget extends StatelessWidget {
  GalleryItemSimpleWidget({required this.galleryItem, required this.tabTag}) {
    Get.lazyPut(
      () => GalleryItemController(galleryItem),
      tag: galleryItem.gid,
    );
  }

  final GalleryItem galleryItem;
  final String tabTag;

  GalleryItemController get _galleryItemController =>
      Get.find(tag: galleryItem.gid);

  @override
  Widget build(BuildContext context) {
    final Widget containerGallery = Container(
      color: _galleryItemController.colorTap.value,
      height: kItemWidth,
      padding: const EdgeInsets.fromLTRB(kPaddingLeft, 6, 6, 6),
      child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            // 封面图片
            _buildCoverImage(),
            Container(
              width: 8,
            ),
            // 右侧信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 标题 provider
                  _buildTitle(),
                  // 上传者
                  Text(
                    _galleryItemController.galleryItem.uploader ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: CupertinoColors.systemGrey),
                  ),
                  // 评分行
                  GetBuilder(
                    init: _galleryItemController,
                    tag: _galleryItemController.galleryItem.gid,
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
                      _buildPostTime(),
                    ],
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
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
      onTap: () => _galleryItemController.onTap(tabTag),
      onTapDown: _galleryItemController.onTapDown,
      onTapUp: _galleryItemController.onTapUp,
      onTapCancel: _galleryItemController.onTapCancel,
      onLongPress: _galleryItemController.onLongPress,
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    return Obx(() => Text(
          _galleryItemController.title,
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
    final GalleryItem _item = _galleryItemController.galleryItem;

    return Container(
      width: kCoverImageWidth,
      height: kItemWidth - 12,
      child: Center(
        child: Hero(
          tag: '${_item.gid}_cover_$tabTag',
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
                  imgUrl: _galleryItemController.galleryItem.imgUrl ?? ''),
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
            size: 16.0,
            rate: _galleryItemController.galleryItem.ratingFallBack ?? 0,
            radiusRatio: 1.5,
            colorLight: ThemeColors.colorRatingMap[
                _galleryItemController.galleryItem.colorRating?.trim() ?? 'ir'],
            colorDark: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey3, Get.context!),
          ),
        ),
        Text(
          _galleryItemController.galleryItem.rating?.toString() ?? '',
          style: TextStyle(
            fontSize: 12,
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
            _galleryItemController.galleryItem.translated ?? '',
            style: const TextStyle(
                fontSize: 12, color: CupertinoColors.systemGrey),
          ),
        ),
        const Icon(
          Icons.panorama,
          size: 13,
          color: CupertinoColors.systemGrey,
        ),
        Container(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            _galleryItemController.galleryItem.filecount ?? '',
            style: const TextStyle(
                fontSize: 12, color: CupertinoColors.systemGrey),
          ),
        ),
      ],
    );
  }

  Widget _buildFavcatIcon() {
    return Container(
      child: _galleryItemController.galleryItem.favTitle?.isNotEmpty ?? false
          ? Container(
              padding: const EdgeInsets.only(bottom: 2.5, right: 8),
              child: Icon(
                FontAwesomeIcons.solidHeart,
                size: 12,
                color: ThemeColors
                    .favColor[_galleryItemController.galleryItem.favcat],
              ),
            )
          : Container(),
    );
  }

  Widget _buildPostTime() {
    return Text(
      _galleryItemController.galleryItem.postTime ?? '',
      style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
    );
  }

  Widget _buildCategory() {
    final Color _colorCategory = CupertinoDynamicColor.resolve(
        ThemeColors.catColor[
                _galleryItemController.galleryItem.category ?? 'default'] ??
            CupertinoColors.systemBackground,
        Get.context!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
        color: _colorCategory,
        child: Text(
          _galleryItemController.galleryItem.category ?? '',
          style: const TextStyle(
            fontSize: 14,
            height: 1,
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
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile.user.cookie ?? '',
    };
    if (imgUrl != null && imgUrl.isNotEmpty) {
      return Obx(() {
        final bool _isBlur = _ehConfigService.isGalleryImgBlur.value;
        return LayoutBuilder(
          builder: (context, constraints) {
            return BlurImage(
              isBlur: _isBlur,
              child: CachedNetworkImage(
                placeholder: (_, __) {
                  return Container(
                    alignment: Alignment.center,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey5, context),
                    child: const CupertinoActivityIndicator(),
                  );
                },
                height: (height ?? 0) * constraints.maxWidth / (width ?? 0),
                width: constraints.maxWidth,
                httpHeaders: _httpHeaders,
                imageUrl: imgUrl,
                fit: BoxFit.fitWidth,
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
