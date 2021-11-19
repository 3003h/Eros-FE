part of 'eh_mysettings_page.dart';

final _controller = Get.find<EhMySettingsController>();

Widget _buildSelectedProfileItem(BuildContext context,
    {bool hideLine = false}) {
  return Obx(() {
    final Map<String, String> actionMap = <String, String>{};
    for (final _profile in _controller.ehSetting.profilelist) {
      actionMap['${_profile.value}'] = _profile.name;
    }
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_selected,
      actionTitle: 'Selected Profile',
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.profileSelected ?? '',
      onValueChanged: (val) {
        print(val);
      },
    );
  });
}

Widget _buildLoadTypeItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Any client (Recommended)',
    '1':
        'Default port clients only (Can be slower. Enable if behind firewall/proxy that blocks outgoing non-standard ports.)',
    '2':
        'No (Donator only. You will not be able to browse as many pages, enable only if having severe problems.)',
  };

  final Map<String, String> simpleActionMap = <String, String>{
    '0': 'Any client',
    '1': 'Default port',
    '2': 'No',
  };
  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_thor_hath,
      hideLine: hideLine,
      actionMap: actionMap,
      simpleActionMap: simpleActionMap,
      initVal: _controller.ehSetting.loadImageThroughHAtH ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(loadImageThroughHAtH: val),
    );
  });
}

Widget _buildImageSizeItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Auto',
    '5': '2400x',
    '4': '1600x',
    '3': '1280x',
    '2': '980x',
    '1': '780x',
  };
  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_res_res,
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.imageSize ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(imageSize: val),
    );
  });
}

Widget _buildNameDisplayItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Default Title',
    '1': 'Japanese Title',
  };
  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_name_display,
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.galleryNameDisplay ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(galleryNameDisplay: val),
    );
  });
}

Widget _buildArchiverSettingsItem(BuildContext context,
    {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Manual Select, Manual Start (Default)',
    '1': 'Manual Select, Auto Start',
    '2': 'Auto Select Original, Manual Start',
    '3': 'Auto Select Original, Auto Start',
    '4': 'Auto Select Resample, Manual Start',
    '5': 'Auto Select Resample, Auto Start',
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
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_archiver_set,
      hideLine: hideLine,
      actionMap: actionMap,
      simpleActionMap: sActionMap,
      initVal: _controller.ehSetting.archiverSettings ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(archiverSettings: val),
    );
  });
}

Widget _buildFrontPageSettingsItem(BuildContext context,
    {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '3': 'Minimal',
    '4': 'Minimal+',
    '0': 'Compact',
    '2': 'Extended',
    '1': 'Thumbnail',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_front_page_dis_mode,
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.frontPageSettings ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(frontPageSettings: val),
    );
  });
}

Widget _buildFavoritesSortItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'By last gallery update time',
    '1': 'By favorited time',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_fav_sort,
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.frontPageSettings ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(frontPageSettings: val),
    );
  });
}

Widget _buildSearchResultCountItem(BuildContext context,
    {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': '25',
    '1': '50',
    '2': '100',
    '3': '200',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_search_r_count,
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.sortOrderFavorites ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(sortOrderFavorites: val),
    );
  });
}

Widget _buildThumbMouseOverItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0':
        'On mouse-over (pages load faster, but there may be a slight delay before a thumb appears)',
    '1':
        'On page load (pages take longer to load, but there is no delay for loading a thumb after the page has loaded)',
  };

  final Map<String, String> sActionMap = <String, String>{
    '0': 'On mouse-over',
    '1': 'On page load',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_mose_over_thumb,
      hideLine: hideLine,
      actionMap: actionMap,
      simpleActionMap: sActionMap,
      initVal: _controller.ehSetting.mouseOverThumbnails ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(mouseOverThumbnails: val),
    );
  });
}

Widget _buildThumbSizeItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Narmal',
    '1': 'Large',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_thumb_size,
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.thumbnailSize ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(thumbnailSize: val),
    );
  });
}

Widget _buildThumbRowItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': '4',
    '1': '10',
    '2': '20',
    '3': '40',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_thumb_row,
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.thumbnailRows ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(thumbnailRows: val),
    );
  });
}

