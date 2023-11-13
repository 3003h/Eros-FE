import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ImageBlockPage extends StatelessWidget {
  const ImageBlockPage({super.key});

  EhSettingService get _ehSettingService => Get.find();

  @override
  Widget build(BuildContext context) {
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

                  Obx(() {
                    return _buildSlide(
                      context,
                      pHashThreshold: _ehSettingService.pHashThreshold,
                      enable: _ehSettingService.enablePHashCheck,
                    );
                  }),
                ]),
                SliverCupertinoListSection.listInsetGrouped(children: [
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(
    BuildContext context, {
    required int pHashThreshold,
    required bool enable,
  }) {
    const kMaxRating = 20.0;
    const kMinRating = 1.0;
    return StatefulBuilder(builder: (context, setState) {
      TextEditingController textEditingController =
          TextEditingController.fromValue(
        TextEditingValue(
          text: pHashThreshold.toString(),
          selection: TextSelection.fromPosition(
            TextPosition(
              affinity: TextAffinity.downstream,
              offset: pHashThreshold.toString().length,
            ),
          ),
        ),
      );

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        constraints: const BoxConstraints(minHeight: kItemHeight),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: CupertinoSlider(
                  value: pHashThreshold.toDouble(),
                  min: kMinRating,
                  max: kMaxRating,
                  activeColor: enable ? null : CupertinoColors.systemGrey,
                  onChanged: enable
                      ? (double val) {
                          setState(() {
                            pHashThreshold = val.toInt();
                          });
                        }
                      : null,
                  onChangeEnd: (double val) {
                    _ehSettingService.pHashThreshold = val.toInt();
                  },
                ),
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: CupertinoTextField(
                  textAlign: TextAlign.center,
                  enabled: enable,
                  style: TextStyle(
                    color: enable ? null : CupertinoColors.systemGrey,
                  ),
                  controller: textEditingController,
                  keyboardType: TextInputType.number,
                  onEditingComplete: () {
                    pHashThreshold = int.parse(textEditingController.text)
                        .clamp(kMinRating, kMaxRating)
                        .toInt();

                    textEditingController.text = pHashThreshold.toString();

                    _ehSettingService.pHashThreshold = pHashThreshold;

                    // close keyboard
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
