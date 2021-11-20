import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/extension.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/setting/setting_items/multi_selector.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:fehviewer/widget/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import 'controller/eh_mysettings_controller.dart';
import 'setting_base.dart';
import 'setting_items/multi_selector.dart';
import 'setting_items/single_input_item.dart';
import 'webview/web_mysetting_in.dart';

part 'eh_mysettings_items.dart';

const kIndicatorRadius = 20.0;

class EhMySettingsPage extends GetView<EhMySettingsController> {
  const EhMySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
            padding: const EdgeInsetsDirectional.only(end: 8),
            middle: Text(L10n.of(context).ehentai_settings),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // CupertinoButton(
                //   padding: const EdgeInsets.all(0),
                //   minSize: 36,
                //   child: const Icon(
                //     LineIcons.download,
                //     size: 24,
                //   ),
                //   onPressed: () async {
                //     controller.loadData();
                //   },
                // ),
                // CupertinoButton(
                //   padding: const EdgeInsets.all(0),
                //   minSize: 36,
                //   child: const Icon(
                //     LineIcons.upload,
                //     size: 24,
                //   ),
                //   onPressed: () async {
                //     controller.print();
                //   },
                // ),
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  minSize: 40,
                  child: const Icon(
                    LineIcons.globeWithAmericasShown,
                    size: 24,
                  ),
                  onPressed: () async {
                    Get.to(() => InWebMySetting());
                  },
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  minSize: 40,
                  child: const Icon(
                    LineIcons.checkCircle,
                    size: 24,
                  ),
                  onPressed: () async {
                    // 保存配置
                    controller.printParam();
                    await controller.applyProfile();
                  },
                ),
              ],
            )),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              ListViewEhMySettings(),
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
  }
}

class ListViewEhMySettings extends StatefulWidget {
  @override
  State<ListViewEhMySettings> createState() => _ListViewEhMySettingsState();
}

class _ListViewEhMySettingsState extends State<ListViewEhMySettings> {
  final controller = Get.find<EhMySettingsController>();
  late Future<EhSettings?> future;

