import 'dart:io';

import 'package:collection/collection.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:eros_fe/common/controller/tag_controller.dart';
import 'package:eros_fe/common/service/dns_service.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/image_view/common.dart';
import 'package:eros_fe/pages/tab/fetch_list.dart';
import 'package:eros_fe/store/db/entity/tag_translat.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:path/path.dart' as path;
import 'package:quiver/core.dart';

import 'common/controller/tag_trans_controller.dart';
import 'common/controller/webdav_controller.dart';
import 'network/api.dart';

extension ExtGC on GalleryCache {
  ViewColumnMode get columnMode =>
      EnumToString.fromString(ViewColumnMode.values, columnModeVal ?? '') ??
      ViewColumnMode.single;

  GalleryCache copyWithMode(ViewColumnMode val) =>
      copyWith(columnModeVal: EnumToString.convertToString(val).oN);
}

extension ExtTabList on TabConfig {
  Map<String, bool> get tabMap {
    final Map<String, bool> _map = <String, bool>{};
    for (final TabItem item in tabItemList) {
      _map[item.name] = item.enable ?? false;
    }
    return _map;
  }

  List<String> get tabNameList {
    return tabItemList.map((TabItem e) => e.name).toList();
  }
}

extension ExtComment on GalleryComment {
  void _parseText(dom.Element element, List<String> textList) {
    if (element.nodes.isEmpty) {
      textList.add(element.text);
    } else {
      for (final dom.Node node in element.nodes) {
        if (node is dom.Element) {
          if (node.localName == 'br') {
            textList.add('\n');
          } else if (node.localName == 'a') {
            textList.add(node.text);
          } else if (node.localName == 'img') {
            textList.add(node.attributes['alt'] ?? '[Image]');
          } else {
            _parseText(node, textList);
          }
        } else if (node is dom.Text) {
          textList.add(node.text);
        }
      }
    }
  }

  List<String> getTextList() {
    if (textList != null && textList!.isNotEmpty) {
      return textList!;
    }

    final _textList = <String>[];

    final dom.Element? body = element as dom.Element?;
    if (body != null) {
      _parseText(body, _textList);
    }

    return _textList;
  }

  String get text => (textList ?? getTextList()).join('');

  String get translatedText => (translatedTextList ?? getTextList()).join('');
}

extension ExtGalleryProvider on GalleryProvider {
  GalleryProvider copyWithAll(GalleryProvider item) {
    return copyWith(
      token: item.token?.oN,
      showKey: item.showKey?.oN,
      url: item.url?.oN,
      imgUrl: item.imgUrl?.oN,
      imgUrlL: item.imgUrlL?.oN,
      imgHeight: item.imgHeight?.oN,
      imgWidth: item.imgWidth?.oN,
      japaneseTitle: item.japaneseTitle?.oN,
      englishTitle: item.englishTitle?.oN,
      category: item.category?.oN,
      uploader: item.uploader?.oN,
      posted: item.posted?.oN,
      language: item.language?.oN,
      filecount: item.filecount?.oN,
      rating: item.rating?.oN,
      ratingCount: item.ratingCount?.oN,
      torrentcount: item.torrentcount?.oN,
      torrents: item.torrents?.oN,
      filesize: item.filesize?.oN,
      filesizeText: item.filesizeText?.oN,
      visible: item.visible?.oN,
      parent: item.parent?.oN,
      ratingFallBack: item.ratingFallBack?.oN,
      numberOfReviews: item.numberOfReviews?.oN,
      postTime: item.postTime?.oN,
      favoritedCount: item.favoritedCount?.oN,
      favTitle: item.favTitle?.oN,
      favcat: item.favcat?.oN,
      localFav: item.localFav?.oN,
      simpleTags: item.simpleTags?.oN,
      tagsFromApi: item.tagsFromApi?.toList().oN,
      translated: item.translated?.oN,
      tagGroup: item.tagGroup?.oN,
      galleryComment: item.galleryComment?.oN,
      galleryImages: item.galleryImages?.oN,
      apikey: item.apikey?.oN,
      apiuid: item.apiuid?.oN,
      isRatinged: item.isRatinged?.oN,
      colorRating: item.colorRating?.oN,
      archiverLink: item.archiverLink?.oN,
      torrentLink: item.torrentLink?.oN,
      lastViewTime: item.lastViewTime?.oN,
      pageOfList: item.pageOfList?.oN,
      favNote: item.favNote?.oN,
      expunged: expunged?.oN,
      chapter: item.chapter?.oN,
    );
  }
}

