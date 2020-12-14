import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/entity/favorite.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/models/states/local_favorite_model.dart';
import 'package:FEhViewer/models/states/user_model.dart';
import 'package:FEhViewer/pages/tab/gallery_base.dart';
import 'package:FEhViewer/pages/tab/tab_base.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../item/gallery_item.dart';

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
  final tabIndex;
  final scrollController;

  @override
  State<StatefulWidget> createState() {
    return _FavoriteTabState();
  }
}

class _FavoriteTabState extends State<FavoriteTab> {
  String _title = '';
  List<GalleryItem> _galleryItemBeans = [];
  String _curFavcat = '';
  int _curPage = 0;
  int _maxPage = 0;
  bool _isLoadMore = false;

  bool enableDelayedLoad = true;

  //页码跳转的控制器
  final TextEditingController _pageController = TextEditingController();

  Future<Tuple2<List<GalleryItem>, int>> _futureBuilderFuture;
  Widget _lastListWidget;

  void _setTitle(String title) {
    setState(() {
      _title = title;
    });
  }

  @override
  void initState() {
    super.initState();
    _curFavcat = Global.profile.ehConfig.lastShowFavcat ?? 'a';
    _title = Global.profile.ehConfig.lastShowFavTitle;
    _futureBuilderFuture = _loadData(first: true);
    Future<void>.delayed(const Duration(milliseconds: 200)).then((_) {
      if (enableDelayedLoad) {
        _reloadData(delayed: true);
      }
    });
  }

  SliverList gallerySliverListView(List<GalleryItem> gallerItemBeans) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == gallerItemBeans.length - 1 && _curPage < _maxPage - 1) {
            Global.logger.v('load more');
            _loadDataMore();
          }
