import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_main/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/network/gallery_request.dart';
import 'package:fehviewer/values/const.dart';
import 'package:fehviewer/values/theme_colors.dart';
import 'package:fehviewer/widget/rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'comment_item.dart';
import 'gallery_all_preview_page.dart';
import 'gallery_favcat.dart';
import 'gallery_preview_clipper.dart';

const double kHeightPreview = 180.0;
const double kPadding = 12.0;

const double kHeaderHeight = 200.0;
const double kHeaderPaddingTop = 12.0;

/// 内容
class GalleryDetailInfo extends StatelessWidget {
  GalleryDetailInfo({Key key}) : super(key: key);

  final GalleryItemController _galleryItemController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
//        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // 标签
          TagBox(),
          _buildTopComment(),
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 0.5,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey4, context),
          ),
          _buildPreviewGrid(),
          _buildAllPreviewButton(context),
        ],
      ),
    );
  }

  CupertinoButton _buildAllPreviewButton(BuildContext context) {
    // final GalleryModel galleryModel =
    //     Provider.of<GalleryModel>(context, listen: false);

    final bool hasMorePreview =
        int.parse(_galleryItemController?.galleryItem?.filecount ?? '0') >
            _galleryItemController.firstPagePreview.length;
    return CupertinoButton(
      minSize: 0,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 30),
      child: Text(
        hasMorePreview
            ? S.of(context).morePreviews
            : S.of(context).noMorePreviews,
        style: const TextStyle(fontSize: 16),
      ),
      onPressed: () {
/*        Get.to(
          ChangeNotifierProvider<GalleryModel>.value(
            value: galleryModel,
            child: const AllPreviewPage(),
          ),
          preventDuplicates: false,
        );*/
        Get.to(const AllPreviewPage());
      },
    );
  }

  Widget _buildTopComment() {
    // 显示最前面两条
    List<Widget> _topComment(List<GalleryComment> comments, {int max = 2}) {
      final Iterable<GalleryComment> _comments = comments.take(max);
      return List<Widget>.from(_comments
          .map((GalleryComment comment) => CommentItem(
                galleryComment: comment,
                simple: true,
              ))
          .toList());
    }

    return Builder(builder: (_) {
      final List<GalleryComment> comment =
          _galleryItemController.galleryItem.galleryComment;
      return Column(
        children: <Widget>[
          // 评论
          GestureDetector(
            onTap: () => NavigatorUtil.goGalleryDetailComment(comment),
            child: Column(
              children: <Widget>[
                ..._topComment(comment, max: 2),
              ],
            ),
          ),
          // 评论按钮
          CupertinoButton(
            minSize: 0,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text(
              S.of(Get.context).all_comment,
              style: const TextStyle(fontSize: 16),
            ),
            onPressed: () {
              NavigatorUtil.goGalleryDetailComment(comment);
            },
          ),
        ],
      );
    });
  }

  Widget _buildPreviewGrid() {
    return Builder(builder: (_) {
      final List<GalleryPreview> previews =
          _galleryItemController.firstPagePreview;
      return GridView.builder(
          padding: const EdgeInsets.only(
              top: kPadding, right: kPadding, left: kPadding),
          shrinkWrap: true,
          //解决无限高度问题
          physics: const NeverScrollableScrollPhysics(),
          //禁用滑动事件
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//              crossAxisCount: _crossAxisCount, //每行列数
              maxCrossAxisExtent: 130,
              mainAxisSpacing: 0, //主轴方向的间距
              crossAxisSpacing: 4, //交叉轴方向子元素的间距
              childAspectRatio: 0.55 //显示区域宽高
              ),
          itemCount: previews.length,
          itemBuilder: (context, index) {
            return Center(
              child: PreviewContainer(
                galleryPreviewList: previews,
                index: index,
              ),
            );
          });
    });
  }
}

class PreviewContainer extends StatelessWidget {
  PreviewContainer({
    Key key,
    @required this.index,
    @required this.galleryPreviewList,
  })  : galleryPreview = galleryPreviewList[index],
        hrefs = List<String>.from(
            galleryPreviewList.map((GalleryPreview e) => e.href).toList()),
        super(key: key);

