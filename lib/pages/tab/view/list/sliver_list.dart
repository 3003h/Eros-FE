import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/item/controller/galleryitem_controller.dart';
import 'package:eros_fe/pages/item/gallery_item.dart';
import 'package:eros_fe/pages/item/gallery_item_placeholder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';

class EhSliverList extends StatelessWidget {
  const EhSliverList(this.galleryProviders, this.tabTag,
      {this.next,
      this.lastComplete,
      this.large = false,
      this.centerKey,
      this.lastTopItemIndex,
      this.keepPosition = false,
      super.key});

  final List<GalleryProvider> galleryProviders;
  final dynamic tabTag;
  final String? next;
  final VoidCallback? lastComplete;
  final bool large;
  final Key? centerKey;
  final int? lastTopItemIndex;
  final bool keepPosition;

  EhSettingService get _ehSettingService => Get.find();

  @override
  Widget build(BuildContext context) {
    return FlutterSliverList(
      delegate: FlutterListViewDelegate(
        (BuildContext context, int index) {
          if (galleryProviders.length - 1 < index) {
            return const SizedBox.shrink();
          }

          if (index == galleryProviders.length - 1 &&
              (next?.isNotEmpty ?? false)) {
            // 加载完成最后一项的回调
            // SchedulerBinding.instance
            //     .addPostFrameCallback((_) => lastComplete?.call());
            lastComplete?.call();
          }

          final GalleryProvider _provider = galleryProviders[index];
          Get.lazyReplace(() => _provider, tag: _provider.gid, fenix: true);
          Get.lazyReplace(
            () => GalleryItemController(
                galleryProvider: Get.find(tag: _provider.gid)),
            tag: _provider.gid,
            fenix: true,
          );

          // return GalleryItemWidget(
          //   galleryProvider: _provider,
          //   tabTag: tabTag,
          // );

          return FrameSeparateWidget(
            index: index,
            placeHolder: const GalleryItemPlaceHolder(),
            child: GalleryItemWidget(
              galleryProvider: _provider,
              tabTag: tabTag,
            ),
          );
        },
        onItemKey: (index) => galleryProviders[index].gid ?? '',
        childCount: galleryProviders.length,
        keepPosition: keepPosition,
      ),
    );
  }

  // Widget itemBuilder
}

Widget buildGallerySliverListView(
  List<GalleryProvider> galleryProviders,
  dynamic tabTag, {
  String? next,
  VoidCallback? lastComplete,
  Key? key,
  Key? centerKey,
  int? lastTopItemIndex,
  bool keepPosition = false,
}) {
  logger.t('buildGallerySliverListView');

  return FlutterSliverList(
    delegate: FlutterListViewDelegate(
      (context, index) {
        if (galleryProviders.length - 1 < index) {
          return const SizedBox.shrink();
        }

        if (index == galleryProviders.length - 1 &&
            (next?.isNotEmpty ?? false)) {
          // 加载完成最后一项的回调
          SchedulerBinding.instance
              .addPostFrameCallback((_) => lastComplete?.call());
        }

        final GalleryProvider _provider = galleryProviders[index];
        Get.lazyReplace(() => _provider, tag: _provider.gid, fenix: true);
        Get.lazyReplace(
          () => GalleryItemController(
              galleryProvider: Get.find(tag: _provider.gid)),
          tag: _provider.gid,
          fenix: true,
        );

        // return GalleryItemWidget(
        //   galleryProvider: _provider,
        //   tabTag: tabTag,
        // );

        return FrameSeparateWidget(
          index: index,
          placeHolder: const GalleryItemPlaceHolder(),
          child: GalleryItemWidget(
            galleryProvider: _provider,
            tabTag: tabTag,
          ),
        );
      },
      onItemKey: (index) => galleryProviders[index].gid ?? '',
      childCount: galleryProviders.length,
      keepPosition: keepPosition,
    ),
  );
}
