import 'dart:async';

import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/utils/openl/translator_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;

import '../../../utils/bcd_code.dart';
import 'gallery_page_controller.dart';
import 'gallery_page_state.dart';

enum EditState {
  newComment,
  editComment,
  reptyComment,
}

class CommentController extends GetxController {
  CommentController();

  GalleryPageController get pageController {
    logger.t('CommentController -> pageCtrlDepth: $pageCtrlTag');
    return Get.find(tag: pageCtrlTag);
  }

  UserController get userController => Get.find();
  bool get isLogin => userController.isLogin;

  BCDCode get bcdCode => BCDCode(code0: '·', code1: '-');

  GalleryPageState get _pageState => pageController.gState;
  List<GalleryComment>? get comments => _pageState.comments;

  String? get uploader => _pageState.galleryProvider?.uploader;

  // id降序排序
  List<GalleryComment> get commentsSorted => List<GalleryComment>.from(
      comments ?? [])
    ..sort((a, b) => int.parse(b.id ?? '0').compareTo(int.parse(a.id ?? '0')));

  final TextEditingController commentTextController = TextEditingController();

  GalleryProvider? get _item => _pageState.galleryProvider;
  late String comment;
  late String oriComment;
  String? commentId;
  FocusNode focusNode = FocusNode();

  late String reptyCommentText;
  late String reptyUser;

  final Rx<EditState> _editState = EditState.newComment.obs;

  EditState get editState => _editState.value;

  set editState(EditState val) => _editState.value = val;

  bool get isEditStat => _editState.value == EditState.editComment;
  bool get isReptyStat => _editState.value == EditState.reptyComment;

  @override
  void onInit() {
    super.onInit();
    logger.t('CommentController onInit');
  }

  @override
  void onClose() {
    for (final element in _tgr) {
      element.dispose();
    }
    super.onClose();
  }

  Future<void> onRefresh() async {
    await pageController.handOnRefresh();
  }

  final List<TapGestureRecognizer> _tgr = [];

  TapGestureRecognizer genTapGestureRecognizer() {
    _tgr.add(TapGestureRecognizer());
    return _tgr.last;
  }

  GalleryComment? parserCommentRepty(GalleryComment comment) {
    GalleryComment? repty;

    // 用户名无空格 id为 #1234# 或者摩尔斯密码形式
    final reg = RegExp(r'\s*@(\S+)((?!#\d+#).)+(#(\d+)#|\n([ ·-]+))?');
    final match = reg.firstMatch(comment.text);
    if (match == null || match.groupCount == 0) {
      return null;
    }

    final curIndex =
        commentsSorted.indexWhere((element) => element.id == comment.id);
    if (curIndex < 0) {
      return null;
    }
    final fill =
        commentsSorted.getRange(curIndex, commentsSorted.length).toList();

    // logger.d('${commentsSorted.map((e) {
    //   final id = e.id ?? '';
    //   return '$id  ${id.substring(min(id.length, 4))}  ${morseCode.enCode(id)} ';
    // }).join('\n')} ');

    // for (int i = 0; i < match.groupCount + 1; i++) {
    //   logger.d('($i)  ${match.group(i)}');
    // }

    final reptyUserName = match.group(1);
    final reptyId = match.group(4);
    final reptyIdMorse = match.group(5);

    // 有明确的评论id的
    if (reptyId != null) {
      repty = comments?.firstWhereOrNull((element) => element.id == reptyId);
    }

    // id
    if (reptyIdMorse != null && reptyIdMorse.isNotEmpty) {
      final reptyId = bcdCode.deCode(reptyIdMorse);
      logger.d('reptyId: [$reptyIdMorse]  => $reptyId');
      repty = comments?.firstWhereOrNull((element) => element.id == reptyId);
    }

    // 没有明确的评论id 或id和所 @用户名 对应不上的
    if (repty == null && reptyUserName != null) {
      // reptyUserName发表的离当前评论最进的评论
      repty = fill.firstWhereOrNull((element) => element.name == reptyUserName);
    }

    if (repty == null) {
      // 如果还是匹配不上 考虑用户名中带空格的可能性 但是需要换行结束
      final regSpace = RegExp(r'\s*@(.+)(\n)?');
      final matchSpace = regSpace.firstMatch(comment.text);
      if (matchSpace == null || matchSpace.groupCount == 0) {
        return null;
      }

      // for (int i = 1; i < matchSpace.groupCount + 1; i++) {
      //   logger.d('space ($i)  ${matchSpace.group(i)}');
      // }

      final _splitRegexp = RegExp(r'[\s+,.，。]');
      final text = matchSpace.group(1) ?? '';
      final arr = text.split(_splitRegexp);
      for (int i = arr.length; i > 0; i--) {
        final _name = arr.getRange(0, i).join(' ');
        // logger.d('name ($_name)');

        repty = fill.firstWhereOrNull(
            (element) => element.name.replaceAll(_splitRegexp, ' ') == _name);
        if (repty != null) {
          return repty;
        }
      }
    }

    return repty;
  }

