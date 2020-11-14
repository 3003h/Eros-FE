import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/pages/tab/gallery_base.dart';
import 'package:FEhViewer/pages/tab/tab_base.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:FEhViewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../item/gallery_item.dart';

class PopularListTab extends StatefulWidget {
  const PopularListTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
  final tabIndex;
  final scrollController;

  @override
  State<StatefulWidget> createState() => _PopularListTabState();
}

class _PopularListTabState extends State<PopularListTab> {
  final List<GalleryItem> _gallerItemBeans = [];
  // bool _firstLoading = false;
  Future<List<GalleryItem>> _futureBuilderFuture;
  Widget _lastListWidget;

  @override
  void initState() {
    super.initState();
    // _loadData();
    _futureBuilderFuture = _loadDataF();
  }

  // Future<void> _loadData() async {
  //   setState(() {
  //     _gallerItemBeans.clear();
  //     _firstLoading = true;
  //   });
  //   final Tuple2<List<GalleryItem>, int> tuple = await Api.getPopular();
  //   final List<GalleryItem> gallerItemBeans = tuple.item1;
  //   _gallerItemBeans.addAll(gallerItemBeans);
  //   setState(() {
  //     _firstLoading = false;
  //   });
  // }

  Future<List<GalleryItem>> _loadDataF() async {
    Global.logger.v('_loadDataF ');
    final Future<Tuple2<List<GalleryItem>, int>> tuple = Api.getPopular();
    final Future<List<GalleryItem>> gallerItemBeans =
        tuple.then((value) => value.item1);
    return gallerItemBeans;
  }

  // Future<void> _reloadData() async {
  //   if (_firstLoading) {
  //     setState(() {
  //       _firstLoading = false;
  //     });
  //   }
  //
  //   Tuple2<List<GalleryItem>, int> tuple = await Api.getPopular();
  //   final List<GalleryItem> gallerItemBeans = tuple.item1;
  //
  //   setState(() {
  //     _gallerItemBeans.clear();
  //     _gallerItemBeans.addAll(gallerItemBeans);
  //   });
  // }

  Future<void> _reloadDataF() async {
    final List<GalleryItem> gallerItemBeans = await _loadDataF();
    setState(() {
      _futureBuilderFuture = Future<List<GalleryItem>>.value(gallerItemBeans);
    });
  }

  Future<void> _reLoadDataFirstF() async {
    setState(() {
      _futureBuilderFuture = _loadDataF();
    });
  }

  SliverList gallerySliverListView(List<GalleryItem> gallerItemBeans) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
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
    final String _title = ln.tab_popular;
    final CustomScrollView customScrollView = CustomScrollView(
      controller: widget.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
//          brightness: Brightness.dark,
          backgroundColor: ThemeColors.navigationBarBackground,
//          heroTag: 'pop',
          largeTitle: TabPageTitle(
            title: _title,
            isLoading: false,
          ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await _reloadDataF();
          },
        ),
        SliverSafeArea(
          top: false,
          sliver: _getGalleryList2(),
        ),
      ],
    );

    return CupertinoPageScaffold(child: customScrollView);
  }

  // Widget _getGalleryList() {
  //   return _firstLoading
  //       ? SliverFillRemaining(
  //           child: Container(
  //             padding: const EdgeInsets.only(bottom: 50),
  //             child: const CupertinoActivityIndicator(
  //               radius: 14.0,
  //             ),
  //           ),
  //         )
  //       : getGalleryList(_gallerItemBeans, widget.tabIndex);
  // }

  Widget _getGalleryList2() {
    return FutureBuilder<List<GalleryItem>>(
      future: _futureBuilderFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<GalleryItem>> snapshot) {
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
              return SliverFillRemaining(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: GalleryErrorPage(
                    onTap: _reLoadDataFirstF,
                  ),
                ),
              );
            } else {
              _lastListWidget = getGalleryList(snapshot.data, widget.tabIndex);
              return _lastListWidget;
            }
        }
        return null;
      },
    );
  }
}