Widget _buildSortOrderComment(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Oldest comments first',
    '1': 'Recent comments first',
    '2': 'By highest score',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_comments_sort_order,
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.sortOrderComments ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(sortOrderComments: val),
    );
  });
}

Widget _buildShowCommentVotes(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'On score hover or click',
    '1': 'Always',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_comments_show_votes,
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.showCommentVotes ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(showCommentVotes: val),
    );
  });
}

Widget _buildSortOrderTags(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Alphabetical',
    '1': 'By tag power',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_tag_short_order,
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.sortOrderTags ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(sortOrderTags: val),
    );
  });
}

Widget _buildShowPageNumbers(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'No',
    '1': 'Yes',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_show_page_num,
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.showGalleryPageNumbers ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(showGalleryPageNumbers: val),
    );
  });
}

Widget _buildOriginalImages(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Nope',
    '1': 'Yup, I can take it',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_ori_image,
      actionTitle:
          'Use original images instead of the resampled versions where applicable?',
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.originalImages ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(originalImages: val),
    );
  });
}

Widget _buildMPVAlwaysUse(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Nope',
    '1': 'Yup',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_mpv_always,
      actionTitle:
          'Always use the Multi-Page Viewer? There will still be a link to manually start it if this is left disabled',
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.alwaysUseMpv ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(alwaysUseMpv: val),
    );
  });
}

Widget _buildMPVDisplayStyle(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Align left; Only scale if image is larger than browser width',
    '1': 'Align center; Only scale if image is larger than browser width',
    '2': 'Align center; Always scale images to fit browser width',
  };

  final Map<String, String> sActionMap = <String, String>{
    '0': 'Align left',
    '1': 'Align center 1',
    '2': 'Align center 2',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_mpv_stype,
      actionTitle: 'Multi-Page Viewer Display Style',
      hideLine: hideLine,
      actionMap: actionMap,
      simpleActionMap: sActionMap,
      initVal: _controller.ehSetting.mpvStyle ?? '',
      onValueChanged: (val) =>
          _controller.ehSetting = _controller.ehSetting.copyWith(mpvStyle: val),
    );
  });
}

Widget _buildMPVThumbPane(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Show',
    '1': 'Hide',
  };

  return Obx(() {
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_mpv_thumb_pane,
      actionTitle: 'Multi-Page Viewer Thumbnail Pane',
      hideLine: hideLine,
      actionMap: actionMap,
      initVal: _controller.ehSetting.mpvThumbnailPane ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(mpvThumbnailPane: val),
    );
  });
}

Widget _buildRatingsItem(BuildContext context, {bool hideLine = false}) {
  return Obx(() {
    return SingleInputItem(
      key: UniqueKey(),
      title: L10n.of(context).uc_rating,
      placeholder: 'RRGGB',
      previousPageTitle: L10n.of(context).ehentai_settings,
      hideLine: hideLine,
      initVal: _controller.ehSetting.ratings ?? '',
      onValueChanged: (val) =>
          _controller.ehSetting = _controller.ehSetting.copyWith(ratings: val),
    );
  });
}

Widget _buildTagFilteringThreshold(BuildContext context) {
  return Obx(() {
    return SingleInputItem(
      key: UniqueKey(),
      title: L10n.of(context).uc_tag_ft,
      previousPageTitle: L10n.of(context).ehentai_settings,
      hideLine: true,
      initVal: _controller.ehSetting.tagFilteringThreshold ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(tagFilteringThreshold: val),
    );
  });
}

Widget _buildTagWatchingThreshold(BuildContext context) {
  return Obx(() {
    return SingleInputItem(
      key: UniqueKey(),
      title: L10n.of(context).uc_tag_wt,
      previousPageTitle: L10n.of(context).ehentai_settings,
      hideLine: true,
      initVal: _controller.ehSetting.tagWatchingThreshold ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(tagWatchingThreshold: val),
    );
  });
}

Widget _buildExcludedUploaders(BuildContext context) {
  return Obx(() {
    return SingleInputItem(
      key: UniqueKey(),
      title: L10n.of(context).uc_exc_up,
      previousPageTitle: L10n.of(context).ehentai_settings,
      hideLine: true,
      initVal: _controller.ehSetting.excludedUploaders ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(excludedUploaders: val),
    );
  });
}

