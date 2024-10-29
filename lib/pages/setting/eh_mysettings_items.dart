part of '../setting/eh_mysettings_page.dart';

final _controller = Get.find<EhMySettingsController>();

Widget _buildSelectedProfileItem(BuildContext context) {
  return Obx(() {
    final Map<String, String> actionMap = <String, String>{};
    for (final ehProfile in _controller.ehSetting.profilelist) {
      actionMap['${ehProfile.value}'] = ehProfile.name;
    }
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_selected,
      actionTitle: 'Selected Profile',
      actionMap: actionMap,
      initVal: _controller.ehSetting.profileSelected ?? '',
      onValueChanged: (val) {
        if (val != _controller.ehSetting.profileSelected) {
          _controller.changeProfile(val);
        }
      },
    );
  });
}

Widget _buildLoadTypeItem(BuildContext context) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_uh_0,
    '1': L10n.of(context).uc_uh_1,
    '2': L10n.of(context).uc_uh_2,
    '3': L10n.of(context).uc_uh_3,
  };

  final Map<String, String> simpleActionMap = <String, String>{
    '0': L10n.of(context).uc_uh_0_s,
    '1': L10n.of(context).uc_uh_1_s,
    '2': L10n.of(context).uc_uh_2_s,
    '3': L10n.of(context).uc_uh_3_s,
  };
  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_thor_hath,
      actionMap: actionMap,
      simpleActionMap: simpleActionMap,
      initVal: _controller.ehSetting.loadImageThroughHAtH ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(loadImageThroughHAtH: val.oN),
    );
  });
}

Widget _buildImageSizeItem(BuildContext context) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_auto,
    '5': '2400x',
    '4': '1600x',
    '3': '1280x',
    // '2': '980x',
    '1': '780x',
  };
  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_res_res,
      actionMap: actionMap,
      initVal: _controller.ehSetting.imageSize ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(imageSize: val.oN),
    );
  });
}

Widget _buildNameDisplayItem(BuildContext context) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_tl_0,
    '1': L10n.of(context).uc_tl_1,
  };
  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_name_display,
      actionMap: actionMap,
      initVal: _controller.ehSetting.galleryNameDisplay ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(galleryNameDisplay: val.oN),
    );
  });
}

Widget _buildArchiverSettingsItem(BuildContext context) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_ar_0,
    '1': L10n.of(context).uc_ar_1,
    '2': L10n.of(context).uc_ar_2,
    '3': L10n.of(context).uc_ar_3,
    '4': L10n.of(context).uc_ar_4,
    '5': L10n.of(context).uc_ar_5,
  };
  final Map<String, String> sActionMap = <String, String>{
    '0': 'MM (Default)',
    '1': 'MA',
    '2': 'AOM',
    '3': 'AOA',
    '4': 'ARM',
    '5': 'ARA',
  };
  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_archiver_set,
      actionMap: actionMap,
      initVal: _controller.ehSetting.archiverSettings ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(archiverSettings: val.oN),
    );
  });
}

Widget _buildFrontPageSettingsItem(BuildContext context) {
  final Map<String, String> actionMap = <String, String>{
    '3': L10n.of(context).uc_dm_3,
    '4': L10n.of(context).uc_dm_4,
    '0': L10n.of(context).uc_dm_0,
    '2': L10n.of(context).uc_dm_2,
    '1': L10n.of(context).uc_dm_1,
  };

  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_front_page_dis_mode,
      actionMap: actionMap,
      initVal: _controller.ehSetting.frontPageSettings ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(frontPageSettings: val.oN),
    );
  });
}

Widget _buildFavoritesSortItem(
  BuildContext context,
) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_fs_0,
    '1': L10n.of(context).uc_fs_1,
  };

  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_fav_sort,
      actionMap: actionMap,
      initVal: _controller.ehSetting.frontPageSettings ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(frontPageSettings: val.oN),
    );
  });
}

Widget _buildSearchResultCountItem(BuildContext context) {
  final Map<String, String> actionMap = <String, String>{
    '0': '25',
    '1': '50',
    '2': '100',
    '3': '200',
  };

  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_search_r_count,
      actionMap: actionMap,
      initVal: _controller.ehSetting.searchResultCount ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(searchResultCount: val.oN),
    );
  });
}

