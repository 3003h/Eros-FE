import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/pages/item/gallery_item_flow.dart';
import 'package:fehviewer/pages/item/gallery_item_flow_large.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class EhWaterfallFlow extends StatelessWidget {
  const EhWaterfallFlow(this.galleryProviders, this.tabTag,
      {this.next,
      this.lastComplete,
      this.large = false,
      this.centerKey,
      this.lastTopItemIndex,
      super.key});

  final List<GalleryProvider> galleryProviders;
  final dynamic tabTag;
  final String? next;
  final VoidCallback? lastComplete;
  final bool large;
  final Key? centerKey;
  final int? lastTopItemIndex;

  EhSettingService get _ehSettingService => Get.find();

  @override
  Widget build(BuildContext context) {
    final double _padding = large
        ? EHConst.waterfallFlowLargeCrossAxisSpacing
        : EHConst.waterfallFlowCrossAxisSpacing;

    final crossAxisSpacing = large
        ? EHConst.waterfallFlowLargeCrossAxisSpacing
        : EHConst.waterfallFlowCrossAxisSpacing;

    final mainAxisSpacing = large
        ? EHConst.waterfallFlowLargeMainAxisSpacing
        : EHConst.waterfallFlowMainAxisSpacing;

    return SliverPadding(
      padding: EdgeInsets.all(_padding),
      sliver: SliverWaterfallFlow(
        key: key,
        gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: getMaxCrossAxisExtent(),
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          lastChildLayoutTypeBuilder: (int index) =>
              index == galleryProviders.length
                  ? LastChildLayoutType.foot
                  : LastChildLayoutType.none,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (galleryProviders.length - 1 < index) {
              return const SizedBox.shrink();
            }

            if (index == galleryProviders.length - 1 &&
                (next?.isNotEmpty ?? false)) {
              // 加载完成最后一项的回调
              lastComplete?.call();
            }

            final GalleryProvider _provider = galleryProviders[index];
            Get.lazyReplace(() => _provider, tag: _provider.gid, fenix: true);
            Get.lazyReplace(
                () => GalleryItemController(
                    galleryProvider: Get.find(tag: _provider.gid)),
                tag: _provider.gid,
                fenix: true);

            if (large) {
              Widget item = GalleryItemFlowLarge(
                key: index == lastTopItemIndex
                    ? centerKey
                    : ValueKey(_provider.gid),
                galleryProvider: _provider,
                tabTag: tabTag,
              );

              // item = FrameSeparateWidget(
              //   index: index,
              //   child: item,
              // );

              return item;
            } else {
              return GalleryItemFlow(
                key: index == lastTopItemIndex
                    ? centerKey
                    : ValueKey(_provider.gid),
                galleryProvider: _provider,
                tabTag: tabTag,
              );
            }
          },
          childCount: galleryProviders.length,
        ),
      ),
    );
  }

  double getMaxCrossAxisExtent() {
    if (large) {
      final itemConfig =
          _ehSettingService.getItemConfig(ListModeEnum.waterfallLarge);
      const defaultMaxCrossAxisExtent =
          EHConst.waterfallFlowLargeMaxCrossAxisExtent;
      if (itemConfig?.enableCustomWidth ?? false) {
        return itemConfig?.customWidth?.toDouble() ?? defaultMaxCrossAxisExtent;
      } else {
        return defaultMaxCrossAxisExtent;
      }
    } else {
      final itemConfig =
          _ehSettingService.getItemConfig(ListModeEnum.waterfall);
      final defaultMaxCrossAxisExtent = Get.context!.isPhone
          ? EHConst.waterfallFlowMaxCrossAxisExtent
          : EHConst.waterfallFlowMaxCrossAxisExtentTablet;
      if (itemConfig?.enableCustomWidth ?? false) {
        return itemConfig?.customWidth?.toDouble() ?? defaultMaxCrossAxisExtent;
      } else {
        return defaultMaxCrossAxisExtent;
      }
    }
  }
}
