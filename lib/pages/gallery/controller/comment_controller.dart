import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/openl/translator_helper.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:learning_language/learning_language.dart';

import 'gallery_page_controller.dart';

enum EditState {
  newComment,
  editComment,
}

class CommentController extends GetxController
    with StateMixin<List<GalleryComment>>, WidgetsBindingObserver {
  CommentController();

  GalleryPageController get pageController {
    logger.v('CommentController -> pageCtrlDepth: $pageCtrlDepth');
    return Get.find(tag: pageCtrlDepth);
  }

  final TextEditingController commentTextController = TextEditingController();

  GalleryItem? get _item => pageController.galleryItem;
  late String comment;
  late String oriComment;
  String? commentId;
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();

  final WidgetsBinding? _widgetsBinding = WidgetsBinding.instance;
  double _preBottomInset = 0;
  double _bottomInset = 0;
  bool _didChangeMetrics = false;

  final Rx<EditState> _editState = EditState.newComment.obs;

  EditState get editState => _editState.value;

  set editState(EditState val) => _editState.value = val;

  bool get isEditStat => _editState.value == EditState.editComment;

  // final LanguageIdentifier languageIdentifier =
  //     GoogleMlKit.nlp.languageIdentifier(confidenceThreshold: 0.34);

  final LanguageIdentifier identifier = LanguageIdentifier();

  @override
  void onInit() {
    super.onInit();
    logger.v('CommentController onInit');

    _loadComment();

    _bottomInset = _mediaQueryBottomInset();
    _preBottomInset = _bottomInset;
    _widgetsBinding?.addObserver(this);
  }

  Future<void> _loadComment() async {
    await Future.delayed(const Duration(milliseconds: 200));
    change(pageController.galleryItem?.galleryComment,
        status: RxStatus.success());
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

  Future<void> commitTranslate(String _id) async {
    logger.v('commitTranslate');
    final int? _commentIndex =
        state?.indexWhere((element) => element.id == _id.toString());
    final List<GalleryCommentSpan>? spans = state?[_commentIndex!].span;

    if (spans != null) {
      for (int i = 0; i < spans.length; i++) {
        String? translate = spans[i].translate;
        if (translate?.isEmpty ?? true) {
          if (spans[i].text?.isEmpty ?? true) {
            return;
          }
          // final List<IdentifiedLanguage> possibleLanguages =
          //     await identifier.idenfityPossibleLanguages(spans[i].text ?? '');
          //
          // final String languages = possibleLanguages
          //     .map((item) => item.language)
          //     .toList()
          //     .join(', ');
          //
          // logger.d('Possible Languages: $languages');
          //
          // if (possibleLanguages.first.language == 'zh') {
          //   return;
          // }

          final language = await identifier.identify(spans[i].text ?? '');

          // final language =
          //     await languageIdentifier.identifyLanguage(spans[i].text!);

          logger.d('language $language');

          translate = await TranslatorHelper.translateText(
            spans[i].text ?? '',
            from: language,
            to: 'zh',
          );

          if (translate.trim().isEmpty) {
            return;
          }
        }

        spans[i] = spans[i].copyWith(translate: translate);
      }
    }

    state![_commentIndex!] = state![_commentIndex].copyWith(
      showTranslate: !(state![_commentIndex].showTranslate ?? false),
    );
    // update([_id]);
    update();
  }

  // 点赞
  Future<void> commitVoteUp(String _id) async {
    if (state == null) {
      return;
    }

    logger.d('commit up id $_id');
    // state?.firstWhere((element) => element.id == _id.toString()).vote = 1;
    final int? _commentIndex =
        state?.indexWhere((element) => element.id == _id.toString());
    state![_commentIndex!] = state![_commentIndex].copyWith(vote: 1);

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
    logger.d('commit down id $_id');
    // state.firstWhere((element) => element.id == _id.toString()).vote = -1;
    final int? _commentIndex =
        state?.indexWhere((element) => element.id == _id.toString());
    state![_commentIndex!] = state![_commentIndex].copyWith(vote: -1);
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
    logger.d('${rult.toJson()}');
    // state.firstWhere((element) => element.id == rult.commentId.toString())
    //   ..vote = rult.commentVote
    //   ..score = '${rult.commentScore}';

    final int? _commentIndex = state?.indexWhere(
        (GalleryComment element) => element.id == rult.commentId.toString());
    state![_commentIndex!] = state![_commentIndex]
        .copyWith(vote: rult.commentVote, score: '${rult.commentScore}');

    // update(['${rult.commentId}']);
    update();
    logger.v('update CommentController id ${rult.commentId}');
  }

  // 推送评论
  Future<void> _postComment(String comment,
      {bool isEdit = false, String? commentId}) async {
    final bool rult = await Api.postComment(
      gid: pageController.gid,
      token: pageController.galleryItem?.token ?? '',
      comment: comment,
      commentId: commentId,
      isEdit: isEdit,
    );

    if (rult) {
      await pageController.handOnRefresh();
    }
  }

  // 会有重复执行的问题 弃用
  Future<void> pressSend_Old() async {
    comment = commentTextController.text;
    logger.d('comment: $comment');
    FocusScope.of(Get.context!).requestFocus(FocusNode());

    showLoadingDialog(Get.overlayContext!, () async {
      // await _postComment(
      //   comment,
      //   isEdit: editState == EditState.editComment,
      //   commentId: commentId,
      // );
      await Future.delayed(const Duration(seconds: 3));
      logger.v('_postComment $comment');
    });
  }

  Future<void> pressSend() async {
    comment = commentTextController.text;
    logger.d('comment: $comment');
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorColor = Colors.transparent
      ..backgroundColor = Colors.transparent
      ..textColor = Colors.transparent
      ..maskType = EasyLoadingMaskType.custom
      ..maskColor = Colors.black.withOpacity(0.25)
      ..userInteractions = false
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle;
    EasyLoading.show(
      indicator: Center(
        child: CupertinoPopupSurface(
          child: Container(
              height: 80,
              width: 80,
              alignment: Alignment.center,
              child: const CupertinoActivityIndicator(
                radius: 20,
              )),
        ),
      ),
    );

    // await Future.delayed(const Duration(seconds: 3));
    // logger.v('_postComment $comment');
    await _postComment(
      comment,
      isEdit: editState == EditState.editComment,
      commentId: commentId,
    );
    pressCancle();

    EasyLoading.dismiss();
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
Future<void> showLoadingDialog(BuildContext context, Function function) async {
  logger.v('showLoadingDialog');
  return showCupertinoDialog<void>(
    context: Get.overlayContext!,
    builder: (BuildContext context) {
      logger5.v('builder showLoadingDialog');

      Future<void> runFunc() async {
        await function();
        Get.back();
      }

      runFunc();

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
