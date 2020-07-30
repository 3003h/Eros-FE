import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../item/gallery_item.dart';

class PopularListTab extends StatefulWidget {
  final tabIndex;
  final scrollController;

  const PopularListTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _PopularListTabState();
}

class _PopularListTabState extends State<PopularListTab> {
  List<GalleryItem> _gallerItemBeans = [];
  bool _firstLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    setState(() {
      _gallerItemBeans.clear();
      _firstLoading = true;
    });
    var tuple = await Api.getPopular();
    var gallerItemBeans = tuple.item1;
    _gallerItemBeans.addAll(gallerItemBeans);
    setState(() {
      _firstLoading = false;
    });
  }

  _reloadData() async {
    if (_firstLoading) {
      setState(() {
        _firstLoading = false;
      });
    }

    var tuple = await Api.getPopular();
    List<GalleryItem> gallerItemBeans = tuple.item1;

    setState(() {
      _gallerItemBeans.clear();
      _gallerItemBeans.addAll(gallerItemBeans);
    });
  }

  SliverList gallerySliverListView(List<GalleryItem> gallerItemBeans) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final _topPad = height / 2 - 150;

    var ln = S.of(context);
    var _title = ln.tab_popular;
    CustomScrollView customScrollView = CustomScrollView(
      controller: widget.scrollController,
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: TabPageTitle(
            title: _title,
            isLoading: false,
          ),
          transitionBetweenRoutes: false,
        ),
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await _reloadData();
          },
        ),
        SliverSafeArea(
          top: false,
          sliver: _firstLoading
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.only(top: _topPad),
                    child: CupertinoActivityIndicator(
                      radius: 14.0,
                    ),
                  ),
                )
              : gallerySliverListView(_gallerItemBeans),
        )
      ],
    );

    return CupertinoPageScaffold(child: customScrollView);
  }
}
