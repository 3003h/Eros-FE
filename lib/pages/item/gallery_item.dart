import 'package:cached_network_image/cached_network_image.dart';
import 'package:fehviewer/common/controller/ehconfig_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/states/gallery_model.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/values/theme_colors.dart';
import 'package:fehviewer/widget/blur_image.dart';
import 'package:fehviewer/widget/rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

const double kCoverImageWidth = 120.0;

/// 画廊列表项
/// 使用provider进行管理
/// 标题和tag需要随设置变化重构ui
class GalleryItemWidget extends StatefulWidget {
  const GalleryItemWidget(
      {@required this.galleryItem, @required this.tabIndex});

  final GalleryItem galleryItem;
  final String tabIndex;

  @override
  _GalleryItemWidgetState createState() => _GalleryItemWidgetState();
}

class _GalleryItemWidgetState extends State<GalleryItemWidget> {
  final double _paddingLeft = 8.0;

  Color _colorTap; // 按下时颜色反馈
  String _title; // 英语或者日语
  GalleryModel _galleryModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          _buildContainer(),
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

  Widget _buildContainer() {
    return Selector<GalleryModel, Tuple2>(
        selector: (_, galleryModel) =>
            Tuple2(galleryModel.galleryItem, galleryModel.detailLoadFinish),
        builder: (context, snapshot, _) {
          final GalleryItem _galleryItem = snapshot.item1;

          // logger.d('${widget.tabIndex} ${_galleryItem.toJson()}');

          return Container(
            color: _colorTap,
            padding: EdgeInsets.fromLTRB(_paddingLeft, 8, 8, 8),
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
                          _galleryItem?.uploader ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: CupertinoColors.systemGrey),
                        ),
                        // 标签
                        const TagBox(),

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
        });
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
              maxLines: 4,
              textAlign: TextAlign.left, // 对齐方式
              overflow: TextOverflow.ellipsis, // 超出部分省略号
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ));
      },
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage() {
    return Consumer<GalleryModel>(builder: (context, galleryModel, _) {
      final GalleryItem _item = galleryModel.galleryItem;

      // 获取图片高度 用于占位
      double _getHeigth() {
        if (_item.imgWidth >= kCoverImageWidth) {
          return _item.imgHeight * kCoverImageWidth / _item.imgWidth;
        } else {
          return _item.imgHeight;
        }
      }

      // logger.d('${_item.englishTitle} ${_getHeigth()}');

      return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        width: kCoverImageWidth,
        height: _item.imgWidth != null ? _getHeigth() : null,
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
            child: Center(
              child: ClipRRect(
                // 圆角
                borderRadius: BorderRadius.circular(6),
                child: CoverImg(
                  imgUrl: galleryModel?.galleryItem?.imgUrl ?? '',
                  height: _item.imgWidth != null ? _getHeigth() : null,
                ),
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
      // _colorTap = CupertinoColors.systemGrey4;
      _colorTap =
          CupertinoDynamicColor.resolve(ThemeColors.pressedBackground, context);
    });
  }
}

///
///
///
///
///
///
class TagItem extends StatelessWidget {
  const TagItem({
    Key key,
    this.text,
    this.color,
    this.backgrondColor,
  }) : super(key: key);

  final String text;
  final Color color;
  final Color backgrondColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        // height: 18,
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
        color: backgrondColor ??
            CupertinoDynamicColor.resolve(ThemeColors.tagBackground, context),
        child: Text(
          text ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1,
            fontWeight:
                backgrondColor == null ? FontWeight.w400 : FontWeight.w500,
            color: color ??
                CupertinoDynamicColor.resolve(ThemeColors.tagText, context),
          ),
          strutStyle: const StrutStyle(height: 1),
        ),
      ),
    );
  }
}

/// 传入原始标签和翻译标签
/// 用于设置切换的时候变更
class TagBox extends StatelessWidget {
  const TagBox({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EhConfigController ehConfigController = Get.find();

    return Selector<GalleryModel, List<SimpleTag>>(
      selector: (context, GalleryModel galleryModel) =>
          galleryModel.galleryItem.simpleTags,
      builder: (context, List<SimpleTag> list, Widget child) {
        final List<SimpleTag> simpleTags = list;
        return simpleTags != null && simpleTags.isNotEmpty
            ? Obx(() => Container(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                  child: Wrap(
                    spacing: 4, //主轴上子控件的间距
                    runSpacing: 4, //交叉轴上子控件之间的间距
                    children: List<Widget>.from(
                        simpleTags.map((SimpleTag _simpleTag) {
                      final String _text =
                          ehConfigController.isTagTranslat.value
                              ? _simpleTag.translat
                              : _simpleTag.text;
                      return TagItem(
                        text: _text,
                        color: ColorsUtil.getTagColor(_simpleTag.color),
                        backgrondColor:
                            ColorsUtil.getTagColor(_simpleTag.backgrondColor),
                      );
                    }).toList()), //要显示的子控件集合
                  ),
                ))
            : Container();
      },
    );
  }
}

/// 封面图片Widget
class CoverImg extends StatelessWidget {
  const CoverImg({
    Key key,
    @required this.imgUrl,
    this.height,
    this.width,
  }) : super(key: key);

  final String imgUrl;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final EhConfigController ehConfigController = Get.find();
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile?.user?.cookie ?? '',
    };

    Widget image() {
      if (imgUrl != null && imgUrl.isNotEmpty) {
        return CachedNetworkImage(
          placeholder: (_, __) {
            return Container(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey5, context),
            );
          },
          height: height,
          width: width,
          httpHeaders: _httpHeaders,
          imageUrl: imgUrl,
          fit: BoxFit.cover,
        );
      } else {
        return Container();
      }
    }

    return Obx(() {
      if (ehConfigController.isGalleryImgBlur.value) {
        return BlurImage(
          child: image(),
        );
      } else {
        return image();
      }
    });
  }
}
