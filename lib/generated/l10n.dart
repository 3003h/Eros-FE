// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class L10n {
  L10n();

  static L10n? _current;

  static L10n get current {
    assert(_current != null,
        'No instance of L10n was loaded. Try to initialize the L10n delegate before accessing L10n.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<L10n> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = L10n();
      L10n._current = instance;

      return instance;
    });
  }

  static L10n of(BuildContext context) {
    final instance = L10n.maybeOf(context);
    assert(instance != null,
        'No instance of L10n present in the widget tree. Did you add L10n.delegate in localizationsDelegates?');
    return instance!;
  }

  static L10n? maybeOf(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  /// `FEhViewer`
  String get app_title {
    return Intl.message(
      'FEhViewer',
      name: 'app_title',
      desc: '',
      args: [],
    );
  }

  /// `~oh~ oh~ oh~~~`
  String get welcome_text {
    return Intl.message(
      '~oh~ oh~ oh~~~',
      name: 'welcome_text',
      desc: '',
      args: [],
    );
  }

  /// `Popular`
  String get tab_popular {
    return Intl.message(
      'Popular',
      name: 'tab_popular',
      desc: '',
      args: [],
    );
  }

  /// `Watched`
  String get tab_watched {
    return Intl.message(
      'Watched',
      name: 'tab_watched',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get tab_gallery {
    return Intl.message(
      'Gallery',
      name: 'tab_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get tab_favorite {
    return Intl.message(
      'Favorites',
      name: 'tab_favorite',
      desc: '',
      args: [],
    );
  }

  /// `Toplists`
  String get tab_toplist {
    return Intl.message(
      'Toplists',
      name: 'tab_toplist',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get tab_history {
    return Intl.message(
      'History',
      name: 'tab_history',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get tab_setting {
    return Intl.message(
      'Settings',
      name: 'tab_setting',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get tab_download {
    return Intl.message(
      'Download',
      name: 'tab_download',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get favcat {
    return Intl.message(
      'Favorites',
      name: 'favcat',
      desc: '',
      args: [],
    );
  }

  /// `Not Favorited`
  String get notFav {
    return Intl.message(
      'Not Favorited',
      name: 'notFav',
      desc: '',
      args: [],
    );
  }

  /// `All Favorites`
  String get all_Favorites {
    return Intl.message(
      'All Favorites',
      name: 'all_Favorites',
      desc: '',
      args: [],
    );
  }

  /// `Local Favorites`
  String get local_favorite {
    return Intl.message(
      'Local Favorites',
      name: 'local_favorite',
      desc: '',
      args: [],
    );
  }

  /// `Processing`
  String get processing {
    return Intl.message(
      'Processing',
      name: 'processing',
      desc: '',
      args: [],
    );
  }

  /// `User Sign`
  String get user_login {
    return Intl.message(
      'User Sign',
      name: 'user_login',
      desc: '',
      args: [],
    );
  }

  /// `Please enter user name`
  String get pls_i_username {
    return Intl.message(
      'Please enter user name',
      name: 'pls_i_username',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get pls_i_passwd {
    return Intl.message(
      'Please enter your password',
      name: 'pls_i_passwd',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get user_name {
    return Intl.message(
      'Username',
      name: 'user_name',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get passwd {
    return Intl.message(
      'Password',
      name: 'passwd',
      desc: '',
      args: [],
    );
  }

  /// `Sign`
  String get login {
    return Intl.message(
      'Sign',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Not Login`
  String get not_login {
    return Intl.message(
      'Not Login',
      name: 'not_login',
      desc: '',
      args: [],
    );
  }

  /// `Sign in on the Web`
  String get login_web {
    return Intl.message(
      'Sign in on the Web',
      name: 'login_web',
      desc: '',
      args: [],
    );
  }

  /// `Press again to exit`
  String get double_click_back {
    return Intl.message(
      'Press again to exit',
      name: 'double_click_back',
      desc: '',
      args: [],
    );
  }

  /// `Read`
  String get read {
    return Intl.message(
      'Read',
      name: 'read',
      desc: '',
      args: [],
    );
  }

  /// `Gallery Comments`
  String get gallery_comments {
    return Intl.message(
      'Gallery Comments',
      name: 'gallery_comments',
      desc: '',
      args: [],
    );
  }

  /// `All Comment`
  String get all_comment {
    return Intl.message(
      'All Comment',
      name: 'all_comment',
      desc: '',
      args: [],
    );
  }

  /// `All Preview`
  String get all_preview {
    return Intl.message(
      'All Preview',
      name: 'all_preview',
      desc: '',
      args: [],
    );
  }

  /// `More previews`
  String get morePreviews {
    return Intl.message(
      'More previews',
      name: 'morePreviews',
      desc: '',
      args: [],
    );
  }

  /// `No more previews`
  String get noMorePreviews {
    return Intl.message(
      'No more previews',
      name: 'noMorePreviews',
      desc: '',
      args: [],
    );
  }

  /// `Previews`
  String get previews {
    return Intl.message(
      'Previews',
      name: 'previews',
      desc: '',
      args: [],
    );
  }

  /// `E·H`
  String get eh {
    return Intl.message(
      'E·H',
      name: 'eh',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `Advanced`
  String get advanced {
    return Intl.message(
      'Advanced',
      name: 'advanced',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Preload Image`
  String get preload_image {
    return Intl.message(
      'Preload Image',
      name: 'preload_image',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Follow System`
  String get follow_system {
    return Intl.message(
      'Follow System',
      name: 'follow_system',
      desc: '',
      args: [],
    );
  }

  /// `Ligth`
  String get light {
    return Intl.message(
      'Ligth',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Custom Hosts`
  String get custom_hosts {
    return Intl.message(
      'Custom Hosts',
      name: 'custom_hosts',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `On`
  String get on {
    return Intl.message(
      'On',
      name: 'on',
      desc: '',
      args: [],
    );
  }

  /// `Off`
  String get off {
    return Intl.message(
      'Off',
      name: 'off',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode effect`
  String get dark_mode_effect {
    return Intl.message(
      'Dark mode effect',
      name: 'dark_mode_effect',
      desc: '',
      args: [],
    );
  }

  /// `Gray black`
  String get gray_black {
    return Intl.message(
      'Gray black',
      name: 'gray_black',
      desc: '',
      args: [],
    );
  }

  /// `Pure black`
  String get pure_black {
    return Intl.message(
      'Pure black',
      name: 'pure_black',
      desc: '',
      args: [],
    );
  }

  /// `Domain fronting`
  String get domain_fronting {
    return Intl.message(
      'Domain fronting',
      name: 'domain_fronting',
      desc: '',
      args: [],
    );
  }

  /// `Clear cache`
  String get clear_cache {
    return Intl.message(
      'Clear cache',
      name: 'clear_cache',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Advanced Options`
  String get s_Advanced_Options {
    return Intl.message(
      'Advanced Options',
      name: 's_Advanced_Options',
      desc: '',
      args: [],
    );
  }

  /// `Search Gallery Name`
  String get s_Search_Gallery_Name {
    return Intl.message(
      'Search Gallery Name',
      name: 's_Search_Gallery_Name',
      desc: '',
      args: [],
    );
  }

  /// `Search Gallery Tags`
  String get s_Search_Gallery_Tags {
    return Intl.message(
      'Search Gallery Tags',
      name: 's_Search_Gallery_Tags',
      desc: '',
      args: [],
    );
  }

  /// `Search Gallery Description`
  String get s_Search_Gallery_Description {
    return Intl.message(
      'Search Gallery Description',
      name: 's_Search_Gallery_Description',
      desc: '',
      args: [],
    );
  }

  /// `Search Torrent Filenames`
  String get s_Search_Torrent_Filenames {
    return Intl.message(
      'Search Torrent Filenames',
      name: 's_Search_Torrent_Filenames',
      desc: '',
      args: [],
    );
  }

  /// `Only Show Galleries With Torrents`
  String get s_Only_Show_Galleries_With_Torrents {
    return Intl.message(
      'Only Show Galleries With Torrents',
      name: 's_Only_Show_Galleries_With_Torrents',
      desc: '',
      args: [],
    );
  }

  /// `Search Low-Power Tags`
  String get s_Search_Low_Power_Tags {
    return Intl.message(
      'Search Low-Power Tags',
      name: 's_Search_Low_Power_Tags',
      desc: '',
      args: [],
    );
  }

  /// `Search Downvoted Tags`
  String get s_Search_Downvoted_Tags {
    return Intl.message(
      'Search Downvoted Tags',
      name: 's_Search_Downvoted_Tags',
      desc: '',
      args: [],
    );
  }

  /// `Show Expunged Galleries`
  String get s_Show_Expunged_Galleries {
    return Intl.message(
      'Show Expunged Galleries',
      name: 's_Show_Expunged_Galleries',
      desc: '',
      args: [],
    );
  }

  /// `Minimum Rating`
  String get s_Minimum_Rating {
    return Intl.message(
      'Minimum Rating',
      name: 's_Minimum_Rating',
      desc: '',
      args: [],
    );
  }

  /// `{rating} ⭐`
  String s_stars(Object rating) {
    return Intl.message(
      '$rating ⭐',
      name: 's_stars',
      desc: '',
      args: [rating],
    );
  }

  /// `Between`
  String get s_Between {
    return Intl.message(
      'Between',
      name: 's_Between',
      desc: '',
      args: [],
    );
  }

  /// `and`
  String get s_and {
    return Intl.message(
      'and',
      name: 's_and',
      desc: '',
      args: [],
    );
  }

  /// `pages`
  String get s_pages {
    return Intl.message(
      'pages',
      name: 's_pages',
      desc: '',
      args: [],
    );
  }

  /// `Disable default filters`
  String get s_Disable_default_filters {
    return Intl.message(
      'Disable default filters',
      name: 's_Disable_default_filters',
      desc: '',
      args: [],
    );
  }

  /// `Search Name`
  String get s_Search_Fav_Name {
    return Intl.message(
      'Search Name',
      name: 's_Search_Fav_Name',
      desc: '',
      args: [],
    );
  }

  /// `Search Tags`
  String get s_Search_Fav_Tags {
    return Intl.message(
      'Search Tags',
      name: 's_Search_Fav_Tags',
      desc: '',
      args: [],
    );
  }

  /// `Search Note`
  String get s_Search_Fav_Note {
    return Intl.message(
      'Search Note',
      name: 's_Search_Fav_Note',
      desc: '',
      args: [],
    );
  }

  /// `Uploader`
  String get uploader {
    return Intl.message(
      'Uploader',
      name: 'uploader',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get tags {
    return Intl.message(
      'Tags',
      name: 'tags',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear_filter {
    return Intl.message(
      'Clear',
      name: 'clear_filter',
      desc: '',
      args: [],
    );
  }

  /// `Clear All History`
  String get t_Clear_all_history {
    return Intl.message(
      'Clear All History',
      name: 't_Clear_all_history',
      desc: '',
      args: [],
    );
  }

  /// `Gallery Site`
  String get galery_site {
    return Intl.message(
      'Gallery Site',
      name: 'galery_site',
      desc: '',
      args: [],
    );
  }

  /// `Current {site}`
  String current_site(Object site) {
    return Intl.message(
      'Current $site',
      name: 'current_site',
      desc: '',
      args: [site],
    );
  }

  /// `EHentai Settings`
  String get ehentai_settings {
    return Intl.message(
      'EHentai Settings',
      name: 'ehentai_settings',
      desc: '',
      args: [],
    );
  }

  /// `Setting on Website`
  String get setting_on_website {
    return Intl.message(
      'Setting on Website',
      name: 'setting_on_website',
      desc: '',
      args: [],
    );
  }

  /// `My Tags`
  String get ehentai_my_tags {
    return Intl.message(
      'My Tags',
      name: 'ehentai_my_tags',
      desc: '',
      args: [],
    );
  }

  /// `My Tags on Website`
  String get mytags_on_website {
    return Intl.message(
      'My Tags on Website',
      name: 'mytags_on_website',
      desc: '',
      args: [],
    );
  }

  /// `List Mode`
  String get list_mode {
    return Intl.message(
      'List Mode',
      name: 'list_mode',
      desc: '',
      args: [],
    );
  }

  /// `List - Medium`
  String get listmode_medium {
    return Intl.message(
      'List - Medium',
      name: 'listmode_medium',
      desc: '',
      args: [],
    );
  }

  /// `List - Small`
  String get listmode_small {
    return Intl.message(
      'List - Small',
      name: 'listmode_small',
      desc: '',
      args: [],
    );
  }

  /// `Waterfall`
  String get listmode_waterfall {
    return Intl.message(
      'Waterfall',
      name: 'listmode_waterfall',
      desc: '',
      args: [],
    );
  }

  /// `WaterfallFlow - Large`
  String get listmode_waterfall_large {
    return Intl.message(
      'WaterfallFlow - Large',
      name: 'listmode_waterfall_large',
      desc: '',
      args: [],
    );
  }

  /// `Grid`
  String get listmode_grid {
    return Intl.message(
      'Grid',
      name: 'listmode_grid',
      desc: '',
      args: [],
    );
  }

  /// `Favorites Order`
  String get favorites_order {
    return Intl.message(
      'Favorites Order',
      name: 'favorites_order',
      desc: '',
      args: [],
    );
  }

  /// `Use Posted`
  String get favorites_order_Use_posted {
    return Intl.message(
      'Use Posted',
      name: 'favorites_order_Use_posted',
      desc: '',
      args: [],
    );
  }

  /// `Use Favorited`
  String get favorites_order_Use_favorited {
    return Intl.message(
      'Use Favorited',
      name: 'favorites_order_Use_favorited',
      desc: '',
      args: [],
    );
  }

  /// `Show Japanese Title`
  String get show_jpn_title {
    return Intl.message(
      'Show Japanese Title',
      name: 'show_jpn_title',
      desc: '',
      args: [],
    );
  }

  /// `Current Version`
  String get current_version {
    return Intl.message(
      'Current Version',
      name: 'current_version',
      desc: '',
      args: [],
    );
  }

  /// `Maximum History`
  String get max_history {
    return Intl.message(
      'Maximum History',
      name: 'max_history',
      desc: '',
      args: [],
    );
  }

  /// `Unlimited`
  String get unlimited {
    return Intl.message(
      'Unlimited',
      name: 'unlimited',
      desc: '',
      args: [],
    );
  }

  /// `Archiver`
  String get p_Archiver {
    return Intl.message(
      'Archiver',
      name: 'p_Archiver',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get p_Download {
    return Intl.message(
      'Download',
      name: 'p_Download',
      desc: '',
      args: [],
    );
  }

  /// `Similar`
  String get p_Similar {
    return Intl.message(
      'Similar',
      name: 'p_Similar',
      desc: '',
      args: [],
    );
  }

  /// `Torrent`
  String get p_Torrent {
    return Intl.message(
      'Torrent',
      name: 'p_Torrent',
      desc: '',
      args: [],
    );
  }

  /// `Rate`
  String get p_Rate {
    return Intl.message(
      'Rate',
      name: 'p_Rate',
      desc: '',
      args: [],
    );
  }

  /// `Read setting`
  String get read_setting {
    return Intl.message(
      'Read setting',
      name: 'read_setting',
      desc: '',
      args: [],
    );
  }

  /// `Reading direction`
  String get reading_direction {
    return Intl.message(
      'Reading direction',
      name: 'reading_direction',
      desc: '',
      args: [],
    );
  }

  /// `Screen orientation`
  String get screen_orientation {
    return Intl.message(
      'Screen orientation',
      name: 'screen_orientation',
      desc: '',
      args: [],
    );
  }

  /// `Follow system`
  String get orientation_system {
    return Intl.message(
      'Follow system',
      name: 'orientation_system',
      desc: '',
      args: [],
    );
  }

  /// `Portrait up`
  String get orientation_portraitUp {
    return Intl.message(
      'Portrait up',
      name: 'orientation_portraitUp',
      desc: '',
      args: [],
    );
  }

  /// `Landscape left`
  String get orientation_landscapeLeft {
    return Intl.message(
      'Landscape left',
      name: 'orientation_landscapeLeft',
      desc: '',
      args: [],
    );
  }

  /// `Landscape right`
  String get orientation_landscapeRight {
    return Intl.message(
      'Landscape right',
      name: 'orientation_landscapeRight',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get orientation_auto {
    return Intl.message(
      'Auto',
      name: 'orientation_auto',
      desc: '',
      args: [],
    );
  }

  /// `Show page interval`
  String get show_page_interval {
    return Intl.message(
      'Show page interval',
      name: 'show_page_interval',
      desc: '',
      args: [],
    );
  }

  /// `Left to right`
  String get left_to_right {
    return Intl.message(
      'Left to right',
      name: 'left_to_right',
      desc: '',
      args: [],
    );
  }

  /// `Right to left`
  String get right_to_left {
    return Intl.message(
      'Right to left',
      name: 'right_to_left',
      desc: '',
      args: [],
    );
  }

  /// `Top to bottom`
  String get top_to_bottom {
    return Intl.message(
      'Top to bottom',
      name: 'top_to_bottom',
      desc: '',
      args: [],
    );
  }

  /// `Tabbar setting`
  String get tabbar_setting {
    return Intl.message(
      'Tabbar setting',
      name: 'tabbar_setting',
      desc: '',
      args: [],
    );
  }

  /// `Long press and drag to sort`
  String get tab_sort {
    return Intl.message(
      'Long press and drag to sort',
      name: 'tab_sort',
      desc: '',
      args: [],
    );
  }

  /// `Add to favorites`
  String get add_to_favorites {
    return Intl.message(
      'Add to favorites',
      name: 'add_to_favorites',
      desc: '',
      args: [],
    );
  }

  /// `Remove from favorites`
  String get remove_from_favorites {
    return Intl.message(
      'Remove from favorites',
      name: 'remove_from_favorites',
      desc: '',
      args: [],
    );
  }

  /// `Change to favorites`
  String get change_to_favorites {
    return Intl.message(
      'Change to favorites',
      name: 'change_to_favorites',
      desc: '',
      args: [],
    );
  }

  /// `Quick search`
  String get quick_search {
    return Intl.message(
      'Quick search',
      name: 'quick_search',
      desc: '',
      args: [],
    );
  }

  /// `Add to search`
  String get add_quick_search {
    return Intl.message(
      'Add to search',
      name: 'add_quick_search',
      desc: '',
      args: [],
    );
  }

  /// `Show filter`
  String get show_filter {
    return Intl.message(
      'Show filter',
      name: 'show_filter',
      desc: '',
      args: [],
    );
  }

  /// `Search type`
  String get search_type {
    return Intl.message(
      'Search type',
      name: 'search_type',
      desc: '',
      args: [],
    );
  }

  /// `Reload image`
  String get reload_image {
    return Intl.message(
      'Reload image',
      name: 'reload_image',
      desc: '',
      args: [],
    );
  }

  /// `Share image`
  String get share_image {
    return Intl.message(
      'Share image',
      name: 'share_image',
      desc: '',
      args: [],
    );
  }

  /// `Saved successfully`
  String get saved_successfully {
    return Intl.message(
      'Saved successfully',
      name: 'saved_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Save into the album`
  String get save_into_album {
    return Intl.message(
      'Save into the album',
      name: 'save_into_album',
      desc: '',
      args: [],
    );
  }

  /// `System share`
  String get system_share {
    return Intl.message(
      'System share',
      name: 'system_share',
      desc: '',
      args: [],
    );
  }

  /// `Load failed, tap to retry`
  String get list_load_more_fail {
    return Intl.message(
      'Load failed, tap to retry',
      name: 'list_load_more_fail',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Copied to clipboard`
  String get copied_to_clipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'copied_to_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `KEEP IT SAFE`
  String get KEEP_IT_SAFE {
    return Intl.message(
      'KEEP IT SAFE',
      name: 'KEEP_IT_SAFE',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Security`
  String get security {
    return Intl.message(
      'Security',
      name: 'security',
      desc: '',
      args: [],
    );
  }

  /// `Blurring in recent tasks`
  String get security_blurredInRecentTasks {
    return Intl.message(
      'Blurring in recent tasks',
      name: 'security_blurredInRecentTasks',
      desc: '',
      args: [],
    );
  }

  /// `Auto-lock`
  String get autoLock {
    return Intl.message(
      'Auto-lock',
      name: 'autoLock',
      desc: '',
      args: [],
    );
  }

  /// `Disabled`
  String get disabled {
    return Intl.message(
      'Disabled',
      name: 'disabled',
      desc: '',
      args: [],
    );
  }

  /// `Instantly`
  String get instantly {
    return Intl.message(
      'Instantly',
      name: 'instantly',
      desc: '',
      args: [],
    );
  }

  /// `hours`
  String get hours {
    return Intl.message(
      'hours',
      name: 'hours',
      desc: '',
      args: [],
    );
  }

  /// `min`
  String get min {
    return Intl.message(
      'min',
      name: 'min',
      desc: '',
      args: [],
    );
  }

  /// `second`
  String get second {
    return Intl.message(
      'second',
      name: 'second',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get loading {
    return Intl.message(
      'Loading',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Search history`
  String get search_history {
    return Intl.message(
      'Search history',
      name: 'search_history',
      desc: '',
      args: [],
    );
  }

  /// `Clear search history`
  String get clear_search_history {
    return Intl.message(
      'Clear search history',
      name: 'clear_search_history',
      desc: '',
      args: [],
    );
  }

  /// `Vote Up`
  String get tag_vote_up {
    return Intl.message(
      'Vote Up',
      name: 'tag_vote_up',
      desc: '',
      args: [],
    );
  }

  /// `Vote Down`
  String get tag_vote_down {
    return Intl.message(
      'Vote Down',
      name: 'tag_vote_down',
      desc: '',
      args: [],
    );
  }

  /// `Withdraw Vote`
  String get tag_withdraw_vote {
    return Intl.message(
      'Withdraw Vote',
      name: 'tag_withdraw_vote',
      desc: '',
      args: [],
    );
  }

  /// `Add tags`
  String get add_tags {
    return Intl.message(
      'Add tags',
      name: 'add_tags',
      desc: '',
      args: [],
    );
  }

  /// `Enter new tags, separated with comma`
  String get add_tag_placeholder {
    return Intl.message(
      'Enter new tags, separated with comma',
      name: 'add_tag_placeholder',
      desc: '',
      args: [],
    );
  }

  /// `Vote successfully`
  String get vote_successfully {
    return Intl.message(
      'Vote successfully',
      name: 'vote_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Vote up successfully`
  String get vote_up_successfully {
    return Intl.message(
      'Vote up successfully',
      name: 'vote_up_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Vote down successfully`
  String get vote_down_successfully {
    return Intl.message(
      'Vote down successfully',
      name: 'vote_down_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Vibrate feedback`
  String get vibrate_feedback {
    return Intl.message(
      'Vibrate feedback',
      name: 'vibrate_feedback',
      desc: '',
      args: [],
    );
  }

  /// `Expand`
  String get expand {
    return Intl.message(
      'Expand',
      name: 'expand',
      desc: '',
      args: [],
    );
  }

  /// `Collapse`
  String get collapse {
    return Intl.message(
      'Collapse',
      name: 'collapse',
      desc: '',
      args: [],
    );
  }

  /// `Download Location`
  String get download_location {
    return Intl.message(
      'Download Location',
      name: 'download_location',
      desc: '',
      args: [],
    );
  }

  /// `Default Favorites`
  String get default_favorites {
    return Intl.message(
      'Default Favorites',
      name: 'default_favorites',
      desc: '',
      args: [],
    );
  }

  /// `Manually select favorites`
  String get manually_sel_favorites {
    return Intl.message(
      'Manually select favorites',
      name: 'manually_sel_favorites',
      desc: '',
      args: [],
    );
  }

  /// `Last Favorites, long press to manually select`
  String get last_favorites {
    return Intl.message(
      'Last Favorites, long press to manually select',
      name: 'last_favorites',
      desc: '',
      args: [],
    );
  }

  /// `Clipboard detection`
  String get clipboard_detection {
    return Intl.message(
      'Clipboard detection',
      name: 'clipboard_detection',
      desc: '',
      args: [],
    );
  }

  /// `Automatically detect clipboard gallery links`
  String get clipboard_detection_desc {
    return Intl.message(
      'Automatically detect clipboard gallery links',
      name: 'clipboard_detection_desc',
      desc: '',
      args: [],
    );
  }

  /// `Jump to Page`
  String get jump_to_page {
    return Intl.message(
      'Jump to Page',
      name: 'jump_to_page',
      desc: '',
      args: [],
    );
  }

  /// `Page range`
  String get page_range {
    return Intl.message(
      'Page range',
      name: 'page_range',
      desc: '',
      args: [],
    );
  }

  /// `Page range error`
  String get page_range_error {
    return Intl.message(
      'Page range error',
      name: 'page_range_error',
      desc: '',
      args: [],
    );
  }

  /// `Input error`
  String get input_error {
    return Intl.message(
      'Input error',
      name: 'input_error',
      desc: '',
      args: [],
    );
  }

  /// `Input empty`
  String get input_empty {
    return Intl.message(
      'Input empty',
      name: 'input_empty',
      desc: '',
      args: [],
    );
  }

  /// `Allow media scan`
  String get allow_media_scan {
    return Intl.message(
      'Allow media scan',
      name: 'allow_media_scan',
      desc: '',
      args: [],
    );
  }

  /// `multi Download`
  String get multi_download {
    return Intl.message(
      'multi Download',
      name: 'multi_download',
      desc: '',
      args: [],
    );
  }

  /// `Downloaded`
  String get downloaded {
    return Intl.message(
      'Downloaded',
      name: 'downloaded',
      desc: '',
      args: [],
    );
  }

  /// `Downloading`
  String get downloading {
    return Intl.message(
      'Downloading',
      name: 'downloading',
      desc: '',
      args: [],
    );
  }

  /// `Paused`
  String get paused {
    return Intl.message(
      'Paused',
      name: 'paused',
      desc: '',
      args: [],
    );
  }

  /// `All-Time`
  String get tolist_alltime {
    return Intl.message(
      'All-Time',
      name: 'tolist_alltime',
      desc: '',
      args: [],
    );
  }

  /// `Past Year`
  String get tolist_past_year {
    return Intl.message(
      'Past Year',
      name: 'tolist_past_year',
      desc: '',
      args: [],
    );
  }

  /// `Past Month`
  String get tolist_past_month {
    return Intl.message(
      'Past Month',
      name: 'tolist_past_month',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday`
  String get tolist_yesterday {
    return Intl.message(
      'Yesterday',
      name: 'tolist_yesterday',
      desc: '',
      args: [],
    );
  }

  /// `Tablet layout`
  String get tablet_layout {
    return Intl.message(
      'Tablet layout',
      name: 'tablet_layout',
      desc: '',
      args: [],
    );
  }

  /// `WebDAV Account`
  String get webdav_Account {
    return Intl.message(
      'WebDAV Account',
      name: 'webdav_Account',
      desc: '',
      args: [],
    );
  }

  /// `Sync history`
  String get sync_history {
    return Intl.message(
      'Sync history',
      name: 'sync_history',
      desc: '',
      args: [],
    );
  }

  /// `Sync read progress`
  String get sync_read_progress {
    return Intl.message(
      'Sync read progress',
      name: 'sync_read_progress',
      desc: '',
      args: [],
    );
  }

  /// `Sync group`
  String get sync_group {
    return Intl.message(
      'Sync group',
      name: 'sync_group',
      desc: '',
      args: [],
    );
  }

  /// `Sync quick search`
  String get sync_quick_search {
    return Intl.message(
      'Sync quick search',
      name: 'sync_quick_search',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get export {
    return Intl.message(
      'Export',
      name: 'export',
      desc: '',
      args: [],
    );
  }

  /// `Read from clipboard`
  String get read_from_clipboard {
    return Intl.message(
      'Read from clipboard',
      name: 'read_from_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Delete Task`
  String get delete_task {
    return Intl.message(
      'Delete Task',
      name: 'delete_task',
      desc: '',
      args: [],
    );
  }

  /// `Delete task only`
  String get delete_task_only {
    return Intl.message(
      'Delete task only',
      name: 'delete_task_only',
      desc: '',
      args: [],
    );
  }

  /// `Delete task and content`
  String get delete_task_and_content {
    return Intl.message(
      'Delete task and content',
      name: 'delete_task_and_content',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get uc_profile {
    return Intl.message(
      'Profile',
      name: 'uc_profile',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get uc_selected {
    return Intl.message(
      'Selected',
      name: 'uc_selected',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get uc_rename {
    return Intl.message(
      'Rename',
      name: 'uc_rename',
      desc: '',
      args: [],
    );
  }

  /// `Create New`
  String get uc_crt_profile {
    return Intl.message(
      'Create New',
      name: 'uc_crt_profile',
      desc: '',
      args: [],
    );
  }

  /// `Delete Profile`
  String get uc_del_profile {
    return Intl.message(
      'Delete Profile',
      name: 'uc_del_profile',
      desc: '',
      args: [],
    );
  }

  /// `Set as Default`
  String get uc_set_as_def {
    return Intl.message(
      'Set as Default',
      name: 'uc_set_as_def',
      desc: '',
      args: [],
    );
  }

  /// `Image Load Settings`
  String get uc_img_load_setting {
    return Intl.message(
      'Image Load Settings',
      name: 'uc_img_load_setting',
      desc: '',
      args: [],
    );
  }

  /// `Through the H@H`
  String get uc_thor_hath {
    return Intl.message(
      'Through the H@H',
      name: 'uc_thor_hath',
      desc: '',
      args: [],
    );
  }

  /// `Image Size Settings`
  String get uc_img_size_setting {
    return Intl.message(
      'Image Size Settings',
      name: 'uc_img_size_setting',
      desc: '',
      args: [],
    );
  }

  /// `Resample Resolution`
  String get uc_res_res {
    return Intl.message(
      'Resample Resolution',
      name: 'uc_res_res',
      desc: '',
      args: [],
    );
  }

  /// `Normally, images are resampled to 1280 pixels of horizontal resolution for online viewing. You can alternatively select one of the following resample resolutions. To avoid murdering the staging servers, resolutions above 1280x are temporarily restricted to donators, people with any hath perk, and people with a UID below 3,000,000.`
  String get uc_res_res_desc {
    return Intl.message(
      'Normally, images are resampled to 1280 pixels of horizontal resolution for online viewing. You can alternatively select one of the following resample resolutions. To avoid murdering the staging servers, resolutions above 1280x are temporarily restricted to donators, people with any hath perk, and people with a UID below 3,000,000.',
      name: 'uc_res_res_desc',
      desc: '',
      args: [],
    );
  }

  /// `Horizontal`
  String get uc_img_horiz {
    return Intl.message(
      'Horizontal',
      name: 'uc_img_horiz',
      desc: '',
      args: [],
    );
  }

  /// `Vertical`
  String get uc_img_vert {
    return Intl.message(
      'Vertical',
      name: 'uc_img_vert',
      desc: '',
      args: [],
    );
  }

  /// `While the site will automatically scale down images to fit your screen width, you can also manually restrict the maximum display size of an image. Like the automatic scaling, this does not resample the image, as the resizing is done browser-side. (0 = no limit)`
  String get uc_img_cussize_desc {
    return Intl.message(
      'While the site will automatically scale down images to fit your screen width, you can also manually restrict the maximum display size of an image. Like the automatic scaling, this does not resample the image, as the resizing is done browser-side. (0 = no limit)',
      name: 'uc_img_cussize_desc',
      desc: '',
      args: [],
    );
  }

  /// `Gallery Name Display`
  String get uc_name_display {
    return Intl.message(
      'Gallery Name Display',
      name: 'uc_name_display',
      desc: '',
      args: [],
    );
  }

  /// `Many galleries have both an English/Romanized title and a title in Japanese script. Which gallery name would you like as default?`
  String get uc_name_display_desc {
    return Intl.message(
      'Many galleries have both an English/Romanized title and a title in Japanese script. Which gallery name would you like as default?',
      name: 'uc_name_display_desc',
      desc: '',
      args: [],
    );
  }

  /// `rchiver Settings`
  String get uc_archiver_set {
    return Intl.message(
      'rchiver Settings',
      name: 'uc_archiver_set',
      desc: '',
      args: [],
    );
  }

  /// `The default behavior for the Archiver is to confirm the cost and selection for original or resampled archive, then present a link that can be clicked or copied elsewhere. You can change this behavior here.`
  String get uc_archiver_desc {
    return Intl.message(
      'The default behavior for the Archiver is to confirm the cost and selection for original or resampled archive, then present a link that can be clicked or copied elsewhere. You can change this behavior here.',
      name: 'uc_archiver_desc',
      desc: '',
      args: [],
    );
  }

  /// `Front Page`
  String get uc_front_page {
    return Intl.message(
      'Front Page',
      name: 'uc_front_page',
      desc: '',
      args: [],
    );
  }

  /// `Front Page Display mode`
  String get uc_front_page_dis_mode {
    return Intl.message(
      'Front Page Display mode',
      name: 'uc_front_page_dis_mode',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get uc_fav {
    return Intl.message(
      'Favorites',
      name: 'uc_fav',
      desc: '',
      args: [],
    );
  }

  /// `Default sort`
  String get uc_fav_sort {
    return Intl.message(
      'Default sort',
      name: 'uc_fav_sort',
      desc: '',
      args: [],
    );
  }

  /// `You can also select your default sort order for galleries on your favorites page. Note that favorites added prior to the March 2016 revamp did not store a timestamp, and will use the gallery posted time regardless of this setting.`
  String get uc_fav_sort_desc {
    return Intl.message(
      'You can also select your default sort order for galleries on your favorites page. Note that favorites added prior to the March 2016 revamp did not store a timestamp, and will use the gallery posted time regardless of this setting.',
      name: 'uc_fav_sort_desc',
      desc: '',
      args: [],
    );
  }

  /// `Ratings Colors`
  String get uc_rating {
    return Intl.message(
      'Ratings Colors',
      name: 'uc_rating',
      desc: '',
      args: [],
    );
  }

  /// `By default, galleries that you have rated will appear with red stars for ratings of 2 stars and below, green for ratings between 2.5 and 4 stars, and blue for ratings of 4.5 or 5 stars. You can customize this by entering your desired color combination below.\n Each letter represents one star. The default RRGGB means R(ed) for the first and second star, G(reen) for the third and fourth, and B(lue) for the fifth. You can also use (Y)ellow for the normal stars. Any five-letter R/G/B/Y combo works.`
  String get uc_rating_desc {
    return Intl.message(
      'By default, galleries that you have rated will appear with red stars for ratings of 2 stars and below, green for ratings between 2.5 and 4 stars, and blue for ratings of 4.5 or 5 stars. You can customize this by entering your desired color combination below.\n Each letter represents one star. The default RRGGB means R(ed) for the first and second star, G(reen) for the third and fourth, and B(lue) for the fifth. You can also use (Y)ellow for the normal stars. Any five-letter R/G/B/Y combo works.',
      name: 'uc_rating_desc',
      desc: '',
      args: [],
    );
  }

  /// `Tag Namespaces`
  String get uc_tag_namesp {
    return Intl.message(
      'Tag Namespaces',
      name: 'uc_tag_namesp',
      desc: '',
      args: [],
    );
  }

  /// `reclass`
  String get uc_reclass {
    return Intl.message(
      'reclass',
      name: 'uc_reclass',
      desc: '',
      args: [],
    );
  }

  /// `language`
  String get uc_language {
    return Intl.message(
      'language',
      name: 'uc_language',
      desc: '',
      args: [],
    );
  }

  /// `parody`
  String get uc_parody {
    return Intl.message(
      'parody',
      name: 'uc_parody',
      desc: '',
      args: [],
    );
  }

  /// `character`
  String get uc_character {
    return Intl.message(
      'character',
      name: 'uc_character',
      desc: '',
      args: [],
    );
  }

  /// `group`
  String get uc_group {
    return Intl.message(
      'group',
      name: 'uc_group',
      desc: '',
      args: [],
    );
  }

  /// `artist`
  String get uc_artist {
    return Intl.message(
      'artist',
      name: 'uc_artist',
      desc: '',
      args: [],
    );
  }

  /// `male`
  String get uc_male {
    return Intl.message(
      'male',
      name: 'uc_male',
      desc: '',
      args: [],
    );
  }

  /// `female`
  String get uc_female {
    return Intl.message(
      'female',
      name: 'uc_female',
      desc: '',
      args: [],
    );
  }

  /// `If you want to exclude certain namespaces from a default tag search, you can check those abover. Note that this does not prevent galleries with tags in these namespaces from appearing, it just makes it so that when searching tags, it will forego those namespaces.`
  String get uc_xt_desc {
    return Intl.message(
      'If you want to exclude certain namespaces from a default tag search, you can check those abover. Note that this does not prevent galleries with tags in these namespaces from appearing, it just makes it so that when searching tags, it will forego those namespaces.',
      name: 'uc_xt_desc',
      desc: '',
      args: [],
    );
  }

  /// `Tag Filtering Threshold`
  String get uc_tag_ft {
    return Intl.message(
      'Tag Filtering Threshold',
      name: 'uc_tag_ft',
      desc: '',
      args: [],
    );
  }

  /// `You can soft filter tags by adding them to My Tags with a negative weight. If a gallery has tags that add up to weight abover this value, it is filtered from view. This threshold can be set between 0 and -9999.`
  String get uc_tag_ft_desc {
    return Intl.message(
      'You can soft filter tags by adding them to My Tags with a negative weight. If a gallery has tags that add up to weight abover this value, it is filtered from view. This threshold can be set between 0 and -9999.',
      name: 'uc_tag_ft_desc',
      desc: '',
      args: [],
    );
  }

  /// `Tag Watching Threshold`
  String get uc_tag_wt {
    return Intl.message(
      'Tag Watching Threshold',
      name: 'uc_tag_wt',
      desc: '',
      args: [],
    );
  }

  /// `Recently uploaded galleries will be included on the watched screen if it has at least one watched tag with positive weight, and the sum of weights on its watched tags add up to this value or higher. This threshold can be set between 0 and 9999.`
  String get uc_tag_wt_desc {
    return Intl.message(
      'Recently uploaded galleries will be included on the watched screen if it has at least one watched tag with positive weight, and the sum of weights on its watched tags add up to this value or higher. This threshold can be set between 0 and 9999.',
      name: 'uc_tag_wt_desc',
      desc: '',
      args: [],
    );
  }

  /// `Excluded Languages`
  String get uc_exc_lang {
    return Intl.message(
      'Excluded Languages',
      name: 'uc_exc_lang',
      desc: '',
      args: [],
    );
  }

  /// `If you wish to hide galleries in certain languages from the gallery list and searches, select them from the list abover.\nNote that matching galleries will never appear regardless of your search query.`
  String get uc_exc_lang_desc {
    return Intl.message(
      'If you wish to hide galleries in certain languages from the gallery list and searches, select them from the list abover.\nNote that matching galleries will never appear regardless of your search query.',
      name: 'uc_exc_lang_desc',
      desc: '',
      args: [],
    );
  }

  /// `Excluded Uploaders`
  String get uc_exc_up {
    return Intl.message(
      'Excluded Uploaders',
      name: 'uc_exc_up',
      desc: '',
      args: [],
    );
  }

  /// `If you wish to hide galleries from certain uploaders from the gallery list and searches, add them abover. Put one username per line.\nNote that galleries from these uploaders will never appear regardless of your search query.`
  String get uc_exc_up_desc {
    return Intl.message(
      'If you wish to hide galleries from certain uploaders from the gallery list and searches, add them abover. Put one username per line.\nNote that galleries from these uploaders will never appear regardless of your search query.',
      name: 'uc_exc_up_desc',
      desc: '',
      args: [],
    );
  }

  /// `Search Result Count`
  String get uc_search_r_count {
    return Intl.message(
      'Search Result Count',
      name: 'uc_search_r_count',
      desc: '',
      args: [],
    );
  }

  /// `How many results would you like per page for the index/search page and torrent search pages? (Hath Perk: Paging Enlargement Required)`
  String get uc_search_r_count_desc {
    return Intl.message(
      'How many results would you like per page for the index/search page and torrent search pages? (Hath Perk: Paging Enlargement Required)',
      name: 'uc_search_r_count_desc',
      desc: '',
      args: [],
    );
  }

  /// `Thumbnail Settings`
  String get uc_thumb_setting {
    return Intl.message(
      'Thumbnail Settings',
      name: 'uc_thumb_setting',
      desc: '',
      args: [],
    );
  }

  /// `mouse-over thumbnails`
  String get uc_mose_over_thumb {
    return Intl.message(
      'mouse-over thumbnails',
      name: 'uc_mose_over_thumb',
      desc: '',
      args: [],
    );
  }

  /// `Size`
  String get uc_thumb_size {
    return Intl.message(
      'Size',
      name: 'uc_thumb_size',
      desc: '',
      args: [],
    );
  }

  /// `Row`
  String get uc_thumb_row {
    return Intl.message(
      'Row',
      name: 'uc_thumb_row',
      desc: '',
      args: [],
    );
  }

  /// `Thumbnail Scaling`
  String get uc_thumb_scaling {
    return Intl.message(
      'Thumbnail Scaling',
      name: 'uc_thumb_scaling',
      desc: '',
      args: [],
    );
  }

  /// `Thumbnails on the thumbnail and extended gallery list views can be scaled to a custom value between 75% and 150%.`
  String get uc_thumb_scaling_desc {
    return Intl.message(
      'Thumbnails on the thumbnail and extended gallery list views can be scaled to a custom value between 75% and 150%.',
      name: 'uc_thumb_scaling_desc',
      desc: '',
      args: [],
    );
  }

  /// `Viewport Override`
  String get uc_viewport_or {
    return Intl.message(
      'Viewport Override',
      name: 'uc_viewport_or',
      desc: '',
      args: [],
    );
  }

  /// `Allows you to override the virtual width of the site for mobile devices. This is normally determined automatically by your device based on its DPI. Sensible values at 100% thumbnail scale are between 640 and 1400.`
  String get uc_viewport_or_desc {
    return Intl.message(
      'Allows you to override the virtual width of the site for mobile devices. This is normally determined automatically by your device based on its DPI. Sensible values at 100% thumbnail scale are between 640 and 1400.',
      name: 'uc_viewport_or_desc',
      desc: '',
      args: [],
    );
  }

  /// `Gallery Comments`
  String get uc_gallery_comments {
    return Intl.message(
      'Gallery Comments',
      name: 'uc_gallery_comments',
      desc: '',
      args: [],
    );
  }

  /// `Sort order`
  String get uc_comments_sort_order {
    return Intl.message(
      'Sort order',
      name: 'uc_comments_sort_order',
      desc: '',
      args: [],
    );
  }

  /// `Show votes`
  String get uc_comments_show_votes {
    return Intl.message(
      'Show votes',
      name: 'uc_comments_show_votes',
      desc: '',
      args: [],
    );
  }

  /// `Gallery Tags`
  String get uc_tag {
    return Intl.message(
      'Gallery Tags',
      name: 'uc_tag',
      desc: '',
      args: [],
    );
  }

  /// `Gallery Tags Sort order`
  String get uc_tag_short_order {
    return Intl.message(
      'Gallery Tags Sort order',
      name: 'uc_tag_short_order',
      desc: '',
      args: [],
    );
  }

  /// `Show Page Numbers`
  String get uc_show_page_num {
    return Intl.message(
      'Show Page Numbers',
      name: 'uc_show_page_num',
      desc: '',
      args: [],
    );
  }

  /// `Hentai@Home Local Network Host`
  String get uc_hath_local_host {
    return Intl.message(
      'Hentai@Home Local Network Host',
      name: 'uc_hath_local_host',
      desc: '',
      args: [],
    );
  }

  /// `IP Address:Port`
  String get uc_ip_addr_port {
    return Intl.message(
      'IP Address:Port',
      name: 'uc_ip_addr_port',
      desc: '',
      args: [],
    );
  }

  /// `This setting can be used if you have a H@H client running on your local network with the same public IP you browse the site with. Some routers are buggy and cannot route requests back to its own IP; this allows you to work around this problem.\nIf you are running the client on the same PC you browse from, use the loopback address (127.0.0.1:port). If the client is running on another computer on your network, use its local network IP. Some browser configurations prevent external web sites from accessing URLs with local network IPs, the site must then be whitelisted for this to work.`
  String get uc_hath_local_host_desc {
    return Intl.message(
      'This setting can be used if you have a H@H client running on your local network with the same public IP you browse the site with. Some routers are buggy and cannot route requests back to its own IP; this allows you to work around this problem.\nIf you are running the client on the same PC you browse from, use the loopback address (127.0.0.1:port). If the client is running on another computer on your network, use its local network IP. Some browser configurations prevent external web sites from accessing URLs with local network IPs, the site must then be whitelisted for this to work.',
      name: 'uc_hath_local_host_desc',
      desc: '',
      args: [],
    );
  }

  /// `Original Images`
  String get uc_ori_image {
    return Intl.message(
      'Original Images',
      name: 'uc_ori_image',
      desc: '',
      args: [],
    );
  }

  /// `Use original images instead of the resampled versions where applicable?`
  String get uc_ori_image_desc {
    return Intl.message(
      'Use original images instead of the resampled versions where applicable?',
      name: 'uc_ori_image_desc',
      desc: '',
      args: [],
    );
  }

  /// `Multi-Page Viewer`
  String get uc_mpv {
    return Intl.message(
      'Multi-Page Viewer',
      name: 'uc_mpv',
      desc: '',
      args: [],
    );
  }

  /// `Always use`
  String get uc_mpv_always {
    return Intl.message(
      'Always use',
      name: 'uc_mpv_always',
      desc: '',
      args: [],
    );
  }

  /// `Display Style`
  String get uc_mpv_stype {
    return Intl.message(
      'Display Style',
      name: 'uc_mpv_stype',
      desc: '',
      args: [],
    );
  }

  /// `Thumbnail Pane`
  String get uc_mpv_thumb_pane {
    return Intl.message(
      'Thumbnail Pane',
      name: 'uc_mpv_thumb_pane',
      desc: '',
      args: [],
    );
  }

  /// `pixels`
  String get uc_pixels {
    return Intl.message(
      'pixels',
      name: 'uc_pixels',
      desc: '',
      args: [],
    );
  }

  /// `Original`
  String get uc_Original {
    return Intl.message(
      'Original',
      name: 'uc_Original',
      desc: '',
      args: [],
    );
  }

  /// `Translated`
  String get uc_Translated {
    return Intl.message(
      'Translated',
      name: 'uc_Translated',
      desc: '',
      args: [],
    );
  }

  /// `Rewrite`
  String get uc_Rewrite {
    return Intl.message(
      'Rewrite',
      name: 'uc_Rewrite',
      desc: '',
      args: [],
    );
  }

  /// `Japanese`
  String get uc_Japanese {
    return Intl.message(
      'Japanese',
      name: 'uc_Japanese',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get uc_English {
    return Intl.message(
      'English',
      name: 'uc_English',
      desc: '',
      args: [],
    );
  }

  /// `Chinese`
  String get uc_Chinese {
    return Intl.message(
      'Chinese',
      name: 'uc_Chinese',
      desc: '',
      args: [],
    );
  }

  /// `Dutch`
  String get uc_Dutch {
    return Intl.message(
      'Dutch',
      name: 'uc_Dutch',
      desc: '',
      args: [],
    );
  }

  /// `French`
  String get uc_French {
    return Intl.message(
      'French',
      name: 'uc_French',
      desc: '',
      args: [],
    );
  }

  /// `German`
  String get uc_German {
    return Intl.message(
      'German',
      name: 'uc_German',
      desc: '',
      args: [],
    );
  }

  /// `Hungarian`
  String get uc_Hungarian {
    return Intl.message(
      'Hungarian',
      name: 'uc_Hungarian',
      desc: '',
      args: [],
    );
  }

  /// `Italian`
  String get uc_Italian {
    return Intl.message(
      'Italian',
      name: 'uc_Italian',
      desc: '',
      args: [],
    );
  }

  /// `Korean`
  String get uc_Korean {
    return Intl.message(
      'Korean',
      name: 'uc_Korean',
      desc: '',
      args: [],
    );
  }

  /// `Polish`
  String get uc_Polish {
    return Intl.message(
      'Polish',
      name: 'uc_Polish',
      desc: '',
      args: [],
    );
  }

  /// `Portuguese`
  String get uc_Portuguese {
    return Intl.message(
      'Portuguese',
      name: 'uc_Portuguese',
      desc: '',
      args: [],
    );
  }

  /// `Russian`
  String get uc_Russian {
    return Intl.message(
      'Russian',
      name: 'uc_Russian',
      desc: '',
      args: [],
    );
  }

  /// `Spanish`
  String get uc_Spanish {
    return Intl.message(
      'Spanish',
      name: 'uc_Spanish',
      desc: '',
      args: [],
    );
  }

  /// `Thai`
  String get uc_Thai {
    return Intl.message(
      'Thai',
      name: 'uc_Thai',
      desc: '',
      args: [],
    );
  }

  /// `Vietnamese`
  String get uc_Vietnamese {
    return Intl.message(
      'Vietnamese',
      name: 'uc_Vietnamese',
      desc: '',
      args: [],
    );
  }

  /// `N/A`
  String get uc_NA {
    return Intl.message(
      'N/A',
      name: 'uc_NA',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get uc_Other {
    return Intl.message(
      'Other',
      name: 'uc_Other',
      desc: '',
      args: [],
    );
  }

  /// `Any client (Recommended)`
  String get uc_uh_0 {
    return Intl.message(
      'Any client (Recommended)',
      name: 'uc_uh_0',
      desc: '',
      args: [],
    );
  }

  /// `Default port clients only (Can be slower. Enable if behind firewall/proxy that blocks outgoing non-standard ports.)`
  String get uc_uh_1 {
    return Intl.message(
      'Default port clients only (Can be slower. Enable if behind firewall/proxy that blocks outgoing non-standard ports.)',
      name: 'uc_uh_1',
      desc: '',
      args: [],
    );
  }

  /// `No [Modern/HTTPS] (Donator only. You will not be able to browse as many pages. Recommended only if having severe problems.)`
  String get uc_uh_2 {
    return Intl.message(
      'No [Modern/HTTPS] (Donator only. You will not be able to browse as many pages. Recommended only if having severe problems.)',
      name: 'uc_uh_2',
      desc: '',
      args: [],
    );
  }

  /// `No [Legacy/HTTP] (Donator only. May not work by default in modern browsers. Recommended for legacy/outdated browsers only.)`
  String get uc_uh_3 {
    return Intl.message(
      'No [Legacy/HTTP] (Donator only. May not work by default in modern browsers. Recommended for legacy/outdated browsers only.)',
      name: 'uc_uh_3',
      desc: '',
      args: [],
    );
  }

  /// `Any client`
  String get uc_uh_0_s {
    return Intl.message(
      'Any client',
      name: 'uc_uh_0_s',
      desc: '',
      args: [],
    );
  }

  /// `Default port clients only`
  String get uc_uh_1_s {
    return Intl.message(
      'Default port clients only',
      name: 'uc_uh_1_s',
      desc: '',
      args: [],
    );
  }

  /// `No [Modern/HTTPS]`
  String get uc_uh_2_s {
    return Intl.message(
      'No [Modern/HTTPS]',
      name: 'uc_uh_2_s',
      desc: '',
      args: [],
    );
  }

  /// `No [Legacy/HTTP]`
  String get uc_uh_3_s {
    return Intl.message(
      'No [Legacy/HTTP]',
      name: 'uc_uh_3_s',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get uc_auto {
    return Intl.message(
      'Auto',
      name: 'uc_auto',
      desc: '',
      args: [],
    );
  }

  /// `Default Title`
  String get uc_tl_0 {
    return Intl.message(
      'Default Title',
      name: 'uc_tl_0',
      desc: '',
      args: [],
    );
  }

  /// `Japanese Title (if available)`
  String get uc_tl_1 {
    return Intl.message(
      'Japanese Title (if available)',
      name: 'uc_tl_1',
      desc: '',
      args: [],
    );
  }

  /// `Manual Select, Manual Start (Default)`
  String get uc_ar_0 {
    return Intl.message(
      'Manual Select, Manual Start (Default)',
      name: 'uc_ar_0',
      desc: '',
      args: [],
    );
  }

  /// `Manual Select, Auto Start`
  String get uc_ar_1 {
    return Intl.message(
      'Manual Select, Auto Start',
      name: 'uc_ar_1',
      desc: '',
      args: [],
    );
  }

  /// `Auto Select Original, Manual Start`
  String get uc_ar_2 {
    return Intl.message(
      'Auto Select Original, Manual Start',
      name: 'uc_ar_2',
      desc: '',
      args: [],
    );
  }

  /// `Auto Select Original, Auto Start`
  String get uc_ar_3 {
    return Intl.message(
      'Auto Select Original, Auto Start',
      name: 'uc_ar_3',
      desc: '',
      args: [],
    );
  }

  /// `Auto Select Resample, Manual Start`
  String get uc_ar_4 {
    return Intl.message(
      'Auto Select Resample, Manual Start',
      name: 'uc_ar_4',
      desc: '',
      args: [],
    );
  }

  /// `Auto Select Resample, Auto Start`
  String get uc_ar_5 {
    return Intl.message(
      'Auto Select Resample, Auto Start',
      name: 'uc_ar_5',
      desc: '',
      args: [],
    );
  }

  /// `Compact`
  String get uc_dm_0 {
    return Intl.message(
      'Compact',
      name: 'uc_dm_0',
      desc: '',
      args: [],
    );
  }

  /// `Thumbnail`
  String get uc_dm_1 {
    return Intl.message(
      'Thumbnail',
      name: 'uc_dm_1',
      desc: '',
      args: [],
    );
  }

  /// `Extended`
  String get uc_dm_2 {
    return Intl.message(
      'Extended',
      name: 'uc_dm_2',
      desc: '',
      args: [],
    );
  }

  /// `Minimal`
  String get uc_dm_3 {
    return Intl.message(
      'Minimal',
      name: 'uc_dm_3',
      desc: '',
      args: [],
    );
  }

  /// `Minimal+`
  String get uc_dm_4 {
    return Intl.message(
      'Minimal+',
      name: 'uc_dm_4',
      desc: '',
      args: [],
    );
  }

  /// `By last gallery update time`
  String get uc_fs_0 {
    return Intl.message(
      'By last gallery update time',
      name: 'uc_fs_0',
      desc: '',
      args: [],
    );
  }

  /// `By favorited time`
  String get uc_fs_1 {
    return Intl.message(
      'By favorited time',
      name: 'uc_fs_1',
      desc: '',
      args: [],
    );
  }

  /// `On mouse-over (pages load faster, but there may be a slight delay before a thumb appears)`
  String get uc_lt_0 {
    return Intl.message(
      'On mouse-over (pages load faster, but there may be a slight delay before a thumb appears)',
      name: 'uc_lt_0',
      desc: '',
      args: [],
    );
  }

  /// `On page load (pages take longer to load, but there is no delay for loading a thumb after the page has loaded)`
  String get uc_lt_1 {
    return Intl.message(
      'On page load (pages take longer to load, but there is no delay for loading a thumb after the page has loaded)',
      name: 'uc_lt_1',
      desc: '',
      args: [],
    );
  }

  /// `On mouse-over`
  String get uc_lt_0_s {
    return Intl.message(
      'On mouse-over',
      name: 'uc_lt_0_s',
      desc: '',
      args: [],
    );
  }

  /// `On page load`
  String get uc_lt_1_s {
    return Intl.message(
      'On page load',
      name: 'uc_lt_1_s',
      desc: '',
      args: [],
    );
  }

  /// `Narmal`
  String get uc_ts_0 {
    return Intl.message(
      'Narmal',
      name: 'uc_ts_0',
      desc: '',
      args: [],
    );
  }

  /// `Large`
  String get uc_ts_1 {
    return Intl.message(
      'Large',
      name: 'uc_ts_1',
      desc: '',
      args: [],
    );
  }

  /// `Oldest comments first`
  String get uc_cs_0 {
    return Intl.message(
      'Oldest comments first',
      name: 'uc_cs_0',
      desc: '',
      args: [],
    );
  }

  /// `Recent comments first`
  String get uc_cs_1 {
    return Intl.message(
      'Recent comments first',
      name: 'uc_cs_1',
      desc: '',
      args: [],
    );
  }

  /// `By highest score`
  String get uc_cs_2 {
    return Intl.message(
      'By highest score',
      name: 'uc_cs_2',
      desc: '',
      args: [],
    );
  }

  /// `On score hover or click`
  String get uc_sc_0 {
    return Intl.message(
      'On score hover or click',
      name: 'uc_sc_0',
      desc: '',
      args: [],
    );
  }

  /// `Always`
  String get uc_sc_1 {
    return Intl.message(
      'Always',
      name: 'uc_sc_1',
      desc: '',
      args: [],
    );
  }

  /// `Alphabetical`
  String get uc_tb_0 {
    return Intl.message(
      'Alphabetical',
      name: 'uc_tb_0',
      desc: '',
      args: [],
    );
  }

  /// `By tag power`
  String get uc_tb_1 {
    return Intl.message(
      'By tag power',
      name: 'uc_tb_1',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get uc_pn_0 {
    return Intl.message(
      'No',
      name: 'uc_pn_0',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get uc_pn_1 {
    return Intl.message(
      'Yes',
      name: 'uc_pn_1',
      desc: '',
      args: [],
    );
  }

  /// `Nope`
  String get uc_oi_0 {
    return Intl.message(
      'Nope',
      name: 'uc_oi_0',
      desc: '',
      args: [],
    );
  }

  /// `Yup, I can take it`
  String get uc_oi_1 {
    return Intl.message(
      'Yup, I can take it',
      name: 'uc_oi_1',
      desc: '',
      args: [],
    );
  }

  /// `Nope`
  String get uc_qb_0 {
    return Intl.message(
      'Nope',
      name: 'uc_qb_0',
      desc: '',
      args: [],
    );
  }

  /// `Yup`
  String get uc_qb_1 {
    return Intl.message(
      'Yup',
      name: 'uc_qb_1',
      desc: '',
      args: [],
    );
  }

  /// `Align left;\n Only scale if image is larger than browser width`
  String get uc_ms_0 {
    return Intl.message(
      'Align left;\n Only scale if image is larger than browser width',
      name: 'uc_ms_0',
      desc: '',
      args: [],
    );
  }

  /// `Align center;\n Only scale if image is larger than browser width`
  String get uc_ms_1 {
    return Intl.message(
      'Align center;\n Only scale if image is larger than browser width',
      name: 'uc_ms_1',
      desc: '',
      args: [],
    );
  }

  /// `Align center;\n Always scale images to fit browser width`
  String get uc_ms_2 {
    return Intl.message(
      'Align center;\n Always scale images to fit browser width',
      name: 'uc_ms_2',
      desc: '',
      args: [],
    );
  }

  /// `Show`
  String get uc_mt_0 {
    return Intl.message(
      'Show',
      name: 'uc_mt_0',
      desc: '',
      args: [],
    );
  }

  /// `Hide`
  String get uc_mt_1 {
    return Intl.message(
      'Hide',
      name: 'uc_mt_1',
      desc: '',
      args: [],
    );
  }

  /// `Auto select profile`
  String get auto_select_profile {
    return Intl.message(
      'Auto select profile',
      name: 'auto_select_profile',
      desc: '',
      args: [],
    );
  }

  /// `Tap to turn page animations`
  String get tap_to_turn_page_anima {
    return Intl.message(
      'Tap to turn page animations',
      name: 'tap_to_turn_page_anima',
      desc: '',
      args: [],
    );
  }

  /// `Download original image`
  String get download_ori_image {
    return Intl.message(
      'Download original image',
      name: 'download_ori_image',
      desc: '',
      args: [],
    );
  }

  /// `it is dangerous! You may get 509 error`
  String get download_ori_image_summary {
    return Intl.message(
      'it is dangerous! You may get 509 error',
      name: 'download_ori_image_summary',
      desc: '',
      args: [],
    );
  }

  /// `Redownload`
  String get redownload {
    return Intl.message(
      'Redownload',
      name: 'redownload',
      desc: '',
      args: [],
    );
  }

  /// `Open with other apps`
  String get open_with_other_apps {
    return Intl.message(
      'Open with other apps',
      name: 'open_with_other_apps',
      desc: '',
      args: [],
    );
  }

  /// `{tagNamespace, select, reclass{reclass} language{language} parody{parody} character{character} group{group} artist{artist} male{male} female{female} mixed{mixed} cosplayer{cosplayer} other{other} temp{temp}}`
  String tagNamespace(Object tagNamespace) {
    return Intl.select(
      tagNamespace,
      {
        'reclass': 'reclass',
        'language': 'language',
        'parody': 'parody',
        'character': 'character',
        'group': 'group',
        'artist': 'artist',
        'male': 'male',
        'female': 'female',
        'mixed': 'mixed',
        'cosplayer': 'cosplayer',
        'other': 'other',
        'temp': 'temp',
      },
      name: 'tagNamespace',
      desc: '',
      args: [tagNamespace],
    );
  }

  /// `Link redirect`
  String get link_redirect {
    return Intl.message(
      'Link redirect',
      name: 'link_redirect',
      desc: '',
      args: [],
    );
  }

  /// `Redirecting gallery links to selected sites`
  String get link_redirect_summary {
    return Intl.message(
      'Redirecting gallery links to selected sites',
      name: 'link_redirect_summary',
      desc: '',
      args: [],
    );
  }

  /// `Fixed height of list items`
  String get fixed_height_of_list_items {
    return Intl.message(
      'Fixed height of list items',
      name: 'fixed_height_of_list_items',
      desc: '',
      args: [],
    );
  }

  /// `Edit comment`
  String get edit_comment {
    return Intl.message(
      'Edit comment',
      name: 'edit_comment',
      desc: '',
      args: [],
    );
  }

  /// `New comment`
  String get new_comment {
    return Intl.message(
      'New comment',
      name: 'new_comment',
      desc: '',
      args: [],
    );
  }

  /// `Group`
  String get group {
    return Intl.message(
      'Group',
      name: 'group',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `New Group`
  String get newGroup {
    return Intl.message(
      'New Group',
      name: 'newGroup',
      desc: '',
      args: [],
    );
  }

  /// `Group Name`
  String get groupName {
    return Intl.message(
      'Group Name',
      name: 'groupName',
      desc: '',
      args: [],
    );
  }

  /// `Group Type`
  String get groupType {
    return Intl.message(
      'Group Type',
      name: 'groupType',
      desc: '',
      args: [],
    );
  }

  /// `Search texts`
  String get searchTexts {
    return Intl.message(
      'Search texts',
      name: 'searchTexts',
      desc: '',
      args: [],
    );
  }

  /// `New Text`
  String get newText {
    return Intl.message(
      'New Text',
      name: 'newText',
      desc: '',
      args: [],
    );
  }

  /// `Global Setting`
  String get global_setting {
    return Intl.message(
      'Global Setting',
      name: 'global_setting',
      desc: '',
      args: [],
    );
  }

  /// `Open supported links`
  String get open_supported_links {
    return Intl.message(
      'Open supported links',
      name: 'open_supported_links',
      desc: '',
      args: [],
    );
  }

  /// `Starting with Android 12, apps can only be used as web link handling apps if they are approved. Otherwise it will be processed using the default browser. You can manually approve it here`
  String get open_supported_links_summary {
    return Intl.message(
      'Starting with Android 12, apps can only be used as web link handling apps if they are approved. Otherwise it will be processed using the default browser. You can manually approve it here',
      name: 'open_supported_links_summary',
      desc: '',
      args: [],
    );
  }

  /// `Download Type`
  String get image_download_type {
    return Intl.message(
      'Download Type',
      name: 'image_download_type',
      desc: '',
      args: [],
    );
  }

  /// `Resample`
  String get resample_image {
    return Intl.message(
      'Resample',
      name: 'resample_image',
      desc: '',
      args: [],
    );
  }

  /// `Original`
  String get original_image {
    return Intl.message(
      'Original',
      name: 'original_image',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Ask for Me`
  String get ask_me {
    return Intl.message(
      'Ask for Me',
      name: 'ask_me',
      desc: '',
      args: [],
    );
  }

  /// `Always`
  String get always {
    return Intl.message(
      'Always',
      name: 'always',
      desc: '',
      args: [],
    );
  }

  /// `Add to Mytags`
  String get tag_add_to_mytag {
    return Intl.message(
      'Add to Mytags',
      name: 'tag_add_to_mytag',
      desc: '',
      args: [],
    );
  }

  /// `Watch`
  String get tag_dialog_Watch {
    return Intl.message(
      'Watch',
      name: 'tag_dialog_Watch',
      desc: '',
      args: [],
    );
  }

  /// `Hide`
  String get tag_dialog_Hide {
    return Intl.message(
      'Hide',
      name: 'tag_dialog_Hide',
      desc: '',
      args: [],
    );
  }

  /// `Tag Weight`
  String get tag_dialog_tagWeight {
    return Intl.message(
      'Tag Weight',
      name: 'tag_dialog_tagWeight',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get tag_dialog_TagColor {
    return Intl.message(
      'Color',
      name: 'tag_dialog_TagColor',
      desc: '',
      args: [],
    );
  }

  /// `Default Color`
  String get tag_dialog_Default_color {
    return Intl.message(
      'Default Color',
      name: 'tag_dialog_Default_color',
      desc: '',
      args: [],
    );
  }

  /// `Primary`
  String get color_picker_primary {
    return Intl.message(
      'Primary',
      name: 'color_picker_primary',
      desc: '',
      args: [],
    );
  }

  /// `Wheel`
  String get color_picker_wheel {
    return Intl.message(
      'Wheel',
      name: 'color_picker_wheel',
      desc: '',
      args: [],
    );
  }

  /// `Restore tasks data`
  String get restore_tasks_data {
    return Intl.message(
      'Restore tasks data',
      name: 'restore_tasks_data',
      desc: '',
      args: [],
    );
  }

  /// `Rebuild tasks data`
  String get rebuild_tasks_data {
    return Intl.message(
      'Rebuild tasks data',
      name: 'rebuild_tasks_data',
      desc: '',
      args: [],
    );
  }

  /// `Aggregate`
  String get aggregate {
    return Intl.message(
      'Aggregate',
      name: 'aggregate',
      desc: '',
      args: [],
    );
  }

  /// `Aggregate groups`
  String get aggregate_groups {
    return Intl.message(
      'Aggregate groups',
      name: 'aggregate_groups',
      desc: '',
      args: [],
    );
  }

  /// `Hide`
  String get hide {
    return Intl.message(
      'Hide',
      name: 'hide',
      desc: '',
      args: [],
    );
  }

  /// `Double page model`
  String get double_page_model {
    return Intl.message(
      'Double page model',
      name: 'double_page_model',
      desc: '',
      args: [],
    );
  }

  /// `Model {modelName}`
  String model(Object modelName) {
    return Intl.message(
      'Model $modelName',
      name: 'model',
      desc: '',
      args: [modelName],
    );
  }

  /// `Reply`
  String get reply_to_comment {
    return Intl.message(
      'Reply',
      name: 'reply_to_comment',
      desc: '',
      args: [],
    );
  }

  /// `Show comment avatar`
  String get show_comment_avatar {
    return Intl.message(
      'Show comment avatar',
      name: 'show_comment_avatar',
      desc: '',
      args: [],
    );
  }

  /// `Avatar`
  String get avatar {
    return Intl.message(
      'Avatar',
      name: 'avatar',
      desc: '',
      args: [],
    );
  }

  /// `Default Avatar Style`
  String get default_avatar_style {
    return Intl.message(
      'Default Avatar Style',
      name: 'default_avatar_style',
      desc: '',
      args: [],
    );
  }

  /// `Authentication Required`
  String get auth_signInTitle {
    return Intl.message(
      'Authentication Required',
      name: 'auth_signInTitle',
      desc: '',
      args: [],
    );
  }

  /// `Verify Identity`
  String get auth_biometricHint {
    return Intl.message(
      'Verify Identity',
      name: 'auth_biometricHint',
      desc: '',
      args: [],
    );
  }

  /// `Chapter`
  String get chapter {
    return Intl.message(
      'Chapter',
      name: 'chapter',
      desc: '',
      args: [],
    );
  }

  /// `Image Limits`
  String get image_limits {
    return Intl.message(
      'Image Limits',
      name: 'image_limits',
      desc: '',
      args: [],
    );
  }

  /// `Reset Cost`
  String get reset_cost {
    return Intl.message(
      'Reset Cost',
      name: 'reset_cost',
      desc: '',
      args: [],
    );
  }

  /// `Image Hide`
  String get image_hide {
    return Intl.message(
      'Image Hide',
      name: 'image_hide',
      desc: '',
      args: [],
    );
  }

  /// `QR code Check`
  String get QR_code_check {
    return Intl.message(
      'QR code Check',
      name: 'QR_code_check',
      desc: '',
      args: [],
    );
  }

  /// `Perceptual Hash Check`
  String get phash_check {
    return Intl.message(
      'Perceptual Hash Check',
      name: 'phash_check',
      desc: '',
      args: [],
    );
  }

  /// `Manage Hidden Images`
  String get mange_hidden_images {
    return Intl.message(
      'Manage Hidden Images',
      name: 'mange_hidden_images',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get author {
    return Intl.message(
      'Author',
      name: 'author',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Donate`
  String get donate {
    return Intl.message(
      'Donate',
      name: 'donate',
      desc: '',
      args: [],
    );
  }

  /// `License`
  String get license {
    return Intl.message(
      'License',
      name: 'license',
      desc: '',
      args: [],
    );
  }

  /// `Fullscreen`
  String get fullscreen {
    return Intl.message(
      'Fullscreen',
      name: 'fullscreen',
      desc: '',
      args: [],
    );
  }

  /// `Layout`
  String get layout {
    return Intl.message(
      'Layout',
      name: 'layout',
      desc: '',
      args: [],
    );
  }

  /// `Blurring of cover background`
  String get blurring_cover_background {
    return Intl.message(
      'Blurring of cover background',
      name: 'blurring_cover_background',
      desc: '',
      args: [],
    );
  }

  /// `Tag Limit`
  String get tag_limit {
    return Intl.message(
      'Tag Limit',
      name: 'tag_limit',
      desc: '',
      args: [],
    );
  }

  /// `No Limit`
  String get no_limit {
    return Intl.message(
      'No Limit',
      name: 'no_limit',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<L10n> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ko', countryCode: 'KR'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<L10n> load(Locale locale) => L10n.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
