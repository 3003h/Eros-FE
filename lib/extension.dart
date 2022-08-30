import 'dart:io';

import 'package:collection/collection.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/controller/tag_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/pages/tab/fetch_list.dart';
import 'package:fehviewer/store/floor/entity/tag_translat.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import 'common/controller/tag_trans_controller.dart';
import 'common/controller/webdav_controller.dart';
import 'common/enum.dart';
import 'common/global.dart';
import 'models/index.dart';
import 'network/api.dart';

extension ExtGC on GalleryCache {
  ViewColumnMode get columnMode =>
      EnumToString.fromString(ViewColumnMode.values, columnModeVal ?? '') ??
      ViewColumnMode.single;

  GalleryCache copyWithMode(ViewColumnMode val) =>
      copyWith(columnModeVal: EnumToString.convertToString(val));
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

  void setItemList(Map<String, bool> map, List<String> nameList) {
    tabItemList.clear();
    for (final String name in nameList) {
      tabItemList.add(TabItem(name: name, enable: map[name] ?? false));
    }
  }
}

extension ExtComment on GalleryComment {
  // 提取评论纯文字部分内容
  String get text => span.map((GalleryCommentSpan e) {
        if (e.imageUrl?.isNotEmpty ?? false) {
          return '[image]${e.href ?? ''} ';
        }
        return e.text ?? '';
      }).join();

  String get textTranslate => span.map((GalleryCommentSpan e) {
        if (e.imageUrl?.isNotEmpty ?? false) {
          return '[image]${e.href ?? ''} ';
        }
        return e.translate ?? '';
      }).join();

  DateTime get dateTime => DateFormat('yyyy-MM-dd HH:mm').parse(time);
}

extension ExtCommentSpan on GalleryCommentSpan {
  CommentSpanType get sType =>
      EnumToString.fromString(CommentSpanType.values, type ?? '') ??
      CommentSpanType.text;

  GalleryCommentSpan copyWithSpanType(CommentSpanType val) =>
      copyWith(type: EnumToString.convertToString(val));
}

extension ExtGalleryProvider on GalleryProvider {
  GalleryProvider copyWithAll(GalleryProvider item) {
    return copyWith(
        token: item.token,
        showKey: item.showKey,
        url: item.url,
        imgUrl: item.imgUrl,
        imgUrlL: item.imgUrlL,
        imgHeight: item.imgHeight,
        imgWidth: item.imgWidth,
        japaneseTitle: item.japaneseTitle,
        englishTitle: item.englishTitle,
        category: item.category,
        uploader: item.uploader,
        posted: item.posted,
        language: item.language,
        filecount: item.filecount,
        rating: item.rating,
        ratingCount: item.ratingCount,
        torrentcount: item.torrentcount,
        torrents: item.torrents,
        filesize: item.filesize,
        filesizeText: item.filesizeText,
        visible: item.visible,
        parent: item.parent,
        ratingFallBack: item.ratingFallBack,
        numberOfReviews: item.numberOfReviews,
        postTime: item.postTime,
        favoritedCount: item.favoritedCount,
        favTitle: item.favTitle,
        favcat: item.favcat,
        localFav: item.localFav,
        simpleTags: item.simpleTags,
        tagsFromApi: item.tagsFromApi?.toList(),
        translated: item.translated,
        tagGroup: item.tagGroup,
        galleryComment: item.galleryComment,
        galleryImages: item.galleryImages,
        apikey: item.apikey,
        apiuid: item.apiuid,
        isRatinged: item.isRatinged,
        colorRating: item.colorRating,
        archiverLink: item.archiverLink,
        torrentLink: item.torrentLink,
        lastViewTime: item.lastViewTime,
        pageOfList: item.pageOfList,
        favNote: item.favNote,
        expunged: expunged,
        chapter: item.chapter);
  }
}

