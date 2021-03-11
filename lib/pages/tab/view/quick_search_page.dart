import 'dart:io';

import 'package:fehviewer/common/controller/quicksearch_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/store/tag_database.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:share/share.dart';

class QuickSearchListPage extends StatelessWidget {
  Future<String?> _getTextTranslate(String text) async {
    final String? tranText = await EhTagDatabase.getTranTagWithNameSpase(text);
    if (tranText?.trim() != text) {
      return tranText;
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuickSearchController quickSearchController = Get.find();
    final CupertinoPageScaffold sca = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(start: 0),
          middle: Text(S.of(context).quick_search),
          transitionBetweenRoutes: false,
          trailing: _buildListBtns(context),
        ),
        child: SafeArea(
          child: Obx(
            () {
              final List<String> _datas = quickSearchController.searchTextList;

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
                      child: FutureBuilder<String?>(
                          future: _getTextTranslate(_datas[position]),
                          initialData: _datas[position],
                          builder: (context, snapshot) {
                            return Container(
                              height: 60,
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _datas[position],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    snapshot.data ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: S.of(context).delete,
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.systemRed, context),
                        icon: Icons.delete,
                        onTap: () {
                          // showToast('delete');
                          quickSearchController.removeTextAt(position);
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
            },
          ),
        ));

    return sca;
  }

  Widget _buildListBtns(BuildContext context) {
    final QuickSearchController quickSearchController = Get.find();

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
              LineIcons.alternateTrash,
              size: 26,
            ),
            onPressed: () {
              _removeAll();
            },
          ),
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              LineIcons.fileImport,
              size: 26,
            ),
            onPressed: () async {
              final FilePickerResult? result =
                  await FilePicker.platform.pickFiles();
              if (result != null) {
                final File _file = File(result.files.single.path!);
                final String _fileText = _file.readAsStringSync();
                if (_fileText.contains('#FEhViewer')) {
                  logger.v('$_fileText');
                  final List<String> _importTexts = _fileText.split('\n');
                  _importTexts.forEach((String element) {
                    if (element.trim().isNotEmpty && !element.startsWith('#'))
                      quickSearchController.addText(element);
                  });
                }
              }
            },
          ),
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              LineIcons.fileExport,
              size: 26,
            ),
            onPressed: () async {
              final List<String> _searchTextList =
                  quickSearchController.searchTextList;
              if (_searchTextList.isNotEmpty) {
                final String _searchText =
                    '#FEhViewer\n${_searchTextList.join('\n')}';
                logger.v(_searchText);
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
    final DateTime _now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyyMMdd_HHmmss');
    final String _fileName = formatter.format(_now);
    return File('${Global.appDocPath}/QSearch_$_fileName.txt');
  }

  Future<void> _removeAll() async {
    final QuickSearchController quickSearchController = Get.find();
    return showCupertinoDialog<void>(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Remove all?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(S.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(S.of(context).ok),
              onPressed: () {
                quickSearchController.removeAll();
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}
