import 'package:FEhViewer/common/controller/ehconfig_controller.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/logger.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:FEhViewer/widget/blur_image.dart';
import 'package:FEhViewer/widget/rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

const double kCoverImageWidth = 70.0;
const double kItemWidth = 115.0;

/// 画廊列表项
/// 尖端模式 精简显示信息 固定高度
/// 使用provider进行管理
/// 标题和tag需要随设置变化重构ui
class GalleryItemSimpleWidget extends StatefulWidget {
  const GalleryItemSimpleWidget(
      {@required this.galleryItem, @required this.tabIndex});

  final GalleryItem galleryItem;
  final String tabIndex;

  @override
  _GalleryItemSimpleWidgetState createState() =>
      _GalleryItemSimpleWidgetState();
}

class _GalleryItemSimpleWidgetState extends State<GalleryItemSimpleWidget> {
  final double _paddingLeft = 8.0;

  Color _colorTap; // 按下时颜色反馈
  String _title; // 英语或者日语
  GalleryModel _galleryModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;
//      galleryModel.initData(widget.galleryItem, tabIndex: widget.tabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final GalleryModel galleryModel = Provider.of<GalleryModel>(context);

    final Widget containerGallery = Container(
      color: _colorTap,
      height: kItemWidth,
      padding: EdgeInsets.fromLTRB(_paddingLeft, 6, 6, 6),
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
                    galleryModel?.galleryItem?.uploader ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: CupertinoColors.systemGrey),
                  ),
                  // 评分行
                  Row(
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
            indent: _paddingLeft,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey4, context),
          ),
        ],
      ),
      // 不可见区域点击有效
      behavior: HitTestBehavior.opaque,
      onTap: () {
        logger.v(_title);
        NavigatorUtil.goGalleryDetailPr(context);
      },
      onLongPress: () {
        logger.v('onLongPress title: $_title ');
      },
      onTapDown: (_) => _updatePressedColor(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          _updateNormalColor();
        });
      },
      onTapCancel: () => _updateNormalColor(),
    );
  }

  /// 构建标题
  /// [EhConfigModel] eh设置的state 控制显示日文还是英文标题
  /// [GalleryModel] 画廊数据
  Widget _buildTitle() {
    return Selector<GalleryModel, GalleryItem>(
      selector: (context, gallery) => gallery.galleryItem,
      builder: (context, GalleryItem galleryItem, child) {
        final EhConfigController ehConfigController = Get.find();
        final String _titleEn = galleryItem?.englishTitle ?? '';
        final String _titleJpn = galleryItem?.japaneseTitle ?? '';

        return Obx(() => Text(
              ehConfigController.isJpnTitle.value &&
                      _titleJpn != null &&
                      _titleJpn.isNotEmpty
                  ? _titleJpn
                  : _titleEn,
              maxLines: 2,
              textAlign: TextAlign.left, // 对齐方式
              overflow: TextOverflow.ellipsis, // 超出部分省略号
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ));
      },
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage() {
    return Consumer<GalleryModel>(builder: (context, galleryModel, child) {
      final GalleryItem _item = galleryModel.galleryItem;

      return Container(
        width: kCoverImageWidth,
        height: kItemWidth - 12,
        child: Center(
          child: Hero(
            tag: '${_item.gid}_${_item.token}_cover_${galleryModel.tabIndex}',
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                //阴影
                BoxShadow(
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey4, context),
                  blurRadius: 10,
                )
              ]),
              child: ClipRRect(
                // 圆角
                borderRadius: BorderRadius.circular(6),
                child:
                    CoverImg(imgUrl: galleryModel?.galleryItem?.imgUrl ?? ''),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRating() {
    return Consumer<GalleryModel>(builder: (context, galleryModel, child) {
      return Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
            child: StaticRatingBar(
              size: 20.0,
              rate: galleryModel.galleryItem.rating,
              radiusRatio: 1.5,
            ),
          ),
          Text(
            galleryModel?.galleryItem?.rating.toString(),
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFilecontWidget() {
    return Consumer<GalleryModel>(builder: (context, galleryModel, child) {
      return Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              galleryModel?.galleryItem?.translated ?? '',
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
              galleryModel?.galleryItem?.filecount ?? '',
              style: const TextStyle(
                  fontSize: 12, color: CupertinoColors.systemGrey),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFavcatIcon() {
    return Consumer<GalleryModel>(builder: (context, galleryModel, child) {
      return Container(
        child: galleryModel.galleryItem.favTitle?.isNotEmpty ?? false
            ? Container(
                padding: const EdgeInsets.only(bottom: 2.5, right: 8),
                child: Icon(
                  FontAwesomeIcons.solidHeart,
                  size: 12,
                  color: ThemeColors.favColor[galleryModel.galleryItem.favcat],
                ),
              )
            : Container(),
      );
    });
  }

  Widget _buildPostTime() {
    return Consumer<GalleryModel>(builder: (context, galleryModel, child) {
      return Text(
        galleryModel?.galleryItem?.postTime ?? '',
        style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
      );
    });
  }

  Widget _buildCategory() {
    return Consumer<GalleryModel>(builder: (context, galleryModel, child) {
      final Color _colorCategory = CupertinoDynamicColor.resolve(
          ThemeColors
                  .catColor[galleryModel?.galleryItem?.category ?? 'default'] ??
              CupertinoColors.systemBackground,
          context);

      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
          color: _colorCategory,
          child: Text(
            galleryModel?.galleryItem?.category ?? '',
            style: const TextStyle(
              fontSize: 14,
              height: 1,
              color: CupertinoColors.white,
            ),
          ),
        ),
      );
    });
  }

  void _updateNormalColor() {
    setState(() {
      _colorTap = null;
    });
  }

  void _updatePressedColor() {
    setState(() {
      _colorTap =
          CupertinoDynamicColor.resolve(ThemeColors.pressedBackground, context);
    });
  }
}

/// 封面图片Widget
class CoverImg extends StatelessWidget {
  const CoverImg({
    Key key,
    @required this.imgUrl,
  }) : super(key: key);

  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    final EhConfigController ehConfigController = Get.find();
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile?.user?.cookie ?? '',
    };
    return imgUrl != null && imgUrl.isNotEmpty
        ? Obx(() {
            if (ehConfigController.isGalleryImgBlur.value) {
              return BlurImage(
                  child: CachedNetworkImage(
                httpHeaders: _httpHeaders,
                imageUrl: imgUrl,
                fit: BoxFit.cover,
              ));
            } else {
              return CachedNetworkImage(
                httpHeaders: _httpHeaders,
                imageUrl: imgUrl,
                fit: BoxFit.cover,
              );
            }
          })
        : Container();
  }
}
