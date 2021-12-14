import 'dart:ui';

import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/comment_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class CommentPage extends StatelessWidget {
  final CommentController controller = Get.find(tag: pageCtrlDepth);

  @override
  Widget build(BuildContext context) {
    // 评论列表
    Widget commentListView = controller.obx(
      (List<GalleryComment>? state) => ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.only(bottom: 60 + context.mediaQueryPadding.bottom),
        itemBuilder: (context, index) {
          return CommentItem(
            galleryComment: state![index],
          ).autoCompressKeyboard(context);
        },
        itemCount: state?.length ?? 0,
      ).paddingSymmetric(horizontal: 12),
    );

    // 原始消息
    Widget _buildOriText() {
      return Obx(
        () {
          if (controller.editState == EditState.editComment) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          L10n.of(context).edit_comment,
                          style: const TextStyle(
                            color: CupertinoColors.activeBlue,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.oriComment,
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
                    FontAwesomeIcons.times,
                    // FontAwesomeIcons.solidCheckCircle,
                    size: 24,
                  ),
                  onPressed: controller.pressCancle,
                )
              ],
            );
          } else {
            return Container();
          }
        },
      );
    }

    final cps = CupertinoPageScaffold(
      // resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).gallery_comments),
        previousPageTitle: L10n.of(context).back,
      ),
      // child: commentListView,
      child: SafeArea(
        // minimum: const EdgeInsets.only(bottom: 20),
        bottom: false,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container().autoCompressKeyboard(context),
            // 评论列表
            commentListView,
            // 评论回复
            SingleChildScrollView(
              child: Container(
                padding:
                    EdgeInsets.only(bottom: context.mediaQueryPadding.bottom),
                decoration: BoxDecoration(
                  border: _kDefaultEditBorder,
                  color: CupertinoDynamicColor.resolve(
                          ehTheme.themeData!.barBackgroundColor, context)
                      .withOpacity(1),
                  // color: Colors.transparent,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 编辑原消息时的显示
                    _buildOriText(),
                    // 输入框
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                            child: CupertinoTextField(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0, vertical: 6.0),
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: BoxDecoration(
                                color: ehTheme.commentTextFieldBackgroundColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(18.0)),
                              ),
                              controller: controller.commentTextController,
                              focusNode: controller.focusNode,
                              placeholder: L10n.of(context).new_comment,
                            ),
                          ),
                        ),
                        CupertinoTheme(
                          data: const CupertinoThemeData(
                            primaryColor: CupertinoColors.activeGreen,
                          ),
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 8),
                            minSize: 0,
                            child: Obx(
                              () => AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                switchInCurve: Curves.bounceIn,
                                // switchOutCurve: Curves.linear,
                                transitionBuilder: (child, animation) =>
                                    // ScaleTransition(
                                    //     scale: animation, child: child),
                                    FadeTransition(
                                        child: child, opacity: animation),
                                child: controller.isEditStat
                                    ? Icon(
                                        FontAwesomeIcons.solidCheckCircle,
                                        key: UniqueKey(),
                                        size: 32,
                                      )
                                    : Icon(
                                        FontAwesomeIcons.arrowCircleUp,
                                        key: UniqueKey(),
                                        size: 32,
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
            ),
          ],
        ),
      ),
    );

    return cps;
  }
}
