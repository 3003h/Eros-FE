import 'dart:ui';

import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/galleryComment.dart';
import 'package:fehviewer/pages/gallery_main/controller/comment_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'comment_item.dart';

const BorderSide _kDefaultRoundedBorderSide = BorderSide(
  color: CupertinoDynamicColor.withBrightness(
    color: Color(0x33000000),
    darkColor: Color(0x33FFFFFF),
  ),
  style: BorderStyle.solid,
  width: 0.0,
);
const Border _kDefaultRoundedBorder = Border(
  top: _kDefaultRoundedBorderSide,
  bottom: _kDefaultRoundedBorderSide,
  left: _kDefaultRoundedBorderSide,
  right: _kDefaultRoundedBorderSide,
);

const BoxDecoration _kDefaultRoundedBorderDecoration = BoxDecoration(
  color: CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: CupertinoColors.black,
  ),
  border: _kDefaultRoundedBorder,
  borderRadius: BorderRadius.all(Radius.circular(18.0)),
);

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
  @override
  Widget build(BuildContext context) {
    final CommentController controller = Get.find(tag: pageCtrlDepth);

    final Widget commList =
        controller.obx((List<GalleryComment> state) => ListView.builder(
              controller: controller.scrollController,
              // MediaQuery.of(context).viewInsets.bottom
              padding: EdgeInsets.only(
                  bottom: 60 + context.mediaQueryPadding.bottom),
              itemBuilder: (context, index) {
                return CommentItem(
                  galleryComment: state[index],
                );
              },
              itemCount: state.length,
            ));

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
                        const Text(
                          'Edit comment',
                          style: TextStyle(
                            color: CupertinoColors.activeBlue,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          controller.oriComment ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
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

    return CupertinoPageScaffold(
      // resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: Text(S.of(context).gallery_comments),
        // trailing: Container(
        //   width: 40,
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       // 评论按钮
        //       CupertinoButton(
        //         minSize: 40,
        //         padding: const EdgeInsets.all(0),
        //         child: const Icon(
        //           FontAwesomeIcons.edit,
        //           size: 20,
        //         ),
        //         onPressed: () {
        //           controller.showCommentModal(context);
        //         },
        //       ),
        //     ],
        //   ),
        // ),
      ),
      // child: commList,
      child: SafeArea(
        // minimum: const EdgeInsets.only(bottom: 20),
        bottom: false,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            GestureDetector(
              // behavior: HitTestBehavior.deferToChild,
              onTap: () {
                // 触摸收起键盘
                FocusScope.of(context).requestFocus(FocusNode());
              },
              onPanDown: (DragDownDetails details) {
                // 滑动收起键盘
                // FocusScope.of(context).requestFocus(FocusNode());
              },
              child: commList,
            ),
            SingleChildScrollView(
              child: Container(
                padding:
                    EdgeInsets.only(bottom: context.mediaQueryPadding.bottom),
                decoration: BoxDecoration(
                  border: _kDefaultEditBorder,
                  color: CupertinoDynamicColor.resolve(
                          ehTheme.themeData.barBackgroundColor, context)
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
                              decoration: _kDefaultRoundedBorderDecoration,
                              controller: controller.commentTextController,
                              focusNode: controller.focusNode,
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
                                    ScaleTransition(
                                        scale: animation, child: child),
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
  }
}

class CommentEditView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('New comment'),
        leading: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: Text(S.of(context).cancel),
          onPressed: () {
            Get.back();
          },
        ),
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: Text(S.of(context).ok),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      child: SafeArea(
        child: Container(
          child: const CupertinoTextField(
            decoration: null,
            // maxLines: null,
            maxLines: 100,
            keyboardType: TextInputType.multiline,
          ),
        ),
      ),
    );
  }
}
