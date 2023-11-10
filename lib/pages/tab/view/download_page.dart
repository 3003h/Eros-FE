import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/item/download_archiver_item.dart';
import 'package:fehviewer/pages/item/download_gallery_item.dart';
import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:fehviewer/store/db/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

const Color _kDefaultNavBarBorderColor = Color(0x4D000000);

const Border _kDefaultNavBarBorder = Border(
  bottom: BorderSide(
    color: _kDefaultNavBarBorderColor,
    width: 0.2, // One physical pixel.
    style: BorderStyle.solid,
  ),
);

class DownloadTab extends StatefulWidget {
  const DownloadTab({Key? key}) : super(key: key);

  @override
  _DownloadTabState createState() => _DownloadTabState();
}

class _DownloadTabState extends State<DownloadTab> {
  final DownloadViewController controller = Get.find();
  late PageController pageController;

  int get currIndex => controller.pageList.indexOf(controller.viewType);

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currIndex);
  }

  @override
  Widget build(BuildContext context) {
    final String _title = L10n.of(context).tab_download;

    final viewList = [
      const DownloadGalleryView(),
      const DownloadArchiverView(),
    ];

    final middle = GetPlatform.isMobile
        ? CupertinoSlidingSegmentedControl<DownloadType>(
            children: <DownloadType, Widget>{
              DownloadType.gallery: Text(
                L10n.of(context).tab_gallery,
                style: const TextStyle(fontSize: 14),
              ).marginSymmetric(horizontal: 6),
              DownloadType.archiver: Text(
                L10n.of(context).p_Archiver,
                style: const TextStyle(fontSize: 14),
              ).marginSymmetric(horizontal: 6),
            },
            groupValue: controller.viewType,
            onValueChanged: (DownloadType? value) {
              final toIndex =
                  controller.pageList.indexOf(value ?? DownloadType.gallery);
              pageController.animateToPage(toIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            },
          )
        : Text(L10n.of(context).download);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 16),
        middle: middle,
        trailing: !kReleaseMode
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    minSize: 40,
                    padding: const EdgeInsets.all(0),
                    child: const Icon(
                      CupertinoIcons.arrow_up_arrow_down_square_fill,
                      size: 28,
                    ),
                    onPressed: _showExportDialog,
                  ),
                ],
              )
            : null,
      ),
      child: PageView(
        controller: pageController,
        children: viewList,
        onPageChanged: (index) {
          setState(() {
            controller.viewType = controller.pageList[index];
          });
        },
      ),
    );
  }

  Future<void> _showExportDialog() async {
    return showCupertinoDialog<void>(
      context: Get.overlayContext!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Import & Export'),
          content: const Text('Import and Export download task'),
          actions: [
            CupertinoDialogAction(
              onPressed: () async {
                Get.back();
                controller.shareTaskInfoFile();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FontAwesomeIcons.squareShareNodes)
                      .paddingOnly(right: 8),
                  const Text('Share '),
                ],
              ),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                Get.back();
                controller.exportTaskInfoFile();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FontAwesomeIcons.fileArrowUp)
                      .paddingOnly(right: 8),
                  const Text('Export'),
                ],
              ),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                Get.back();
                await controller.importTaskInfoFile();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FontAwesomeIcons.fileArrowDown)
                      .paddingOnly(right: 8),
                  const Text('Import'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class DownloadArchiverView extends StatefulWidget {
  const DownloadArchiverView();

  @override
  _DownloadArchiverViewState createState() => _DownloadArchiverViewState();
}

class _DownloadArchiverViewState extends State<DownloadArchiverView>
    with AutomaticKeepAliveClientMixin {
  final DownloadViewController controller = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: AnimatedList(
        key: controller.animatedArchiverListKey,
        padding: EdgeInsets.only(
          top: context.mediaQueryPadding.top,
          bottom: context.mediaQueryPadding.bottom,
        ),
        initialItemCount: controller.archiverTasks.length,
        itemBuilder: downloadArchiverItemBuilder,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DownloadGalleryView extends StatefulWidget {
  const DownloadGalleryView();

  @override
  _DownloadGalleryViewState createState() => _DownloadGalleryViewState();
}

class _DownloadGalleryViewState extends State<DownloadGalleryView>
    with AutomaticKeepAliveClientMixin {
  final DownloadController downloadController = Get.find();
  final DownloadViewController controller = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      // controller.galleryTasks更新时，生成新的animatedGalleryListKey，确保列表能刷新
      // TODO: 会导致任务状态变化时， 列表重新回到顶部
      // controller.animatedGalleryListKey = GlobalKey<AnimatedListState>();
      return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedList(
          key: controller.animatedGalleryListKey,
          padding: EdgeInsets.only(
            top: context.mediaQueryPadding.top,
            bottom: context.mediaQueryPadding.bottom,
          ),
          initialItemCount: controller.galleryTasks.length,
          itemBuilder: downloadItemBuilder,
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}

Widget downloadItemBuilder(
    BuildContext context, int _taskIndex, Animation<double> animation) {
  return _buildAnimatedListItem(
    animation,
    child: _downloadItemBuilder(context, _taskIndex),
  );
}

Widget downloadDelItemBuilder(
    BuildContext context, int _taskIndex, Animation<double> animation) {
  return _buildDelAnimatedListItem(
    animation,
    child: _downloadItemBuilder(context, _taskIndex),
  );
}

Widget downloadArchiverItemBuilder(
    BuildContext context, int _taskIndex, Animation<double> animation) {
  return _buildAnimatedListItem(
    animation,
    child: _downloadArciverItemBuilder(context, _taskIndex),
  );
}

Widget downloadArchiverDelItemBuilder(
    BuildContext context, int _taskIndex, Animation<double> animation) {
  return _buildDelAnimatedListItem(
    animation,
    child: _downloadArciverItemBuilder(context, _taskIndex),
  );
}

Widget _downloadItemBuilder(BuildContext context, int _taskIndex) {
  final DownloadViewController controller = Get.find();
  if (controller.galleryTasks.length - 1 < _taskIndex) {
    return const SizedBox.shrink();
  }

  final gid = controller.galleryTasks[_taskIndex].gid;
  return GetBuilder<DownloadViewController>(
    id: '${idDownloadGalleryItem}_$gid',
    builder: (logic) {
      logger.t('rebuild DownloadGalleryItem_$gid');

      final GalleryTask _taskInfo = logic.galleryTasks[_taskIndex];
      final String? _speed = logic.downloadSpeedMap[_taskInfo.gid];
      final String? _errInfo = logic.errInfoMap[_taskInfo.gid];

      return DownloadGalleryItem(
        galleryTask: _taskInfo,
        taskIndex: _taskIndex,
        speed: _speed,
        errInfo: _errInfo,
      );
    },
  );
}

Widget _downloadArciverItemBuilder(BuildContext context, int _taskIndex) {
  final DownloadViewController controller = Get.find();
  if (controller.archiverTasks.length - 1 < _taskIndex) {
    return const SizedBox.shrink();
  }

  final _tag = controller.archiverTasks[_taskIndex].tag;
  return GetBuilder<DownloadViewController>(
    id: '${idDownloadArchiverItem}_$_tag',
    builder: (logic) {
      final _taskInfo = logic.archiverTasks[_taskIndex];
      return GestureDetector(
        onLongPress: () =>
            logic.onLongPress(_taskIndex, type: DownloadType.archiver),
        behavior: HitTestBehavior.opaque,
        child: DownloadArchiverItem(
          archiverTaskInfo: _taskInfo,
          index: _taskIndex,
        ),
      );
    },
  );
}

Widget _buildDelAnimatedListItem(
  Animation<double> _animation, {
  required Widget child,
}) {
  return FadeTransition(
    opacity: _animation.drive(
        CurveTween(curve: const Interval(0.0, 1.0, curve: Curves.easeOut))),
    child: SizeTransition(
      sizeFactor: _animation.drive(
          CurveTween(curve: const Interval(0.0, 1.0, curve: Curves.easeOut))),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _animation,
                curve: const Interval(0.4, 1.0, curve: Curves.easeOut))),
        child: child,
      ),
    ),
  );
}

Widget _buildAnimatedListItem(
  Animation<double> _animation, {
  required Widget child,
}) {
  return FadeTransition(
    opacity: _animation.drive(CurveTween(curve: Curves.easeIn)),
    child: SizeTransition(
      sizeFactor: _animation.drive(CurveTween(curve: Curves.easeIn)),
      child: child,
    ),
  );
}
