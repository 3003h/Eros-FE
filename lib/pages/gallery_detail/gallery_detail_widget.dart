import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'comment_item.dart';
import 'gallery_all_preview_page.dart';
import 'gallery_preview_clipper.dart';

const double kHeightPreview = 180.0;
const double kPadding = 12.0;

/// 内容
class GalleryDetailInfo extends StatelessWidget {
  const GalleryDetailInfo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final S ln = S.of(context);
    return Container(
      child: Column(
        children: <Widget>[
          // 标签
          _buildTagBox(),
          _buildTopComment(),
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 0.5,
            color: CupertinoColors.systemGrey4,
          ),
          _buildPreviewGrid(),
          CupertinoButton(
            minSize: 0,
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 30),
            child: Text(
              ln.all_preview,
              style: const TextStyle(fontSize: 16),
            ),
            onPressed: () {
              final GalleryModel galleryModel =
                  Provider.of<GalleryModel>(context, listen: false);
              Navigator.push(context,
                  CupertinoPageRoute(builder: (BuildContext context) {
                return ChangeNotifierProvider<GalleryModel>.value(
                  value: galleryModel,
                  child: const AllPreviewPage(),
                );
              }));
            },
          ),
        ],
      ),
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

    return Selector<GalleryModel, List<GalleryComment>>(
        shouldRebuild: (pre, next) => false, // 不进行重绘
        selector: (context, galleryModel) =>
            galleryModel.galleryItem.galleryComment,
//        shouldRebuild: (pre, next) => pre != next,
        builder: (context, comment, child) {
          final S ln = S.of(context);
          return Column(
            children: <Widget>[
              // 评论
              ..._topComment(comment, max: 2),
              // 评论按钮
              CupertinoButton(
                minSize: 0,
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Text(
                  ln.all_comment,
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  NavigatorUtil.goGalleryDetailComment(context, comment);
                },
              ),
            ],
          );
        });
  }

  Widget _buildPreviewGrid() {
    return Selector<GalleryModel, List<GalleryPreview>>(
        shouldRebuild: (pre, next) => false, // 不进行重绘
        selector: (context, galleryModel) => galleryModel.oriGalleryPreview,
        builder: (context, List<GalleryPreview> previews, child) {
          return Container(
            padding: const EdgeInsets.only(
                top: kPadding, right: kPadding, left: kPadding),
            child: GridView.builder(
                shrinkWrap: true, //解决无限高度问题
                physics: const NeverScrollableScrollPhysics(), //禁用滑动事件
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//              crossAxisCount: _crossAxisCount, //每行列数
                    maxCrossAxisExtent: 130,
                    mainAxisSpacing: 0, //主轴方向的间距
                    crossAxisSpacing: 10, //交叉轴方向子元素的间距
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
                }),
          );
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
  final List images = [];

  @override
  Widget build(BuildContext context) {
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile?.user?.cookie ?? '',
    };
    Widget _buildImage() {
      if (galleryPreview.isLarge ?? false) {
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
                    offset: galleryPreview.offSet as double,
                    height: galleryPreview.height as double,
                    width: galleryPreview.width as double,
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
        NavigatorUtil.goGalleryViewPagePr(context, index);
      },
      child: Container(
        margin: const EdgeInsets.all(2.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    height: kHeightPreview,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4), //圆角
                        // ignore: prefer_const_literals_to_create_immutables
                        boxShadow: [
                          //阴影
                          const BoxShadow(
                            color: CupertinoColors.systemGrey2,
                            blurRadius: 2.0,
                          )
                        ]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        color: CupertinoColors.white,
                        child: _buildImage(),
                      ),
                    ),
                  ),
                  // 直接使用Card实现的方式，缺点 阴影方向好像是固定的
                  /*Card(
                    margin: const EdgeInsets.all(0),
                    elevation: 2,
                    color: CupertinoColors.white,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _buildImage()),
                  ),*/
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${galleryPreview.ser ?? ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
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
    this.color,
    VoidCallback onPressed,
  }) : _onPressed = onPressed;

  final String text;
  final Color color;
  final VoidCallback _onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1,
        ),
        strutStyle: const StrutStyle(height: 1),
      ),
      minSize: 0,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      borderRadius: BorderRadius.circular(50),
      color: color,
      onPressed: _onPressed,
      disabledColor: Colors.blueGrey,
    );
  }
}

class TagButtonB extends StatelessWidget {
  const TagButtonB({
    @required this.text,
    Color textColor,
    Color color,
    VoidCallback onPressed,
  })  : textColor = textColor ?? const Color(0xff505050),
        color = color ?? const Color(0xffeeeeee),
        _onPressed = onPressed;

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
          color: color,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
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
Widget _buildTagBox() {
  return Selector<GalleryModel, List<TagGroup>>(
      selector: (context, galleryModel) => galleryModel.galleryItem.tagGroup,
      builder: (context, List<TagGroup> listTagGroup, child) {
        final List<Widget> listGroupWidget = [];
        for (final TagGroup tagGroupData in listTagGroup) {
          listGroupWidget.add(TagGroupItem(tagGroupData: tagGroupData));
        }

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(
                  kPadding, kPadding / 2, kPadding, kPadding / 2),
              child: Column(children: listGroupWidget),
            ),
            Container(
              height: 0.5,
              color: CupertinoColors.systemGrey4,
            ),
          ],
        );
      });
}

/// 封面小图
class CoveTinyImage extends StatelessWidget {
  const CoveTinyImage({Key key, this.imgUrl, double statusBarHeight})
      : statusBarHeight = statusBarHeight,
        super(key: key);

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

  final tagGroupData;

  _initTagBtnList(galleryTags, context) {
    final _isTagTranslat = Global.profile.ehConfig.tagTranslat;
    List<Widget> _tagBtnList = [];
    galleryTags.forEach((tag) {
      _tagBtnList.add(TagButtonB(
        text: _isTagTranslat ? tag?.tagTranslat ?? '' : tag?.title ?? '',
        onPressed: () {
          Global.logger.v('search type[${tag.type}] tag[${tag.title}]');
          NavigatorUtil.goGalleryList(context,
              simpleSearch: '${tag.type}:${tag.title}');
        },
      ));
    });
    return _tagBtnList;
  }

  @override
  Widget build(BuildContext context) {
    final bool _isTagTranslat = Global.profile.ehConfig.tagTranslat;

    final _tagBtnList = _initTagBtnList(tagGroupData.galleryTags, context);
    final _tagType = tagGroupData.tagType;

    final Container container = Container(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // tag 分类
          Container(
            padding: const EdgeInsets.only(right: 8),
            child: TagButtonB(
              color: EHConst.tagColorTagType[_tagType.trim()],
              text: _isTagTranslat
                  ? EHConst.translateTagType[_tagType.trim()] ?? _tagType
                  : _tagType,
            ),
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
