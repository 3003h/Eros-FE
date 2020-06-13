import 'package:FEhViewer/model/favorite.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:FEhViewer/values/theme_colors.dart';
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

/// 收藏夹选择页面 列表
class SelFavorite extends StatefulWidget {
  final FavcatItemBean favcatItemBean;

  SelFavorite({this.favcatItemBean});

  @override
  State<StatefulWidget> createState() => _SelFavorite();
}


/// 收藏夹选择页面 列表
class _SelFavorite extends State<SelFavorite> {
  String _title = "收藏夹";
  Color _color;

  final List<FavcatItemBean> favItemBeans = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    EHConst.favList.forEach((fav) {
      var name = fav['name'];
      var desc = fav['desc'];
      favItemBeans.add(FavcatItemBean(desc, ThemeColors.favColor[name]));
    });
  }

  @override
  Widget build(BuildContext context) {
    CupertinoPageScaffold sca = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_title),
        ),
        child: SafeArea(
          child: ListViewFavorite(favItemBeans),
        ));

    return sca;
  }
}

class ListViewFavorite extends StatelessWidget {
  List<FavcatItemBean> favItemBeans = [];

  ListViewFavorite(this.favItemBeans);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: favItemBeans.length,

      //列表项构造器
      itemBuilder: (BuildContext context, int index) {
//        return Text("fav $index");
        return FavSelItemWidget(
          favcatItemBean: favItemBeans[index],
          index: index,
        );
      },
    );
  }
}

/// 收藏夹选择单项
class FavSelItemWidget extends StatefulWidget {
  final int index;
  final FavcatItemBean favcatItemBean;

  FavSelItemWidget({this.index, this.favcatItemBean});

  @override
  _FavSelItemWidgetState createState() => _FavSelItemWidgetState();
}

class _FavSelItemWidgetState extends State<FavSelItemWidget> {
  Color _colorTap;

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      color: _colorTap,
      padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            Icon(
              CupertinoIcons.heart_solid,
              color: widget.favcatItemBean.color,
            ),
            Container(
              width: 18,
            ),
            Text(
              widget?.favcatItemBean?.title ?? '',
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
      _colorTap = Colors.white;
    });
  }

  void _updatePressedColor() {
    setState(() {
      _colorTap = Color(0xFFF0F1F2);
    });
  }

  /// 设置项分隔线
  Widget _settingItemDivider() {
    return Divider(
      height: 1.0,
      indent: 48,
      color: CupertinoColors.systemGrey,
    );
  }
}
