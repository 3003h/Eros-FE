import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ImageBlockPage extends StatelessWidget {
  const ImageBlockPage({super.key});

  @override
  Widget build(BuildContext context) {
    EhSettingService _ehSettingService = Get.find();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).image_block),
      ),
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
              sliver: MultiSliver(
            children: [
              SliverCupertinoListSection.listInsetGrouped(
                children: [
                  // QR_code_block switch
                  EhCupertinoListTile(
                    title: Text(L10n.of(context).QR_code_block),
                    trailing: Obx(() {
                      return CupertinoSwitch(
                        value: _ehSettingService.enableQRCodeCheck,
                        onChanged: (bool val) =>
                            _ehSettingService.enableQRCodeCheck = val,
                      );
                    }),
                  ),
                ],
              ),
              SliverCupertinoListSection.listInsetGrouped(children: [
                // phash_check switch
                EhCupertinoListTile(
                  title: Text(L10n.of(context).phash_check),
                  trailing: Obx(() {
                    return CupertinoSwitch(
                      value: _ehSettingService.enablePHashCheck,
                      onChanged: (bool val) =>
                          _ehSettingService.enablePHashCheck = val,
                    );
                  }),
                ),

                // to phash_block_list
                EhCupertinoListTile(
                  title: Text(L10n.of(context).phash_block_list),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {
                    Get.toNamed(
                      EHRoutes.mangaHidedImage,
                      id: isLayoutLarge ? 2 : null,
                    );
                  },
                ),
              ]),
            ],
          )),
        ],
      ),
    );
  }
}
