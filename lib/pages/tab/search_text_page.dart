import 'package:FEhViewer/common/tag_database.dart';
import 'package:FEhViewer/models/states/search_text_model.dart';
import 'package:FEhViewer/utils/db_util.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class SearchQuickListPage extends StatelessWidget {
  final String _title = '快速搜索';

  Future<String> _getTextTranslate(String text) async {
    final String tranText =
        await EhTagDatabase.getTranTagWithFullNameSpase(text);
    if (tranText.trim() != text) {
      return '$text / $tranText';
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold sca = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: ThemeColors.navigationBarBackground,
          middle: Text(_title),
          transitionBetweenRoutes: false,
        ),
        child: SafeArea(
          child: Consumer<SearchTextModel>(builder:
              (context, SearchTextModel searchTextModel, Widget child) {
            List<String> _datas = searchTextModel.searchTextList;

            Widget _itemBuilder(BuildContext context, int position) {
              return Container(
                margin: const EdgeInsets.only(left: 24),
                child: Slidable(
                  key: Key(_datas[position].toString()),
                  actionPane: const SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context, _datas[position]);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: FutureBuilder<String>(
                        future: _getTextTranslate(_datas[position]),
                        initialData: _datas[position],
                        builder: (context, snapshot) {
                          return Container(
                            height: 46,
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              snapshot.data,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }),
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: '删除',
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemRed, context),
                      icon: Icons.delete,
                      onTap: () {
                        showToast('delete');
                        searchTextModel.removeTextAt(position);
                      },
                    ),
                  ],
                ),
              );
            }

            return Container(
              child: ListView.separated(
                itemBuilder: _itemBuilder,
                itemCount: _datas.length,
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0.5,
                    indent: 12.0,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey4, context),
                  );
                },
              ),
            );
          }),
        ));

    return sca;
  }
}
