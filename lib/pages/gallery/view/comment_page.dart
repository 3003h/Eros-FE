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
  const CommentPage({super.key});

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
    // logger.d('pageCtrlTag $pageCtrlTag');
    return CupertinoPageScaffold(
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
  }

  // 评论列表
  Widget commentListView(BuildContext context) {
    if (!_ehSettingService.showComments) {
      return const SizedBox();
    }

    return Obx(() {
      logger.t('build commentListView');

      List<GalleryComment> comments =
          _filterComments(controller.comments) ?? [];

      return CustomScrollView(
        slivers: [
          SliverSafeArea(
            bottom: false,
            sliver: CupertinoSliverRefreshControl(
              onRefresh: controller.onRefresh,
            ),
          ),
          if (comments.isEmpty)
            const SliverFillRemaining()
          else
            SliverSafeArea(
              top: false,
              minimum: EdgeInsets.only(
                  left: kPadding,
                  right: kPadding,
                  bottom: 64 + context.mediaQueryPadding.bottom),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _itemBuilder(comments[index]);
                  },
                  childCount: comments.length,
                ),
              ),
            ),
        ],
      );
    });
  }

  List<GalleryComment>? _filterComments(List<GalleryComment>? comments) {
    List<GalleryComment>? commentsFilter;

    if (_ehSettingService.showOnlyUploaderComment) {
      final uploaderId =
          comments?.firstWhere((element) => element.score.isEmpty).memberId;

      if (uploaderId != null) {
        commentsFilter = comments
            ?.where((element) => element.memberId == uploaderId)
            .toList();
      } else {
        commentsFilter = comments
            ?.where((element) => element.name == controller.uploader)
            .toList();
      }
    } else {
      commentsFilter = comments;
    }

    // 根据屏蔽规则过滤评论
    commentsFilter = commentsFilter?.where((element) {
      return !_blockController.matchRule(
            text: element.text,
            blockType: BlockType.comment,
          ) &&
          !_blockController.matchRule(
            text: element.name,
            blockType: BlockType.commentator,
          );
    }).toList();

    return commentsFilter;
  }

  Widget _itemBuilder(GalleryComment comment) {
    if (controller.comments == null || controller.comments!.isEmpty) {
      return const SizedBox();
    }

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
                onPressed: controller.pressCancel,
                child: const Icon(
                  FontAwesomeIcons.xmark,
                  // FontAwesomeIcons.solidCheckCircle,
                  size: 24,
                ),
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
                    onPressed: controller.pressSend,
                    child: Obx(
                      () => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.bounceIn,
                        // switchOutCurve: Curves.linear,
                        transitionBuilder: (child, animation) =>
                            // ScaleTransition(
                            //     scale: animation, child: child),
                            FadeTransition(opacity: animation, child: child),
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
