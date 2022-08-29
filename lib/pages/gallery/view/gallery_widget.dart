import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_state.dart';
import 'package:fehviewer/pages/gallery/view/comment_item.dart';
import 'package:fehviewer/pages/gallery/view/taginfo_dialog.dart';
import 'package:fehviewer/widget/rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    return Container(
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        // 圆角
        borderRadius: BorderRadius.circular(4),
        child: EhNetworkImage(
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
      if (imageUrl != null && imageUrl!.isNotEmpty) {
        Widget image = Container(
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
              child: EhNetworkImage(
                placeholder: (_, __) {
                  return Container(
                    alignment: Alignment.center,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey5, context),
                    child: const CupertinoActivityIndicator(),
                  );
                },
                imageUrl: (imageUrl ?? '').handleUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );

        return Container(
          width: kWidth,
          margin: const EdgeInsets.only(right: 10),
          child: Center(
            child: Hero(
              tag: heroTag,
              child: image,
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
    required this.title,
  }) : super(key: key);

  // final GalleryPageController _pageController = Get.find(tag: pageCtrlTag);
  // GalleryPageState get _pageState => _pageController.gState;

  final String title;

  @override
  Widget build(BuildContext context) {
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
      child: SelectableText(
        title,
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
        NavigatorUtil.goSearchPageWithParam(simpleSearch: 'uploader:$uploader');
      },
    );
  }
}

class ReadButton extends StatelessWidget {
  ReadButton({
    Key? key,
    required this.gid,
  }) : super(key: key);
  final String gid;

  final GalleryPageController _pageController = Get.find(tag: pageCtrlTag);
  GalleryPageState get _pageState => _pageController.gState;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => MouseRegionClick(
        child: CupertinoButton(
            child: Text(
              (_pageState.lastIndex > 0)
                  ? '${L10n.of(context).read.toUpperCase()} ${_pageState.lastIndex + 1}'
                  : L10n.of(context).read.toUpperCase(),
              style: const TextStyle(fontSize: 15, height: 1.2),
            ),
            minSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            borderRadius: BorderRadius.circular(20),
            color: CupertinoColors.activeBlue,
            onPressed: _pageState.enableRead
                ? () => _toViewPage(_pageState.galleryProvider?.gid ?? '0',
                    _pageState.lastIndex)
                : null),
      ),
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
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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

class TopCommentEx extends StatelessWidget {
  const TopCommentEx({Key? key, this.comments, this.max = 2}) : super(key: key);
  final List<GalleryComment>? comments;
  final int max;

  @override
  Widget build(BuildContext context) {
    // 显示最前面两条
    List<Widget> _topComment(List<GalleryComment>? comments, {int max = 2}) {
      final Iterable<GalleryComment> _comments = comments?.take(max) ?? [];
      return _comments
          .map((GalleryComment comment) => CommentItem(
                galleryComment: comment,
                simple: true,
              ))
          .toList();
    }

    return Column(
      children: [
        ..._topComment(comments, max: max),
        if ((comments?.length ?? 0) > max)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Icon(FontAwesomeIcons.ellipsis),
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
    return Column(
        children: listTagGroup
            .map((tagGroupData) => TagGroupItem(tagGroupData: tagGroupData))
            .toList());
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
        Get.toNamed(
          EHRoutes.galleryAllPreviews,
          id: isLayoutLarge ? 2 : null,
        );
      },
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
    List<GalleryTag> galleryTags,
    BuildContext context,
  ) {
    final EhConfigService ehConfigService = Get.find();

    return galleryTags.map((e) {
      final tag = e.setColor();
      return Obx(() => TagButton(
            text: ehConfigService.isTagTranslat ? tag.tagTranslat : tag.title,
            color: ColorsUtil.hexStringToColor(tag.backgrondColor),
            textColor: () {
              switch (tag.vote) {
                case 0:
                  return ColorsUtil.hexStringToColor(tag.color);
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
              NavigatorUtil.goSearchPageWithParam(
                  simpleSearch: '${tag.type}:${tag.title.trim()}');
            },
            onLongPress: () {
              showTagInfoDialog(
                tag.title,
                translate: tag.tagTranslat,
                type: tag.type,
                vote: tag.vote ?? 0,
              );
            },
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final EhConfigService ehConfigService = Get.find();

    final List<Widget> _tagBtnList =
        _initTagBtnList(tagGroupData.galleryTags, context);
    final String? _tagType = tagGroupData.tagType;

    logger.v('tagType $_tagType');

    final Container container = Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // tag 分类
          Container(
            padding: const EdgeInsets.only(right: 8),
            child: Obx(() => _tagType != null
                ? TagButton(
                    color: CupertinoDynamicColor.resolve(
                        ThemeColors.tagColorTagType[_tagType.trim()] ??
                            radomList<Color>(
                                ThemeColors.tagColorTagType.values),
                        context),
                    text: ehConfigService.isTagTranslat
                        ? EHConst.translateTagType[_tagType.trim()] ?? _tagType
                        : _tagType,
                  )
                : const SizedBox.shrink()),
          ),
          Expanded(
            child: Wrap(
              spacing: 4, //主轴上子控件的间距
              runSpacing: 4, //交叉轴上子控件之间的间距
              children: _tagBtnList, //要显示的子控件集合
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
    this.padding,
    this.onLongPress,
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
        // key: key,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: padding ?? const EdgeInsets.fromLTRB(6, 3, 6, 4),
          color: color ??
              CupertinoDynamicColor.resolve(ThemeColors.tagBackground, context),
          child: Column(
            children: [
              Text(
                text,
                style: TextStyle(
                  color: textColor ??
                      CupertinoDynamicColor.resolve(
                          ThemeColors.tagText, context),
                  fontSize: 13,
                  fontWeight: textColor != null ? FontWeight.w500 : null,
                  height: 1.3,
                ),
                strutStyle: const StrutStyle(height: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchHisTagButton extends StatelessWidget {
  const SearchHisTagButton({
    Key? key,
    required this.text,
    this.desc,
    this.textColor,
    this.color,
    this.onPressed,
    this.onLongPress,
    this.padding,
  }) : super(key: key);

  final String text;
  final String? desc;
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
        // key: key,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: padding ?? const EdgeInsets.fromLTRB(6, 3, 6, 4),
          color: color ??
              CupertinoDynamicColor.resolve(ThemeColors.tagBackground, context),
          child: IntrinsicWidth(
            child: Column(
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: textColor ??
                        CupertinoDynamicColor.resolve(
                            ThemeColors.tagText, context),
                    fontSize: 13,
                    fontWeight: textColor != null ? FontWeight.w500 : null,
                    height: 1.3,
                  ),
                  strutStyle: const StrutStyle(height: 1),
                ),
                if (desc != null && desc!.isNotEmpty)
                  Container(
                    height: 0.1,
                    color: ThemeColors.tagText,
                  ),
                if (desc != null && desc!.isNotEmpty)
                  Text(
                    desc!,
                    style: TextStyle(
                      color: textColor ??
                          CupertinoDynamicColor.resolve(
                              ThemeColors.tagText, context),
                      fontSize: 12,
                      height: 1.3,
                      // fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextBtn extends StatelessWidget {
  const TextBtn(this.iconData,
      {Key? key,
      this.iconSize,
      this.title,
      this.onTap,
      this.onLongPress,
      this.color,
      this.iconPadding})
      : super(key: key);
  final IconData iconData;
  final double? iconSize;
  final String? title;
  final Color? color;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? iconPadding;

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data:
          CupertinoThemeData(primaryColor: color ?? CupertinoColors.systemGrey),
      child: GestureDetector(
        // behavior: HitTestBehavior.opaque,
        child: Container(
          // padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Container(
                padding: iconPadding,
                child: MouseRegionClick(
                  disable: onTap == null && onLongPress == null,
                  child: CupertinoButton(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Icon(
                      iconData,
                      size: iconSize ?? 28,
                      // color: CupertinoColors.systemGrey3,
                    ),
                    onPressed: onTap,
                  ),
                ),
              ),
              Text(
                title ?? '',
                style: const TextStyle(fontSize: 12, height: 1),
              ),
            ],
          ),
        ),
        onLongPress: onLongPress,
      ),
    );
  }
}

// 导航栏封面小图
class NavigationBarImage extends StatelessWidget {
  const NavigationBarImage({
    Key? key,
    this.imageUrl,
    this.scrollController,
  }) : super(key: key);

  final String? imageUrl;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final double _statusBarHeight = MediaQuery.of(Get.context!).padding.top;

    Widget cover = imageUrl == null || (imageUrl?.isEmpty ?? true)
        ? const SizedBox.expand()
        : Container(
            child: CoveTinyImage(
              imgUrl: imageUrl!,
              statusBarHeight: _statusBarHeight,
            ),
          );

    return GestureDetector(
      onTap: () {
        scrollController?.animateTo(0,
            duration: const Duration(milliseconds: 500), curve: Curves.ease);
      },
      child: cover,
    );
  }
}
