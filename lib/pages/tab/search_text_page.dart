import 'dart:io';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/common/tag_database.dart';
import 'package:FEhViewer/models/states/search_text_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

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
          padding: const EdgeInsetsDirectional.only(start: 0),
          middle: Text(_title),
          transitionBetweenRoutes: false,
          trailing: _buildListBtns(context),
        ),
        child: SafeArea(
          child: Consumer<SearchTextModel>(builder:
              (context, SearchTextModel searchTextModel, Widget child) {
            final List<String> _datas = searchTextModel.searchTextList;

            Widget _itemBuilder(BuildContext context, int position) {
              return Container(
                margin: const EdgeInsets.only(left: 24),
                child: Slidable(
                  key: Key(_datas[position].toString()),
                  actionPane: const SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: GestureDetector(
                    onTap: () {
                      Get.back<String>(result: _datas[position]);
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
                        // showToast('delete');
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

  Widget _buildListBtns(BuildContext context) {
    final SearchTextModel searchTextModel =
        Provider.of<SearchTextModel>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: 130,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // 清除按钮
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              FontAwesomeIcons.solidTrashAlt,
              size: 20,
            ),
            onPressed: () {
              _removeAll(context, searchTextModel);
            },
          ),
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              FontAwesomeIcons.fileImport,
              size: 20,
            ),
            onPressed: () async {
              final FilePickerResult result =
                  await FilePicker.platform.pickFiles();
              if (result != null) {
                final File _file = File(result.files.single.path);
                final String _fileText = _file.readAsStringSync();
                if (_fileText.contains('#FEhViewer')) {
                  Global.logger.v('$_fileText');
                  final List<String> _importTexts = _fileText.split('\n');
                  _importTexts.forEach((String element) {
                    if (element.trim().isNotEmpty && !element.startsWith('#'))
                      searchTextModel.addText(element);
                  });
                }
              }
            },
          ),
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              FontAwesomeIcons.fileExport,
              size: 20,
            ),
            onPressed: () async {
              final List<String> _searchTextList = Global.profile.searchText;
              if (_searchTextList.isNotEmpty) {
                final String _searchText =
                    '#FEhViewer\n${_searchTextList.join('\n')}';
                Global.logger.v(_searchText);
                // Share.share(_searchText, subject: 'FEhViewer');
                final File _tempFlie = await _getLocalFile();
                _tempFlie.writeAsStringSync(_searchText);
                Share.shareFiles([_tempFlie.path]);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<File> _getLocalFile() async {
    // 获取临时目录
    final String dir = (await getTemporaryDirectory()).path;
    final DateTime _now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyyMMdd_HHmmss');
    final String _fileName = formatter.format(_now);
    return File('$dir/FEhViewerSearch_$_fileName.txt');
  }

  Future<void> _removeAll(
      BuildContext context, SearchTextModel searchTextModel) async {
    return showCupertinoDialog<void>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('清除所有?'),
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
                searchTextModel.removeAll();
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}
