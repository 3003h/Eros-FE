import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/item/download_archiver_item.dart';
import 'package:fehviewer/pages/item/download_gallery_item.dart';
import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
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
  const DownloadTab({Key? key, this.tabIndex, this.scrollController})
      : super(key: key);
  final String? tabIndex;
  final ScrollController? scrollController;

  @override
  _DownloadTabState createState() => _DownloadTabState();
}

class _DownloadTabState extends State<DownloadTab> {
  final DownloadViewController controller = Get.find();
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: controller.currIndex);
  }

  @override
  Widget build(BuildContext context) {
    final String _title = L10n.of(context).tab_download;

    final viewList = [
      DownloadGalleryView(scrollController: widget.scrollController),
      DownloadArchiverView(scrollController: widget.scrollController),
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Obx(
          () => CupertinoSlidingSegmentedControl<DownloadType>(
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
              // if (value != null) {
              //   controller.animateToPage(value);
              // }
              final toIndex =
                  controller.pageList.indexOf(value ?? DownloadType.gallery);
              pageController.animateToPage(toIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
              // controller.viewType = value ?? DownloadType.gallery;
            },
          ),
        ),
      ),
      child: PageView(
        controller: pageController,
        children: viewList,
        onPageChanged: controller.handOnPageChange,
      ),
      // child: Obx(() {
      //   final _index = controller.pageList.indexOf(controller.viewType);
      //   return viewList[_index];
      // }),
    );
  }
}

class DownloadArchiverView extends StatefulWidget {
  const DownloadArchiverView({this.scrollController});
  final ScrollController? scrollController;

  @override
  _DownloadArchiverViewState createState() => _DownloadArchiverViewState();
}

class _DownloadArchiverViewState extends State<DownloadArchiverView>
    with AutomaticKeepAliveClientMixin {
  final DownloadViewController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CupertinoScrollbar(
      child: ListView.separated(
        controller: widget.scrollController,
        itemBuilder: (_, int index) {
          final _id = controller.archiverTasks[index].tag;

          return GetBuilder<DownloadViewController>(
              id: _id,
              builder: (DownloadViewController _controller) {
                final DownloadTaskInfo _taskInfo =
                    _controller.archiverTasks[index];

                return GestureDetector(
                  onLongPress: () => _controller.onLongPress(index,
                      type: DownloadType.archiver),
                  behavior: HitTestBehavior.opaque,
                  child: DownloadArchiverItem(
                    title: _taskInfo.title ?? '',
                    progress: _taskInfo.progress ?? 0,
                    status: DownloadTaskStatus(_taskInfo.status ?? 0),
                    index: index,
                  ),
                );
              });
        },
        separatorBuilder: (_, __) {
          return Divider(
            indent: 20,
            height: 0.6,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey4, context),
          );
        },
        itemCount: controller.archiverTasks.length,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DownloadGalleryView extends StatefulWidget {
  const DownloadGalleryView({this.scrollController});
  final ScrollController? scrollController;

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
    return GetBuilder<DownloadViewController>(
      id: 'DownloadGalleryView',
      builder: (logic) {
        return CupertinoScrollbar(
          controller: widget.scrollController,
          child: ListView.separated(
            controller: widget.scrollController,
            itemBuilder: (_, int _taskIndex) {
              final gid = controller.galleryTasks[_taskIndex].gid;

              return GetBuilder<DownloadViewController>(
                id: 'DownloadGalleryItem_$gid',
                builder: (logic) {
                  logger.v('rebuild DownloadGalleryItem_$gid');

                  final GalleryTask _taskInfo = logic.galleryTasks[_taskIndex];
                  final String? _speed = logic.downloadSpeeds[_taskInfo.gid];

                  return GestureDetector(
                    onLongPress: () => controller.onLongPress(_taskIndex),
                    behavior: HitTestBehavior.opaque,
                    child: DownloadGalleryItem(
                      galleryTask: _taskInfo,
                      speed: _speed,
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, __) {
              return Divider(
                indent: 20,
                height: 0.6,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey4, context),
              );
            },
            itemCount: controller.galleryTasks.length,
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