Widget _buildThumbMouseOverItem(
  BuildContext context,
) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_lt_0,
    '1': L10n.of(context).uc_lt_1,
  };

  final Map<String, String> sActionMap = <String, String>{
    '0': L10n.of(context).uc_lt_0_s,
    '1': L10n.of(context).uc_lt_1_s,
  };

  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_mose_over_thumb,
      actionMap: actionMap,
      simpleActionMap: sActionMap,
      initVal: _controller.ehSetting.mouseOverThumbnails ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(mouseOverThumbnails: val.oN),
    );
  });
}

Widget _buildThumbSizeItem(
  BuildContext context,
) {
  final Map<String, String> actionMap = <String, String>{
    // auto
    '0': L10n.of(context).uc_ts_0,
    // normal
    '1': L10n.of(context).uc_ts_1,
    // small
    '2': L10n.of(context).uc_ts_2,
  };

  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_thumb_size,
      actionMap: actionMap,
      initVal: _controller.ehSetting.thumbnailSize ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(thumbnailSize: val.oN),
    );
  });
}

Widget _buildThumbRowItem(
  BuildContext context,
) {
  final Map<String, String> actionMap = <String, String>{
    '0': '4',
    '1': '8',
    '2': '20',
    '3': '40',
  };

  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_thumb_row,
      actionMap: actionMap,
      initVal: _controller.ehSetting.thumbnailRows ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(thumbnailRows: val.oN),
    );
  });
}

Widget _buildSortOrderComment(
  BuildContext context,
) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_cs_0,
    '1': L10n.of(context).uc_cs_1,
    '2': L10n.of(context).uc_cs_2,
  };

  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_comments_sort_order,
      actionMap: actionMap,
      initVal: _controller.ehSetting.sortOrderComments ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(sortOrderComments: val.oN),
    );
  });
}

Widget _buildShowCommentVotes(
  BuildContext context,
) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_sc_0,
    '1': L10n.of(context).uc_sc_1,
  };

  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_comments_show_votes,
      actionMap: actionMap,
      initVal: _controller.ehSetting.showCommentVotes ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(showCommentVotes: val.oN),
    );
  });
}

Widget _buildSortOrderTags(
  BuildContext context,
) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_tb_0,
    '1': L10n.of(context).uc_tb_1,
  };

  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_tag_short_order,
      actionMap: actionMap,
      initVal: _controller.ehSetting.sortOrderTags ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(sortOrderTags: val.oN),
    );
  });
}

Widget _buildShowPageNumbers(
  BuildContext context,
) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_pn_0,
    '1': L10n.of(context).uc_pn_1,
    '2': L10n.of(context).uc_pn_2,
  };

  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_show_page_num,
      actionMap: actionMap,
      initVal: _controller.ehSetting.showGalleryPageNumbers ?? '0',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(showGalleryPageNumbers: val.oN),
    );
  });

  // return EhCupertinoListTile(
  //   title: Text(L10n.of(context).uc_show_page_num),
  //   trailing: Obx(() {
  //     return CupertinoSwitch(
  //       value: _controller.ehSetting.showGalleryPageNumbers == '0',
  //       onChanged: (val) => _controller.ehSetting = _controller.ehSetting
  //           .copyWith(showGalleryPageNumbers: val ? '0'.oN : '1'.oN),
  //     );
  //   }),
  // );
}

Widget _buildOriginalImages(
  BuildContext context,
) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_oi_0,
    '1': L10n.of(context).uc_oi_1,
  };

  return EhCupertinoListTile(
    title: Text(L10n.of(context).uc_ori_image),
    trailing: Obx(() {
      return CupertinoSwitch(
        value: _controller.ehSetting.originalImages == '1',
        onChanged: (val) => _controller.ehSetting = _controller.ehSetting
            .copyWith(originalImages: val ? '1'.oN : '0'.oN),
      );
    }),
  );
}

Widget _buildMPVAlwaysUse(
  BuildContext context,
) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_qb_0,
    '1': L10n.of(context).uc_qb_1,
  };

  return EhCupertinoListTile(
    title: Text(L10n.of(context).uc_mpv_always),
    trailing: Obx(() {
      return CupertinoSwitch(
        value: _controller.ehSetting.alwaysUseMpv == '1',
        onChanged: (val) => _controller.ehSetting =
            _controller.ehSetting.copyWith(alwaysUseMpv: val ? '1'.oN : '0'.oN),
      );
    }),
  );
}

