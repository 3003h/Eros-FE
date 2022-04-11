import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../fehviewer.dart';

class SearchImagePage extends StatelessWidget {
  SearchImagePage({Key? key}) : super(key: key);

  // 色彩数据
  final List<Color> data = List.generate(24, (i) => Color(0xFF0000FF - 24 * i));

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Search image'),
      ),
      child: Container(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(top: 0),
              sliver: SliverPersistentHeader(
                delegate: UnitPersistentHeaderDelegate(),
                // pinned: true,
                floating: true,
              ),
            ),
            EhCupertinoSliverRefreshControl(
              onRefresh: () async {
                await 1.seconds.delay();
              },
            ),
            _buildSliverList(),
          ],
        ),
      ),
    );
  }

  // 构建颜色列表
  Widget _buildSliverList() => SliverList(
        delegate: SliverChildBuilderDelegate(
            (_, int index) => _buildColorItem(data[index]),
            childCount: data.length),
      );

  // 构建颜色列表item
  Widget _buildColorItem(Color color) => Card(
        child: Container(
          alignment: Alignment.center,
          width: 100,
          height: 60,
          color: color,
          child: Text(
            colorString(color),
            style: const TextStyle(color: Colors.white, shadows: [
              Shadow(color: Colors.black, offset: Offset(.5, .5), blurRadius: 2)
            ]),
          ),
        ),
      );

  // 颜色转换为文字
  String colorString(Color color) =>
      "#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}";
}

class UnitPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    print(
        '=====shrinkOffset:$shrinkOffset======overlapsContent:$overlapsContent====');
    final String info = 'shrinkOffset:${shrinkOffset.toStringAsFixed(1)}'
        '\noverlapsContent:$overlapsContent';

    final paddingTop = context.mediaQueryPadding.top;

    return Container(
      alignment: Alignment.center,
      color: Colors.orangeAccent,
      margin: EdgeInsets.only(top: paddingTop),
      child: Row(
        children: [
          // CupertinoNavigationBar(
          //   middle: Text('Search image'),
          // ),
          Text(
            info,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 200;

  @override
  double get minExtent => 200;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
