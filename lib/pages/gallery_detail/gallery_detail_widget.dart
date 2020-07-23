import 'package:FEhViewer/client/parser/gallery_view_parser.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'comment_item.dart';
import 'gallery_preview_clipper.dart';

const heightPreview = 180.0;

/// 内容
class GalleryDetailContex extends StatelessWidget {
  const GalleryDetailContex({
    Key key,
    @required List<Widget> lisTagGroupW,
    @required GalleryItem galleryItem,
  })  : _lisTagGroupW = lisTagGroupW,
        _galleryItem = galleryItem,
        super(key: key);

  final List<Widget> _lisTagGroupW;
  final GalleryItem _galleryItem;

  List<Widget> _topComment(List<GalleryComment> comments, {int max = 2}) {
    var _comments = comments.take(max);
    return List<Widget>.from(_comments
        .map((comment) => CommentItem(
              galleryComment: comment,
              simple: true,
            ))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);
    return Container(
      child: Column(
        children: <Widget>[
          // 标签
          TagBox(
            lisTagGroup: _lisTagGroupW,
          ),
          ..._topComment(_galleryItem.galleryComment, max: 2),
          // 评论按钮
          CupertinoButton(
            minSize: 0,
            padding: const EdgeInsets.fromLTRB(4, 4, 0, 0),
            child: Text(
              ln.all_comment,
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              NavigatorUtil.goGalleryDetailComment(
                  context, _galleryItem.galleryComment);
            },
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 0.5,
            color: CupertinoColors.systemGrey4,
          ),
          PreviewBoxGrid(
            galleryPreviewList: _galleryItem.galleryPreview,
            showKey: _galleryItem.showKey,
          ),
        ],
      ),
    );
  }
}

class PreviewBoxGrid extends StatelessWidget {
  final List<GalleryPreview> galleryPreviewList;
  final showKey;

  const PreviewBoxGrid(
      {Key key, @required this.galleryPreviewList, @required this.showKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final _crossAxisCount = width ~/ 120;

//    Global.logger.v('${width}');

    return Container(
      padding: const EdgeInsets.only(top: 20, right: 10, left: 10),
      child: GridView.builder(
          shrinkWrap: true, //解决无限高度问题
          physics: NeverScrollableScrollPhysics(), //禁用滑动事件
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCount, //每行列数
              mainAxisSpacing: 0, //主轴方向的间距
              crossAxisSpacing: 10, //交叉轴方向子元素的间距
              childAspectRatio: 0.55 //显示区域宽高
              ),
          itemCount: galleryPreviewList.length,
          itemBuilder: (context, index) {
            return Center(
              child: PreviewContainer(
                galleryPreviewList: galleryPreviewList,
                index: index,
                showKey: showKey,
              ),
            );
          }),
    );
  }
}

class PreviewContainer extends StatelessWidget {
  final int index;
  final List<GalleryPreview> galleryPreviewList;
  final List<String> hrefs;
  final GalleryPreview galleryPreview;
  final showKey;

  PreviewContainer(
      {Key key,
      @required this.index,
      @required this.galleryPreviewList,
      @required this.showKey})
      : galleryPreview = galleryPreviewList[index],
        hrefs =
            List<String>.from(galleryPreviewList.map((e) => e.href).toList()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var _httpHeaders = {
      "Cookie": Global.profile?.token ?? '',
    };
    var image = galleryPreview.isLarge ?? false
        ? Container(
            child: CachedNetworkImage(
              httpHeaders: _httpHeaders,
              height: heightPreview,
              imageUrl: galleryPreview.imgUrl,
            ),
          )
        : Container(
            child: PreviewImageClipper(
              imgUrl: galleryPreview.imgUrl,
              offset: galleryPreview.offSet,
              height: galleryPreview.height,
              width: galleryPreview.width,
            ),
          );

    return GestureDetector(
      onTap: () async {
        hrefs[index] =
            await GalleryViewParser.getShowInfo(hrefs[index], showKey);
        NavigatorUtil.goGalleryViewPage(context, hrefs, index);
      },
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
                //阴影
//            boxShadow: [
//              BoxShadow(
//                color: CupertinoColors.systemGrey,
//                offset: Offset(0.0, 0.0),
//                blurRadius: 4.0,
//              ),
//            ],
                ),
            child: Container(
              child: image,
            ),
          ),
          Container(
//            padding: const EdgeInsets.only(top: 0),
            child: Text(
              '${galleryPreview.ser ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 标签按钮
/// onPressed 回调
class TagButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback _onPressed;

  const TagButton({
    @required this.text,
    color,
    VoidCallback onPressed,
  })  : this.color = color ?? Colors.teal,
        _onPressed = onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1,
        ),
        strutStyle: StrutStyle(height: 1),
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
  final String text;
  final Color textColor;
  final Color color;
  final VoidCallback _onPressed;

  const TagButtonB({
    @required this.text,
    textColor,
    color,
    VoidCallback onPressed,
  })  : this.textColor = textColor ?? const Color(0xff505050),
        this.color = color ?? const Color(0xffeeeeee),
        _onPressed = onPressed;

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
            strutStyle: StrutStyle(height: 1),
          ),
        ),
      ),
    );
  }
}

/// 包含多个 TagGroup
class TagBox extends StatelessWidget {
  final List<Widget> lisTagGroup;

  const TagBox({Key key, this.lisTagGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(children: lisTagGroup),
        ),
        Container(
          height: 0.5,
          color: CupertinoColors.systemGrey4,
        ),
      ],
    );
  }
}

/// 封面小图
class CoveTinyImage extends StatelessWidget {
  final String imgUrl;
  final double statusBarHeight;

  const CoveTinyImage({Key key, this.imgUrl, double statusBarHeight})
      : statusBarHeight = statusBarHeight,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var _httpHeaders = {
      "Cookie": Global.profile?.token ?? '',
    };
    return Container(
      padding: EdgeInsets.all(4),
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
  TagGroupItem({
    @required this.tagGroupData,
  });

  final tagGroupData;

  static initTagBtnList(galleryTags) {
    final _isTagTranslat = Global.profile.ehConfig.tagTranslat;
    List<Widget> _tagBtnList = [];
    galleryTags.forEach((tag) {
      _tagBtnList.add(TagButtonB(
        text: _isTagTranslat ? tag?.tagTranslat ?? '' : tag?.title ?? '',
        onPressed: () {
          Global.logger.v('search type[${tag.type}] tag[${tag.title}]');
        },
      ));
    });
    return _tagBtnList;
  }

  @override
  Widget build(BuildContext context) {
    final _isTagTranslat = Global.profile.ehConfig.tagTranslat;
    final _tagBtnList = initTagBtnList(tagGroupData.galleryTags);
    final _tagType = tagGroupData.tagType;

    Container container = Container(
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
