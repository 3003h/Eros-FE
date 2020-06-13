import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/icon.dart';
import 'package:FEhViewer/route/routes.dart';

class FavoriteTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FavoriteTab();
  }
}

class _FavoriteTab extends State<FavoriteTab> {
  String _title = "All Favorites";

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text(_title),
          trailing: GestureDetector(
            onTap: () {
              debugPrint('add icon tapped');
              NavigatorUtil.jump(context, EHRoutes.selFavorie);
            },
            child: Icon(
              EHCupertinoIcons.menu,
            ),
          ),
        ),
        SliverSafeArea(
          top: false,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < 100) {
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

class SelFavorite extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SelFavorite();
}

/// 收藏夹选择页面
class _SelFavorite extends State<SelFavorite> {
  String _title = "收藏夹";
  Color _color;

  @override
  Widget build(BuildContext context) {
    CupertinoPageScaffold sca = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_title),
        ),
        child: SafeArea(
          child: ListViewFavorite(),
        ));

    return sca;
  }
}

class ListViewFavorite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 11,
//      itemExtent: 40.0, //强制高度

      //列表项构造器
      itemBuilder: (BuildContext context, int index) {
//        return Text("fav $index");
        return FavSelItemWidget(
          itemText: "fav $index",
          index: index,
        );
      },
    );
  }
}

/// 收藏夹选择单项
class FavSelItemWidget extends StatefulWidget {
  final String itemText;
  final int index;

  FavSelItemWidget({this.itemText, this.index});

  @override
  _FavSelItemWidgetState createState() => _FavSelItemWidgetState();
}

class _FavSelItemWidgetState extends State<FavSelItemWidget> {
  Color _color;

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      color: _color,
      padding: EdgeInsets.fromLTRB(32, 4, 8, 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            Text(
              widget?.itemText ?? '',
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  CupertinoIcons.forward,
                  size: 24.0,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ]),
        ],
      ),
    );

    return GestureDetector(
      child: Column(
        children: <Widget>[
          container,
          _settingItemDivider(),
        ],
      ),
      onTap: () {
        debugPrint("fav tap ${widget.index}");
//        NavigatorUtil.goBack(context);
      },
      onTapDown: (_) => _updatePressedColor(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _updateNormalColor();
        });
      },
      onTapCancel: () => _updateNormalColor(),
    );
  }

  void _updateNormalColor() {
    setState(() {
      _color = Colors.white;
    });
  }

  void _updatePressedColor() {
    setState(() {
      _color = Color(0xFFF0F1F2);
    });
  }

  /// 设置项分隔线
  Widget _settingItemDivider() {
    return Divider(
      height: 1.0,
      indent: 32,
      color: CupertinoColors.systemGrey,
    );
  }
}
