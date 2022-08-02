import 'dart:async';

import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/utils/openl/translator_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../../../utils/bcd_code.dart';
import 'gallery_page_controller.dart';
import 'gallery_page_state.dart';

enum EditState {
  newComment,
  editComment,
  reptyComment,
}

class CommentController extends GetxController with WidgetsBindingObserver {
  CommentController();

  GalleryPageController get pageController {
    logger.v('CommentController -> pageCtrlDepth: $pageCtrlTag');
    return Get.find(tag: pageCtrlTag);
  }

  // MorseCode get morseCode => MorseCode(di: '·', dah: '-');

  BCDCode get bcdCode => BCDCode(code0: '·', code1: '-');

  GalleryPageState get _pageState => pageController.gState;
  List<GalleryComment>? get comments => _pageState.comments;

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
  ScrollController scrollController = ScrollController();

  late String reptyCommentText;
  late String reptyUser;

  final WidgetsBinding? _widgetsBinding = WidgetsBinding.instance;
  double _preBottomInset = 0;
  double _bottomInset = 0;
  bool _didChangeMetrics = false;

  final Rx<EditState> _editState = EditState.newComment.obs;

  EditState get editState => _editState.value;

  set editState(EditState val) => _editState.value = val;

  bool get isEditStat => _editState.value == EditState.editComment;
  bool get isReptyStat => _editState.value == EditState.reptyComment;

  @override
  void onInit() {
    super.onInit();
    logger.v('CommentController onInit');

    _bottomInset = _mediaQueryBottomInset();
    _preBottomInset = _bottomInset;
    _widgetsBinding?.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    _didChangeMetrics = true;
    super.didChangeMetrics();
    _widgetsBinding?.addPostFrameCallback((Duration timeStamp) {
      _bottomInset = _mediaQueryBottomInset();
      if (_preBottomInset != _bottomInset) {
        final double _offset = _bottomInset - _preBottomInset;
        _preBottomInset = _bottomInset;
      }
    });
  }

  @override
  void onClose() {
    _tgr.forEach((element) => element.dispose());
    scrollController.dispose();
    _widgetsBinding?.removeObserver(this);
    super.onClose();
  }

  final List<TapGestureRecognizer> _tgr = [];

  TapGestureRecognizer genTapGestureRecognizer() {
    _tgr.add(TapGestureRecognizer());
    return _tgr.last;
  }

  double _mediaQueryBottomInset() {
    return MediaQueryData.fromWindow(_widgetsBinding!.window).viewInsets.bottom;
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
    List<String> textList = comment.text.split('@').map((e) => '@$e').toList();

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
        logger.v('($i)  ${match.group(i)}');
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
        logger.v('没有明确的评论id 或id和所 @用户名 对应不上的\n${repty?.toJson()}');
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
    logger.v('commitTranslate');
    final int? _commentIndex =
        comments?.indexWhere((element) => element.id == _id.toString());
    final List<GalleryCommentSpan>? spans = comments?[_commentIndex!].span;

    if (spans != null) {
      for (int i = 0; i < spans.length; i++) {
        String? translate = spans[i].translate;
        if (translate?.isEmpty ?? true) {
          if (spans[i].text?.isEmpty ?? true) {
            return;
          }

          translate = await translatorHelper.translateText(spans[i].text ?? '');

          if (translate.trim().isEmpty) {
            return;
          }
        }

        spans[i] = spans[i].copyWith(translate: translate);
      }
    }

    comments![_commentIndex!] = comments![_commentIndex].copyWith(
      showTranslate: !(comments![_commentIndex].showTranslate ?? false),
    );
    // update([_id]);
    update();
  }

  // 点赞
  Future<void> commitVoteUp(String _id) async {
    if (comments == null) {
      return;
    }

    logger.v('commit up id $_id');
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
    logger.v('commit down id $_id');
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
    logger.v('${rult.toJson()}');

    final int? _commentIndex = comments?.indexWhere(
        (GalleryComment element) => element.id == rult.commentId.toString());
    comments![_commentIndex!] = comments![_commentIndex]
        .copyWith(vote: rult.commentVote, score: '${rult.commentScore}');

    update();
    logger.v('update CommentController id ${rult.commentId}');
  }

  // 推送评论
  Future<void> _postComment(String comment,
      {bool isEdit = false, String? commentId}) async {
    logger.d('_postComment\n$comment');
    // final bool rult = await Api.postComment(
    //   gid: pageController.gid,
    //   token: pageController.galleryProvider?.token ?? '',
    //   comment: comment,
    //   commentId: commentId,
    //   isEdit: isEdit,
    // );
    //
    // if (rult) {
    //   await pageController.handOnRefresh();
    // }
    final rult = await postComment(
      gid: _pageState.gid,
      token: _pageState.galleryProvider?.token ?? '',
      comment: comment,
      commentId: commentId,
      isEdit: isEdit,
    );

    if (rult ?? false) {
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
        pressCancle();
        // await Future.delayed(const Duration(seconds: 3));
        logger.v('_postComment $comment');
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
    logger.v('_postComment $comment');
    try {
      await _postComment(
        comment,
        isEdit: editState == EditState.editComment,
        commentId: commentId,
      );
    } finally {
      pressCancle();
      SmartDialog.dismiss();
    }
  }

  void pressCancle() {
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

  // 滚动到列表底部
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 400), () {
      logger.d('${scrollController.position.maxScrollExtent}');
      // scrollController.jumpTo(scrollController.position.maxScrollExtent);
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 400),
        curve: Curves.linear,
      );
    });
  }

  void _scrollView() {
    _bottomInset = _mediaQueryBottomInset();
    if (_preBottomInset != _bottomInset) {
      final double _offset = _bottomInset - _preBottomInset;
      _preBottomInset = _bottomInset;
      logger.d(' ${_bottomInset} $_offset  ${scrollController.offset}');

      final double _viewHeigth = Get.context!.height -
          Get.context!.mediaQueryViewPadding.top -
          Get.context!.mediaQueryViewPadding.bottom -
          60 -
          44;

      logger.d('_viewHeigth $_viewHeigth,  ${Get.context!.height} '
          ' ${Get.context!.mediaQueryViewPadding.top}  '
          '${Get.context!.mediaQueryViewPadding.bottom}');

      if (scrollController.position.maxScrollExtent > _viewHeigth) {
        if (scrollController.offset > _bottomInset && _offset < 0) {
          scrollController.animateTo(
            scrollController.offset + _offset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        } else if (_offset > 0) {
          scrollController.animateTo(
            scrollController.offset + _offset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        }
      } else {
        final double _o =
            _viewHeigth - scrollController.position.maxScrollExtent;
        logger.d('_o $_o');
      }
    }
  }
}

/// 显示等待
Future<void> showLoadingDialog(
  BuildContext context,
  Completer completer,
  Function function,
) async {
  logger.v('showLoadingDialog');

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
