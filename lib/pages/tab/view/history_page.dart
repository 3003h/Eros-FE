import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/pages/tab/controller/history_controller.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class HistoryTab extends GetView<HistoryViewController> {
  const HistoryTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
  final String tabIndex;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    // final HistoryController historyController = Get.find();
    final String _title = 'tab_history'.tr;
    final CustomScrollView customScrollView = CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: TabPageTitle(
            title: _title,
            isLoading: false,
          ),
          trailing: Container(
            width: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 清除按钮
                CupertinoButton(
                  minSize: 40,
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    FontAwesomeIcons.solidTrashAlt,
                    size: 20,
                  ),
                  onPressed: () {
                    controller.clearHistory();
                  },
                ),
              ],
            ),
          ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await controller.reloadData();
          },
        ),
        SliverSafeArea(
            top: false,
            // sliver: _getGalleryList(),
            sliver: GetBuilder<HistoryController>(
              init: HistoryController(),
              builder: (_) {
                return getGalleryList(_.historys, tabIndex);
              },
            )
            // sliver: _getGalleryList(),
            ),
      ],
    );

    return CupertinoPageScaffold(child: customScrollView);
  }
}
