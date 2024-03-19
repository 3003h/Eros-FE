import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class BlockController extends GetxController {
  EhSettingService get ehSettingService => Get.find();

  BlockType? latestBlockType = BlockType.title;
  bool? latestEnableRegex = false;

  final ruleForTitle = <BlockRule>[].obs;
  final ruleForUploader = <BlockRule>[].obs;
  final ruleForCommentator = <BlockRule>[].obs;
  final ruleForComment = <BlockRule>[].obs;

  final blockRuleTextEditingController = TextEditingController();

  final _currentRuleText = ''.obs;
  String get currentRuleText => _currentRuleText.value;
  set currentRuleText(String value) => _currentRuleText.value = value;

  final _currentEnableRegex = false.obs;
  bool get currentEnableRegex => _currentEnableRegex.value;
  set currentEnableRegex(bool value) => _currentEnableRegex.value = value;

  bool get isRegexFormatError {
    if (currentRuleText.isEmpty || !currentEnableRegex) {
      return false;
    }
    // logger.d('currentRuleText $currentRuleText');
    try {
      RegExp(currentRuleText);
      return false;
    } catch (e) {
      logger.e('$e');
      return true;
    }
  }

  @override
  void onInit() {
    super.onInit();
    logger.d('onInit');
    ruleForTitle.value = ehSettingService.blockConfig.ruleForTitle ?? [];
    ruleForUploader.value = ehSettingService.blockConfig.ruleForUploader ?? [];
    ruleForCommentator.value =
        ehSettingService.blockConfig.ruleForCommentator ?? [];
    ruleForComment.value = ehSettingService.blockConfig.ruleForComment ?? [];

    blockRuleTextEditingController.addListener(() {
      currentRuleText = blockRuleTextEditingController.text;
    });
  }

  bool matchRule({String? text, required BlockType blockType}) {
    if (text == null || text.isEmpty) {
      return false;
    }
    final List<BlockRule> _ruleList = getRuleListByType(blockType);
    for (final BlockRule _rule in _ruleList) {
      // 不支持 (?i) 写法, 最小限度修正
      final _ruleText = _rule.ruleText?.trim().replaceAll('(?i)', '');

      // default enabled
      if (!(_rule.enabled ?? true) || _ruleText == null || _ruleText.isEmpty) {
        continue;
      }
      if (_rule.enableRegex ?? false) {
        try {
          final RegExp _regExp = RegExp(_ruleText);
          if (_regExp.hasMatch(text)) {
            logger.d('matchRule:${_rule.toJson()}\ntext: $text');
            return true;
          }
        } catch (e, s) {
          logger.e('$e\n$s');
          return false;
        }
      } else {
        if (text.contains(_ruleText)) {
          logger.d('matchRule: ${_rule.toJson()}\ntext: $text');
          return true;
        }
      }
    }
    return false;
  }

  List<BlockRule> getRuleListByType(BlockType? blockType) {
    switch (blockType) {
      case BlockType.title:
        return ruleForTitle;
      case BlockType.uploader:
        return ruleForUploader;
      case BlockType.commentator:
        return ruleForCommentator;
      case BlockType.comment:
        return ruleForComment;
      default:
        return [];
    }
  }

  void saveBlockRule() {
    ehSettingService.blockConfig = ehSettingService.blockConfig.copyWith(
      ruleForTitle: ruleForTitle.oN,
      ruleForUploader: ruleForUploader.oN,
      ruleForCommentator: ruleForCommentator.oN,
      ruleForComment: ruleForComment.oN,
    );
    Global.saveProfile();
  }

  void addBlockRule(BlockRule result) {
    logger.d('start addBlockRule ${result.toJson()}');
    if (result.ruleText?.trim().isEmpty ?? true) {
      return;
    }
    final BlockType? _blockType =
        BlockType.values.asNameMap()[result.blockType];
    getRuleListByType(_blockType).add(result);
    saveBlockRule();
  }

  void updateBlockRule(BlockRule oldBlockRule, BlockRule newBlockRule) {
    logger.d('oldBlockRule ${oldBlockRule.toJson()}');
    logger.d('newBlockRule ${newBlockRule.toJson()}');

    // if type is different, remove old rule and add new rule
    if (oldBlockRule.blockType != newBlockRule.blockType) {
      final _oldBlockType =
          BlockType.values.asNameMap()[oldBlockRule.blockType];
      removeRule(
        oldBlockRule.blockType,
        getRuleListByType(_oldBlockType).indexOf(oldBlockRule),
      );
      addBlockRule(newBlockRule);
      return;
    }

    if (newBlockRule.ruleText?.trim().isEmpty ?? true) {
      return;
    }
    final BlockType? _blockType =
        BlockType.values.asNameMap()[oldBlockRule.blockType];

    final int _index = getRuleListByType(_blockType).indexOf(oldBlockRule);
    getRuleListByType(_blockType)[_index] = newBlockRule;

    saveBlockRule();
  }

  void removeRule(String? blockType, int index) {
    logger.d('removeRule $blockType $index');
    final BlockType? _blockType = BlockType.values.asNameMap()[blockType];
    getRuleListByType(_blockType).removeAt(index);
    saveBlockRule();
  }
}
