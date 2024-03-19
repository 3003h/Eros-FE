import 'package:eros_fe/common/controller/quicksearch_controller.dart';
import 'package:eros_fe/common/controller/tag_trans_controller.dart';
import 'package:eros_fe/common/controller/webdav_controller.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/common/service/locale_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/utils/import_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class QuickSearchListPage extends StatelessWidget {
  QuickSearchListPage({Key? key, this.autoSearch = true}) : super(key: key);

  final bool autoSearch;
  final QuickSearchController quickSearchController = Get.find();
  final LocaleService localeService = Get.find();

  Future<String?> _getTextTranslate(String text) async {
    final String? tranText =
        await Get.find<TagTransController>().getTranTagWithNameSpaseAuto(text);
    if (tranText?.trim() != text) {
      return tranText;
    } else {
      return text;
    }
  }

  Widget _buildListButtons(BuildContext context) {
    Future<void> _showFile() async {
      return showCupertinoDialog<void>(
        context: Get.overlayContext!,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Import and Export'),
            // content: Text('Sync with Google Cloud Firestore'),
            actions: [
              CupertinoDialogAction(
                onPressed: () async {
                  final _tempFilePath = await writeQuickSearchTempFile();
                  if (_tempFilePath != null) {
                    Share.shareXFiles([XFile(_tempFilePath)]);
                  }
                  Get.back();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FontAwesomeIcons.share).paddingOnly(right: 4),
                    const Text('Share'),
                  ],
                ),
              ),
              CupertinoDialogAction(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FontAwesomeIcons.fileExport)
                        .paddingOnly(right: 4),
                    const Text('Export'),
                  ],
                ),
                onPressed: () async {
                  Get.back();
                  logger.d('Export');
                  exportQuickSearchToFile();
                },
              ),
              CupertinoDialogAction(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FontAwesomeIcons.fileImport)
                        .paddingOnly(right: 4),
                    const Text('Import'),
                  ],
                ),
                onPressed: () async {
                  Get.back();
                  importQuickSearchFromFile();
                },
              ),
              CupertinoDialogAction(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(L10n.of(context).cancel)),
            ],
          );
        },
      );
    }

    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // 清除按钮
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              FontAwesomeIcons.solidTrashCan,
              size: 20,
            ),
            onPressed: () {
              _removeAll();
            },
          ),
          CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              FontAwesomeIcons.solidFileLines,
              size: 20,
            ),
            onPressed: _showFile,
          ),
          if (Get.find<WebdavController>().syncQuickSearch)
            CupertinoButton(
              minSize: 40,
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.arrowsRotate,
                size: 20,
              ),
              onPressed: quickSearchController.syncQuickSearch,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final QuickSearchController quickSearchController = Get.find();
    final CupertinoPageScaffold sca = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(start: 0),
          middle: Text(L10n.of(context).quick_search),
          transitionBetweenRoutes: false,
          trailing: _buildListButtons(context),
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
                    endActionPane: ActionPane(
                      extentRatio: 0.25,
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          // An action can be bigger than the others.
                          // flex: 2,
                          onPressed: (_) =>
                              quickSearchController.removeTextAt(position),
                          backgroundColor: CupertinoDynamicColor.resolve(
                              CupertinoColors.systemRed, context),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: L10n.of(context).delete,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (autoSearch) {
                          Get.back<String>(
                            result: _datas[position],
                            id: isLayoutLarge ? 2 : null,
                          );
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: localeService.isLanguageCodeZh
                          ? FutureBuilder<String?>(
                              future: _getTextTranslate(_datas[position]),
                              initialData: _datas[position],
                              builder: (context, snapshot) {
                                return Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 60),
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _datas[position],
                                        softWrap: true,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        snapshot.data ?? '',
                                        softWrap: true,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                    ],
                                  ).paddingSymmetric(vertical: 8),
                                );
                              },
                            )
                          : Container(
                              constraints: const BoxConstraints(minHeight: 40),
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _datas[position],
                                    softWrap: true,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ).paddingSymmetric(vertical: 8),
                            ),
                    ),
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
              child: Text(L10n.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(L10n.of(context).ok),
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
