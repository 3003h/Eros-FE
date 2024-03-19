import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/network/request.dart';
import 'package:eros_fe/pages/setting/const.dart';
import 'package:eros_fe/pages/setting/controller/eh_mytags_controller.dart';
import 'package:eros_fe/pages/setting/mytags/eh_usertag_edit_dialog.dart';
import 'package:eros_fe/pages/setting/webview/eh_tagset_edit_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class EhUserTagsPage extends StatefulWidget {
  const EhUserTagsPage({super.key});

  @override
  State<EhUserTagsPage> createState() => _EhUserTagsPageState();
}

class _EhUserTagsPageState extends State<EhUserTagsPage> {
  EhMyTagsController get controller => Get.find();
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.isSearchUserTags = false;
    controller.searchTags.clear();
    controller.searchNewTags.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 10),
        middle: _middle(context),
        trailing: _trailing(context),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const ListViewEhMyTags(),
          Obx(() {
            if (controller.isStackLoading) {
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
                                    CupertinoColors.systemGrey, Get.context!)
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
    );
  }

  Widget _normalTrailing(BuildContext context) {
    logger.d('controller.canDelete ${controller.canDelete}');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Obx(() {
          return AnimatedCrossFade(
            firstChild: const SizedBox.square(
              dimension: 40,
            ),
            secondChild: CupertinoButton(
              padding: const EdgeInsets.all(0),
              minSize: 40,
              child: const Icon(
                CupertinoIcons.trash,
                size: 26,
              ),
              onPressed: () async {
                showSimpleEhDiglog(
                  context: context,
                  title: 'Delete Tagset',
                  onOk: () async {
                    if (await controller.deleteTagset()) {
                      Get.back();
                    }
                  },
                );
              },
            ),
            crossFadeState: controller.canDelete
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 100),
          );
        }),
        // if (controller.canDelete)
        //   CupertinoButton(
        //     padding: const EdgeInsets.all(0),
        //     minSize: 40,
        //     child: const Icon(
        //       CupertinoIcons.trash,
        //       size: 26,
        //     ),
        //     onPressed: () async {
        //       showSimpleEhDiglog(
        //         context: context,
        //         title: 'Delete Tagset',
        //         onOk: () async {
        //           if (await controller.deleteTagset()) {
        //             Get.back();
        //           }
        //         },
        //       );
        //     },
        //   ),
        CupertinoButton(
          padding: const EdgeInsets.all(0),
          minSize: 40,
          child: const Icon(
            // FontAwesomeIcons.penRuler,
            CupertinoIcons.pencil_ellipsis_rectangle,
            size: 28,
          ),
          onPressed: () async {
            final currName = controller.curTagSet?.name ?? '';
            final newName = await showCupertinoDialog<String>(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return EhTagSetEditDialog(
                    text: currName,
                    title: L10n.of(context).uc_rename,
                  );
                });
            if (newName != null && newName.isNotEmpty && newName != currName) {
              controller.renameTagSet(newName: newName);
            }
          },
        ),
        CupertinoButton(
          padding: const EdgeInsets.all(0),
          minSize: 40,
          child: const Icon(
            // FontAwesomeIcons.magnifyingGlass,
            CupertinoIcons.search,
            size: 28,
          ),
          onPressed: () => controller.isSearchUserTags = true,
        ),
      ],
    );
  }

  Widget _searchTrailing(BuildContext context) {
    final _style = TextStyle(
      // height: 1,
      color: CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            controller.isSearchUserTags = false;
            controller.searchTags.clear();
            controller.searchNewTags.clear();
          },
          child: Text(
            L10n.of(context).cancel,
            style: _style,
          ).paddingSymmetric(horizontal: 8),
        ),
      ],
    );
  }

  Widget _trailing(BuildContext context) {
    return Obx(() {
      return controller.isSearchUserTags
          ? _searchTrailing(context)
          : _normalTrailing(context);
    });
  }

  Widget _normalMiddle(BuildContext context) {
    return Text(controller.curTagSet?.name ?? '');
  }

  Widget _searchMiddle(BuildContext context) {
    return CupertinoTextField.borderless(
      autofocus: true,
      controller: textEditingController,
      placeholder: 'Search tags',
      clearButtonMode: OverlayVisibilityMode.editing,
      onChanged: (value) => controller.inputSearchText = value,
    );
  }

  Widget _middle(BuildContext context) {
    return Obx(() {
      return controller.isSearchUserTags
          ? _searchMiddle(context)
          : _normalMiddle(context);
    });
  }
}