Widget _buildMPVDisplayStyle(
  BuildContext context,
) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_ms_0,
    '1': L10n.of(context).uc_ms_1,
    '2': L10n.of(context).uc_ms_2,
  };

  final Map<String, String> sActionMap = <String, String>{
    '0': 'Align left',
    '1': 'Align center 1',
    '2': 'Align center 2',
  };

  return Obx(() {
    return SelectorCupertinoListTile<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_mpv_stype,
      actionTitle: 'Multi-Page Viewer Display Style',
      actionMap: actionMap,
      initVal: _controller.ehSetting.mpvStyle ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(mpvStyle: val.oN),
    );
  });
}

Widget _buildMPVThumbPane(
  BuildContext context,
) {
  final Map<String, String> actionMap = <String, String>{
    '0': L10n.of(context).uc_mt_0,
    '1': L10n.of(context).uc_mt_1,
  };

  return EhCupertinoListTile(
    title: Text(L10n.of(context).uc_mpv_thumb_pane),
    trailing: Obx(() {
      return CupertinoSwitch(
        value: _controller.ehSetting.mpvThumbnailPane == '0',
        onChanged: (val) => _controller.ehSetting = _controller.ehSetting
            .copyWith(mpvThumbnailPane: val ? '0'.oN : '1'.oN),
      );
    }),
  );
}

Widget _buildRatingsItem(
  BuildContext context,
) {
  return Obx(() {
    return CupertinoTextInputListTile(
      title: L10n.of(context).uc_rating,
      placeholder: 'RRGGB',
      initValue: _controller.ehSetting.ratings ?? '',
      onChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(ratings: val.oN),
    );
  });
}

Widget _buildTagFilteringThreshold(BuildContext context) {
  return Obx(() {
    return CupertinoTextInputListTile(
      title: L10n.of(context).uc_tag_ft,
      initValue: _controller.ehSetting.tagFilteringThreshold ?? '',
      onChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(tagFilteringThreshold: val.oN),
    );
  });
}

Widget _buildTagWatchingThreshold(BuildContext context) {
  return Obx(() {
    return CupertinoTextInputListTile(
      title: L10n.of(context).uc_tag_wt,
      initValue: _controller.ehSetting.tagWatchingThreshold ?? '',
      onChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(tagWatchingThreshold: val.oN),
    );
  });
}

Widget _buildExcludedUploaders(BuildContext context) {
  return Obx(() {
    return SingleInputItem(
      title: L10n.of(context).uc_exc_up,
      hideLine: true,
      maxLines: _controller.ehSetting.xuQuotaMax,
      selector:
          '${_controller.ehSetting.excludedUploaders?.trim().split('\n').where((element) => element.trim().isNotEmpty).length ?? 0}'
          '/${_controller.ehSetting.xuQuotaMax}',
      initValue: _controller.ehSetting.excludedUploaders ?? '',
      onChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(excludedUploaders: val.oN),
    );
  });
}

Widget _buildThumbnailScaling(BuildContext context) {
  // Thumbnail Scaling
  return Obx(() {
    return CupertinoTextInputListTile(
      title: L10n.of(context).uc_thumb_scaling,
      placeholder: '100',
      trailing: const Text('%'),
      initValue: _controller.ehSetting.thumbnailScaling ?? '',
      onChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(thumbnailScaling: val.oN),
    );
  });
}

Widget _buildViewportOverride(BuildContext context) {
  // Thumbnail Scaling
  return Obx(() {
    return CupertinoTextInputListTile(
      title: L10n.of(context).uc_viewport_or,
      trailing: const Text('px'),
      initValue: _controller.ehSetting.viewportOverride ?? '',
      onChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(viewportOverride: val.oN),
    );
  });
}

Widget _buildSizeHorizontal(BuildContext context) {
  return Obx(() {
    return CupertinoTextInputListTile(
      title: L10n.of(context).uc_img_horiz,
      initValue: _controller.ehSetting.imageSizeHorizontal ?? '',
      onChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(imageSizeHorizontal: val.oN),
    );
  });
}

Widget _buildSizeVertical(BuildContext context) {
  return Obx(() {
    return CupertinoTextInputListTile(
      title: L10n.of(context).uc_img_vert,
      initValue: _controller.ehSetting.imageSizeVertical ?? '',
      onChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(imageSizeVertical: val.oN),
    );
  });
}
