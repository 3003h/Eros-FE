import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:fehviewer/common/exts.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery/controller/comment_controller.dart';
import 'package:fehviewer/pages/gallery/controller/extended_text_selection_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/view/comment_item.dart';
import 'package:fehviewer/pages/gallery/view/preview_clipper.dart';
import 'package:fehviewer/pages/gallery/view/taginfo_dialog.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
// import 'package:fehviewer/utils/cust_lib/selectable_text.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/widget/eh_cached_network_image.dart';
import 'package:fehviewer/widget/network_extended_image.dart';
import 'package:fehviewer/widget/rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 封面小图 纯StatelessWidget
class CoveTinyImage extends StatelessWidget {
  const CoveTinyImage(
      {Key? key, required this.imgUrl, required this.statusBarHeight})
      : super(key: key);

  final String imgUrl;
  final double statusBarHeight;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile.user.cookie ?? '',
    };
    return Container(
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        // 圆角
        borderRadius: BorderRadius.circular(4),
        child: EhCachedNetworkImage(
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          imageUrl: imgUrl,
        ),
        // child: NetworkExtendedImage(
        //   url: imgUrl,
        //   height: 44,
        //   width: 44,
        //   fit: BoxFit.cover,
        // ),
      ),
    );
  }
}

// 画廊封面
class CoverImage extends StatelessWidget {
  const CoverImage({
    Key? key,
    required this.imageUrl,
    required this.heroTag,
    this.imgHeight,
    this.imgWidth,
  }) : super(key: key);

  static const double kWidth = 145.0;
  final String? imageUrl;

  // ${_item.gid}_${_item.token}_cover_$_tabIndex
  final Object heroTag;

  final double? imgHeight;
  final double? imgWidth;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      final Map<String, String> _httpHeaders = {
        'Cookie': Global.profile.user.cookie ?? '',
        'host': Uri.parse(imageUrl ?? '').host,
      };

      if (imageUrl != null && imageUrl!.isNotEmpty) {
        return Container(
          width: kWidth,
          margin: const EdgeInsets.only(right: 10),
          child: Center(
            child: Hero(
              tag: heroTag,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    //阴影
                    BoxShadow(
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey4, context),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: imgHeight,
                    width: imgWidth,
                    child: CachedNetworkImage(
                      placeholder: (_, __) {
                        return Container(
                          alignment: Alignment.center,
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.systemGrey5, context),
                          child: const CupertinoActivityIndicator(),
                        );
                      },
                      imageUrl: (imageUrl ?? '').dfUrl,
                      fit: BoxFit.cover,
                      httpHeaders: _httpHeaders,
                    ),
                    // child: NetworkExtendedImage(
                    //   url: imageUrl ?? '',
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return Container(
          width: kWidth,
          margin: const EdgeInsets.only(right: 10),
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
                color: CupertinoColors.systemBackground,
              ),
            ),
          ),
        );
      }
    });
  }
}

class GalleryTitle extends StatelessWidget {
  const GalleryTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);

    /// 构建标题
    ///
    /// 问题 文字如果使用 SelectableText 并且页面拉到比较下方的时候
    /// 在返回列表时会异常 疑似和封面图片的Hero动画有关
    /// 如果修改封面图片的 Hero tag ,即不使用 Hero 动画
    /// 异常则不会出现
    ///
    /// 暂时放弃使用 SelectableText
    ///
    /// 20210107 改用SelectableText测试

    return GestureDetector(
      /*child: SelectableText(
        _pageController.title,
        maxLines: 6,
        minLines: 1,
        textAlign: TextAlign.left,
        // 对齐方式
        // overflow: TextOverflow.ellipsis, // 超出部分省略号
        style: const TextStyle(
          textBaseline: TextBaseline.alphabetic,
          // height: 1.2,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        strutStyle: const StrutStyle(
          height: 1.2,
          forceStrutHeight: true,
        ),
      ),*/
      child: ExtendedText(
        _pageController.title,
        selectionEnabled: true,
        textAlign: TextAlign.left,
        // 对齐方式
        overflow: TextOverflow.ellipsis, // 超出部分省略号
        maxLines: 6,
        selectionControls: EHTextSelectionControls(),
        style: const TextStyle(
          textBaseline: TextBaseline.alphabetic,
          // height: 1.2,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        strutStyle: const StrutStyle(
          height: 1.2,
          forceStrutHeight: true,
        ),
      ),
    );
  }
}

/// 上传用户
class GalleryUploader extends StatelessWidget {
  const GalleryUploader({
    Key? key,
    required this.uploader,
  }) : super(key: key);

