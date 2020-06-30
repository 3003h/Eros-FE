import 'package:FEhViewer/values/const.dart';
import 'package:flutter/cupertino.dart';

class GalleryDetailPage extends StatefulWidget {
  GalleryDetailPage({Key key}) : super(key: key);

  @override
  _GalleryDetailPageState createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildGalletyHead(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalletyHead() {
    return Container(
      margin: const EdgeInsets.all(12),
      height: 200,
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 8),
            color: CupertinoColors.systemGrey6,
            width: 130,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标",
                  maxLines: 3,
                  textAlign: TextAlign.left, // 对齐方式
                  overflow: TextOverflow.ellipsis, // 超出部分省略号
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      fontFamilyFallback: [EHConst.FONT_FAMILY]),
                ),
                Text(
                  "上传者上传者上传者",
                  maxLines: 1,
                  textAlign: TextAlign.left, // 对齐方式
                  overflow: TextOverflow.ellipsis, // 超出部分省略号
                  style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                      fontFamilyFallback: [EHConst.FONT_FAMILY]),
                ),
                // Spacer()
              ],
            ),
          )
        ],
      ),
    );
  }
}
