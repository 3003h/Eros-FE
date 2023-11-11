import 'package:fehviewer/common/controller/block_controller.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

class BlockRulesPage extends GetView<BlockController> {
  const BlockRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String _title = L10n.of(context).block_rules;

    final List<({String groupName, List<BlockRule> rules})> ruleGroups = [
      (groupName: L10n.of(context).title, rules: controller.ruleForTitle),
      (groupName: L10n.of(context).uploader, rules: controller.ruleForUploader),
      (
        groupName: L10n.of(context).commentator,
        rules: controller.ruleForCommentator
      ),
      (groupName: L10n.of(context).comment, rules: controller.ruleForComment),
    ];

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 8),
        middle: Text(_title),
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          minSize: 40,
          child: const Icon(
            CupertinoIcons.plus_circle,
            size: 28,
          ),
          onPressed: () async {
            final result = await Get.toNamed<dynamic>(
              EHRoutes.blockRuleEdit,
              id: isLayoutLarge ? 2 : null,
            );
            if (result != null && result is BlockRule) {
              controller.addBlockRule(result);
            }
          },
        ),
      ),
      child: CustomScrollView(slivers: [
        SliverSafeArea(
          sliver: Obx(() {
            return MultiSliver(
              children: [
                ...ruleGroups.map(
                  (e) {
                    if (e.rules.isEmpty) {
                      return const SliverToBoxAdapter();
                    }

                    return SliverCupertinoListSection.insetGrouped(
                      header: Text(e.groupName),
                      itemCount: e.rules.length,
                      itemBuilder: (BuildContext context, int index) {
                        final BlockRule _blockRule = e.rules[index];
                        return Slidable(
                          key:
                              Key('_blockRule.blockType${_blockRule.hashCode}'),
                          endActionPane: ActionPane(
                            extentRatio: 0.25,
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) => controller.removeRule(
                                    _blockRule.blockType, index),
                                backgroundColor: CupertinoDynamicColor.resolve(
                                    CupertinoColors.systemRed, context),
                                foregroundColor: CupertinoColors.white,
                                icon: CupertinoIcons.delete,
                                // label: L10n.of(context).delete,
                              ),
                            ],
                          ),
                          child: EhCupertinoListTile(
                            title: Text(_blockRule.ruleText ?? ''),
                            trailing: const CupertinoListTileChevron(),
                            onTap: () async {
                              final result = await Get.toNamed<dynamic>(
                                EHRoutes.blockRuleEdit,
                                arguments: _blockRule,
                                id: isLayoutLarge ? 2 : null,
                              );
                              if (result != null && result is BlockRule) {
                                controller.updateBlockRule(
                                  _blockRule,
                                  result,
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          }),
        ),
      ]),
    );
  }
}
