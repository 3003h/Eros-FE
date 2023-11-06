import 'package:fehviewer/common/controller/block_controller.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/comment_controller.dart';
import 'package:fehviewer/pages/gallery/view/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'comment_item.dart';

const Color _kDefaultNavBarBorderColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x33000000),
  darkColor: Color(0x33FFFFFF),
);

const Border _kDefaultEditBorder = Border(
  top: BorderSide(
    color: _kDefaultNavBarBorderColor,
    width: 0.5, // One physical pixel.
    style: BorderStyle.solid,
  ),
);

class CommentPage extends StatefulWidget {
  const CommentPage({Key? key}) : super(key: key);
  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage>
    with AutomaticKeepAliveClientMixin {
  late CommentController controller;

  EhSettingService get _ehSettingService => Get.find();
  BlockController get _blockController => Get.find();

  @override
  void initState() {
    super.initState();
    controller = Get.put(CommentController(), tag: pageCtrlTag);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    logger.d('pageCtrlTag $pageCtrlTag');
    final cps = CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).gallery_comments),
        previousPageTitle: L10n.of(context).back,
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SafeArea(
            bottom: false,
            top: false,
            child: commentListView(context),
          ),
          // 评论回复
          buildCommentTextField(context),
        ],
      ),
    );

    return cps;
  }

  // 评论列表
  Widget commentListView(BuildContext context) {
    if (!_ehSettingService.showComments) {
      return const SizedBox();
    }

    return Obx(() {
      logger.t('build commentListView');

      List<GalleryComment>? _comments;

      if (_ehSettingService.showOnlyUploaderComment) {
        final _uploaderId = controller.comments
            ?.firstWhere((element) => element.score.isEmpty)
            .memberId;

        if (_uploaderId != null) {
          _comments = controller.comments
              ?.where((element) => element.memberId == _uploaderId)
              .toList();
        } else {
          _comments = controller.comments
              ?.where((element) => element.name == controller.uploader)
              .toList();
        }
      } else {
        _comments = controller.comments;
      }

      // 根据屏蔽规则过滤评论
      _comments = _comments?.where((element) {
        return !_blockController.matchRule(
              text: element.text,
              blockType: BlockType.comment,
            ) &&
            !_blockController.matchRule(
              text: element.name,
              blockType: BlockType.commentator,
            );
      }).toList();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: kPadding),
        child: ListView.builder(
          padding: EdgeInsets.only(
            bottom: 60 + context.mediaQueryPadding.bottom,
            top: context.mediaQueryPadding.top +
                kMinInteractiveDimensionCupertino,
          ),
          itemBuilder: (context, index) {
            if (_comments == null || _comments.isEmpty) {
              return const SizedBox();
            }

            final comment = _comments[index];

            final hideComment = _ehSettingService.filterCommentsByScore &&
                (comment.score.isNotEmpty &&
                    (int.tryParse(comment.score) ?? 0) <=
                        _ehSettingService.scoreFilteringThreshold);

            if (!hideComment) {
              return CommentItem(
                galleryComment: comment,
              ).autoCompressKeyboard(context);
            } else {
              return const SizedBox();
            }
          },
          itemCount: _comments?.length ?? 0,
        ),
      );
    });
  }

  // 原始消息
  Widget _buildOriText(BuildContext context) {
    return Obx(
      () {
        if (controller.editState != EditState.newComment) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (controller.isEditStat)
                        Text(
                          L10n.of(context).edit_comment,
                          style: const TextStyle(
                            color: CupertinoColors.activeBlue,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        )
                      else
                        Row(
                          children: [
                            Text(
                              L10n.of(context).reply_to_comment,
                              style: const TextStyle(
                                color: CupertinoColors.activeOrange,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${controller.reptyUser}:',
                              style: const TextStyle(
                                color: CupertinoColors.activeBlue,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Text(
                        controller.isEditStat
                            ? controller.oriComment
                            : controller.reptyCommentText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.label, context),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                minSize: 0,
                child: const Icon(
                  FontAwesomeIcons.xmark,
                  // FontAwesomeIcons.solidCheckCircle,
                  size: 24,
                ),
                onPressed: controller.pressCancel,
              )
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget buildCommentTextField(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: context.mediaQueryPadding.bottom,
          left: context.mediaQueryPadding.left + 8,
          right: context.mediaQueryPadding.right + 8,
        ),
        decoration: BoxDecoration(
          border: _kDefaultEditBorder,
          color: CupertinoDynamicColor.resolve(
                  ehTheme.themeData!.barBackgroundColor, context)
              .withOpacity(1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 编辑原消息 或者回复消息 时的显示
            _buildOriText(context),
            // 输入框
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                    child: CupertinoTextField(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 8.0),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: BoxDecoration(
                        color: ehTheme.commentTextFieldBackgroundColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(18.0)),
                      ),
                      controller: controller.commentTextController,
                      focusNode: controller.focusNode,
                      placeholder: L10n.of(context).new_comment,
                      strutStyle: const StrutStyle(height: 1.25),
                      // placeholderStyle: const TextStyle(fontSize: 16),
                      style: const TextStyle(fontSize: 16, height: 1.25),
                    ),
                  ),
                ),
                CupertinoTheme(
                  data: const CupertinoThemeData(
                    primaryColor: CupertinoColors.activeGreen,
                  ),
                  child: CupertinoButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    minSize: 0,
                    child: Obx(
                      () => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.bounceIn,
                        // switchOutCurve: Curves.linear,
                        transitionBuilder: (child, animation) =>
                            // ScaleTransition(
                            //     scale: animation, child: child),
                            FadeTransition(child: child, opacity: animation),
                        child: controller.isEditStat || controller.isReptyStat
                            ? Icon(
                                FontAwesomeIcons.solidCircleCheck,
                                key: UniqueKey(),
                                size: 34,
                              )
                            : Icon(
                                FontAwesomeIcons.circleArrowUp,
                                key: UniqueKey(),
                                size: 34,
                              ),
                      ),
                    ),
                    onPressed: controller.pressSend,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