  final String uploader;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(top: 8, right: 8, bottom: 4),
        child: Text(
          uploader,
          maxLines: 1,
          textAlign: TextAlign.left, // 对齐方式
          overflow: TextOverflow.ellipsis, // 超出部分省略号
          style: TextStyle(
            fontSize: 13,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondaryLabel, context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onTap: () {
        logger.v('search uploader:$uploader');
        NavigatorUtil.goGalleryListBySearch(simpleSearch: 'uploader:$uploader');
      },
    );
  }
}

class ReadButton extends StatelessWidget {
  const ReadButton({
    Key? key,
    required this.gid,
  }) : super(key: key);
  final String gid;

  @override
  Widget build(BuildContext context) {
    final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);

    return Obx(
      () => CupertinoButton(
          child: Text(
            (_pageController.lastIndex != null && _pageController.lastIndex > 0)
                ? '${L10n.of(context).READ} ${_pageController.lastIndex + 1}'
                : L10n.of(context).READ,
            style: const TextStyle(fontSize: 15, height: 1.2),
          ),
          minSize: 20,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          borderRadius: BorderRadius.circular(20),
          color: CupertinoColors.activeBlue,
          onPressed: _pageController.enableRead
              ? () => _toViewPage(
                  _pageController.galleryItem.gid, _pageController.lastIndex)
              : null),
    );
  }

  Future<void> _toViewPage(String? gid, int _index) async {
    // logger.d('_toViewPage lastIndex $_index');
    NavigatorUtil.goGalleryViewPage(_index, gid ?? '');
  }
}

/// 类别
class GalleryCategory extends StatelessWidget {
  const GalleryCategory({
    Key? key,
    required this.category,
  }) : super(key: key);

  final String? category;

  @override
  Widget build(BuildContext context) {
    final Color _colorCategory = CupertinoDynamicColor.resolve(
        ThemeColors.catColor[category ?? 'default'] ??
            CupertinoColors.systemGrey4,
        context);
    // final Color _colorCategory = CupertinoDynamicColor.resolve(
    //     ThemeColors.catColor[category ?? 'default']!, context);
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
          color: _colorCategory,
          child: Text(
            category ?? '',
            style: const TextStyle(
              fontSize: 14.5,
              // height: 1.1,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
      onTap: () {
        final int iCat = EHConst.cats[category]!;
        final int cats = EHConst.sumCats - iCat;
        // NavigatorUtil.goGalleryList(cats: iCat);
      },
    );
  }
}

class GalleryRating extends StatelessWidget {
  const GalleryRating({
    Key? key,
    this.rating,
    this.ratingFB,
    this.color,
  }) : super(key: key);

  final double? rating;
  final double? ratingFB;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // logger.d('rating $rating');
    return Row(
      children: <Widget>[
        Container(
            padding: const EdgeInsets.only(right: 8),
            child: Text('${rating ?? 0}')),
        // 星星
        StaticRatingBar(
          size: 18.0,
          rate: ratingFB ?? 0,
          radiusRatio: 1.5,
          colorLight: color,
          colorDark: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey3, context),
        ),
      ],
    );
  }
}

class PreviewGrid extends StatefulWidget {
  const PreviewGrid({Key? key, required this.images, required this.gid})
      : super(key: key);
  final List<GalleryImage> images;
  final String gid;

  @override
  _PreviewGridState createState() => _PreviewGridState();
}

class _PreviewGridState extends State<PreviewGrid> {
  final Map<String, bool> _loadComplets = {};

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        //解决无限高度问题
        physics: const NeverScrollableScrollPhysics(),
        //禁用滑动事件
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 130,
            mainAxisSpacing: 0, //主轴方向的间距
            crossAxisSpacing: 4, //交叉轴方向子元素的间距
            childAspectRatio: 0.55 //显示区域宽高
            ),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Center(
            child: PreviewContainer(
              galleryImageList: widget.images,
              index: index,
              gid: widget.gid,
              onLoadComplet: () {
                final thumbUrl = widget.images[index].thumbUrl ?? '';
                Future.delayed(const Duration(milliseconds: 50)).then(
                  (_) {
                    if (!(_loadComplets[thumbUrl] ?? false) && mounted) {
                      logger.d('onLoadComplet $thumbUrl');
                      setState(() {
                        _loadComplets[thumbUrl] = true;
                      });
                    }
                  },
                );
              },
            ),
          );
        });
  }
}

class TopComment extends StatelessWidget {
  const TopComment({Key? key, this.showBtn = true}) : super(key: key);

  // final List<GalleryComment> comment;
  final bool showBtn;