class ListViewEhMyTags extends StatefulWidget {
  const ListViewEhMyTags({super.key});

  @override
  State<ListViewEhMyTags> createState() => _ListViewEhMyTagsState();
}

class _ListViewEhMyTagsState extends State<ListViewEhMyTags> {
  EhMyTagsController get controller => Get.find<EhMyTagsController>();
  late Future<EhMytags?> future;

  @override
  void initState() {
    super.initState();
    future = controller.loadData();
  }

  Future tapUserTagItem(EhUsertag usertag) async {
    final _userTag = await showCupertinoDialog<EhUsertag>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return EhUserTagEditDialog(usertag: usertag);
        });
    if (_userTag == null || _userTag.tagid == null) {
      return;
    }
    logger.d('_userTag: ${_userTag.toJson()}');

    await Api.setUserTag(
      apikey: controller.apikey,
      apiuid: controller.apiuid,
      tagid: _userTag.tagid!,
      tagColor: _userTag.colorCode ?? '',
      tagWeight: _userTag.tagWeight ?? '',
      tagHide: _userTag.hide ?? false,
      tagWatch: _userTag.watch ?? false,
    );

    showToast('Save tag successfully');
    controller.isStackLoading = true;
    await controller.reloadData();
    controller.isStackLoading = false;
  }

  Future tapAddUserTagItem(EhUsertag usertag) async {
    final _userTag = await showCupertinoDialog<EhUsertag>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return EhUserTagEditDialog(usertag: usertag);
        });
    if (_userTag == null) {
      return;
    }
    logger.d('add _userTag: ${_userTag.toJson()}');

    await actionNewUserTag(
      tagName: _userTag.title,
      tagColor: _userTag.colorCode,
      tagWeight: _userTag.tagWeight,
      tagWatch: _userTag.watch,
      tagHide: _userTag.hide,
      tagset: controller.currSelected,
    );
    showToast('Add to mytags successful');

    controller.isStackLoading = true;
    await controller.reloadData();
    controller.isStackLoading = false;
  }

  Widget _buildUserTagItem(
    EhUsertag usertag,
    String title, {
    bool isTagTranslat = false,
    ValueChanged<String>? deleteUserTag,
    bool showLine = true,
  }) {
    final tagColor = ColorsUtil.hexStringToColor(usertag.colorCode);
    final inerTextColor = ColorsUtil.hexStringToColor(usertag.textColor);
    final tagWeight = usertag.tagWeight;

    late Widget _item;

    _item = EhCupertinoListTile(
      title: Text(usertag.title),
      leading: _buildHideIcon(usertag.hide, usertag.watch),
      trailing: _buildColorBox(
        tagColor: tagColor,
        tagWeight: tagWeight,
        inerTextColor: inerTextColor,
      ),
      subtitle: isTagTranslat ? Text(usertag.translate ?? '') : null,
      onTap: () async => tapUserTagItem(usertag),
    );

    return Slidable(
      key: ValueKey(usertag.title),
      child: _item,
      endActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => controller.deleteUserTag(title),
            backgroundColor: CupertinoDynamicColor.resolve(
                CupertinoColors.systemRed, context),
            icon: CupertinoIcons.delete,
          ),
        ],
      ),
    );
  }

  Widget _buildNewAddUserTagItem(
    EhUsertag usertag,
    int index, {
    bool isTagTranslat = false,
    ValueChanged<String>? deleteUserTag,
    bool showLine = true,
  }) {
    return EhCupertinoListTile(
      title: Text(usertag.title),
      leading: const Icon(FontAwesomeIcons.tag),
      subtitle: isTagTranslat ? Text(usertag.translate ?? '') : null,
      onTap: () async => tapAddUserTagItem(usertag),
    );
  }

  Widget _buildHideIcon(bool? hide, bool? watch) {
    late final IconData iconData;
    late final Color iconColor;

    if (watch ?? false) {
      iconColor =
          CupertinoDynamicColor.resolve(CupertinoColors.activeGreen, context);
      iconData = FontAwesomeIcons.circleCheck;
    } else if (hide ?? false) {
      iconColor = CupertinoDynamicColor.resolve(
          CupertinoColors.destructiveRed, context);
      iconData = FontAwesomeIcons.circleXmark;
    } else {
      iconColor =
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey4, context);
      iconData = FontAwesomeIcons.circleDot;
    }

    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Icon(
        iconData,
        size: 24,
        color: iconColor,
      ),
    );
  }

  Widget _buildColorBox({
    required Color? tagColor,
    required String? tagWeight,
    required Color? inerTextColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tagColor ??
            CupertinoColors.systemGroupedBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 2,
          color: CupertinoColors.systemGrey.withOpacity(0.5),
        ),
      ),
      child: Text(
        tagWeight ?? '',
        style: TextStyle(
          color: inerTextColor,
          height: 1.25,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: EhCupertinoSliverRefreshControl(
            onRefresh: controller.reloadData,
          ),
        ),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: FutureBuilder<EhMytags?>(
              future: future,
              initialData: controller.ehMyTags,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SliverFillRemaining(
                    child: CupertinoActivityIndicator(
                      radius: 16,
                    ),
                  );
                } else {
                  return Obx(() {
                    final usertags = controller.usertags;
                    if (usertags.isEmpty) {
                      return const SliverToBoxAdapter();
                    }
                    return SliverCupertinoListSection.insetGrouped(
                      additionalDividerMargin: 50,
                      itemBuilder: (context, index) {
                        final usertag = usertags[index];
                        return _buildUserTagItem(
                          usertag,
                          usertag.title,
                          isTagTranslat: controller.isTagTranslat,
                          deleteUserTag: (title) =>
                              controller.deleteUserTag(title),
                          showLine: index < usertags.length - 1,
                        );
                      },
                      itemCount: usertags.length,
                    );
                  });
                }
              }),
        ),
        // Obx(() {
        //   if (controller.isSearchUserTags) {
        //     return SliverSafeArea(
        //       top: false,
        //       sliver: Obx(() {
        //         final usertags = controller.searchNewTags;
        //         return SliverCupertinoListSection.insetGrouped(
        //           additionalDividerMargin: 50,
        //           key: ValueKey(usertags),
        //           itemBuilder: (context, index) {
        //             final usertag = usertags[index];
        //             return _buildNewAddUserTagItem(
        //               usertag,
        //               index,
        //               isTagTranslat: controller.isTagTranslat,
        //               deleteUserTag: (title) => controller.deleteUserTag(title),
        //               showLine: index < usertags.length - 1,
        //             );
        //           },
        //           itemCount: usertags.length,
        //         );
        //       }),
        //     );
        //   } else {
        //     return const SliverToBoxAdapter();
        //   }
        // }),
        SliverSafeArea(
          top: false,
          sliver: Obx(() {
            final usertags = controller.searchNewTags;
            return SliverCupertinoListSection.insetGrouped(
              additionalDividerMargin: 50,
              key: ValueKey(usertags),
              itemBuilder: (context, index) {
                final usertag = usertags[index];
                return _buildNewAddUserTagItem(
                  usertag,
                  index,
                  isTagTranslat: controller.isTagTranslat,
                  deleteUserTag: (title) => controller.deleteUserTag(title),
                  showLine: index < usertags.length - 1,
                );
              },
              itemCount: usertags.length,
            );
          }),
        ),
      ],
    );
  }
}
