import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery_main/view/comment_page.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'gallery_page_controller.dart';

enum EditState {
  newComment,
  editComment,
}

class CommentController extends GetxController
    with StateMixin<List<GalleryComment>> {
  CommentController({this.pageController});
  final GalleryPageController pageController;
  final TextEditingController commentTextController = TextEditingController();

  GalleryItem get _item => pageController.galleryItem;
  String comment;
  String oriComment;
  String commentId;
  FocusNode focusNode = FocusNode();

  final Rx<EditState> _editState = EditState.newComment.obs;
  EditState get editState => _editState.value;
  set editState(EditState val) => _editState.value = val;

  @override
  void onInit() {
    super.onInit();
    logger.d('CommentController onInit');
    change(pageController.galleryItem.galleryComment,
        status: RxStatus.success());
  }

  Future<void> commitVoteUp(String _id) async {
    logger.d('commit up id $_id');
    state.firstWhere((element) => element.id == _id.toString()).vote = 1;
    update(['$_id']);
    final CommitVoteRes rult = await Api.commitVote(
      apikey: _item.apikey,
      apiuid: _item.apiuid,
      gid: _item.gid,
      token: _item.token,
      commentId: _id,
      vote: 1,
    );
    _paraRes(rult);
    showToast('commitVoteUp successfully');
  }

  Future<void> commitVoteDown(String _id) async {
    logger.d('commit down id $_id');
    state.firstWhere((element) => element.id == _id.toString()).vote = -1;
    update(['$_id']);
    final CommitVoteRes rult = await Api.commitVote(
      apikey: _item.apikey,
      apiuid: _item.apiuid,
      gid: _item.gid,
      token: _item.token,
      commentId: _id,
      vote: -1,
    );
    _paraRes(rult);
    showToast('commitVoteDown successfully');
  }

  void _paraRes(CommitVoteRes rult) {
    logger.d('${rult.toJson()}');
    state.firstWhere((element) => element.id == rult.commentId.toString())
      ..vote = rult.commentVote
      ..score = '${rult.commentScore}';
    update(['${rult.commentId}']);
  }

  Future<void> _postComment(String comment,
      {bool isEdit = false, String commentId}) async {
    final bool rult = await Api.postComment(
      gid: pageController.gid,
      token: pageController.galleryItem.token,
      comment: comment,
      commentId: commentId,
      isEdit: isEdit,
    );

    if (rult) {
      await pageController.handOnRefresh();
    }
  }

  void showCommentModal(context) {
    CupertinoScaffold.showCupertinoModalBottomSheet(
      context: context,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.linearToEaseOut.flipped,
      builder: (context) => CommentEditView(),
    );

/*    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('comment'),
            content: Container(),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(S.of(context).ok),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          );
        });*/
  }

  Future<void> pressSend() async {
    comment = commentTextController.text;
    logger.d('comment: $comment');
    FocusScope.of(Get.context).requestFocus(FocusNode());

    showLoadingDialog(Get.context, () async {
      await _postComment(
        comment,
        isEdit: editState == EditState.editComment,
        commentId: commentId,
      );
      pressCancle();
    });
  }

  void pressCancle() {
    oriComment = '';
    commentTextController.clear();
    editState = EditState.newComment;
    // FocusScope.of(Get.context).requestFocus(FocusNode());
  }

  void editComment({String id, String oriComment}) {
    comment = oriComment;
    commentId = id;
    this.oriComment = oriComment;
    commentTextController.value = TextEditingValue(
      text: comment,
      selection: TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream, offset: comment.length)),
    );
    editState = EditState.editComment;
    FocusScope.of(Get.context).requestFocus(focusNode);
  }
}

/// 显示等待
Future<void> showLoadingDialog(BuildContext context, Function function) async {
  return showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) {
      Future<void>.delayed(const Duration(milliseconds: 0))
          .then((_) => function())
          .whenComplete(() => Get.back());

      return Center(
        child: CupertinoPopupSurface(
          child: Container(
              height: 80,
              width: 80,
              alignment: Alignment.center,
              child: const CupertinoActivityIndicator(
                radius: 20,
              )),
        ),
      );
    },
  );
}