extension ExtUser on User {
  String get cookie {
    final cookieList = <Cookie>[
      Cookie('ipb_member_id', memberId ?? ''),
      Cookie('ipb_pass_hash', passHash ?? ''),
      Cookie('igneous', igneous ?? ''),
      Cookie('sk', sk ?? ''),
      Cookie('hath_perks', hathPerks ?? ''),
      Cookie('star', star ?? ''),
      Cookie('yay', yay ?? ''),
      Cookie('iq', iq ?? ''),
    ];

    return cookieList
        .whereNot((e) => e.value.isEmpty)
        .map((e) => '${e.name}=${e.value}')
        .join('; ');
  }

  List<Cookie> get cookies {
    final cookieList = <Cookie>[
      Cookie('ipb_member_id', memberId ?? ''),
      Cookie('ipb_pass_hash', passHash ?? ''),
      Cookie('igneous', igneous ?? ''),
      Cookie('sk', sk ?? ''),
      Cookie('hath_perks', hathPerks ?? ''),
      Cookie('star', star ?? ''),
      Cookie('yay', yay ?? ''),
      Cookie('iq', iq ?? ''),
    ];

    return cookieList.whereNot((e) => e.value.isEmpty).toList();
  }
}

extension ExtTagTranlat on TagTranslat {
  String? get nameNotMD {
    final reg = RegExp(r'!\[(\S+)?\]\(.+?\)(\S+)');
    final match = reg.allMatches(name ?? '');
    if (match.isNotEmpty) {
      return name?.replaceAllMapped(reg, (match) => match.group(2) ?? '') ??
          name;
    } else {
      return name;
    }
  }

  /// 根据不同图片级别， 处理tag简介中的图片
  String? get introMDimage {
    final EhSettingService ehSettingService = Get.find();

    // 匹配R18g
    final regR18g = RegExp(r'!\[((\S+)?)\]\(##\s+?"(.+?)"\)');

    // 匹配R18和R18g
    final regR18And18g = RegExp(r'!\[((\S+)?)\]\(##?\s+?"(.+?)"\)');

    // 匹配所有级别图片
    final regAll = RegExp(r'!\[((\S+)?)\]\((.+?)\)');

    final lv = ehSettingService.tagIntroImgLv.value;

    String? _remove(RegExp regExp, String? text) {
      final match = regExp.allMatches(text ?? '');
      if (match.isNotEmpty) {
        final rult = text?.replaceAllMapped(regExp, (match) => '') ?? text;
        return rult;
      } else {
        return text;
      }
    }

    String? _fix(RegExp regExp, String? text) {
      final match = regExp.allMatches(text ?? '');
      if (match.isNotEmpty) {
        final rult = text?.replaceAllMapped(
                regExp, (match) => '![${match.group(2)}](${match.group(3)})') ??
            text;
        return rult;
      } else {
        return text;
      }
    }

    switch (lv) {
      case TagIntroImgLv.disable:
        // 去除所有
        return _remove(regAll, intro);
      case TagIntroImgLv.nonh:
        // 去除R18和r18g
        return _remove(regR18And18g, intro);
      case TagIntroImgLv.r18:
        // 去除R18g, 把r18的格式修正
        return _fix(regR18And18g, _remove(regR18g, intro));
      case TagIntroImgLv.r18g:
        // 把r18和r18g的格式修正
        return _fix(regR18And18g, intro);
    }
  }

  String? get fullTagTranslate {
    return '${EHConst.translateTagType[namespace] ?? namespace}:$nameNotMD';
  }

  String? get fullTagText {
    return '${namespace.shortName}:$key';
  }
}

extension ExtString on String {
  EhSettingService get _ehSettingService => Get.find();

  String get linkRedirect {
    if (_ehSettingService.linkRedirect) {
      final uri = Uri.parse(this);
      if (uri.host.contains(RegExp(r'e[-x]hentai.org'))) {
        return uri.replace(host: Api.getBaseHost()).toString();
      }
    }
    return this;
  }

  String get shortName {
    return EHConst.prefixToNameSpaceMap.entries
            .firstWhereOrNull((e) => e.value == trim().toLowerCase())
            ?.key ??
        this;
  }

  String get shortTitle {
    return replaceAll(RegExp(r'(\[.*?\]|\(.*?\))|{.*?}'), '')
        .trim()
        .split('\|')
        .first;
  }

  String get realDownloadPath {
    if (GetPlatform.isIOS) {
      final List<String> pathList = path.split(this).reversed.toList();
      return path.join(Global.appDocPath, pathList[1], pathList[0]);
    } else {
      return this;
    }
  }

