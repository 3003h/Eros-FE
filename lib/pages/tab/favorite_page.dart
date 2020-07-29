import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/entity/favorite.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/models/states/user_model.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../item/gallery_item.dart';

class FavoriteTab extends StatefulWidget {
  final tabIndex;
  final scrollController;

  const FavoriteTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
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
    _curFavcat = 'a';
    _loadDataFirst();
  }

  _loadDataFirst() async {
    setState(() {
      _loading = true;
      _curPage = 0;
    });
    var tuple = await Api.getFavorite(favcat: _curFavcat);
    var gallerItemBeans = tuple.item1;

    setState(() {
      _gallerItemBeans.clear();
      _gallerItemBeans.addAll(gallerItemBeans);
      _loading = false;
    });
  }

  _reloadData() async {
    if (_loading) {
      setState(() {
        _loading = false;
      });
    }
    var tuple = await Api.getFavorite(favcat: _curFavcat);
    var gallerItemBeans = tuple.item1;
    setState(() {
      _gallerItemBeans.clear();
      _gallerItemBeans.addAll(gallerItemBeans);
    });
  }

  _loadDataMore() async {
    if (_isLoadMore) {
      return;
    }

    // 增加延时 避免build期间进行 setState
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      _isLoadMore = true;
    });

    _curPage += 1;
    var tuple = await Api.getFavorite(favcat: _curFavcat, page: _curPage);
    var gallerItemBeans = tuple.item1;

    setState(() {
      _gallerItemBeans.addAll(gallerItemBeans);
      _isLoadMore = false;
    });
  }

  SliverList gallerySliverListView(List<GalleryItem> gallerItemBeans) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == gallerItemBeans.length - 1) {
            Global.logger.v('load more');
            _loadDataMore();
          }
//          Global.logger.v('build ${gallerItemBeans[index].gid} ');
          return ChangeNotifierProvider.value(
            value: GalleryModel(),
            child: GalleryItemWidget(
              galleryItem: gallerItemBeans[index],
              tabIndex: widget.tabIndex,
            ),
          );
        },
        childCount: gallerItemBeans.length,
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
    // final width = size.width;
    final height = size.height;
    final _topPad = height / 2 - 150;

    return CupertinoPageScaffold(
      child: Selector<UserModel, bool>(
          selector: (context, provider) => provider.isLogin,
          builder: (context, isLogin, child) {
            return isLogin
                ? CustomScrollView(
                    controller: widget.scrollController,
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
                                  await _loadDataFirst();
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
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 150),
                          child: _isLoadMore
                              ? CupertinoActivityIndicator(
                                  radius: 14,
                                  iOSVersionStyle:
                                      CupertinoActivityIndicatorIOSVersionStyle
                                          .iOS14,
                                )
                              : Container(),
                        ),
                      ),
                    ],
                  )
                : CustomScrollView(slivers: <Widget>[
                    CupertinoSliverNavigationBar(
                      largeTitle: TabPageTitle(
                        title: ln.not_login,
                        isLoading: false,
                      ),
                      transitionBetweenRoutes: false,
                    ),
                  ]);
          }),
    );
  }
}
