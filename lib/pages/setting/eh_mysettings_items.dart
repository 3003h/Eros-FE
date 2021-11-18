part of 'eh_mysettings_page.dart';

final _controller = Get.find<EhMySettingsController>();
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
  return SelectorItem<String>(
    title: 'Load images through the H@H',
    actionTitle:
        'Do you wish to load images through the Hentai@Home Network, if available?',
    hideLine: hideLine,
    actionMap: actionMap,
    simpleActionMap: simpleActionMap,
    initVal: _controller.ehSetting.loadImageThroughHAtH ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(loadImageThroughHAtH: val),
  );
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
  return SelectorItem<String>(
    title: 'Resample Resolution',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.imageSize ?? '',
    onValueChanged: (val) =>
        _controller.ehSetting = _controller.ehSetting.copyWith(imageSize: val),
  );
}

Widget _buildNameDisplayItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Default Title',
    '1': 'Japanese Title',
  };
  return SelectorItem<String>(
    title: 'Name Display',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.galleryNameDisplay ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(galleryNameDisplay: val),
  );
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
  return SelectorItem<String>(
    title: 'Behavior',
    hideLine: hideLine,
    actionMap: actionMap,
    simpleActionMap: sActionMap,
    initVal: _controller.ehSetting.archiverSettings ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(archiverSettings: val),
  );
}

Widget _buildFrontPageSettingsItem(BuildContext context,
    {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Minimal',
    '1': 'Minimal+',
    '2': 'Compact',
    '3': 'Extended',
    '4': 'Thumbnail',
  };

  return SelectorItem<String>(
    title: 'Display mode',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.frontPageSettings ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(frontPageSettings: val),
  );
}

Widget _buildFavoritesSortItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'By last gallery update time',
    '1': 'By favorited time',
  };

  return SelectorItem<String>(
    title: 'Default sort',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.frontPageSettings ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(frontPageSettings: val),
  );
}

Widget _buildSearchResultCountItem(BuildContext context,
    {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': '25',
    '1': '50',
    '2': '100',
    '3': '200',
  };

  return SelectorItem<String>(
    title: 'Search Result Count',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.sortOrderFavorites ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(sortOrderFavorites: val),
  );
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

  return SelectorItem<String>(
    title: 'mouse-over thumbnails',
    hideLine: hideLine,
    actionMap: actionMap,
    simpleActionMap: sActionMap,
    initVal: _controller.ehSetting.mouseOverThumbnails ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(mouseOverThumbnails: val),
  );
}

Widget _buildThumbSizeItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Narmal',
    '1': 'Large',
  };

  return SelectorItem<String>(
    title: 'Size',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.thumbnailSize ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(thumbnailSize: val),
  );
}

Widget _buildThumbRowItem(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': '4',
    '1': '10',
    '2': '20',
    '3': '40',
  };

  return SelectorItem<String>(
    title: 'Row',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.thumbnailRows ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(thumbnailRows: val),
  );
}

Widget _buildSortOrderComment(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Oldest comments first',
    '1': 'Recent comments first',
    '2': 'By highest score',
  };

  return SelectorItem<String>(
    title: 'Sort order',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.sortOrderComments ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(sortOrderComments: val),
  );
}

Widget _buildShowCommentVotes(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'On score hover or click',
    '1': 'Always',
  };

  return SelectorItem<String>(
    title: 'Show votes',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.showCommentVotes ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(showCommentVotes: val),
  );
}

Widget _buildSortOrderTags(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Alphabetical',
    '1': 'By tag power',
  };

  return SelectorItem<String>(
    title: 'Sort order',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.sortOrderTags ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(sortOrderTags: val),
  );
}

Widget _buildShowPageNumbers(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'No',
    '1': 'Yes',
  };

  return SelectorItem<String>(
    title: 'Show Page Numbers',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.showGalleryPageNumbers ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(showGalleryPageNumbers: val),
  );
}

Widget _buildOriginalImages(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Nope',
    '1': 'Yup, I can take it',
  };

  return SelectorItem<String>(
    title: 'Original images',
    actionTitle:
        'Use original images instead of the resampled versions where applicable?',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.originalImages ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(originalImages: val),
  );
}

Widget _buildMPVAlwaysUse(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Nope',
    '1': 'Yup',
  };

  return SelectorItem<String>(
    title: 'Always use',
    actionTitle:
        'Always use the Multi-Page Viewer? There will still be a link to manually start it if this is left disabled',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.alwaysUseMpv ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(alwaysUseMpv: val),
  );
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

  return SelectorItem<String>(
    title: 'Display Style',
    actionTitle: 'Multi-Page Viewer Display Style',
    hideLine: hideLine,
    actionMap: actionMap,
    simpleActionMap: sActionMap,
    initVal: _controller.ehSetting.mpvStyle ?? '',
    onValueChanged: (val) =>
        _controller.ehSetting = _controller.ehSetting.copyWith(mpvStyle: val),
  );
}

Widget _buildMPVThumbPane(BuildContext context, {bool hideLine = false}) {
  final Map<String, String> actionMap = <String, String>{
    '0': 'Show',
    '1': 'Hide',
  };

  return SelectorItem<String>(
    title: 'Thumbnail Pane',
    actionTitle: 'Multi-Page Viewer Thumbnail Pane',
    hideLine: hideLine,
    actionMap: actionMap,
    initVal: _controller.ehSetting.mpvThumbnailPane ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(mpvThumbnailPane: val),
  );
}

