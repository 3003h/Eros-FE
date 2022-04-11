import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../component/setting_base.dart';
import '../../fehviewer.dart';
import 'controller/eh_mytags_controller.dart';
import 'webview/eh_tagset_edit_dialog.dart';
import 'webview/mytags_in.dart';

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
                    FontAwesomeIcons.earthAmericas,
                    size: 22,
                  ),
                  onPressed: () async {
                    Get.to(() => InWebMyTags());
                  },
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  minSize: 40,
                  child: const Icon(
                    FontAwesomeIcons.plus,
                    size: 22,
                  ),
                  onPressed: () async {
                    final newName = await showCupertinoDialog<String>(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return const EhTagSetEditDialog(
                            text: '',
                            title: 'New Tagset',
                          );
                        });
                    if (newName != null && newName.isNotEmpty) {
                      controller.crtNewTagset(name: newName);
                    }
                  },
                ),
              ],
            )),
        child: SafeArea(
          child: controller.obx(
            (state) {
              if (state == null) {
                return const SizedBox.shrink();
              }
              return CustomScrollView(
                slivers: [
                  EhCupertinoSliverRefreshControl(
                    onRefresh: controller.reloadData,
                  ),
                  SliverSafeArea(
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final e = state[index];

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
                        childCount: state.length,
                      ),
                    ),
                  ),
                ],
              );
            },
            onLoading: const Center(
              child: CupertinoActivityIndicator(
                radius: 16,
              ),
            ),
            onEmpty: CustomScrollView(
              slivers: [
                EhCupertinoSliverRefreshControl(
                  onRefresh: controller.reloadData,
                ),
              ],
            ),
          ),
        ),
      );
    });

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
                    FontAwesomeIcons.earthAmericas,
                    size: 22,
                  ),
                  onPressed: () async {
                    Get.to(() => InWebMyTags());
                  },
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  minSize: 40,
                  child: const Icon(
                    FontAwesomeIcons.plus,
                    size: 22,
                  ),
                  onPressed: () async {
                    // Get.to(() => InWebMyTags());
                  },
                ),
              ],
            )),
        child: CustomScrollView(
          slivers: [
            // EhCupertinoSliverRefreshControl(
            //   onRefresh: controller.reloadData,
            // ),
            // SliverList(
            //   delegate: SliverChildBuilderDelegate(
            //     (context, index) {
            //       final e = _ehMyTagsController.ehMyTags.tagsets[index];
            //
            //       return SelectorSettingItem(
            //         title: e.name,
            //         onTap: () async {
            //           if (controller.currSelected != e.value) {
            //             controller.currSelected = e.value ?? '';
            //             // await controller.reloadData();
            //           }
            //           Get.toNamed(
            //             EHRoutes.userTags,
            //             id: isLayoutLarge ? 2 : null,
            //           );
            //         },
            //       );
            //       // return _list[index];
            //     },
            //     childCount: _ehMyTagsController.ehMyTags.tagsets.length,
            //   ),
            // ),
            controller.obx(
              (List<EhMytagSet>? state) {
                return Text('AAA');
              },
            )
            // controller.obx(
            //   (List<EhMytagSet>? state) {
            //     if (state == null) {
            //       return const SliverToBoxAdapter(
            //           child: SizedBox.shrink());
            //     }
            //     return SliverList(
            //       delegate: SliverChildBuilderDelegate(
            //         (context, index) {
            //           final e = state[index];
            //
            //           return SelectorSettingItem(
            //             title: e.name,
            //             onTap: () async {
            //               if (controller.currSelected != e.value) {
            //                 controller.currSelected = e.value ?? '';
            //                 // await controller.reloadData();
            //               }
            //               Get.toNamed(
            //                 EHRoutes.userTags,
            //                 id: isLayoutLarge ? 2 : null,
            //               );
            //             },
            //           );
            //           // return _list[index];
            //         },
            //         childCount: state.length,
            //       ),
            //     );
            //   },
            //   onEmpty: const SliverToBoxAdapter(
            //     child: CupertinoActivityIndicator(),
            //   ),
            // ),
          ],
        ),
      );
    });
  }
}
