import 'package:eros_fe/common/controller/download_controller.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/models/download_archiver_task_info.dart';
import 'package:eros_fe/pages/item/download_archiver_item.dart';
import 'package:eros_fe/pages/item/download_gallery_item.dart';
import 'package:eros_fe/pages/tab/controller/download_view_controller.dart';
import 'package:eros_fe/store/db/entity/gallery_task.dart';
import 'package:eros_fe/utils/logger.dart';
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
  const DownloadTab({super.key});

  @override
  State<DownloadTab> createState() => _DownloadTabState();
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
                    onPressed: _showExportDialog,
                    child: const Icon(
                      CupertinoIcons.arrow_up_arrow_down_square_fill,
                      size: 28,
                    ),
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
  const DownloadArchiverView({super.key});

  @override
  State<DownloadArchiverView> createState() => _DownloadArchiverViewState();
}

class _DownloadArchiverViewState extends State<DownloadArchiverView>
    with AutomaticKeepAliveClientMixin {
  final DownloadViewController controller = Get.find();

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
  const DownloadGalleryView({super.key});

  @override
  State<DownloadGalleryView> createState() => _DownloadGalleryViewState();
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
    BuildContext context, int taskIndex, Animation<double> animation) {
  return _buildAnimatedListItem(
    animation,
    child: _downloadItemBuilder(context, taskIndex),
  );
}

Widget downloadDelItemBuilder(
    BuildContext context, int taskIndex, Animation<double> animation) {
  return _buildDelAnimatedListItem(
    animation,
    child: _downloadItemBuilder(context, taskIndex),
  );
}

Widget downloadArchiverItemBuilder(
    BuildContext context, int taskIndex, Animation<double> animation) {
  return _buildAnimatedListItem(
    animation,
    child: _downloadArchiverItemBuilder(context, taskIndex),
  );
}

Widget downloadArchiverDelItemBuilder(
    BuildContext context, int taskIndex, Animation<double> animation) {
  return _buildDelAnimatedListItem(
    animation,
    child: _downloadArchiverItemBuilder(context, taskIndex),
  );
}

Widget _downloadItemBuilder(BuildContext context, int taskIndex) {
  final DownloadViewController controller = Get.find();
  if (controller.galleryTasks.length - 1 < taskIndex) {
    return const SizedBox.shrink();
  }

  final gid = controller.galleryTasks[taskIndex].gid;
  return GetBuilder<DownloadViewController>(
    id: '${idDownloadGalleryItem}_$gid',
    builder: (logic) {
      logger.t('rebuild DownloadGalleryItem_$gid');

      final GalleryTask taskInfo = logic.galleryTasks[taskIndex];
      final String? speed = logic.downloadSpeedMap[taskInfo.gid];
      final String? errInfo = logic.errInfoMap[taskInfo.gid];

      return DownloadGalleryItem(
        galleryTask: taskInfo,
        taskIndex: taskIndex,
        speed: speed,
        errInfo: errInfo,
      );
    },
  );
}

Widget _downloadArchiverItemBuilder(BuildContext context, int taskIndex) {
  final DownloadViewController controller = Get.find();
  if (controller.archiverTasks.length - 1 < taskIndex) {
    return const SizedBox.shrink();
  }

  final tag = controller.archiverTasks[taskIndex].tag;
  return GetBuilder<DownloadViewController>(
    id: '${idDownloadArchiverItem}_$tag',
    builder: (logic) {
      final DownloadArchiverTaskInfo archiveTaskInfo =
          logic.archiverTasks[taskIndex];
      return GestureDetector(
        onLongPress: () =>
            logic.onLongPress(taskIndex, type: DownloadType.archiver),
        behavior: HitTestBehavior.opaque,
        child: DownloadArchiverItem(
          archiverTaskInfo: archiveTaskInfo,
          index: taskIndex,
        ),
      );
    },
  );
}

Widget _buildDelAnimatedListItem(
  Animation<double> animation, {
  required Widget child,
}) {
  return FadeTransition(
    opacity: animation.drive(
        CurveTween(curve: const Interval(0.0, 1.0, curve: Curves.easeOut))),
    child: SizeTransition(
      sizeFactor: animation.drive(
          CurveTween(curve: const Interval(0.0, 1.0, curve: Curves.easeOut))),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: animation,
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
