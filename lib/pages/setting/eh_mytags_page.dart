import 'package:fehviewer/common/service/theme_service.dart';
import 'package:flutter/cupertino.dart';
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
                  // CupertinoButton(
                  //   padding: const EdgeInsets.all(0),
                  //   minSize: 40,
                  //   child: const Icon(
                  //     LineIcons.checkCircle,
                  //     size: 24,
                  //   ),
                  //   onPressed: () async {
                  //     // 保存配置
                  //     // controller.printParam();
                  //     // await controller.applyProfile();
                  //   },
                  // ),
                ],
              )),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
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

    logger.d('_userTag: ${_userTag?.toJson()}');
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      GroupItem(
        title: 'Tagset',
        child: Column(
          children: [
            _buildSelectedTagsetItem(context, hideLine: false),
            TextItem(
              L10n.of(context).uc_rename,
              textColor: CupertinoDynamicColor.resolve(
                  CupertinoColors.activeBlue, context),
              // onTap: controller.renameProfile,
            ),
            Obx(() {
              if (controller.ehMyTags.canDelete ?? false) {
                return TextItem(
                  L10n.of(context).uc_del_profile,
                  onTap: controller.deleteTagset,
                  textColor: CupertinoDynamicColor.resolve(
                      CupertinoColors.activeBlue, context),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
            TextItem(
              L10n.of(context).uc_crt_profile,
              onTap: controller.crtNewTagset,
              textColor: CupertinoDynamicColor.resolve(
                  CupertinoColors.activeBlue, context),
              hideLine: true,
            ),
          ],
        ),
      ),
      Obx(() {
        final usertags = controller.ehMyTags.usertags ?? [];
        return GroupItem(
          title: usertags.isNotEmpty ? 'User tags' : '',
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final usertag = usertags[index];

              final tagColor = ColorsUtil.hexStringToColor(usertag.colorCode);
              final borderColor =
                  ColorsUtil.hexStringToColor(usertag.borderColor);
              final inerTextColor =
                  ColorsUtil.hexStringToColor(usertag.textColor);
              final tagWeight = usertag.tagWeight;

              if (controller.isTagTranslat) {
                return FutureBuilder<String?>(
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
                return UserTagItem(
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
            },
            itemCount: usertags.length,
          ),
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