//          Global.logger.v('build ${gallerItemBeans[index].gid} ');
          return ChangeNotifierProvider<GalleryModel>.value(
            value: GalleryModel()
              ..initData(gallerItemBeans[index], tabIndex: widget.tabIndex),
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
    final S ln = S.of(context);

    return CupertinoPageScaffold(
      child: Selector<UserModel, bool>(
          selector: (BuildContext context, UserModel provider) =>
              provider.isLogin,
          builder: (BuildContext context, bool isLogin, Widget child) {
            Global.logger.d(' rebuild fav');

            if (isLogin) {
              if (_title == null || _title.isEmpty) {
                _title = ln.all_Favorites;
              }
              return _buildNetworkFavView(context);
            } else {
              return _buildLocalFavView();
            }
          }),
    );
  }

  Widget _buildNetworkFavView(BuildContext context) {
    return CustomScrollView(
      controller: widget.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 4),
          largeTitle: TabPageTitle(
            title: _title,
          ),
          trailing: Container(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                      color: CupertinoColors.activeBlue,
                      child: Text(
                        '${_curPage + 1}',
                        style: const TextStyle(color: CupertinoColors.white),
                      ),
                    ),
                  ),
                  onPressed: () {
                    _jumtToPage(context);
                  },
                ),
                _buildFavcatButton(context),
              ],
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
          sliver: _getGalleryList(),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(bottom: 150),
            child: _isLoadMore
                ? const CupertinoActivityIndicator(
                    radius: 14,
                  )
                : Container(),
          ),
        ),
      ],
    );
  }

  Widget _buildLocalFavView() {
    return CustomScrollView(slivers: <Widget>[
      CupertinoSliverNavigationBar(
        largeTitle: TabPageTitle(
          title: '本地收藏',
          isLoading: false,
        ),
        transitionBetweenRoutes: false,
      ),
      CupertinoSliverRefreshControl(
        onRefresh: () async {
          await _reloadData();
        },
      ),
      Selector<LocalFavModel, int>(
          selector: (context, localFavModel) => localFavModel.loacalFavs.length,
          builder: (context, _, __) {
            return SliverSafeArea(
              top: false,
              sliver: _getGalleryList(),
            );
          }),
      SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.only(bottom: 150),
          child: _isLoadMore
              ? const CupertinoActivityIndicator(
                  radius: 14,
                )
              : Container(),
        ),
      ),
    ]);
  }

  Widget _getGalleryList() {
    return FutureBuilder<Tuple2<List<GalleryItem>, int>>(
      future: _futureBuilderFuture,
      builder: (BuildContext context,
          AsyncSnapshot<Tuple2<List<GalleryItem>, int>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return _lastListWidget ??
                SliverFillRemaining(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: const CupertinoActivityIndicator(
                      radius: 14.0,
                    ),
                  ),
                );
          case ConnectionState.done:
            if (snapshot.hasError) {
              Global.logger.e('${snapshot.error}');
              return SliverFillRemaining(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: GalleryErrorPage(
                    onTap: _reLoadDataFirst,
                  ),
                ),
              );
            } else {
              _galleryItemBeans = snapshot.data.item1;
              _maxPage = snapshot.data.item2;
              _lastListWidget = getGalleryList(
                  _galleryItemBeans, widget.tabIndex,
                  maxPage: _maxPage,
                  curPage: _curPage,
                  loadMord: _loadDataMore);
              return _lastListWidget;
            }
        }
        return null;
      },
    );
  }

  Future<Tuple2<List<GalleryItem>, int>> _loadData({
    bool refresh = false,
    bool first = false,
  }) async {
    Global.logger.v('_loadDataFirst  fav');
    _curPage = 0;

    final bool _isLogin =
        Provider.of<UserModel>(context, listen: false).isLogin;
    if (!_isLogin) {
      _curFavcat = 'l';
    }

    if (_curFavcat != 'l') {
      // 网络收藏夹
      final Future<Tuple2<List<GalleryItem>, int>> tuple = Api.getFavorite(
        favcat: _curFavcat,
        refresh: refresh,
      );
      return tuple;
    } else {
      if (first) {
        Global.profile.ehConfig.lastShowFavcat = 'l';
        Global.profile.ehConfig.lastShowFavTitle = '本地收藏';
        Global.saveProfile();
      }
      // 本地收藏夹
      Global.logger.v('本地收藏');
      final List<GalleryItem> localFav =
          Provider.of<LocalFavModel>(context, listen: false).loacalFavs;

      return Future<Tuple2<List<GalleryItem>, int>>.value(Tuple2(localFav, 1));
    }
  }

  Future<void> _reLoadDataFirst() async {
    setState(() {
      _lastListWidget = null;
      _futureBuilderFuture = _loadData(refresh: false, first: true);
    });
  }

  Future<void> _reloadData({bool delayed = false}) async {
    _curPage = 0;
    final Tuple2<List<GalleryItem>, int> tuple = await _loadData(refresh: true);
    if (delayed && enableDelayedLoad) {
      Global.logger.d(' delayed reload');
      setState(() {
        _futureBuilderFuture =
            Future<Tuple2<List<GalleryItem>, int>>.value(tuple);
      });
    } else {
      setState(() {
        _futureBuilderFuture =
            Future<Tuple2<List<GalleryItem>, int>>.value(tuple);
      });
    }
  }

  Future<void> _loadFromPage(int page, {bool cleanSearch = false}) async {
    Global.logger.v('jump to page =>  $page');

    _curPage = page;
    final Future<Tuple2<List<GalleryItem>, int>> tuple =
        Api.getFavorite(favcat: _curFavcat, page: _curPage, refresh: true);

    setState(() {
      _lastListWidget = null;
      _futureBuilderFuture = tuple;
    });
  }

  Future<void> _loadDataMore() async {
    if (_isLoadMore) {
      return;
    }

    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));
    setState(() {
      _isLoadMore = true;
    });

    _curPage += 1;
    final Tuple2<List<GalleryItem>, int> tuple = await Api.getFavorite(
      favcat: _curFavcat,
      page: _curPage,
      refresh: true,
    );
    final List<GalleryItem> gallerItemBeans = tuple.item1;

    setState(() {
      _galleryItemBeans.addAll(gallerItemBeans);
      _isLoadMore = false;
    });
  }

  /// 跳转页码
  Future<void> _jumtToPage(BuildContext context) async {
    void _jump(BuildContext context) {
      final String _input = _pageController.text.trim();

      if (_input.isEmpty) {
        showToast('输入为空');
      }

      // 数字检查
      if (!RegExp(r'(^\d+$)').hasMatch(_input)) {
        showToast('输入格式有误');
      }

      final int _toPage = int.parse(_input) - 1;
      if (_toPage >= 0 && _toPage <= _maxPage) {
        FocusScope.of(context).requestFocus(FocusNode());
        _loadFromPage(_toPage);
        Get.back();
      } else {
        showToast('输入范围有误');
      }
    }

    return showCupertinoDialog<void>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('页面跳转'),
          content: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('跳转范围 1~$_maxPage'),
                ),
                CupertinoTextField(
                  controller: _pageController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  onEditingComplete: () {
                    // 点击键盘完成
                    // 画廊跳转
                    _jump(context);
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                // 画廊跳转
                _jump(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// 切换收藏夹
  Widget _buildFavcatButton(BuildContext context) {
    return CupertinoButton(
      minSize: 40,
      padding: const EdgeInsets.only(right: 8),
      child: const Icon(
        FontAwesomeIcons.star,
      ),
      onPressed: () async {
        // 跳转收藏夹选择页
        Get.toNamed(EHRoutes.selFavorie).then((result) async {
          if (result.runtimeType == FavcatItemBean) {
            final FavcatItemBean fav = result;
            if (_curFavcat != fav.favId) {
              Global.loggerNoStack.v('set fav to ${fav.title}');
              _setTitle(fav.title);
              enableDelayedLoad = false;
              _curFavcat = fav.favId;
              Global.profile.ehConfig.lastShowFavcat = _curFavcat;
              Global.profile.ehConfig.lastShowFavTitle = fav.title;
              Global.saveProfile();
              _reLoadDataFirst();
            } else {
              Global.loggerNoStack.v('未修改favcat');
            }
          }
        });
      },
    );
  }
}