  String get realArchiverPath {
    if (GetPlatform.isIOS) {
      final List<String> pathList = path.split(this).reversed.toList();
      return path.join(
          Global.appDocPath, pathList[2], pathList[1], pathList[0]);
    } else {
      return this;
    }
  }

  bool get isContentUri {
    return startsWith('content://');
  }
}

extension ExtensionWidget on Widget {
  Widget autoCompressKeyboard(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 触摸收起键盘
        FocusScope.of(context).requestFocus(FocusNode());
      },
      onPanDown: (DragDownDetails details) {
        // 滑动收起键盘
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: this,
    );
  }
}

extension ExtEhSettings on EhSettings {
  Map<String, String> get xnMap {
    final _map = <String, String>{};
    for (final _x in xn) {
      if (_x.ser != null) {
        _map[_x.ser!] = _x.value ?? '';
      }
    }
    return _map;
  }

  Map<String, EhSettingItem> get xnItemMap {
    final _map = <String, EhSettingItem>{};
    for (final _x in xn) {
      if (_x.ser != null) {
        _map[_x.name!] = _x;
      }
    }
    return _map;
  }

  void setXnItem(String namespace, String? value) {
    if (value == null) {
      return;
    }

    final _index = xn.indexWhere((element) => element.name == namespace);
    if (_index > -1) {
      xn[_index] = xn[_index].copyWith(value: value.oN);
    }
  }

  Map<String, String> get xlMap {
    final _map = <String, String>{};
    for (final _x in xl) {
      if (_x.ser != null) {
        _map[_x.ser!] = _x.value ?? '';
      }
    }
    return _map;
  }

  Map<String, String> get favMap {
    final map = <String, String>{};
    for (final _fav in favorites) {
      if (_fav.ser != null) {
        map[_fav.ser!] = _fav.value ?? '';
      }
    }
    return map;
  }

  Map<String, bool> get xlBoolMap {
    return xlMap.map((key, value) => MapEntry(key, value == '1'));
  }

  bool getBoolXl(String ser) => xlBoolMap[ser] ?? false;
  void setBoolXl(String ser, bool val) => setXl(ser, val ? '1' : '');

  void setXn(String ser, String? value) {
    if (value == null) {
      return;
    }

    final _index = xn.indexWhere((element) => element.ser == ser);
    if (_index > -1) {
      xn[_index] = xn[_index].copyWith(value: value.oN);
    } else {
      xn.add(EhSettingItem(ser: ser, value: value, type: 'xn'));
    }
  }

  void setXl(String ser, String? value) {
    if (value == null) {
      return;
    }
    final _index = xl.indexWhere((element) => element.ser == ser);
    if (_index > -1) {
      xl[_index] = xl[_index].copyWith(value: value.oN);
    } else {
      xl.add(EhSettingItem(ser: ser, value: value, type: 'xl'));
    }
  }

  void setFavname(String ser, String? value) {
    if (value == null) {
      return;
    }
    final _index = favorites.indexWhere((element) => element.ser == ser);
    if (_index > -1) {
      favorites[_index] = favorites[_index].copyWith(value: value.oN);
    } else {
      favorites.add(EhSettingItem(ser: ser, value: value, type: 'xl'));
    }
  }

