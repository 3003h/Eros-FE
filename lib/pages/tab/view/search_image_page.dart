import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
            SliverPersistentHeader(
              delegate: ImagePersistentHeaderDelegate(),
              // pinned: true,
              floating: true,
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

class ImagePersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // print(
    //     '=====shrinkOffset:$shrinkOffset======overlapsContent:$overlapsContent====');
    final String info = 'shrinkOffset:${shrinkOffset.toStringAsFixed(1)}'
        '\noverlapsContent:$overlapsContent';

    final paddingTop = context.mediaQueryPadding.top;

    return Container(
      // alignment: Alignment.center,
      // color: Colors.transparent,
      padding: EdgeInsets.only(top: paddingTop),
      child: Row(
        children: [
          // CupertinoNavigationBar(
          //   middle: Text('Search image'),
          // ),
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.all(0.0),
              onPressed: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: CupertinoColors.systemGrey3,
                ),
                margin: const EdgeInsets.all(8.0),
                // color: CupertinoColors.systemGrey3,
                child: Center(
                  child: Icon(
                    FontAwesomeIcons.circlePlus,
                    // color: CupertinoColors.systemGrey2,
                    color: CupertinoTheme.of(context).barBackgroundColor,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          // Container(
          //   width: 80,
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(8.0),
          //     color: CupertinoColors.activeBlue,
          //   ),
          //   margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
          //   // color: CupertinoColors.systemGrey3,
          //   child: Center(
          //     child: Icon(
          //       FontAwesomeIcons.magnifyingGlass,
          //       color: CupertinoTheme.of(context).barBackgroundColor,
          //       size: 40,
          //     ),
          //   ),
          // ),
          CupertinoButton(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: CupertinoColors.activeBlue,
              ),
              margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              // color: CupertinoColors.systemGrey3,
              child: Center(
                child: Icon(
                  FontAwesomeIcons.magnifyingGlass,
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  size: 40,
                ),
              ),
            ),
            onPressed: () {},
          ),
        ],
      ).frosted(
        blur: 8,
        frostColor:
            CupertinoTheme.of(context).barBackgroundColor.withOpacity(1),
        frostOpacity: 0.55,
      ),
    );
  }

  @override
  double get maxExtent => 300;

  @override
  double get minExtent => 200;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
