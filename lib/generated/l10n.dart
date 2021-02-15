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
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
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

  /// `Sign in on the web`
  String get login_web {
    return Intl.message(
      'Sign in on the web',
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

  /// `READ`
  String get READ {
    return Intl.message(
      'READ',
      name: 'READ',
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

  /// `Preload image`
  String get preload_image {
    return Intl.message(
      'Preload image',
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

  /// `Follow system`
  String get follow_system {
    return Intl.message(
      'Follow system',
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

  /// `Custom hosts`
  String get custom_hosts {
    return Intl.message(
      'Custom hosts',
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

  /// `Clear all history`
  String get t_Clear_all_history {
    return Intl.message(
      'Clear all history',
      name: 't_Clear_all_history',
      desc: '',
      args: [],
    );
  }

  /// `Gallery site`
  String get galery_site {
    return Intl.message(
      'Gallery site',
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

  /// `EHentai settings`
  String get ehentai_settings {
    return Intl.message(
      'EHentai settings',
      name: 'ehentai_settings',
      desc: '',
      args: [],
    );
  }

  /// `Setting on website`
  String get setting_on_website {
    return Intl.message(
      'Setting on website',
      name: 'setting_on_website',
      desc: '',
      args: [],
    );
  }

  /// `My tags`
  String get ehentai_my_tags {
    return Intl.message(
      'My tags',
      name: 'ehentai_my_tags',
      desc: '',
      args: [],
    );
  }

  /// `My tags on website`
  String get mytags_on_website {
    return Intl.message(
      'My tags on website',
      name: 'mytags_on_website',
      desc: '',
      args: [],
    );
  }

  /// `List mode`
  String get list_mode {
    return Intl.message(
      'List mode',
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

  /// `Favorites order`
  String get favorites_order {
    return Intl.message(
      'Favorites order',
      name: 'favorites_order',
      desc: '',
      args: [],
    );
  }

  /// `Use posted`
  String get favorites_order_Use_posted {
    return Intl.message(
      'Use posted',
      name: 'favorites_order_Use_posted',
      desc: '',
      args: [],
    );
  }

  /// `Use favorited`
  String get favorites_order_Use_favorited {
    return Intl.message(
      'Use favorited',
      name: 'favorites_order_Use_favorited',
      desc: '',
      args: [],
    );
  }

  /// `Show japanese title`
  String get show_jpn_title {
    return Intl.message(
      'Show japanese title',
      name: 'show_jpn_title',
      desc: '',
      args: [],
    );
  }

  /// `Current version`
  String get current_version {
    return Intl.message(
      'Current version',
      name: 'current_version',
      desc: '',
      args: [],
    );
  }

  /// `Maximum history`
  String get max_history {
    return Intl.message(
      'Maximum history',
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
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}