  Map<String, dynamic> get postParam {
    final param = <String, dynamic>{
      if (loadImageThroughHAtH != null) 'uh': loadImageThroughHAtH,
      if (loadBrowsingCountry != null) 'co': loadBrowsingCountry,
      if (imageSize != null) 'xr': imageSize,
      if (imageSizeHorizontal != null) 'rx': imageSizeHorizontal,
      if (imageSizeVertical != null) 'ry': imageSizeVertical,
      if (galleryNameDisplay != null) 'tl': galleryNameDisplay,
      if (archiverSettings != null) 'ar': archiverSettings,
      if (frontPageSettings != null) 'dm': frontPageSettings,
      if (ctDoujinshi != null) 'ct_doujinshi': ctDoujinshi,
      if (ctManga != null) 'ct_manga': ctManga,
      if (ctArtistcg != null) 'ct_artistcg': ctArtistcg,
      if (ctGamecg != null) 'ct_gamecg': ctGamecg,
      if (ctWestern != null) 'ct_western': ctWestern,
      if (ctNonH != null) 'ct_non-h': ctNonH,
      if (ctImageset != null) 'ct_imageset': ctImageset,
      if (ctDoujinshi != null) 'ct_cosplay': ctCosplay,
      if (ctAsianporn != null) 'ct_asianporn': ctAsianporn,
      if (ctMisc != null) 'ct_misc': ctMisc,
      if (sortOrderFavorites != null) 'fs': sortOrderFavorites,
      if (ratings != null) 'ru': ratings,
      if (tagFilteringThreshold != null) 'ft': tagFilteringThreshold,
      if (tagWatchingThreshold != null) 'wt': tagWatchingThreshold,
      if (excludedUploaders != null) 'xu': excludedUploaders,
      if (searchResultCount != null) 'rc': searchResultCount,
      if (mouseOverThumbnails != null) 'lt': mouseOverThumbnails,
      if (thumbnailSize != null) 'ts': thumbnailSize,
      if (thumbnailRows != null) 'tr': thumbnailRows,
      if (thumbnailScaling != null) 'tp': thumbnailScaling,
      if (viewportOverride != null) 'vp': viewportOverride,
      if (sortOrderComments != null) 'cs': sortOrderComments,
      if (showCommentVotes != null) 'sc': showCommentVotes,
      if (sortOrderTags != null) 'tb': sortOrderTags,
      if (showGalleryPageNumbers != null) 'pn': showGalleryPageNumbers,
      if (hentaiAtHomeLocalNetworkHost != null)
        'hh': hentaiAtHomeLocalNetworkHost,
      if (originalImages != null) 'oi': originalImages,
      if (alwaysUseMpv != null) 'qb': alwaysUseMpv,
      if (mpvStyle != null) 'ms': mpvStyle,
      if (mpvThumbnailPane != null) 'mt': mpvThumbnailPane,
      'apply': 'apply',
    };

    for (final _xn in xn) {
      if (_xn.value == '1') {
        param['xn_${_xn.ser}'] = 'on';
      }
    }

    for (final _xl in xl) {
      if (_xl.value == '1') {
        param['xl_${_xl.ser}'] = 'on';
      }
    }

    for (final _fav in favorites) {
      param['favorite_${_fav.ser}'] = _fav.value;
    }

    return param;
  }
}

extension ExtGalleryList on GalleryList {
  Future<GalleryList> get qrySimpleTagTranslate async {
    final trController = Get.find<TagTransController>();
    final galleryFuture = gallerys?.map((e) async {
          final simpleTagsFuture = e.simpleTags?.map((e) async {
                final tr = await trController.getTagTranslateText(e.text!);
                return e.copyWith(translat: (tr ?? e.text).oN);
              }) ??
              [];
          final simpleTags = Future.wait<SimpleTag>(simpleTagsFuture);
          return e.copyWith(simpleTags: (await simpleTags).oN);
        }) ??
        [];

    final galleryList = Future.wait(galleryFuture);
    return copyWith(gallerys: (await galleryList).oN);
  }
}

extension ExtEhMytags on EhMytags {
  Future<List<EhUsertag>> get qryFullTagTranslate async {
    final trController = Get.find<TagTransController>();
    final userTagsFuture = usertags?.map((e) async {
          final tr = await trController.getTranTagWithNameSpase(e.title);
          return e.copyWith(translate: tr.oN);
        }) ??
        [];

    final userTags = Future.wait(userTagsFuture);
    return await userTags;
  }
}

extension ExtMvpImage on MvpImage {
  // 050e0cfa0fa8f3564afb38b8cabdadd5885ecf5e-636194-1286-1964-jpg_l.jpg
  String? get thumbName => Uri.parse(t ?? '').pathSegments.last;
  RegExpMatch? get _match => regExpMpvThumbName.firstMatch(thumbName ?? '');

  String? get width => _match?.group(2);
  String? get height => _match?.group(3);
  String? get size => _match?.group(1);
}

extension ExtAdvanceSearch on AdvanceSearch {
  Map<String, dynamic> get param {
    return <String, dynamic>{
      if (requireGalleryTorrent ?? false) 'f_sto': 'on',
      if (browseExpungedGalleries ?? false) 'f_sh': 'on',
      if (searchWithMinRating ?? false) 'f_sr': 'on',
      if (searchWithMinRating ?? false) 'f_srdd': minRating,
      if (searchBetweenPage ?? false) 'f_sp': 'on',
      if ((searchBetweenPage ?? false) && (startPage?.isNotEmpty ?? false))
        'f_spf': startPage,
      if ((searchBetweenPage ?? false) && (endPage?.isNotEmpty ?? false))
        'f_spt': endPage,
      if (disableCustomFilterLanguage ?? false) 'f_sfl': 'on',
      if (disableCustomFilterUploader ?? false) 'f_sfu': 'on',
      if (disableCustomFilterTags ?? false) 'f_sft': 'on',
    };
  }
}

