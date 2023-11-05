import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:get/get.dart';

class BlockController extends GetxController {
  EhSettingService get ehSettingService => Get.find();

  BlockType? latestBlockType = BlockType.title;
  bool? latestEnableRegex = false;

  final ruleForTitle = <BlockRule>[].obs;
  final ruleForUploader = <BlockRule>[].obs;
  final ruleForCommentator = <BlockRule>[].obs;
  final ruleForComment = <BlockRule>[].obs;

  @override
  void onInit() {
    super.onInit();
    logger.d('onInit');
    ruleForTitle.value = ehSettingService.blockConfig.ruleForTitle ?? [];
    ruleForUploader.value = ehSettingService.blockConfig.ruleForUploader ?? [];
    ruleForCommentator.value =
        ehSettingService.blockConfig.ruleForCommentator ?? [];
    ruleForComment.value = ehSettingService.blockConfig.ruleForComment ?? [];
  }

  void updateBlockRule() {
    ehSettingService.blockConfig = ehSettingService.blockConfig.copyWith(
      ruleForTitle: ruleForTitle,
      ruleForUploader: ruleForUploader,
      ruleForCommentator: ruleForCommentator,
      ruleForComment: ruleForComment,
    );
  }

  void addBlockRule(BlockRule result) {
    logger.d('start addBlockRule ${result.toJson()}');
    if (result.ruleText?.trim().isEmpty ?? true) {
      return;
    }
    final BlockType? _blockType =
        BlockType.values.asNameMap()[result.blockType];
    switch (_blockType) {
      case BlockType.title:
        ruleForTitle.add(result);
        break;
      case BlockType.uploader:
        ruleForUploader.add(result);
        break;
      case BlockType.commentator:
        ruleForCommentator.add(result);
        break;
      case BlockType.comment:
        ruleForComment.add(result);
        break;
      default:
        break;
    }
  }
}
