import 'package:fehviewer/common/controller/quicksearch_controller.dart';
import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/utils/import_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class QuickSearchListPage extends StatelessWidget {
  const QuickSearchListPage({super.key, this.autoSearch = true});

  final bool autoSearch;

  QuickSearchController get quickSearchController => Get.find();

  LocaleService get localeService => Get.find();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 8),
        middle: Text(L10n.of(context).quick_search),
        trailing: Row(
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
      ),
      child: CustomScrollView(slivers: [
        SliverSafeArea(
          sliver: Obx(() {
            final List<String> _qSearchList =
                quickSearchController.searchTextList;
            return SliverCupertinoListSection.insetGrouped(
              itemCount: _qSearchList.length,
              itemBuilder: (context, index) {
                final _qSearchText = _qSearchList[index];
                return _QuickSearchListTile(
                  text: _qSearchText,
                  index: index,
                  autoSearch: autoSearch,
                );
              },
            );
          }),
        ),
      ]),
    );
  }

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
                  const Icon(FontAwesomeIcons.fileExport).paddingOnly(right: 4),
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
                  const Icon(FontAwesomeIcons.fileImport).paddingOnly(right: 4),
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

class _QuickSearchListTile extends GetView<QuickSearchController> {
  const _QuickSearchListTile({
    super.key,
    required this.text,
    required this.index,
    this.autoSearch = true,
  });

  final String text;
  final int index;
  final bool autoSearch;

  LocaleService get localeService => Get.find();

  Future<String?> _getTextTranslate(String text) async {
    final String? tranText =
        await Get.find<TagTransController>().getTranTagWithNameSpaseAuto(text);
    if (tranText?.trim() != text) {
      return tranText;
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(text),
      endActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => controller.removeTextAt(index),
            backgroundColor: CupertinoDynamicColor.resolve(
                CupertinoColors.systemRed, context),
            icon: CupertinoIcons.delete,
          ),
        ],
      ),
      child: EhCupertinoListTile(
        padding: const EdgeInsets.only(left: 20, right: 10, top: 6, bottom: 6),
        title: Text(text),
        subtitle: localeService.isLanguageCodeZh
            ? FutureBuilder<String?>(
                future: _getTextTranslate(text),
                initialData: text,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data!);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              )
            : null,
        trailing: const CupertinoListTileChevron(),
        onTap: () {
          if (autoSearch) {
            Get.back<String>(
              result: text,
              id: isLayoutLarge ? 2 : null,
            );
          }
        },
      ),
    );
  }
}
