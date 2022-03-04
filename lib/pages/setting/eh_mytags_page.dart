import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/network/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../component/setting_base.dart';
import '../../fehviewer.dart';
import 'comp/user_tag_item.dart';
import 'const.dart';
import 'controller/eh_mytags_controller.dart';
import 'eh_usertag_edit_dialog.dart';
import 'setting_items/selector_Item.dart';
import 'webview/mytags_in.dart';

part 'eh_mytags_items.dart';

final _ehMyTagsController = Get.find<EhMyTagsController>();

class EhMyTagsPage extends GetView<EhMyTagsController> {
  const EhMyTagsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
              padding: const EdgeInsetsDirectional.only(end: 8),
              middle: Text(L10n.of(context).ehentai_my_tags),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    minSize: 40,
                    child: const Icon(
                      LineIcons.globeWithAmericasShown,
                      size: 24,
                    ),
                    onPressed: () async {
                      Get.to(() => InWebMyTags());
                    },
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    minSize: 40,
                    child: const Icon(
                      LineIcons.plus,
                      size: 24,
                    ),
                    onPressed: () async {
                      // Get.to(() => InWebMyTags());
                    },
                  ),
                ],
              )),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomScrollView(
                  slivers: [
                    EhCupertinoSliverRefreshControl(
                      onRefresh: controller.reloadData,
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final e = _ehMyTagsController.ehMyTags.tagsets[index];

                          return SelectorSettingItem(
                            title: e.name,
                            onTap: () async {
                              if (controller.currSelected != e.value) {
                                controller.currSelected = e.value ?? '';
                                // await controller.reloadData();
                              }
                              Get.toNamed(
                                EHRoutes.userTags,
                                id: isLayoutLarge ? 2 : null,
                              );
                            },
                          );
                          // return _list[index];
                        },
                        childCount: _ehMyTagsController.ehMyTags.tagsets.length,
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  if (controller.isLoading) {
                    // loading 提示组件
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque, // 拦截触摸手势
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoDynamicColor.resolve(
                                          CupertinoColors.systemGrey,
                                          Get.context!)
                                      .withOpacity(0.1),
                                  offset: const Offset(0, 5),
                                  blurRadius: 10, //阴影模糊程度
                                  spreadRadius: 3, //阴影扩散程度
                                ),
                              ],
                            ),
                            child: CupertinoPopupSurface(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: const CupertinoActivityIndicator(
                                    radius: kIndicatorRadius),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              ],
            ),
            bottom: false,
          ));
    });
  }
}