  @override
  Widget build(BuildContext context) {
    // 显示最前面两条
    List<Widget> _topComment(List<GalleryComment>? comments, {int max = 2}) {
      final Iterable<GalleryComment> _comments = comments?.take(max) ?? [];
      return List<Widget>.from(_comments
          .map((GalleryComment comment) => CommentItem(
                galleryComment: comment,
                simple: true,
              ))
          .toList());
    }

    return Column(
      children: <Widget>[
        // 评论
        GetBuilder<CommentController>(
          init: CommentController(),
          tag: pageCtrlDepth,
          id: GetIds.PAGE_VIEW_TOP_COMMENT,
          builder: (CommentController _commentController) {
            return _commentController.obx(
                (List<GalleryComment>? state) => Column(
                      children: <Widget>[
                        ..._topComment(state, max: 2),
                      ],
                    ),
                onLoading: Container(
                  padding: const EdgeInsets.all(8),
                  child: const CupertinoActivityIndicator(
                    radius: 10,
                  ),
                ));
          },
        ),
        // 评论按钮
        if (showBtn)
          CupertinoButton(
            minSize: 0,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Text(
              L10n.of(Get.context!).all_comment,
              style: const TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Get.toNamed(EHRoutes.galleryComment);
            },
          ),
      ],
    );
  }
}

/// 包含多个 TagGroup
class TagBox extends StatelessWidget {
  const TagBox({Key? key, required this.listTagGroup}) : super(key: key);

  final List<TagGroup> listTagGroup;

  @override
  Widget build(BuildContext context) {
    final List<Widget> listGroupWidget = <Widget>[];
    for (final TagGroup tagGroupData in listTagGroup) {
      listGroupWidget.add(TagGroupItem(tagGroupData: tagGroupData));
    }

    return Column(children: listGroupWidget);
  }
}

class MorePreviewButton extends StatelessWidget {
  const MorePreviewButton({
    Key? key,
    required this.hasMorePreview,
  }) : super(key: key);

  final bool hasMorePreview;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Text(
        hasMorePreview
            ? L10n.of(Get.context!).morePreviews
            : L10n.of(Get.context!).noMorePreviews,
        style: const TextStyle(fontSize: 16),
      ),
      onPressed: () {
        Get.toNamed(EHRoutes.galleryAllPreviews);
      },
    );
  }
}

class PreviewContainer extends StatelessWidget {
  PreviewContainer({
    Key? key,
    required this.index,
    required this.galleryImageList,
    required this.gid,
    this.onLoadComplet,
  })  : galleryImage = galleryImageList[index],
        hrefs = List<String>.from(
            galleryImageList.map((GalleryImage e) => e.href).toList()),
        super(key: key);

  final int index;
  final String gid;
  final List<GalleryImage> galleryImageList;
  final List<String> hrefs;
  final GalleryImage galleryImage;
  final VoidCallback? onLoadComplet;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile.user.cookie ?? '',
    };
    Widget _buildImage() {
      if (galleryImage.isLarge ?? false) {
        // 缩略大图
        return EhCachedNetworkImage(
          imageUrl: galleryImage.thumbUrl ?? '',
          progressIndicatorBuilder: (_, __, ___) {
            return const CupertinoActivityIndicator();
          },
        );
        // return NetworkExtendedImage(
        //   url: galleryImage.thumbUrl ?? '',
        // );
      } else {
        return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
/*
          double _subHeight;
          double _subWidth;
          final double _subHeightP = (galleryImage.thumbHeight ?? 0) *
              constraints.maxWidth /
              (galleryImage.thumbWidth ?? 0);
          if (_subHeightP > kHeightPreview) {
            _subHeight = kHeightPreview;
            _subWidth = kHeightPreview *
                (galleryImage.thumbWidth ?? 0) /
                (galleryImage.thumbHeight ?? 0);
          } else {
            _subWidth = constraints.maxWidth;
            _subHeight = _subHeightP;
          }
*/
          final imageSize =
              Size(galleryImage.thumbWidth!, galleryImage.thumbHeight!);
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final FittedSizes fittedSizes =
              applyBoxFit(BoxFit.contain, imageSize, size);

          return ExtendedImageRect(
            url: galleryImage.thumbUrl!,
            height: fittedSizes.destination.height,
            width: fittedSizes.destination.width,
            onLoadComplet: onLoadComplet,
            sourceRect: Rect.fromLTWH(
              galleryImage.offSet! + 1,
              1.0,
              galleryImage.thumbWidth! - 2,
              galleryImage.thumbHeight! - 2,
            ),
          );
          if (false)
            return Container(
              height: fittedSizes.destination.height,
              width: fittedSizes.destination.width,
              // 缩略小图
              child: Stack(
                alignment: AlignmentDirectional.center,
                fit: StackFit.expand,
                children: <Widget>[
                  PreviewImageClipper(
                    imgUrl: galleryImage.thumbUrl!,
                    offset: galleryImage.offSet!,
                    height: galleryImage.thumbHeight!,
                    width: galleryImage.thumbWidth!,
                  ),
                ],
              ),
            );
        });
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        NavigatorUtil.goGalleryViewPage(index, gid);
      },
      child: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    child: _buildImage(),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${galleryImage.ser}',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey, context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 一个标签组 第一个是类型
