import 'package:fehviewer/common/controller/block_controller.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class BlockersPage extends GetView<BlockController> {
  const BlockersPage({super.key});

  Widget _buildSlide(BuildContext context, int score) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        constraints: const BoxConstraints(minHeight: kItemHeight),
        color: CupertinoDynamicColor.resolve(
            ehTheme.itemBackgroundColor!, context),
        child: Row(
          children: [
            Expanded(
              child: CupertinoSlider(
                value: score.toDouble(),
                min: -100,
                max: 100,
                onChanged: (double val) {
                  setState(() {
                    score = val.toInt();
                  });
                },
                onChangeEnd: (double val) {
                  logger.d('onChangeEnd $val');
                  controller.ehSettingService.scoreFilteringThreshold =
                      val.toInt();
                },
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text('${score.toInt()}'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final String _title = L10n.of(context).blockers;

    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(start: 0),
          middle: Text(_title),
        ),
        child: SafeArea(
          bottom: false,
          top: false,
          child: ListView(
            children: [
              if (!kReleaseMode)
                SelectorSettingItem(
                  hideDivider: true,
                  title: 'Block Rules',
                  onTap: () {
                    Get.toNamed(
                      EHRoutes.blockRules,
                      id: isLayoutLarge ? 2 : null,
                    );
                  },
                ),
              if (!kReleaseMode) const ItemSpace(),
              // 开关
              Obx(() {
                return TextSwitchItem(
                  L10n.of(context).filter_comments_by_score,
                  desc: L10n.of(context).filter_comments_by_score_summary,
                  value: controller.ehSettingService.filterCommentsByScore,
                  onChanged: (val) =>
                      controller.ehSettingService.filterCommentsByScore = val,
                  // hideDivider:
                  //     !controller.ehSettingService.filterCommentsByScore,
                  hideDivider: true,
                );
              }),
              Obx(() {
                return AnimatedCrossFade(
                  firstChild: const SizedBox(),
                  secondChild: _buildSlide(context,
                      controller.ehSettingService.scoreFilteringThreshold),
                  crossFadeState:
                      controller.ehSettingService.filterCommentsByScore
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                  secondCurve: Curves.easeOut,
                  duration: const Duration(milliseconds: 200),
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}