  final int index;
  final List<GalleryPreview> galleryPreviewList;
  final List<String> hrefs;
  final GalleryPreview galleryPreview;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile?.user?.cookie ?? '',
    };
    Widget _buildImage() {
      if (galleryPreview.isLarge ?? false) {
        // 缩略大图
        return CachedNetworkImage(
          httpHeaders: _httpHeaders,
          imageUrl: galleryPreview.imgUrl,
        );
      } else {
        return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          double _subHeight;
          double _subWidth;
          final double _subHeightP = galleryPreview.height *
              constraints.maxWidth /
              galleryPreview.width;
          if (_subHeightP > kHeightPreview) {
            _subHeight = kHeightPreview;
            _subWidth =
                kHeightPreview * galleryPreview.width / galleryPreview.height;
          } else {
            _subWidth = constraints.maxWidth;
            _subHeight = _subHeightP;
          }
          return Container(
            height: _subHeight,
            width: _subWidth,
            // 缩略小图
            child: Stack(
              alignment: AlignmentDirectional.center,
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  child: PreviewImageClipper(
                    imgUrl: galleryPreview.imgUrl,
                    offset: galleryPreview.offSet,
                    height: galleryPreview.height,
                    width: galleryPreview.width,
                  ),
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
        NavigatorUtil.goGalleryViewPage(index);
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
                '${galleryPreview.ser ?? ''}',
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

/// 标签按钮
/// onPressed 回调
class TagButton extends StatelessWidget {
  const TagButton({
    @required this.text,
    this.textColor,
    this.color,
    VoidCallback onPressed,
  }) : _onPressed = onPressed;

  final String text;
  final Color textColor;
  final Color color;
  final VoidCallback _onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 3, 6, 4),
          color: color ??
              CupertinoDynamicColor.resolve(ThemeColors.tagBackground, context),
          child: Text(
            text,
            style: TextStyle(
              color: textColor ??
                  CupertinoDynamicColor.resolve(ThemeColors.tagText, context),
              fontSize: 13,
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

/// 包含多个 TagGroup
class TagBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GalleryItemController _galleryItemController = Get.find();
    final List<TagGroup> listTagGroup =
        _galleryItemController.galleryItem.tagGroup;
    final List<Widget> listGroupWidget = <Widget>[];
    for (final TagGroup tagGroupData in listTagGroup) {
      listGroupWidget.add(TagGroupItem(tagGroupData: tagGroupData));
    }

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(
              kPadding, kPadding / 2, kPadding, kPadding / 2),
          child: Column(children: listGroupWidget),
        ),
        Container(
          height: 0.5,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey4, Get.context),
        ),
      ],
    );
  }
}

/// 封面小图
class CoveTinyImage extends StatelessWidget {
  const CoveTinyImage({Key key, this.imgUrl, this.statusBarHeight})
      : super(key: key);

  final String imgUrl;
  final double statusBarHeight;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile?.user?.cookie ?? '',
    };
    return Container(
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        // 圆角
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          httpHeaders: _httpHeaders,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          imageUrl: imgUrl,
        ),
      ),
    );
  }
}

/// 一个标签组 第一个是类型
class TagGroupItem extends StatelessWidget {
  const TagGroupItem({
    @required this.tagGroupData,
  });

  final TagGroup tagGroupData;

  List<Widget> _initTagBtnList(galleryTags, context) {
    final EhConfigService ehConfigController = Get.find();
    final List<Widget> _tagBtnList = <Widget>[];
    galleryTags.forEach((tag) {
      _tagBtnList.add(
        Obx(() => TagButton(
              text: ehConfigController.isTagTranslat.value
                  ? tag?.tagTranslat ?? ''
                  : tag?.title ?? '',
              onPressed: () {
                logger.v('search type[${tag.type}] tag[${tag.title}]');
                NavigatorUtil.goGalleryListBySearch(
                    simpleSearch: '${tag.type}:${tag.title}');
              },
            )),
      );
    });
    return _tagBtnList;
  }