  List<GalleryComment?> parserAllCommentRepty(GalleryComment comment) {
    List<String> textList =
        (comment.text).split('@').map((e) => '@$e').toList();

    final reps = <GalleryComment?>[];

    int textNum = 0;
    for (final commentText in textList) {
      textNum++;
      if (textNum == 1) {
        continue;
      }

      // 用户名无空格 id为 bcd code
      final reg = RegExp(r'\s*@(\S+)((?!#\d+#).)+(#(\d+)#|\n([ ·-]+))?');
      final match = reg.firstMatch(commentText);
      if (match == null || match.groupCount == 0) {
        continue;
      }

      final curIndex =
          commentsSorted.indexWhere((element) => element.id == comment.id);
      if (curIndex < 0) {
        continue;
      }
      final fill =
          commentsSorted.getRange(curIndex, commentsSorted.length).toList();

      for (int i = 0; i < match.groupCount + 1; i++) {
        logger.t('($i)  ${match.group(i)}');
      }

      final reptyUserName = match.group(1);
      final reptyId = match.group(4);
      final reptyIdMorse = match.group(5);

      GalleryComment? repty;

      // 有明确的评论id的
      if (reptyId != null) {
        repty = comments?.firstWhereOrNull((element) => element.id == reptyId);
      }

      // id
      if (reptyIdMorse != null && reptyIdMorse.isNotEmpty) {
        final reptyId = bcdCode.deCode(reptyIdMorse);
        // logger.d('reptyId: [$reptyIdMorse]  => $reptyId');
        repty = comments?.firstWhereOrNull((element) => element.id == reptyId);
      }

      // 没有明确的评论id 或id和所 @用户名 对应不上的
      if (repty == null && reptyUserName != null) {
        // reptyUserName发表的离当前评论最进的评论
        repty =
            fill.firstWhereOrNull((element) => element.name == reptyUserName);
        logger.t('没有明确的评论id 或id和所 @用户名 对应不上的\n${repty?.toJson()}');
      }

      if (repty == null) {
        // 如果还是匹配不上 考虑用户名中带空格的可能性 但是需要换行结束
        final regSpace = RegExp(r'\s*@(.+)(\n)?');
        final matchSpace = regSpace.firstMatch(commentText);
        if (matchSpace == null || matchSpace.groupCount == 0) {
          continue;
        }

        // for (int i = 1; i < matchSpace.groupCount + 1; i++) {
        //   logger.d('space ($i)  ${matchSpace.group(i)}');
        // }

        final _splitRegexp = RegExp(r'[\s+,.，。]');
        final text = matchSpace.group(1) ?? '';
        final arr = text.split(_splitRegexp);
        for (int i = arr.length; i > 0; i--) {
          final _name = arr.getRange(0, i).join(' ');
          // logger.d('name ($_name)');

          repty = fill.firstWhereOrNull(
              (element) => element.name.replaceAll(_splitRegexp, ' ') == _name);
        }
      }

      if (repty != null) {
        reps.add(repty);
      }
    }

    if (reps.isEmpty) {
      final repty = parserCommentRepty(comment);
      if (repty != null) {
        reps.add(repty);
      }
    }

    return reps;
  }

