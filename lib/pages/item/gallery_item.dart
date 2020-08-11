import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:FEhViewer/widget/blur_image.dart';
import 'package:FEhViewer/widget/rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

const double kCoverImageWidth = 120.0;

/// 画廊列表项
/// 使用provider进行管理
/// 标题和tag需要随设置变化重构ui
class GalleryItemWidget extends StatefulWidget {
  const GalleryItemWidget(
      {@required this.galleryItem, @required this.tabIndex});

  final GalleryItem galleryItem;
  final tabIndex;

  @override
  _GalleryItemWidgetState createState() => _GalleryItemWidgetState();
}

class _GalleryItemWidgetState extends State<GalleryItemWidget> {
  final double _paddingLeft = 8.0;

  Color _colorTap; // 按下时颜色反馈
  String _title; // 英语或者日语
  GalleryModel _galleryModel;

  @override
  void initState() {
    super.initState();
//    Future.delayed(Duration.zero, () {
//      Provider.of<GalleryModel>(context, listen: false)
//          .initData(widget.galleryItem, tabIndex: widget.tabIndex);
//    });
//    WidgetsBinding.instance.addPostFrameCallback((callback) {});
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
      // height: 200,
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
                    galleryModel?.galleryItem?.uploader ?? '',
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

    return GestureDetector(
      child: Column(
        children: <Widget>[
          containerGallery,
          Divider(
            height: 0.5,
            indent: _paddingLeft,
            color: CupertinoColors.systemGrey4,
          ),
        ],
      ),
      // 不可见区域点击有效
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Global.logger.v(_title);
        NavigatorUtil.goGalleryDetailPr(context);
      },
      onLongPress: () {
        Global.logger.v('onLongPress title: $_title ');
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
    return Selector2<EhConfigModel, GalleryModel, String>(
      selector: (context, ehconfig, gallery) {
        final String _titleEn = gallery?.galleryItem?.englishTitle ?? '';
        final String _titleJpn = gallery?.galleryItem?.japaneseTitle ?? '';

        // 日语标题判断
        final String _title =
            ehconfig.isJpnTitle && _titleJpn != null && _titleJpn.isNotEmpty
                ? _titleJpn
                : _titleEn;

        return _title;
      },
      builder: (context, title, child) {
        _title = title;
        return Text(
          title,
          maxLines: 4,
          textAlign: TextAlign.left, // 对齐方式
          overflow: TextOverflow.ellipsis, // 超出部分省略号
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage() {
    return Consumer<GalleryModel>(builder: (context, galleryModel, child) {
      final GalleryItem _item = galleryModel.galleryItem;

      num _getHeigth() {
        if (_item.imgWidth >= kCoverImageWidth) {
          return _item.imgHeight * kCoverImageWidth / _item.imgWidth;
        } else {
          return _item.imgHeight;
        }
      }

      return Hero(
        tag: '${_item.gid}_${_item.token}_cover_${galleryModel.tabIndex}',
        child: Container(
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(6.0), //圆角
                  // ignore: prefer_const_literals_to_create_immutables
                  boxShadow: [
                //阴影
                const BoxShadow(
                  color: CupertinoColors.systemGrey2,
                  blurRadius: 2.0,
                )
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: kCoverImageWidth,
              height: _getHeigth(),
              color: CupertinoColors.systemBackground,
              child: Center(
                child: ClipRRect(
                  // 圆角
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                      child: CoverImg(
                          imgUrl: galleryModel?.galleryItem?.imgUrl ?? '')),
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
          const Icon(
            Icons.panorama,
            size: 13,
            color: CupertinoColors.systemGrey,
          ),
          Container(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              galleryModel?.galleryItem?.filecount ?? "",
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
      final Color _colorCategory = ThemeColors
                  .nameColor[galleryModel?.galleryItem?.category ?? 'defaule']
              ['color'] ??
          CupertinoColors.white;

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
      _colorTap = CupertinoColors.systemGrey4;
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
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        // height: 18,
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
        color: const Color(0xffeeeeee),
        child: Text(
          text ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w400,
            color: Color(0xff444444),
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
    return Selector2<EhConfigModel, GalleryModel, List>(
      selector: (context, EhConfigModel ehconfig, GalleryModel galleryModel) =>
          ehconfig.isTagTranslat
              ? galleryModel.galleryItem.simpleTagsTranslat
              : galleryModel.galleryItem.simpleTags,
      builder: (context, simpleTags, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
          child: Wrap(
            spacing: 4, //主轴上子控件的间距
            runSpacing: 4, //交叉轴上子控件之间的间距
            children: List<Widget>.from(simpleTags
                .map((tagText) => TagItem(
                      text: tagText,
                    ))
                .toList()), //要显示的子控件集合
          ),
        );
      },
    );
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
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile?.user?.cookie ?? '',
    };
    return Selector<EhConfigModel, bool>(
        selector: (context, provider) => provider.isGalleryImgBlur,
        builder: (BuildContext context, bool value, Widget child) {
          return imgUrl != null
              ? (value
                  ? BlurImage(
                      child: CachedNetworkImage(
                      httpHeaders: _httpHeaders,
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                    ))
                  : CachedNetworkImage(
                      httpHeaders: _httpHeaders,
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                    ))
              : Container();
        });
  }
}
