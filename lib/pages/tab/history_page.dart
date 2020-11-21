import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/history_model.dart';
import 'package:FEhViewer/pages/tab/gallery_base.dart';
import 'package:FEhViewer/pages/tab/tab_base.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:FEhViewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
  final String tabIndex;
  final ScrollController scrollController;

  @override
  State<StatefulWidget> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  Future<List<GalleryItem>> _futureBuilderFuture;
  Widget _lastListWidget;
  HistoryModel _historyModel;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final HistoryModel historyModel =
        Provider.of<HistoryModel>(context, listen: false);
    if (historyModel != _historyModel) {
      _historyModel = historyModel;
    }
  }

  Future<List<GalleryItem>> _loadData() async {
    Global.logger.v('_loadData ');
    final List<GalleryItem> historys = _historyModel.history;

    return Future<List<GalleryItem>>.value(historys);
  }

  Future<void> _reloadData() async {
    final List<GalleryItem> gallerItemBeans = await _loadData();
    setState(() {
      _futureBuilderFuture = Future<List<GalleryItem>>.value(gallerItemBeans);
    });
  }

  @override
  Widget build(BuildContext context) {
    final S ln = S.of(context);
    final String _title = ln.tab_history;
    final CustomScrollView customScrollView = CustomScrollView(
      controller: widget.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          backgroundColor: ThemeColors.navigationBarBackground,
          largeTitle: TabPageTitle(
            title: _title,
            isLoading: false,
          ),
          trailing: Container(
            width: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 清除按钮
                CupertinoButton(
                  minSize: 40,
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    FontAwesomeIcons.solidTrashAlt,
                    size: 20,
                  ),
                  onPressed: () {
                    _clearHistory(context);
                  },
                ),
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
          sliver: Selector<HistoryModel, String>(selector: (_, historyModel) {
            if (historyModel.history.isEmpty) {
              return '';
            }
            return historyModel.history.first.url;
          }, builder: (context, snapshot, _) {
            return _getGalleryList();
          }),
          // sliver: _getGalleryList(),
        ),
      ],
    );

    return CupertinoPageScaffold(child: customScrollView);
  }

  // 清除历史记录 Dialog
  Future<void> _clearHistory(BuildContext context) async {
    return showCupertinoDialog<void>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('清除所有历史?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                _historyModel.cleanHistory();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getGalleryList() {
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
                    onTap: _reloadData,
                  ),
                ),
              );
            } else {
              _lastListWidget = getGalleryList(snapshot.data, widget.tabIndex);
              return _lastListWidget;
            }
        }
        return SliverToBoxAdapter(
          child: Container(),
        );
      },
    );
  }
}
