import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/network/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../const.dart';
import '../controller/eh_mytags_controller.dart';
import '../webview/eh_tagset_edit_dialog.dart';
import 'eh_usertag_edit_dialog.dart';
import 'user_tag_item.dart';

class EhUserTagsPage extends StatefulWidget {
  const EhUserTagsPage({Key? key}) : super(key: key);

  @override
  State<EhUserTagsPage> createState() => _EhUserTagsPageState();
}

class _EhUserTagsPageState extends State<EhUserTagsPage> {
  final EhMyTagsController controller = Get.find<EhMyTagsController>();
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.isSearchUserTags = false;
    controller.searchTags.clear();
    controller.searchNewTags.clear();
  }

  Widget _normalTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (controller.canDelete)
          CupertinoButton(
            padding: const EdgeInsets.all(0),
            minSize: 40,
            child: const Icon(
              FontAwesomeIcons.trash,
              size: 22,
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
              controller.renameTagset(newName: newName);
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

      // return AnimatedCrossFade(
      //   firstChild: _normalTrailing(context),
      //   secondChild: _searchTrailing(context),
      //   crossFadeState: controller.isSearchUserTags
      //       ? CrossFadeState.showSecond
      //       : CrossFadeState.showFirst,
      //   duration: 300.milliseconds,
      // );
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

      // return AnimatedCrossFade(
      //   firstChild: _normalMiddle(context),
      //   secondChild: _searchMiddle(context),
      //   crossFadeState: controller.isSearchUserTags
      //       ? CrossFadeState.showSecond
      //       : CrossFadeState.showFirst,
      //   duration: 200.milliseconds,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
            padding: const EdgeInsetsDirectional.only(end: 8),
            middle: _middle(context),
            trailing: _trailing(context),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // _buildSelectedTagsetItem(context),
              const ListViewEhMytags(),
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
          ));
    });
  }
}

class ListViewEhMytags extends StatefulWidget {
  const ListViewEhMytags({Key? key}) : super(key: key);

  @override
  _ListViewEhMytagsState createState() => _ListViewEhMytagsState();
}

class _ListViewEhMytagsState extends State<ListViewEhMytags> {
  final controller = Get.find<EhMyTagsController>();
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
    int index, {
    bool isTagTranslat = false,
    ValueChanged<int>? deleteUserTag,
    bool showLine = true,
  }) {
    final tagColor = ColorsUtil.hexStringToColor(usertag.colorCode);
    final borderColor = ColorsUtil.hexStringToColor(usertag.borderColor);
    final inerTextColor = ColorsUtil.hexStringToColor(usertag.textColor);
    final tagWeight = usertag.tagWeight;

    late Widget _item;

    _item = UserTagItem(
      title: usertag.title,
      desc: isTagTranslat ? usertag.translate : null,
      tagColor: tagColor,
      borderColor: borderColor,
      inerTextColor: inerTextColor,
      tagWeight: tagWeight,
      watch: usertag.watch ?? false,
      hide: usertag.hide ?? false,
      onTap: () async => tapUserTagItem(usertag),
      hideLine: !showLine,
    );

    return Slidable(
      key: ValueKey(usertag.title),
      child: _item,
      endActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => controller.deleteUsertag(index),
            backgroundColor: CupertinoDynamicColor.resolve(
                CupertinoColors.systemRed, context),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            // label: L10n.of(context).delete,
          ),
        ],
      ),
    );
  }

  Widget _buildNewAddUserTagItem(
    EhUsertag usertag,
    int index, {
    bool isTagTranslat = false,
    ValueChanged<int>? deleteUserTag,
    bool showLine = true,
  }) {
    final tagColor = ColorsUtil.hexStringToColor(usertag.colorCode);
    final borderColor = ColorsUtil.hexStringToColor(usertag.borderColor);
    final inerTextColor = ColorsUtil.hexStringToColor(usertag.textColor);
    final tagWeight = usertag.tagWeight;

    return UserTagItem(
      addItem: true,
      title: usertag.title,
      desc: isTagTranslat ? usertag.translate : null,
      tagColor: tagColor,
      borderColor: borderColor,
      inerTextColor: inerTextColor,
      tagWeight: tagWeight,
      watch: usertag.watch ?? false,
      hide: usertag.hide ?? false,
      onTap: () async => tapAddUserTagItem(usertag),
      hideLine: !showLine,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: context.mediaQueryPadding.top),
          sliver: EhCupertinoSliverRefreshControl(
            onRefresh: controller.reloadData,
          ),
        ),
        SliverSafeArea(
          top: false,
          bottom: !controller.isSearchUserTags,
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
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final usertag = usertags[index];
                          return _buildUserTagItem(
                            usertag,
                            index,
                            isTagTranslat: controller.isTagTranslat,
                            deleteUserTag: (i) => controller.deleteUsertag(i),
                            showLine: index < usertags.length - 1,
                          );
                        },
                        childCount: usertags.length,
                      ),
                    );
                  });
                }
              }),
        ),
        Obx(() {
          if (controller.isSearchUserTags) {
            return SliverToBoxAdapter(
              child: Obx(() {
                return Container(
                  height: 20,
                  color: !ehTheme.isDarkMode
                      ? CupertinoColors.secondarySystemBackground
                      : null,
                );
              }),
            );
          } else {
            return const SliverToBoxAdapter();
          }
        }),
        Obx(() {
          if (controller.isSearchUserTags) {
            return SliverSafeArea(
              top: false,
              sliver: Obx(() {
                final usertags = controller.searchNewTags;
                return SliverList(
                  key: ValueKey(usertags),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final usertag = usertags[index];
                      return _buildNewAddUserTagItem(
                        usertag,
                        index,
                        isTagTranslat: controller.isTagTranslat,
                        deleteUserTag: (i) => controller.deleteUsertag(i),
                        showLine: index < usertags.length - 1,
                      );
                    },
                    childCount: usertags.length,
                  ),
                );
              }),
            );
          } else {
            return const SliverToBoxAdapter();
          }
        }),
      ],
    );
  }
}
