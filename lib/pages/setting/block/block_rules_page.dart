import 'package:fehviewer/common/controller/block_controller.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
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
        child: CustomScrollView(
          slivers: [
            SliverSafeArea(
              left: false,
              right: false,
              sliver: MultiSliver(children: [
                ...ruleGroups.map(
                  (e) => MultiSliver(
                    pushPinnedChildren: true,
                    children: [
                      if (e.rules.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.only(
                            left: 20,
                            bottom: 4,
                            top: 20,
                          ),
                          width: double.infinity,
                          child: Text(
                            e.groupName ?? '',
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final BlockRule _blockRule = e.rules[index];
                            return Slidable(
                              key: Key(
                                  '_blockRule.blockType${_blockRule.hashCode}'),
                              endActionPane: ActionPane(
                                extentRatio: 0.25,
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) => controller.removeRule(
                                        _blockRule.blockType, index),
                                    backgroundColor:
                                        CupertinoDynamicColor.resolve(
                                            CupertinoColors.systemRed, context),
                                    foregroundColor: Colors.white,
                                    icon: CupertinoIcons.delete,
                                    // label: L10n.of(context).delete,
                                  ),
                                ],
                              ),
                              child: SelectorSettingItem(
                                title: _blockRule.ruleText ?? '',
                                hideDivider: _blockRule == e.rules.last,
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
                          childCount: e.rules.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      );
    });
  }
}