  // 翻译评论内容
  Future<void> commitTranslate(String _id) async {
    logger.t('commitTranslate');
    final int? _commentIndex =
        comments?.indexWhere((element) => element.id == _id.toString());
    final comment = comments?[_commentIndex!];

    if (comment?.translatedElement != null &&
        comment?.translatedElement is dom.Element) {
      comments![_commentIndex!] = comments![_commentIndex].copyWith(
        showTranslate: !(comments![_commentIndex].showTranslate ?? false),
      );

      return;
    }

    // new dom.Element from comment?.element
    final _translatedElement = (comment?.element as dom.Element?)?.clone(true);
    if (_translatedElement == null) {
      return;
    }

    final _translatedTextList = <String>[];

    logger.d('t :${comment?.text}');
    await _translateText(_translatedElement, _translatedTextList);

    logger.d('t :${_translatedTextList.join('\n')}');

    comments![_commentIndex!] = comments![_commentIndex].copyWith(
      showTranslate: !(comments![_commentIndex].showTranslate ?? false),
      translatedElement: _translatedElement,
    );

    // update([_id]);
  }

  Future<void> _translateText(
    dom.Element element,
    List<String> translatedTextList,
  ) async {
    if (element.nodes.isEmpty) {
      translatedTextList.add(element.text);
    } else {
      for (final dom.Node node in element.nodes) {
        if (node is dom.Element) {
          if (node.localName == 'br') {
            translatedTextList.add('\n');
          } else if (node.localName == 'a') {
            translatedTextList.add(node.text);
          } else if (node.localName == 'img') {
            translatedTextList.add(
                node.attributes['alt'] ?? '[Image]${node.attributes['src']}');
          } else {
            await _translateText(node, translatedTextList);
          }
        } else if (node is dom.Text) {
          final text = node.text;
          if (text.trim().isNotEmpty) {
            final translate = await translatorHelper.translateText(text) ?? '';
            node.text = translate;
          }
          translatedTextList.add(node.text);
        }
      }
    }
  }

  // 点赞
  Future<void> commitVoteUp(String _id) async {
    if (comments == null) {
      return;
    }

    logger.t('commit up id $_id');
    final int? _commentIndex =
        comments?.indexWhere((element) => element.id == _id.toString());
    comments![_commentIndex!] = comments![_commentIndex].copyWith(vote: 1);

    update([_id]);
    final CommitVoteRes rult = await Api.commitVote(
      apikey: _item?.apikey ?? '',
      apiuid: _item?.apiuid ?? '',
      gid: _item?.gid ?? '0',
      token: _item?.token ?? '',
      commentId: _id,
      vote: 1,
    );
    _paraRes(rult);
    if (rult.commentVote != 0) {
      showToast(L10n.of(Get.context!).vote_up_successfully);
    }
  }

  // 点踩
  Future<void> commitVoteDown(String _id) async {
    logger.t('commit down id $_id');
    final int? _commentIndex =
        comments?.indexWhere((element) => element.id == _id.toString());
    comments![_commentIndex!] = comments![_commentIndex].copyWith(vote: -1);
    update([_id]);
    final CommitVoteRes rult = await Api.commitVote(
      apikey: _item?.apikey ?? '',
      apiuid: _item?.apiuid ?? '',
      gid: _item?.gid ?? '',
      token: _item?.token ?? '',
      commentId: _id,
      vote: -1,
    );
    _paraRes(rult);
    if (rult.commentVote != 0) {
      showToast(L10n.of(Get.context!).vote_down_successfully);
    }
  }

  // 点赞和踩的响应处理
  void _paraRes(CommitVoteRes rult) {
    logger.t('${rult.toJson()}');

    final int? _commentIndex = comments?.indexWhere(
        (GalleryComment element) => element.id == rult.commentId.toString());
    comments![_commentIndex!] = comments![_commentIndex]
        .copyWith(vote: rult.commentVote, score: '${rult.commentScore}');

    update();
    logger.t('update CommentController id ${rult.commentId}');
  }