extension ExtCustomProfile on CustomProfile {
  CustomProfileType get catsType =>
      EnumToString.fromString(CustomProfileType.values, catsTypeValue ?? '') ??
      CustomProfileType.disable;

  CustomProfileType get advSearchType =>
      EnumToString.fromString(
          CustomProfileType.values, advSearchTypeValue ?? '') ??
      CustomProfileType.disable;

  GalleryListType get listType =>
      EnumToString.fromString(GalleryListType.values, listTypeValue ?? '') ??
      GalleryListType.gallery;

  CustomProfile copyWithListType(GalleryListType value) =>
      copyWith(listTypeValue: value.name.oN);

  ListModeEnum get listMode =>
      EnumToString.fromString(ListModeEnum.values, listModeValue ?? '') ??
      ListModeEnum.global;

  String get syncFileName =>
      <String>[name, uuid, '${lastEditTime ?? 0}'].join(kGroupSeparator);
}

extension EhIterableExtension<T> on Iterable<T> {
  List<T> separat({required T separator}) {
    Iterator<T> iterator = this.iterator;
    if (!iterator.moveNext()) {
      return <T>[];
    }
    final rult = <T>[];
    if (separator == null) {
      do {
        rult.add(iterator.current);
      } while (iterator.moveNext());
    } else {
      rult.add(iterator.current);
      while (iterator.moveNext()) {
        rult.add(separator);
        rult.add(iterator.current);
      }
    }
    return rult;
  }
}

extension ExtGalleryTag on GalleryTag {
  GalleryTag setColor() {
    return Get.find<TagController>().getColorCode(this);
  }

  bool get needHide {
    return Get.find<TagController>().hideTags.contains(this);
  }
}

extension EhString on String {
  String toRealUrl() {
    final DnsService dnsService = Get.find();
    final bool enableDoH = dnsService.enableDoH;
    final bool enableCustomHosts = dnsService.enableCustomHosts;
    final List<DnsCache> dohDnsCacheList = dnsService.dohCache;
    final String host = Uri.parse(this).host;
    if (host.isEmpty) {
      return this;
    }
    String realHost = host;
    if (!enableDoH && !enableCustomHosts) {
      logger.d(' none');
      return this;
    } else if (enableDoH && enableCustomHosts) {
      // 同时开启doh和自定义host的情况
      logger.d(' both');
      return this;
    } else if (enableDoH) {
      // logger.d(' enableDoH');
      Get.find<DnsService>().getDoHCache(host);
      final int dohDnsCacheIndex = dnsService.dohCache
          .indexWhere((DnsCache element) => element.host == host);
      final DnsCache? dohDnsCache =
          dohDnsCacheIndex > -1 ? dohDnsCacheList[dohDnsCacheIndex] : null;
      realHost = dohDnsCache?.addr ?? host;
      final String realUrl = replaceFirst(host, realHost);
      logger.d('realUrl: $realUrl');
      return realUrl;
    }
    return this;
  }

  String get handleUrl {
    return _handleThumbUrlToEh;
  }

  String get _handleThumbUrlToEh {
    final EhSettingService _ehSettingService = Get.find();

    // if (startsWith(RegExp(EHConst.REG_URL_PREFIX_THUMB_EX)) &&
    //     _ehSettingService.redirectThumbLink) {
    //   return replaceFirst(
    //     RegExp(EHConst.REG_URL_PREFIX_THUMB_EX),
    //     EHConst.URL_PREFIX_THUMB_EH,
    //   );
    // }

    if (RegExp(EHConst.REG_URL_THUMB).hasMatch(this) &&
        contains(EHConst.EX_BASE_HOST) &&
        _ehSettingService.redirectThumbLink) {
      return replaceFirstMapped(
        RegExp(EHConst.REG_URL_THUMB),
        (Match m) => '${EHConst.URL_PREFIX_THUMB_EH}/${m.group(2)}',
      );
    }

    return this;
  }

  String get gid {
    final RegExp urlRex = RegExp(r'/g/(\d+)/(\w+)/$');
    final RegExpMatch? urlRult = urlRex.firstMatch(this);

    final String gid = urlRult?.group(1) ?? '';
    final String token = urlRult?.group(2) ?? '';
    return gid;
  }

  String get numberFormat {
    return replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}

extension EhT<T> on T {
  Optional<T> get toOptional {
    return Optional<T>.of(this);
  }

  Optional<T> get toOptionalNullable {
    return Optional<T>.fromNullable(this);
  }

  Optional<T> get o {
    return Optional<T>.of(this);
  }

  Optional<T> get oN {
    return Optional<T>.fromNullable(this);
  }
}
