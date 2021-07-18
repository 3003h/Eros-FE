import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const kTextStyle = TextStyle(fontSize: 13);

class GalleryInfoPage extends StatelessWidget {
  const GalleryInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Gallery info'),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: GetBuilder<GalleryPageController>(
            init: GalleryPageController(),
            tag: pageCtrlDepth,
            id: GetIds.PAGE_VIEW_HEADER,
            builder: (GalleryPageController controller) {
              final _infoMap = {
                'Gid': controller.galleryItem.gid,
                'Token': controller.galleryItem.token,
                'Url': '${Api.getBaseUrl()}${controller.galleryItem.url}',
                'Title': controller.galleryItem.englishTitle,
                'Jpn Title': controller.galleryItem.japaneseTitle,
                'Thumb': controller.galleryItem.imgUrl,
                'Category': controller.galleryItem.category,
                'Uploader': controller.galleryItem.uploader,
                'Posted': controller.galleryItem.postTime,
                'Language': controller.galleryItem.language,
                'Pages': controller.galleryItem.filecount,
                'Size': controller.galleryItem.filesizeText,
                'Favorite count': controller.galleryItem.favoritedCount,
                'Favorited':
                    '${controller.galleryItem.favcat?.isNotEmpty ?? false}',
                'Favorite': controller.galleryItem.favTitle ?? '',
                'Rating count': controller.galleryItem.ratingCount,
                'Rating': '${controller.galleryItem.rating}',
                'Torrents': controller.galleryItem.torrentcount,
                // 'Torrents Url': controller.galleryItem.torrentcount,
              };

              return CupertinoFormSection.insetGrouped(
                // backgroundColor: Colors.transparent,
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
  }
}

class TextItem extends StatelessWidget {
  const TextItem({Key? key, required this.prefixText, this.initialValue})
      : super(key: key);
  final String prefixText;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      prefix: Text(
        prefixText,
        style: kTextStyle.copyWith(fontWeight: FontWeight.w500),
      ),
      initialValue: initialValue,
      readOnly: true,
      maxLines: null,
      style: kTextStyle,
      textAlign: TextAlign.right,
      onTap: () {
        // print('tap $initialValue');
        showToast('Copied to clipboard');
        Clipboard.setData(ClipboardData(text: initialValue));
      },
    );
  }
}