  @override
  void initState() {
    super.initState();
    future = _controller.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      GroupItem(
        title: L10n.of(context).uc_profile,
        child: Column(
          children: [
            _buildSelectedProfileItem(context, hideLine: false),
            TextItem(
              L10n.of(context).uc_rename,
              onTap: controller.renameProfile,
            ),
            Obx(() {
              return TextItem(
                L10n.of(context).uc_crt_profile,
                onTap: controller.crtNewProfile,
                hideLine: controller.selectedIsDefault,
              );
            }),
            Obx(() {
              if (controller.selectedIsDefault) {
                return const SizedBox.shrink();
              } else {
                return TextItem(
                  L10n.of(context).uc_del_profile,
                  onTap: controller.deleteProfile,
                );
              }
            }),
            Obx(() {
              if (controller.selectedIsDefault) {
                return const SizedBox.shrink();
              } else {
                return TextItem(
                  L10n.of(context).uc_set_as_def,
                  onTap: controller.setDefaultProfile,
                  hideLine: true,
                );
              }
            }),
          ],
        ),
      ),

      // uh
      GroupItem(
        title: L10n.of(context).uc_img_load_setting,
        child: _buildLoadTypeItem(context, hideLine: true),
      ),
      // xr
      GroupItem(
        title: L10n.of(context).uc_img_size_setting,
        desc: L10n.of(context).uc_res_res_desc,
        child: _buildImageSizeItem(context, hideLine: true),
      ),
      GroupItem(
        desc: L10n.of(context).uc_img_cussize_desc,
        child: Column(
          children: [
            _buildSizeHorizontal(context),
            _buildSizeVertical(context),
          ],
        ),
      ),
      GroupItem(
        // title: 'Gallery Name Display',
        desc: L10n.of(context).uc_name_display_desc,
        child: _buildNameDisplayItem(context, hideLine: true),
      ),
      GroupItem(
        // title: 'Archiver Settings',
        desc: L10n.of(context).uc_archiver_desc,
        child: _buildArchiverSettingsItem(context, hideLine: true),
      ),
      GroupItem(
        // title: 'Front Page',
        child: _buildFrontPageSettingsItem(context, hideLine: true),
      ),
      GroupItem(
        title: L10n.of(context).uc_fav,
        child: Column(
          children: [
            _buildFavoritesSortItem(context, hideLine: true),
          ],
        ),
        desc: L10n.of(context).uc_fav_sort_desc,
      ),
      GroupItem(
        desc: L10n.of(context).uc_rating_desc,
        child: _buildRatingsItem(context, hideLine: true),
      ),
      GroupItem(
        title: L10n.of(context).uc_tag_namesp,
        child: _buildTagNamespaces(context),
        desc: L10n.of(context).uc_xt_desc,
      ),
      GroupItem(
        child: _buildTagFilteringThreshold(context),
        desc: L10n.of(context).uc_tag_ft_desc,
      ),
      GroupItem(
        child: _buildTagWatchingThreshold(context),
        desc: L10n.of(context).uc_tag_wt_desc,
      ),
      GroupItem(
        title: L10n.of(context).uc_exc_lang,
        child: _buildExcludedLanguage(context),
        desc: L10n.of(context).uc_exc_lang_desc,
      ),
      GroupItem(
        child: _buildExcludedUploaders(context),
        desc: L10n.of(context).uc_exc_up_desc,
      ),
      GroupItem(
        desc: L10n.of(context).uc_search_r_count_desc,
        child: _buildSearchResultCountItem(context, hideLine: true),
      ),
      GroupItem(
        title: L10n.of(context).uc_thumb_setting,
        child: Column(
          children: [
            _buildThumbMouseOverItem(context),
            _buildThumbSizeItem(context),
            _buildThumbRowItem(context, hideLine: true),
          ],
        ),
      ),
      GroupItem(
        child: _buildThumbnailScaling(context),
        desc: L10n.of(context).uc_thumb_scaling_desc,
      ),
      GroupItem(
        child: _buildViewportOverride(context),
        desc: L10n.of(context).uc_viewport_or_desc,
      ),
      GroupItem(
        title: L10n.of(context).uc_gallery_comments,
        child: Column(
          children: [
            _buildSortOrderComment(context),
            _buildShowCommentVotes(context, hideLine: true),
          ],
        ),
      ),
      GroupItem(
        // title: 'Gallery Tags',
        child: _buildSortOrderTags(context, hideLine: true),
      ),
      GroupItem(
        // title: 'Gallery Page Numbering',
        child: _buildShowPageNumbers(context, hideLine: true),
      ),
      GroupItem(
        title: L10n.of(context).uc_hath_local_host,
        child: _buildHatHLocalNetworkHost(context),
        desc: L10n.of(context).uc_hath_local_host_desc,
      ),
      GroupItem(
        // title: 'Original Images',
        desc: L10n.of(context).uc_ori_image_desc,
        child: _buildOriginalImages(context, hideLine: true),
      ),
      GroupItem(
        title: L10n.of(context).uc_mpv,
        child: Column(
          children: [
            _buildMPVAlwaysUse(context),
            _buildMPVDisplayStyle(context),
            _buildMPVThumbPane(context, hideLine: true),
          ],
        ),
      ),
    ];

    return CustomScrollView(
      slivers: [
        EhCupertinoSliverRefreshControl(
          onRefresh: _controller.reloadData,
        ),
        SliverSafeArea(
          sliver: FutureBuilder<EhSettings?>(
              future: future,
              initialData: controller.ehSetting,
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
                        return _list[index];
                      },
                      childCount: _list.length,
                    ),
                  );
                }
              }),
        ),
      ],
    );

    // return ListView.builder(
    //   itemCount: _list.length,
    //   itemBuilder: (BuildContext context, int index) {
    //     return _list[index];
    //   },
    // );
  }
}

class GroupItem extends StatelessWidget {
  const GroupItem({Key? key, this.title, this.child, this.desc})
      : super(key: key);
  final String? title;
  final Widget? child;
  final String? desc;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          // constraints: const BoxConstraints(minHeight: 38),
          padding: EdgeInsets.only(
            left: 20,
            bottom: 4,
            top: title != null ? 20 : 0,
          ),
          width: double.infinity,
          child: Text(
            title ?? '',
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.start,
          ),
        ),
        child ?? const SizedBox.shrink(),
        if (desc != null)
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              top: 4,
              bottom: 10,
              right: 20,
            ),
            width: double.infinity,
            child: Text(
              desc!,
              style: TextStyle(
                fontSize: 12.5,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel, context),
              ),
              textAlign: TextAlign.start,
            ),
          ),
      ],
    );
  }
}
