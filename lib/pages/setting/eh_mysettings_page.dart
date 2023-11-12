import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/setting/const.dart';
import 'package:fehviewer/pages/setting/controller/eh_mysettings_controller.dart';
import 'package:fehviewer/pages/setting/setting_items/excluded_language.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:fehviewer/pages/setting/webview/web_mysetting_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'setting_items/single_input_item.dart';

part 'eh_mysettings_items.dart';

const kFavList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

class EhMySettingsPage extends GetView<EhMySettingsController> {
  const EhMySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
            padding: const EdgeInsetsDirectional.only(end: 8),
            middle: Text(L10n.of(context).ehentai_settings),
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
                    Get.to(() => InWebMySetting());
                  },
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  minSize: 40,
                  child: const Icon(
                    FontAwesomeIcons.circleCheck,
                    size: 22,
                  ),
                  onPressed: () async {
                    // 保存配置
                    controller.printParam();
                    await controller.applyProfile();
                  },
                ),
              ],
            )),
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
    future = controller.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _sliverList = <Widget>[
      Obx(() {
        return SliverCupertinoListSection.listInsetGrouped(
            header: Text(L10n.of(context).uc_profile),
            children: [
              _buildSelectedProfileItem(context),
              EhCupertinoListTile(
                title: Text(L10n.of(context).uc_rename),
                onTap: controller.renameProfile,
              ),
              EhCupertinoListTile(
                title: Text(L10n.of(context).uc_crt_profile),
                onTap: controller.crtNewProfile,
              ),
              if (!controller.selectedIsDefault)
                EhCupertinoListTile(
                  title: Text(L10n.of(context).uc_del_profile),
                  onTap: controller.deleteProfile,
                ),
              if (!controller.selectedIsDefault)
                EhCupertinoListTile(
                  title: Text(L10n.of(context).uc_set_as_def),
                  onTap: controller.setDefaultProfile,
                ),
            ]);
      }),

      SliverCupertinoListSection.listInsetGrouped(
        header: Text(L10n.of(context).uc_img_load_setting),
        children: [_buildLoadTypeItem(context)],
      ),

      // xr
      SliverCupertinoListSection.listInsetGrouped(
        header: Text(L10n.of(context).uc_img_size_setting),
        footer: Text(L10n.of(context).uc_res_res_desc),
        children: [_buildImageSizeItem(context)],
      ),

      // uc_ori_image_desc
      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_ori_image_desc),
        children: [_buildOriginalImages(context)],
      ),

      // uc_img_cussize_desc
      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_img_cussize_desc),
        children: [
          _buildSizeHorizontal(context),
          _buildSizeVertical(context),
        ],
      ),

      // uc_name_display_desc
      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_name_display_desc),
        children: [_buildNameDisplayItem(context)],
      ),

      // uc_archiver_desc
      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_archiver_desc),
        children: [_buildArchiverSettingsItem(context)],
      ),

      // uc_front_page_desc
      SliverCupertinoListSection.listInsetGrouped(
        children: [_buildFrontPageSettingsItem(context)],
      ),

      // uc_fav
      Obx(() {
        return SliverCupertinoListSection.listInsetGrouped(
          header: Text(L10n.of(context).uc_fav),
          hasLeading: true,
          children: [
            ...kFavList.map((e) {
              final String _title = controller.ehSetting.favMap['$e'] ?? '';
              // logger.d('favMap: $e $_title');
              return CupertinoTextInputListTile(
                leading: Icon(
                  FontAwesomeIcons.solidHeart,
                  color: ThemeColors.favColor['$e'],
                ),
                // textAlign: TextAlign.left,
                initValue: _title,
                onChanged: (val) => controller.ehSetting.setFavname('$e', val),
              );
            }).toList(),
          ],
        );
      }),

      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_fav_sort_desc),
        children: [_buildFavoritesSortItem(context)],
      ),

      // uc_rating_desc
      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_rating_desc),
        children: [_buildRatingsItem(context)],
      ),

      // uc_tag_ft_desc
      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_tag_ft_desc),
        children: [_buildTagFilteringThreshold(context)],
      ),

      // uc_tag_wt_desc
      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_tag_wt_desc),
        children: [_buildTagWatchingThreshold(context)],
      ),

      // to uc_exc_lang
      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_exc_lang_desc),
        children: [
          // to ExcludedLanguagePage
          EhCupertinoListTile(
            title: Text(L10n.of(context).uc_exc_lang),
            trailing: const CupertinoListTileChevron(),
            onTap: () {
              Get.to(
                () => const ExcludedLanguagePage(),
                id: isLayoutLarge ? 2 : null,
              );
            },
          ),
        ],
      ),

      // uc_exc_up_desc
      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_exc_up_desc),
        children: [_buildExcludedUploaders(context)],
      ),

      // uc_search_r_count_desc
      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_search_r_count_desc),
        children: [_buildSearchResultCountItem(context)],
      ),

      // uc_thumb_setting
      SliverCupertinoListSection.listInsetGrouped(
        header: Text(L10n.of(context).uc_thumb_setting),
        children: [
          _buildThumbMouseOverItem(context),
          _buildThumbSizeItem(context),
          _buildThumbRowItem(context),
        ],
      ),

      // uc_thumb_scaling_desc
      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_thumb_scaling_desc),
        children: [_buildThumbnailScaling(context)],
      ),

      // uc_viewport_or_desc
      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).uc_viewport_or_desc),
        children: [_buildViewportOverride(context)],
      ),

      // uc_gallery_comments
      SliverCupertinoListSection.listInsetGrouped(
        header: Text(L10n.of(context).uc_gallery_comments),
        children: [
          _buildSortOrderComment(context),
          _buildShowCommentVotes(context),
        ],
      ),

      // uc_gallery_tags
      SliverCupertinoListSection.listInsetGrouped(
        children: [_buildSortOrderTags(context)],
      ),

      // uc_gallery_page_numbering
      SliverCupertinoListSection.listInsetGrouped(
        children: [_buildShowPageNumbers(context)],
      ),

      // uc_mpv
      SliverCupertinoListSection.listInsetGrouped(
        header: Text(L10n.of(context).uc_mpv),
        children: [
          _buildMPVAlwaysUse(context),
          _buildMPVDisplayStyle(context),
          _buildMPVThumbPane(context),
        ],
      ),

      // end
    ];

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
                  return MultiSliver(
                    children: _sliverList,
                  );
                }
              }),
        ),
      ],
    );
  }
}
