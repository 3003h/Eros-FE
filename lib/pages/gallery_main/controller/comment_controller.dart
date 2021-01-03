import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';

class CommentController extends GetxController
    with StateMixin<List<GalleryComment>> {
  CommentController({this.pageController});
  final GalleryPageController pageController;

  GalleryItem get _item => pageController.galleryItem;

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
}
