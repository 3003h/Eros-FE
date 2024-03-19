import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/pages/gallery/controller/gallery_page_controller.dart';
import 'package:eros_fe/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const kTextStyle = TextStyle(fontSize: 13);

class GalleryInfoPage extends StatelessWidget {
  const GalleryInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Gallery info'),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: GetBuilder<GalleryPageController>(
              // init: GalleryPageController(),
              tag: pageCtrlTag,
              id: GetIds.PAGE_VIEW_HEADER,
              builder: (GalleryPageController controller) {
                final pageState = controller.gState;
                if (pageState.galleryProvider == null) {
                  return const SizedBox.shrink();
                }

                final _infoMap = {
                  'Gid': pageState.galleryProvider!.gid,
                  'Token': pageState.galleryProvider!.token,
                  'Url': pageState.url,
                  'Title': pageState.galleryProvider!.englishTitle,
                  'Jpn Title': pageState.galleryProvider!.japaneseTitle,
                  'Thumb': pageState.galleryProvider!.imgUrl,
                  'Category': pageState.galleryProvider!.category,
                  'Uploader': pageState.galleryProvider!.uploader,
                  'Posted': pageState.galleryProvider!.postTime,
                  'Language': pageState.galleryProvider!.language,
                  'Pages': pageState.galleryProvider!.filecount,
                  'Size': pageState.galleryProvider!.filesizeText,
                  'Favorite count': pageState.galleryProvider!.favoritedCount,
                  'Favorited':
                      '${pageState.galleryProvider!.favcat?.isNotEmpty ?? false}',
                  'Favorite': pageState.galleryProvider!.favTitle ?? '',
                  'Rating count': pageState.galleryProvider!.ratingCount,
                  'Rating': '${pageState.galleryProvider!.rating}',
                  'Torrents': pageState.galleryProvider!.torrentcount,
                  // 'Torrents Url': controller.galleryProvider.torrentcount,
                };

                return CupertinoFormSection.insetGrouped(
                  backgroundColor: Colors.transparent,
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                  children: _infoMap.entries
                      .map((e) => TextItem(
                            prefixText: e.key,
                            initialValue: e.value,
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}

class TextItem extends StatelessWidget {
  const TextItem({Key? key, required this.prefixText, this.initialValue})
      : super(key: key);
  final String prefixText;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showToast('Copied to clipboard');
        Clipboard.setData(ClipboardData(text: initialValue ?? ''));
      },
      child: CupertinoFormRow(
        prefix: Text(
          prefixText,
          style: kTextStyle.copyWith(fontWeight: FontWeight.w500),
        ).paddingOnly(right: 20),
        child: SelectableText(
          initialValue ?? '',
          style: kTextStyle,
        ),
      ).paddingSymmetric(horizontal: 8, vertical: 8),
    );
  }
}
