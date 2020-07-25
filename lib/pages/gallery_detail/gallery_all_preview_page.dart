import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:flutter/cupertino.dart';

import 'gallery_detail_widget.dart';

class AllPreviewPage extends StatefulWidget {
  final List<GalleryPreview> galleryPreviewList;
  final showKey;

  const AllPreviewPage(
      {Key key, @required this.galleryPreviewList, @required this.showKey})
      : super(key: key);

  @override
  _AllPreviewPageState createState() => _AllPreviewPageState();
}

class _AllPreviewPageState extends State<AllPreviewPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
//    final _crossAxisCount = width ~/ 120;

    var ln = S.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(ln.all_preview),
      ),
      child: SafeArea(
//        top: false,
        bottom: false,
        child: Container(
          padding: const EdgeInsets.all(4),
          child: GridView.builder(
              shrinkWrap: true, //解决无限高度问题
//              physics: NeverScrollableScrollPhysics(), //禁用滑动事件
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 135.0,
                  mainAxisSpacing: 0, //主轴方向的间距
                  crossAxisSpacing: 4, //交叉轴方向子元素的间距
                  childAspectRatio: 0.595 //显示区域宽高
                  ),
              itemCount: widget.galleryPreviewList.length,
              itemBuilder: (context, index) {
                return Center(
                  child: PreviewContainer(
                    galleryPreviewList: widget.galleryPreviewList,
                    index: index,
                    showKey: widget.showKey,
                  ),
                );
              }),
        ),
      ),
    );
  }
}
