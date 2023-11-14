import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/pages/item/gallery_item_grid.dart';
import 'package:fehviewer/pages/item/gallery_item_grid_placeholder.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';

class EhGridView extends StatelessWidget {
  const EhGridView(this.galleryProviders, this.tabTag,
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
    return SliverPadding(
      padding: const EdgeInsets.all(EHConst.gridCrossAxisSpacing),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: getMaxCrossAxisExtent(),
          crossAxisSpacing: EHConst.gridCrossAxisSpacing,
          mainAxisSpacing: EHConst.gridMainAxisSpacing,
          childAspectRatio: EHConst.gridChildAspectRatio,
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

            return FrameSeparateWidget(
              index: index,
              placeHolder: const GalleryItemGridPlaceHolder(),
              child: GalleryItemGrid(
                key: index == lastTopItemIndex
                    ? centerKey
                    : ValueKey(_provider.gid),
                galleryProvider: _provider,
                tabTag: tabTag,
              ),
            );
          },
          childCount: galleryProviders.length,
        ),
      ),
    );
  }

  double getMaxCrossAxisExtent() {
    final itemConfig = _ehSettingService.getItemConfig(ListModeEnum.grid);
    const defaultMaxCrossAxisExtent = EHConst.gridMaxCrossAxisExtent;
    if (itemConfig?.enableCustomWidth ?? false) {
      return itemConfig?.customWidth?.toDouble() ?? defaultMaxCrossAxisExtent;
    } else {
      return defaultMaxCrossAxisExtent;
    }
  }
}