Widget _buildThumbnailScaling(BuildContext context) {
  // Thumbnail Scaling
  return Obx(() {
    return SingleInputItem(
      key: UniqueKey(),
      title: L10n.of(context).uc_thumb_scaling,
      previousPageTitle: L10n.of(context).ehentai_settings,
      suffixText: '%',
      hideLine: true,
      initVal: _controller.ehSetting.thumbnailScaling ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(thumbnailScaling: val),
    );
  });
}

Widget _buildViewportOverride(BuildContext context) {
  // Thumbnail Scaling
  return Obx(() {
    return SingleInputItem(
      key: UniqueKey(),
      title: L10n.of(context).uc_viewport_or,
      previousPageTitle: L10n.of(context).ehentai_settings,
      suffixText: 'px',
      hideLine: true,
      initVal: _controller.ehSetting.viewportOverride ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(viewportOverride: val),
    );
  });
}

Widget _buildHatHLocalNetworkHost(BuildContext context) {
  // Hentai@Home Local Network Host
  return Obx(() {
    return SingleInputItem(
      key: UniqueKey(),
      title: 'IP Address:Port',
      pageTitle: 'Host',
      previousPageTitle: L10n.of(context).ehentai_settings,
      hideLine: true,
      initVal: _controller.ehSetting.hentaiAtHomeLocalNetworkHost ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(hentaiAtHomeLocalNetworkHost: val),
    );
  });
}

Widget _buildSizeHorizontal(BuildContext context) {
  return Obx(() {
    return SingleInputItem(
      key: UniqueKey(),
      title: L10n.of(context).uc_img_horiz,
      previousPageTitle: L10n.of(context).ehentai_settings,
      suffixText: 'pixels',
      hideLine: false,
      initVal: _controller.ehSetting.imageSizeHorizontal ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(imageSizeHorizontal: val),
    );
  });
}

Widget _buildSizeVertical(BuildContext context) {
  return Obx(() {
    return SingleInputItem(
      key: UniqueKey(),
      title: L10n.of(context).uc_img_vert,
      previousPageTitle: L10n.of(context).ehentai_settings,
      suffixText: 'pixels',
      hideLine: true,
      initVal: _controller.ehSetting.imageSizeVertical ?? '',
      onValueChanged: (val) => _controller.ehSetting =
          _controller.ehSetting.copyWith(imageSizeVertical: val),
    );
  });
}

Widget _buildTagNamespaces(BuildContext context) {
  // _controller.ehSetting.frontPageSettings ?? ''
  // return SizedBox.shrink();
  return Obx(() {
    return MultiSelectorGroup(
      key: UniqueKey(),
      selectorMap: {
        'reclass': SingleSelectItemBean(
            title: 'reclass', enable: _controller.ehSetting.xnReclass == '1'),
        'language': SingleSelectItemBean(
            title: 'language', enable: _controller.ehSetting.xnLanguage == '1'),
        'parody': SingleSelectItemBean(
            title: 'parody', enable: _controller.ehSetting.xnParody == '1'),
        'character': SingleSelectItemBean(
            title: 'character',
            enable: _controller.ehSetting.xnCharacter == '1'),
        'group': SingleSelectItemBean(
            title: 'group', enable: _controller.ehSetting.xnGroup == '1'),
        'artist': SingleSelectItemBean(
            title: 'artist', enable: _controller.ehSetting.xnArtist == '1'),
        'male': SingleSelectItemBean(
            title: 'male', enable: _controller.ehSetting.xnMale == '1'),
        'female': SingleSelectItemBean(
            title: 'female', enable: _controller.ehSetting.xnFemale == '1'),
      },
      onValueChanged: (val) {
        _controller.ehSetting
          ..xnReclass = (val['reclass']?.enable ?? false) ? '1' : '0'
          ..xnLanguage = (val['language']?.enable ?? false) ? '1' : '0'
          ..xnParody = (val['parody']?.enable ?? false) ? '1' : '0'
          ..xnCharacter = (val['character']?.enable ?? false) ? '1' : '0'
          ..xnGroup = (val['group']?.enable ?? false) ? '1' : '0'
          ..xnArtist = (val['artist']?.enable ?? false) ? '1' : '0'
          ..xnMale = (val['male']?.enable ?? false) ? '1' : '0'
          ..xnFemale = (val['female']?.enable ?? false) ? '1' : '0';
      },
    );
  });
}