  // 推送评论
  Future<void> _postComment(String comment,
      {bool isEdit = false, String? commentId}) async {
    logger.d('_postComment\n$comment');
    // final bool result = await Api.postComment(
    //   gid: pageController.gid,
    //   token: pageController.galleryProvider?.token ?? '',
    //   comment: comment,
    //   commentId: commentId,
    //   isEdit: isEdit,
    // );
    //
    // if (result) {
    //   await pageController.handOnRefresh();
    // }
    final result = await postComment(
      gid: _pageState.gid,
      token: _pageState.galleryProvider?.token ?? '',
      comment: comment,
      commentId: commentId,
      isEdit: isEdit,
    );

    if (result ?? false) {
      logger.d('_postComment handOnRefresh');
      await pageController.handOnRefresh();
    }
  }

  // 好像会有重复执行的问题
  Future<void> pressSendOld() async {
    comment = commentTextController.text;
    logger.d('comment: $comment');
    FocusScope.of(Get.context!).requestFocus(FocusNode());

    final Completer completer = Completer();

    showLoadingDialog(
      Get.context!,
      completer,
      () async {
        await _postComment(
          comment,
          isEdit: editState == EditState.editComment,
          commentId: commentId,
        );
        pressCancel();
        // await Future.delayed(const Duration(seconds: 3));
        logger.t('_postComment $comment');
      },
    );
  }

  Future<void> pressSend() async {
    comment = commentTextController.text;
    logger.d('comment: $comment');
    FocusScope.of(Get.context!).requestFocus(FocusNode());

    final indicator = Center(
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
    SmartDialog.showLoading(builder: (_) => indicator, backDismiss: false);

    // await Future.delayed(const Duration(seconds: 2));
    logger.t('_postComment $comment');
    try {
      await _postComment(
        comment,
        isEdit: editState == EditState.editComment,
        commentId: commentId,
      );
    } finally {
      pressCancel();
      SmartDialog.dismiss();
    }
  }

  void pressCancel() {
    oriComment = '';
    commentTextController.clear();
    editState = EditState.newComment;
    // FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  // 编辑评论
  void editComment({required String id, required String oriComment}) {
    comment = oriComment;
    commentId = id;
    this.oriComment = oriComment;
    commentTextController.value = TextEditingValue(
      text: comment,
      selection: TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream, offset: comment.length)),
    );
    editState = EditState.editComment;
    FocusScope.of(Get.context!).requestFocus(focusNode);
    // _scrollToBottom();
  }

  // 回复评论
  void reptyComment({required String reptyCommentId}) {
    final repty =
        comments?.firstWhereOrNull((element) => element.id == reptyCommentId);

    reptyCommentText = repty?.text.replaceAll('\n', '    ') ?? '';
    reptyUser = repty?.name ?? '';

    if (repty != null) {
      // comment = '@${repty.name} #${repty.id}#\n';
      // MorseCode(dah: '_').enCode(id)
      comment = '@${repty.name}\n${bcdCode.enCode(repty.id ?? '')}\n';
    }

    commentTextController.value = TextEditingValue(
      text: comment,
      selection: TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream, offset: comment.length)),
    );
    editState = EditState.reptyComment;
    FocusScope.of(Get.context!).requestFocus(focusNode);
    // _scrollToBottom();
  }
}

/// 显示等待
Future<void> showLoadingDialog(
  BuildContext context,
  Completer completer,
  Function function,
) async {
  logger.t('showLoadingDialog');

  Future<void> runFunc() async {
    try {
      await function.call();
      completer.complete();
    } catch (e) {
      logger.e('$e');
      completer.complete([e]);
    }
    logger.d('currentRoute ${Get.currentRoute}');
  }

  return await showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) {
      logger5.v('builder showLoadingDialog');

      runFunc().then((_) {
        if (completer.isCompleted) {
          Get.back();
        }
      });

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