class TagGroupItem extends StatelessWidget {
  const TagGroupItem({
    required this.tagGroupData,
  });

  final TagGroup tagGroupData;

  List<Widget> _initTagBtnList(
      List<GalleryTag> galleryTags, BuildContext context) {
    final EhConfigService ehConfigService = Get.find();
    final List<Widget> _tagBtnList = <Widget>[];
    galleryTags.forEach((GalleryTag tag) {
      _tagBtnList.add(
        Obx(() => TagButton(
              text: ehConfigService.isTagTranslat ? tag.tagTranslat : tag.title,
              textColor: () {
                switch (tag.vote) {
                  case 0:
                    return null;
                  case 1:
                    return CupertinoDynamicColor.resolve(
                        ThemeColors.tagUpColor, context);
                  case -1:
                    return CupertinoDynamicColor.resolve(
                        ThemeColors.tagDownColor, context);
                }
              }(),
              onPressed: () {
                logger.v('search type[${tag.type}] tag[${tag.title}]');
                NavigatorUtil.goGalleryListBySearch(
                    simpleSearch: '${tag.type}:${tag.title.trim()}');
              },
              onLongPress: () {
                if (ehConfigService.isTagTranslat) {
                  showTagInfoDialog(
                    tag.title,
                    translate: tag.tagTranslat,
                    type: tag.type,
                    vote: tag.vote ?? 0,
                  );
                }
              },
            )),
      );
    });
    return _tagBtnList;
  }

  @override
  Widget build(BuildContext context) {
    final EhConfigService ehConfigService = Get.find();

    final List<Widget> _tagBtnList =
        _initTagBtnList(tagGroupData.galleryTags, context);
    final String _tagType = tagGroupData.tagType ?? '';

    final Container container = Container(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // tag 分类
          Container(
            padding: const EdgeInsets.only(right: 8),
            child: Obx(() => TagButton(
                  color: CupertinoDynamicColor.resolve(
                      ThemeColors.tagColorTagType[_tagType.trim()]!, context),
                  text: ehConfigService.isTagTranslat
                      ? EHConst.translateTagType[_tagType.trim()] ?? _tagType
                      : _tagType,
                )),
          ),
          Expanded(
            child: Container(
              child: Wrap(
                spacing: 4, //主轴上子控件的间距
                runSpacing: 4, //交叉轴上子控件之间的间距
                children: _tagBtnList, //要显示的子控件集合
              ),
            ),
          )
        ],
      ),
    );

    return container;
  }
}

/// 标签按钮
/// onPressed 回调
class TagButton extends StatelessWidget {
  const TagButton({
    Key? key,
    required this.text,
    this.textColor,
    this.color,
    this.onPressed,
    this.onLongPress,
    this.padding,
  }) : super(key: key);

  final String text;
  final Color? textColor;
  final Color? color;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: ClipRRect(
        key: key,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: padding ?? const EdgeInsets.fromLTRB(6, 3, 6, 4),
          color: color ??
              CupertinoDynamicColor.resolve(ThemeColors.tagBackground, context),
          child: Text(
            text,
            style: TextStyle(
              color: textColor ??
                  CupertinoDynamicColor.resolve(ThemeColors.tagText, context),
              fontSize: 13,
              fontWeight: textColor != null ? FontWeight.w500 : null,
              height: 1.3,
//              fontWeight: FontWeight.w500,
            ),
            strutStyle: const StrutStyle(height: 1),
          ),
        ),
      ),
    );
  }
}

class TextBtn extends StatelessWidget {
  const TextBtn(this.iconData,
      {Key? key, this.iconSize, this.title, this.onTap})
      : super(key: key);
  final IconData iconData;
  final double? iconSize;
  final String? title;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(primaryColor: CupertinoColors.systemGrey),
      child: GestureDetector(
        child: Container(
          // padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              CupertinoButton(
                padding: const EdgeInsets.only(bottom: 8.0),
                // color: CupertinoColors.activeBlue,
                child: Icon(
                  iconData,
                  size: iconSize ?? 28,
                  // color: CupertinoColors.systemGrey3,
                ),
                onPressed: onTap,
              ),
              Text(
                title ?? '',
                style: const TextStyle(fontSize: 12, height: 1),
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
