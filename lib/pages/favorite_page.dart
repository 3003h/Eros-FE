import 'package:FEhViewer/client/parser/gallery_list_parser.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/entity/favorite.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/user_model.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:FEhViewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'item/gallery_item.dart';

class FavoriteTab extends StatefulWidget {
  final tabIndex;

  const FavoriteTab({Key key, this.tabIndex}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _FavoriteTabState();
  }
}

class _FavoriteTabState extends State<FavoriteTab> {
  String _title = '';
  final List<GalleryItem> _gallerItemBeans = [];
  String _curFavcat = '';
  bool _loading = false;
  int _curPage = 0;
  bool _isLoadMore = false;

  void _setTitle(String title) {
    setState(() {
      _title = title;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    setState(() {
      _loading = true;
    });
    var tuple = await GalleryListParser.getFavorite(favcat: _curFavcat);
    var gallerItemBeans = tuple.item1;

    setState(() {
      _gallerItemBeans.clear();
      _gallerItemBeans.addAll(gallerItemBeans);
      _loading = false;
    });
  }

  _reloadData() async {
    var tuple = await GalleryListParser.getFavorite(favcat: _curFavcat);
    var gallerItemBeans = tuple.item1;
    setState(() {
      _gallerItemBeans.clear();
      _gallerItemBeans.addAll(gallerItemBeans);
    });
  }

  _loadDataMore() async {
    _isLoadMore = true;
    _curPage += 1;
    var tuple =
        await GalleryListParser.getFavorite(favcat: _curFavcat, page: _curPage);
    var gallerItemBeans = tuple.item1;

    _isLoadMore = false;
    setState(() {
      _gallerItemBeans.addAll(gallerItemBeans);
    });
  }

  SliverList gallerySliverListView(List gallerItemBeans) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < gallerItemBeans.length) {
            return GalleryItemWidget(
              galleryItem: gallerItemBeans[index],
              tabIndex: widget.tabIndex,
            );
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);
    if (_title.isEmpty) {
      _title = ln.all_Favorites;
    }

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final _topPad = height / 2 - 150;

    return Selector<UserModel, bool>(
        selector: (context, provider) => provider.isLogin,
        builder: (context, isLogin, child) {
          return isLogin
              ? EasyRefresh(
                  onLoad: () async {
                    // 上拉加载更多
                    await _loadDataMore();
                  },
                  child: CustomScrollView(
                    slivers: <Widget>[
                      CupertinoSliverNavigationBar(
                        largeTitle: TabPageTitle(
                          title: _title,
                        ),
                        transitionBetweenRoutes: false,
                        trailing: CupertinoButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            debugPrint('sel icon tapped');
                            // 跳转收藏夹选择页
                            NavigatorUtil.jump(context, EHRoutes.selFavorie)
                                .then((result) async {
                              if (result.runtimeType == FavcatItemBean) {
                                FavcatItemBean fav = result;
                                Global.loggerNoStack.i('${fav.title}');
                                if (_curFavcat != fav.key) {
                                  Global.loggerNoStack
                                      .v('修改favcat to ${fav.title}');
                                  _setTitle(fav.title);
                                  _curFavcat = fav.key;
                                  setState(() {
                                    _loading = true;
                                    _gallerItemBeans.clear();
                                  });
                                  await _loadData();
                                } else {
                                  Global.loggerNoStack.v('未修改favcat');
                                }
                              } else {
                                Global.loggerNoStack.i('$result');
                              }
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.star,
                          ),
                        ),
                      ),
                      CupertinoSliverRefreshControl(
                        onRefresh: () async {
                          await _reloadData();
                        },
                      ),
                      SliverSafeArea(
                        top: false,
                        sliver: _loading
                            ? SliverToBoxAdapter(
                                child: Container(
                                  padding: EdgeInsets.only(top: _topPad),
                                  child: CupertinoActivityIndicator(
                                    radius: 14.0,
                                  ),
                                ),
                              )
                            : gallerySliverListView(_gallerItemBeans),
                      ),
                    ],
                  ))
              : CustomScrollView(slivers: <Widget>[
                  CupertinoSliverNavigationBar(
                    largeTitle: TabPageTitle(
                      title: ln.not_login,
                      isLoading: false,
                    ),
                    transitionBetweenRoutes: false,
                  ),
                ]);
        });
  }
}
