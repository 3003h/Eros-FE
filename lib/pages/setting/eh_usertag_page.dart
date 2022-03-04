import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import 'comp/user_tag_item.dart';
import 'const.dart';
import 'controller/eh_mytags_controller.dart';
import 'eh_usertag_edit_dialog.dart';

class EhUserTagsPage extends GetView<EhMyTagsController> {
  const EhUserTagsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final title = controller.curTagSet?.name ?? '';
    return Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
              padding: const EdgeInsetsDirectional.only(end: 8),
              middle: Text(controller.curTagSet?.name ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (controller.ehMyTags.canDelete ?? false)
                    CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      minSize: 40,
                      child: const Icon(
                        LineIcons.trash,
                        size: 24,
                      ),
                      onPressed: () async {},
                    ),
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    minSize: 40,
                    child: const Icon(
                      LineIcons.plus,
                      size: 24,
                    ),
                    onPressed: () async {},
                  ),
                ],
              )),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // _buildSelectedTagsetItem(context),
                const ListViewEhMytags(),
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

    controller.reloadData();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      Obx(() {
        logger.d('build usertags ListView');
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final usertag = controller.usertags[index];

            final tagColor = ColorsUtil.hexStringToColor(usertag.colorCode);
            final borderColor =
                ColorsUtil.hexStringToColor(usertag.borderColor);
            final inerTextColor =
                ColorsUtil.hexStringToColor(usertag.textColor);
            final tagWeight = usertag.tagWeight;

            late Widget _item;

            if (controller.isTagTranslat) {
              _item = FutureBuilder<String?>(
                  future: controller.getTextTranslate(usertag.title),
                  initialData: usertag.title,
                  builder: (context, snapshot) {
                    return UserTagItem(
                      title: usertag.title,
                      desc: snapshot.data,
                      tagColor: tagColor,
                      borderColor: borderColor,
                      inerTextColor: inerTextColor,
                      tagWeight: tagWeight,
                      watch: usertag.watch ?? false,
                      hide: usertag.hide ?? false,
                      onTap: () async => tapUserTagItem(usertag),
                    );
                  });
            } else {
              _item = UserTagItem(
                title: usertag.title,
                tagColor: tagColor,
                borderColor: borderColor,
                inerTextColor: inerTextColor,
                tagWeight: tagWeight,
                watch: usertag.watch ?? false,
                hide: usertag.hide ?? false,
                onTap: () async => tapUserTagItem(usertag),
              );
            }

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
          },
          itemCount: controller.usertags.length,
        );
      }),
    ];

    return CustomScrollView(
      slivers: [
        EhCupertinoSliverRefreshControl(
          onRefresh: controller.reloadData,
        ),
        SliverSafeArea(
          sliver: FutureBuilder<EhMytags?>(
              future: future,
              initialData: controller.ehMyTags,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SliverFillRemaining(
                    child: CupertinoActivityIndicator(
                      radius: 20,
                    ),
                  );
                } else {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _list[index].autoCompressKeyboard(context);
                        // return _list[index];
                      },
                      childCount: _list.length,
                    ),
                  );
                }
              }),
        ),
        // Obx(() {
        //   if ((controller.ehMyTags.usertags ?? []).isNotEmpty) {
        //     return SliverToBoxAdapter(
        //       child: Container(
        //         padding: const EdgeInsets.only(
        //           left: 20,
        //           bottom: 4,
        //           top: 20,
        //         ),
        //         width: double.infinity,
        //         child: const Text(
        //           'User tags',
        //           style: TextStyle(fontSize: 14),
        //           textAlign: TextAlign.start,
        //         ),
        //       ),
        //     );
        //   } else {
        //     return const SliverToBoxAdapter();
        //   }
        // }),
        // Obx(() {
        //   final usertags = controller.ehMyTags.usertags ?? [];
        //   return SliverList(
        //     delegate: SliverChildBuilderDelegate(
        //       (context, index) {
        //         return TextItem(
        //           usertags[index].title,
        //           // onTap: controller.deleteProfile,
        //         );
        //       },
        //       childCount: usertags.length,
        //     ),
        //   );
        // }),
      ],
    );
  }
}