extension ExtUser on User {
  String get cookie {
    final _list = <Cookie>[
      Cookie('ipb_member_id', memberId ?? ''),
      Cookie('ipb_pass_hash', passHash ?? ''),
      Cookie('igneous', igneous ?? ''),
      Cookie('sk', sk ?? ''),
      Cookie('hath_perks', hathPerks ?? ''),
      Cookie('star', star ?? ''),
      Cookie('yay', yay ?? ''),
    ];

    return _list
        .whereNot((e) => e.value.isEmpty)
        .map((e) => '${e.name}=${e.value}')
        .join('; ');
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

  String? get introMDimage {
    final EhConfigService ehConfigService = Get.find();

    // 匹配R18g
    final regR18g = RegExp(r'!\[((\S+)?)\]\(##\s+?"(.+?)"\)');

    // 匹配R18和R18g
    final regR18And18g = RegExp(r'!\[((\S+)?)\]\(##?\s+?"(.+?)"\)');

    // 匹配所有级别图片
    final regAll = RegExp(r'!\[((\S+)?)\]\((.+?)\)');

    final lv = ehConfigService.tagIntroImgLv.value;

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
        break;
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
  EhConfigService get _ehConfigService => Get.find();

  String get linkRedirect {
    if (_ehConfigService.linkRedirect) {
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
      xn[_index] = xn[_index].copyWith(value: value);
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
    final _map = <String, String>{};
    for (final _fav in favorites) {
      if (_fav.ser != null) {
        _map[_fav.ser!] = _fav.value ?? '';
      }
    }
    return _map;
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
      xn[_index] = xn[_index].copyWith(value: value);
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
      xl[_index] = xl[_index].copyWith(value: value);
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
      favorites[_index] = favorites[_index].copyWith(value: value);
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
    final _gallerysF = gallerys?.map((e) async {
          final _simpleTagsF = e.simpleTags?.map((e) async {
                final tr = await trController.getTagTranslateText(e.text!);
                return e.copyWith(translat: tr ?? e.text);
              }) ??
              [];
          final _simpleTags = Future.wait<SimpleTag>(_simpleTagsF);
          return e.copyWith(simpleTags: await _simpleTags);
        }) ??
        [];

    final _gallerys = Future.wait(_gallerysF);
    return copyWith(gallerys: await _gallerys);
  }
}

extension ExtEhMytags on EhMytags {
  Future<List<EhUsertag>> get qryFullTagTranslate async {
    final trController = Get.find<TagTransController>();
    final _usertagsFuture = usertags?.map((e) async {
          final tr = await trController.getTranTagWithNameSpase(e.title);
          return e.copyWith(translate: tr);
        }) ??
        [];

    final _userTags = Future.wait(_usertagsFuture);
    return await _userTags;
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
      if (searchGalleryName) 'f_sname': 'on',
      if (searchGalleryTags) 'f_stags': 'on',
      if (searchGalleryDesc) 'f_sdesc': 'on',
      if (searchToreenFilenames) 'f_storr': 'on',
      if (onlyShowWhithTorrents) 'f_sto': 'on',
      if (searchLowPowerTags) 'f_sdt1': 'on',
      if (searchDownvotedTags) 'f_sdt2': 'on',
      if (searchExpunged) 'f_sh': 'on',
      if (searchWithminRating) 'f_sr': 'on',
      if (searchWithminRating) 'f_srdd': minRating,
      if (searchBetweenpage) 'f_sp': 'on',
      if (searchBetweenpage && startPage.isNotEmpty) 'f_spf': startPage,
      if (searchBetweenpage && endPage.isNotEmpty) 'f_spt': endPage,
      if (disableDFLanguage) 'f_sfl': 'on',
      if (disableDFUploader) 'f_sfu': 'on',
      if (disableDFTags) 'f_sft': 'on',
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
      copyWith(listTypeValue: value.name);

  ListModeEnum get listMode =>
      EnumToString.fromString(ListModeEnum.values, listModeValue ?? '') ??
      ListModeEnum.global;

  String get syncFileName =>
      '$name$kGroupSeparator$uuid$kGroupSeparator${lastEditTime ?? '0'}';
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
