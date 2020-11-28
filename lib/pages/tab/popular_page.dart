import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/pages/tab/gallery_base.dart';
import 'package:FEhViewer/pages/tab/tab_base.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class PopularListTab extends StatefulWidget {
  const PopularListTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
  final tabIndex;
  final scrollController;

  @override
  State<StatefulWidget> createState() => _PopularListTabState();
}

class _PopularListTabState extends State<PopularListTab> {
  // bool _firstLoading = false;
  Future<List<GalleryItem>> _futureBuilderFuture;
  Widget _lastListWidget;

  @override
  void initState() {
    super.initState();
    // _loadData();
    _futureBuilderFuture = _loadData();
  }

  Future<List<GalleryItem>> _loadData() async {
    Global.logger.v('_loadDataF ');
    final Future<Tuple2<List<GalleryItem>, int>> tuple = Api.getPopular();
    final Future<List<GalleryItem>> gallerItemBeans =
        tuple.then((value) => value.item1);
    return gallerItemBeans;
  }

  Future<void> _reloadDataF() async {
    final List<GalleryItem> gallerItemBeans = await _loadData();
    setState(() {
      _futureBuilderFuture = Future<List<GalleryItem>>.value(gallerItemBeans);
    });
  }

  Future<void> _reLoadDataFirstF() async {
    setState(() {
      _futureBuilderFuture = _loadData();
    });
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
              Global.logger.e('${snapshot.error}');
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
