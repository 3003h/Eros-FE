import 'package:eros_fe/common/controller/block_controller.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/component/setting_base.dart';
import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

class BlockersPage extends GetView<BlockController> {
  const BlockersPage({super.key});

  Widget _buildSlide(
    BuildContext context, {
    required int score,
    required bool enable,
  }) {
    const kMaxRating = 100.0;
    const kMinRating = -100.0;
    return StatefulBuilder(builder: (context, setState) {
      TextEditingController textEditingController =
          TextEditingController.fromValue(
        TextEditingValue(
          text: score.toString(),
          selection: TextSelection.fromPosition(
            TextPosition(
              affinity: TextAffinity.downstream,
              offset: score.toString().length,
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
                  value: score.toDouble(),
                  min: kMinRating,
                  max: kMaxRating,
                  activeColor: enable ? null : CupertinoColors.systemGrey,
                  onChanged: enable
                      ? (double val) {
                          setState(() {
                            score = val.toInt();
                          });
                        }
                      : null,
                  onChangeEnd: (double val) {
                    controller.ehSettingService.scoreFilteringThreshold =
                        val.toInt();
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
                    score = int.parse(textEditingController.text)
                        .clamp(kMinRating, kMaxRating)
                        .toInt();

                    textEditingController.text = score.toString();

                    controller.ehSettingService.scoreFilteringThreshold = score;
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
                SliverCupertinoListSection.listInsetGrouped(children: [
                  // to block_rules
                  EhCupertinoListTile(
                    title: Text(L10n.of(context).block_rules),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      Get.toNamed(
                        EHRoutes.blockRules,
                        id: isLayoutLarge ? 2 : null,
                      );
                    },
                  ),
                ]),
                SliverCupertinoListSection.listInsetGrouped(
                  footer:
                      Text(L10n.of(context).filter_comments_by_score_summary),
                  children: [
                    // filter_comments_by_score switch
                    EhCupertinoListTile(
                      title: Text(L10n.of(context).filter_comments_by_score),
                      // subtitle:
                      //     Text(L10n.of(context).filter_comments_by_score_summary),
                      trailing: Obx(() {
                        return CupertinoSwitch(
                          value:
                              controller.ehSettingService.filterCommentsByScore,
                          onChanged: (bool val) => controller
                              .ehSettingService.filterCommentsByScore = val,
                        );
                      }),
                    ),
                    Obx(() {
                      return _buildSlide(
                        context,
                        score:
                            controller.ehSettingService.scoreFilteringThreshold,
                        enable:
                            controller.ehSettingService.filterCommentsByScore,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