Widget _buildRatingsItem(BuildContext context, {bool hideLine = false}) {
  return SingleInputItem(
    title: 'Ratings Colors',
    previousPageTitle: L10n.of(context).ehentai_settings,
    hideLine: hideLine,
    initVal: _controller.ehSetting.ratings ?? '',
    onValueChanged: (val) =>
        _controller.ehSetting = _controller.ehSetting.copyWith(ratings: val),
  );
}

Widget _buildTagFilteringThreshold(BuildContext context) {
  return SingleInputItem(
    title: 'Tag Filtering Threshold',
    previousPageTitle: L10n.of(context).ehentai_settings,
    hideLine: true,
    initVal: _controller.ehSetting.tagFilteringThreshold ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(tagFilteringThreshold: val),
  );
}

Widget _buildTagWatchingThreshold(BuildContext context) {
  return SingleInputItem(
    title: 'Tag Watching Threshold',
    previousPageTitle: L10n.of(context).ehentai_settings,
    hideLine: true,
    initVal: _controller.ehSetting.tagWatchingThreshold ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(tagWatchingThreshold: val),
  );
}

Widget _buildExcludedUploaders(BuildContext context) {
  return SingleInputItem(
    title: 'Excluded Uploaders',
    previousPageTitle: L10n.of(context).ehentai_settings,
    hideLine: true,
    initVal: _controller.ehSetting.excludedUploaders ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(excludedUploaders: val),
  );
}

Widget _buildThumbnailScaling(BuildContext context) {
  // Thumbnail Scaling
  return SingleInputItem(
    title: 'Thumbnail Scaling',
    previousPageTitle: L10n.of(context).ehentai_settings,
    suffixText: '%',
    hideLine: true,
    initVal: _controller.ehSetting.thumbnailScaling ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(thumbnailScaling: val),
  );
}

Widget _buildViewportOverride(BuildContext context) {
  // Thumbnail Scaling
  return SingleInputItem(
    title: 'Viewport Override',
    previousPageTitle: L10n.of(context).ehentai_settings,
    suffixText: 'px',
    hideLine: true,
    initVal: _controller.ehSetting.viewportOverride ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(viewportOverride: val),
  );
}

Widget _buildHatHLocalNetworkHost(BuildContext context) {
  // Hentai@Home Local Network Host
  return SingleInputItem(
    title: 'IP Address:Port',
    pageTitle: 'Host',
    previousPageTitle: L10n.of(context).ehentai_settings,
    hideLine: true,
    initVal: _controller.ehSetting.hentaiAtHomeLocalNetworkHost ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(hentaiAtHomeLocalNetworkHost: val),
  );
}

Widget _buildSizeHorizontal(BuildContext context) {
  return SingleInputItem(
    title: 'Horizontal',
    previousPageTitle: L10n.of(context).ehentai_settings,
    suffixText: 'pixels',
    hideLine: false,
    initVal: _controller.ehSetting.imageSizeHorizontal ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(imageSizeHorizontal: val),
  );
}

Widget _buildSizeVertical(BuildContext context) {
  return SingleInputItem(
    title: 'Vertical',
    previousPageTitle: L10n.of(context).ehentai_settings,
    suffixText: 'pixels',
    hideLine: true,
    initVal: _controller.ehSetting.imageSizeVertical ?? '',
    onValueChanged: (val) => _controller.ehSetting =
        _controller.ehSetting.copyWith(imageSizeVertical: val),
  );
}

Widget _buildTagNamespaces(BuildContext context) {
  // _controller.ehSetting.frontPageSettings ?? ''
  return MultiSelectorGroup(
    selectorMap: {
      'reclass': SingleSelectItemBean(
          title: 'reclass', enable: _controller.ehSetting.xn1 == '1'),
      'language': SingleSelectItemBean(
          title: 'language', enable: _controller.ehSetting.xn2 == '1'),
      'parody': SingleSelectItemBean(
          title: 'parody', enable: _controller.ehSetting.xn3 == '1'),
      'character': SingleSelectItemBean(
          title: 'character', enable: _controller.ehSetting.xn4 == '1'),
      'group': SingleSelectItemBean(
          title: 'group', enable: _controller.ehSetting.xn5 == '1'),
      'artist': SingleSelectItemBean(
          title: 'artist', enable: _controller.ehSetting.xn6 == '1'),
      'male': SingleSelectItemBean(
          title: 'male', enable: _controller.ehSetting.xn7 == '1'),
      'female': SingleSelectItemBean(
          title: 'female', enable: _controller.ehSetting.xn8 == '1'),
    },
    onValueChanged: (val) {
      // logger.d(val.toString());
      _controller.ehSetting = _controller.ehSetting.copyWith(
        xn1: (val['reclass']?.enable ?? false) ? '1' : '0',
        xn2: (val['language']?.enable ?? false) ? '1' : '0',
        xn3: (val['parody']?.enable ?? false) ? '1' : '0',
        xn4: (val['character']?.enable ?? false) ? '1' : '0',
        xn5: (val['group']?.enable ?? false) ? '1' : '0',
        xn6: (val['artist']?.enable ?? false) ? '1' : '0',
        xn7: (val['male']?.enable ?? false) ? '1' : '0',
        xn8: (val['female']?.enable ?? false) ? '1' : '0',
      );
    },
  );
}