  @override
  Widget build(BuildContext context) {
    final EhConfigService ehConfigController = Get.find();

    final List<Widget> _tagBtnList =
        _initTagBtnList(tagGroupData.galleryTags, context);
    final String _tagType = tagGroupData.tagType;

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
                      ThemeColors.tagColorTagType[_tagType.trim()], context),
                  text: ehConfigController.isTagTranslat.value
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

class GalleryHeader extends StatelessWidget {
  const GalleryHeader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(kPadding),
      child: Column(
        children: <Widget>[
          Container(
            height: kHeaderHeight,
            child: Row(
              children: <Widget>[
                // 封面
                const CoverImage(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 标题
                      const GalleryTitle(),
                      // 上传用户
                      const GalleryUploader(),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const <Widget>[
                          // 阅读按钮
                          ReadButton(),
                          Spacer(),
                          // 收藏按钮
                          GalleryFavButton(),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              // ignore: prefer_const_literals_to_create_immutables
              children: <Widget>[
                // 评分
                const GalleryRating(),
                const Spacer(),
                // 类型
                const GalleryCategory(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// 封面
class CoverImage extends StatelessWidget {
  const CoverImage({
    Key key,
  }) : super(key: key);

  static const double kWidth = 145.0;

  @override
  Widget build(BuildContext context) {
    final GalleryItemController _galleryItemController = Get.find();
    return Builder(builder: (_) {
      final String _imageUrl = _galleryItemController.galleryItem.imgUrl;
      // final dynamic _tabIndex = _galleryItemController.tabIndex;
      final _tabIndex = '';
      final GalleryItem _item = _galleryItemController.galleryItem;

      final Map<String, String> _httpHeaders = {
        'Cookie': Global.profile?.user?.cookie ?? '',
      };

      if (_imageUrl != null && _imageUrl.isNotEmpty) {
        return Container(
          width: kWidth,
          margin: const EdgeInsets.only(right: 10),
          child: Center(
            child: Hero(
              tag: '${_item.gid}_${_item.token}_cover_$_tabIndex',
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
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: _item.imgHeight,
                    width: _item.imgWidth,
                    color: CupertinoColors.systemBackground,
                    child: CachedNetworkImage(
                      placeholder: (_, __) {
                        return Container(
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.systemGrey5, context),
                        );
                      },
                      imageUrl: _imageUrl,
                      fit: BoxFit.cover,
                      httpHeaders: _httpHeaders,
                    ),
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

class ReadButton extends StatelessWidget {
  const ReadButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final GalleryModel _galleryModel =
    //     Provider.of<GalleryModel>(context, listen: false);
    final GalleryItemController _galleryItemController = Get.find();
    return Builder(builder: (_) {
      return CupertinoButton(
          child: Text(
            S.of(context).READ,
            style: const TextStyle(fontSize: 15),
          ),
          minSize: 20,
          padding: const EdgeInsets.fromLTRB(15, 2.5, 15, 2.5),
          borderRadius: BorderRadius.circular(50),
          color: CupertinoColors.activeBlue,
          onPressed: _galleryItemController.firstPagePreview.isNotEmpty
              ? () async {
                  final GalleryCacheController galleryCacheController =
                      Get.find();
                  final GalleryCache _galleryCache = galleryCacheController
                      .getGalleryCache(_galleryItemController.galleryItem.gid);
                  final int _index = _galleryCache?.lastIndex ?? 0;
                  logger.d('lastIndex $_index');
                  await showLoadingDialog(context, _index);
                  NavigatorUtil.goGalleryViewPage(_index);
                }
              : null);
    });
  }
}

/// 类别 点击可跳转搜索
class GalleryCategory extends StatelessWidget {
  const GalleryCategory({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GalleryItemController _galleryItemController = Get.find();
    return Builder(builder: (_) {
      final String category = _galleryItemController.galleryItem.category;
      final Color _colorCategory = CupertinoDynamicColor.resolve(
          ThemeColors.catColor[category ?? 'default'], context);

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
          final int iCat = EHConst.cats[category];
          final int cats = EHConst.sumCats - iCat;
          NavigatorUtil.goGalleryList(cats: cats);
        },
      );
    });
  }
}

class GalleryRating extends StatelessWidget {
  const GalleryRating({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GalleryItemController _galleryItemController = Get.find();
    return Builder(builder: (_) {
      double rating = _galleryItemController.galleryItem.rating;
      return Row(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.only(right: 8), child: Text('$rating')),
          // 星星
          StaticRatingBar(
            size: 18.0,
            rate: rating,
            radiusRatio: 1.5,
          ),
        ],
      );
    });
  }
}

/// 上传用户
class GalleryUploader extends StatelessWidget {
  const GalleryUploader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GalleryItemController _galleryItemController = Get.find();
    return Builder(builder: (_) {
      final String uploader = _galleryItemController.galleryItem.uploader;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.only(top: 8, right: 8, bottom: 4),
          child: Text(
            uploader ?? '',
            maxLines: 1,
            textAlign: TextAlign.left, // 对齐方式
            overflow: TextOverflow.ellipsis, // 超出部分省略号
            style: const TextStyle(
              fontSize: 13,
              color: Colors.brown,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () {
          logger.v('search uploader:$uploader');
          // NavigatorUtil.goGalleryList(context,
          //     simpleSearch: 'uploader:$uploader');
          NavigatorUtil.goGalleryListBySearch(
              simpleSearch: 'uploader:$uploader');
        },
      );
    });
  }
}

/// 标题
class GalleryTitle extends StatelessWidget {
  const GalleryTitle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GalleryItemController _galleryItemController = Get.find();
    final EhConfigService _ehConfigController = Get.find();

    /// 构建标题
    /// [EhConfigModel] eh设置的state 控制显示日文还是英文标题
    /// [GalleryModel] 画廊数据
    ///
    /// 问题 文字如果使用 SelectableText 并且页面拉到比较下方的时候
    /// 在返回列表时会异常 疑似和封面图片的Hero动画有关
    /// 如果修改封面图片的 Hero tag ,即不使用 Hero 动画
    /// 异常则不会出现
    ///
    /// 暂时放弃使用 SelectableText
    return Builder(
      builder: (_) {
        final GalleryItem galleryItem = _galleryItemController.galleryItem;
        final String _titleEn = galleryItem?.englishTitle ?? '';
        final String _titleJpn = galleryItem?.japaneseTitle ?? '';

        return GestureDetector(
          child: Obx(() => Text(
                _ehConfigController.isJpnTitle.value &&
                        _titleJpn != null &&
                        _titleJpn.isNotEmpty
                    ? _titleJpn
                    : _titleEn,
                maxLines: 5,
                textAlign: TextAlign.left, // 对齐方式
                overflow: TextOverflow.ellipsis, // 超出部分省略号
                style: const TextStyle(
                  textBaseline: TextBaseline.alphabetic,
                  height: 1.2,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
//            backgroundColor: CupertinoColors.systemGrey3,
//            fontFamilyFallback: EHConst.FONT_FAMILY_FB,
                ),
              )),
        );

        /*return cust.SelectableText(
          title,
          maxLines: 5,
          minLines: 1,
          textAlign: TextAlign.left, // 对齐方式
//          overflow: TextOverflow.ellipsis, // 超出部分省略号
          style: TextStyle(
            textBaseline: TextBaseline.alphabetic,
            height: 1.2,
            fontSize: 16,
            fontWeight: FontWeight.w500,
//            backgroundColor: CupertinoColors.systemGrey3,
//            fontFamilyFallback: EHConst.FONT_FAMILY_FB,
          ),
          scrollPhysics: ClampingScrollPhysics(),
        );*/
      },
    );
  }
}

/// 显示等待
Future<void> showLoadingDialog(BuildContext context, int index) async {
  final GalleryPageController _galleryPageController = Get.find();

  /// 加载下一页缩略图
  Future<void> _loarMordPriview({CancelToken cancelToken}) async {
    final List<GalleryPreview> _galleryPreviewList =
        _galleryPageController.galleryItem.galleryPreview;
    //

    // 增加延时 避免build期间进行 setState
    // await Future<void>.delayed(const Duration(milliseconds: 0));
    // _galleryPageController.currentPreviewPageAdd();
    // logger.v(
    //     '获取更多预览 ${_galleryPageController.galleryItem.url} : ${_galleryPageController.currentPreviewPage}');

    final List<GalleryPreview> _moreGalleryPreviewList =
        await Api.getGalleryPreview(
      _galleryPageController.galleryItem.url,
      // page: _galleryPageController.currentPreviewPage,
      page: 0,
      cancelToken: cancelToken,
    );

    _galleryPreviewList.addAll(_moreGalleryPreviewList);
  }

  Future<bool> _loadPriview(int index) async {
    final List<GalleryPreview> _galleryPreviewList =
        _galleryPageController.galleryItem.galleryPreview;

    while (index > _galleryPreviewList.length - 1) {
      logger.d(' index = $index ; len = ${_galleryPreviewList.length}');
      await _loarMordPriview();
    }
    return true;
  }

  return showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) {
      Future<void>.delayed(const Duration(milliseconds: 0))
          .then((_) => _loadPriview(index))
          .whenComplete(() => Get.back());
      return CupertinoAlertDialog(
        content: Container(
            width: 40,
            child: const CupertinoActivityIndicator(
              radius: 30,
            )),
        actions: const <Widget>[],
      );
    },
  );
}
