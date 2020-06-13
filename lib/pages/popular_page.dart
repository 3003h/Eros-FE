import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PopularListTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PopularListTab();
  }
}

class _PopularListTab extends State<PopularListTab> {
  String _title = "当前热门";

  @override
  Widget build(BuildContext context) {
//    return CupertinoPageScaffold(
//        navigationBar: CupertinoNavigationBar(
//          middle: Text(_title),
//          previousPageTitle: _title,
//        ),
//        child: Center(
//            child: SingleChildScrollView(
//          child: Column(children: <Widget>[
//            CupertinoButton(
////              color: CupertinoColors.activeBlue,
//              child: Text('TAG更新'),
//              onPressed: () {
//                NavigatorUtil.goHttpTestPage(context);
//              },
//            )
//          ]),
//        )));

    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(largeTitle: Text(_title)),
        SliverSafeArea(
          top: false,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < 1) {
                  return GestureDetector(
                    child: Text("$index"),
                    onTap: () {},
                  );
                }
                return null;
              },
            ),
          ),
        )
      ],
    );
  }
}
