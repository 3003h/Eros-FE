import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/store/floor/entity/tag_translat.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'common/controller/tag_trans_controller.dart';
import 'models/index.dart';

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
}

extension ExtCommentSpan on GalleryCommentSpan {
  CommentSpanType get sType =>
      EnumToString.fromString(CommentSpanType.values, type ?? '') ??
      CommentSpanType.text;

  // set sType(CommentSpanType val) => type = EnumToString.convertToString(val);
  GalleryCommentSpan copyWithSpanType(CommentSpanType val) =>
      copyWith(type: EnumToString.convertToString(val));
}

extension ExtItem on GalleryItem {
  Map<int, GalleryImage> get imageMap =>
      {for (GalleryImage v in galleryImages ?? []) v.ser: v};

  GalleryItem copyWithAll(GalleryItem item) {
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
        pageOfList: item.pageOfList);
  }
}

extension ExtUser on User {
  List<String> get _cookieStrList => cookie?.split(';') ?? [];
  List<Cookie> get _cookies =>
      _cookieStrList.map((e) => Cookie.fromSetCookieValue(e)).toList();

  String get memberIdFromCookie => _cookies
      .where((Cookie element) => element.name == 'ipb_member_id')
      .first
      .value;

  String get passHashFromCookie => _cookies
      .where((Cookie element) => element.name == 'ipb_pass_hash')
      .first
      .value;

  String get igneousFromCookie =>
      _cookies.where((Cookie element) => element.name == 'igneous').first.value;

  String get memberIdFB => memberId ?? memberIdFromCookie;

  String get passHashFB => passHash ?? passHashFromCookie;

  String get igneousFB => igneous ?? igneousFromCookie;
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

extension ExtString on String {}

extension ExSearch on String {
  String get shortName {
    if (this != 'misc') {
      return substring(0, 1);
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

  Map<String, String> get xlMap {
    final _map = <String, String>{};
    for (final _x in xl) {
      if (_x.ser != null) {
        _map[_x.ser!] = _x.value ?? '';
      }
    }
    return _map;
  }

  void setXn(String ser, String? value) {
    if (value == null) {
      return;
    }

    final _index = xn.indexWhere((element) => element.ser == ser);
    if (_index > -1) {
      xn[_index] = xn[_index].copyWith(value: value);
    } else {
      xn.add(EhSettingItem(ser: ser, value: value, name: 'xn'));
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
      xl.add(EhSettingItem(ser: ser, value: value, name: 'xl'));
    }
  }

  //
  String? get xnReclass => xnMap['1'];
  set xnReclass(String? val) => setXn('1', val);

  String? get xnLanguage => xnMap['2'];
  set xnLanguage(String? val) => setXn('2', val);

  String? get xnParody => xnMap['3'];
  set xnParody(String? val) => setXn('3', val);

  String? get xnCharacter => xnMap['4'];
  set xnCharacter(String? val) => setXn('4', val);

  String? get xnGroup => xnMap['5'];
  set xnGroup(String? val) => setXn('5', val);

  String? get xnArtist => xnMap['6'];
  set xnArtist(String? val) => setXn('6', val);

  String? get xnMale => xnMap['7'];
  set xnMale(String? val) => setXn('7', val);

  String? get xnFemale => xnMap['8'];
  set xnFemale(String? val) => setXn('1', val);

  Map get postParam {
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
      if (favorites0 != null) 'favorite_0': favorites0,
      if (favorites1 != null) 'favorite_1': favorites1,
      if (favorites2 != null) 'favorite_2': favorites2,
      if (favorites3 != null) 'favorite_3': favorites3,
      if (favorites4 != null) 'favorite_4': favorites4,
      if (favorites5 != null) 'favorite_5': favorites5,
      if (favorites6 != null) 'favorite_6': favorites6,
      if (favorites7 != null) 'favorite_7': favorites7,
      if (favorites8 != null) 'favorite_8': favorites8,
      if (favorites9 != null) 'favorite_9': favorites9,
      if (sortOrderFavorites != null) 'fs': sortOrderFavorites,
      if (ratings != null) 'ru': ratings,

      // if (xnReclass != null) 'xn_1': xnReclass,
      // if (xnLanguage != null) 'xn_2': xnLanguage,
      // if (xnParody != null) 'xn_3': xnParody,
      // if (xnCharacter != null) 'xn_4': xnCharacter,
      // if (xnGroup != null) 'xn_5': xnGroup,
      // if (xnArtist != null) 'xn_6': xnArtist,
      // if (xnMale != null) 'xn_7': xnMale,
      // if (xnFemale != null) 'xn_8': xnFemale,

      // if (xlJpnTl1024 != null) 'xl_1024': xlJpnTl1024,
      // if (xlJpnRw2048 != null) 'xl_2048': xlJpnRw2048,
      // if (xlEnOr1 != null) 'xl_1': xlEnOr1,
      // if (xlEnTr1025 != null) 'xl_1025': xlEnTr1025,
      // if (xlEnRe2049 != null) 'xl_2049': xlEnRe2049,
      // if (xlChiOr10 != null) 'xl_10': xlChiOr10,
      // if (xlChiTr1034 != null) 'xl_1034': xlChiTr1034,
      // if (xlChiRe2058 != null) 'xl_2058': xlChiRe2058,
      // if (xlDutOr20 != null) 'xl_20': xlDutOr20,
      // if (xlDutTr1044 != null) 'xl_1044': xlDutTr1044,
      // if (xlDutRe2068 != null) 'xl_2068': xlDutRe2068,
      // if (xlFrOr30 != null) 'xl_30': xlFrOr30,
      // if (xlFrTr1054 != null) 'xl_1054': xlFrTr1054,
      // if (xlFrRe2078 != null) 'xl_2078': xlFrRe2078,
      // if (xlGmOr40 != null) 'xl_40': xlGmOr40,
      // if (xlGmTr1064 != null) 'xl_1064': xlGmTr1064,
      // if (xlGmRe2088 != null) 'xl_2088': xlGmRe2088,
      // if (xlHungOr50 != null) 'xl_50': xlHungOr50,
      // if (xlHungTr1074 != null) 'xl_1074': xlHungTr1074,
      // if (xlHungRe2098 != null) 'xl_2098': xlHungRe2098,
      // if (xlItaOr60 != null) 'xl_60': xlItaOr60,
      // if (xlItaTr1084 != null) 'xl_1084': xlItaTr1084,
      // if (xlItaRe2108 != null) 'xl_2108': xlItaRe2108,
      // if (xlKrOr70 != null) 'xl_70': xlKrOr70,
      // if (xlKrTr1094 != null) 'xl_1094': xlKrTr1094,
      // if (xlKrRe2118 != null) 'xl_2118': xlKrRe2118,
      // if (xlPoliOr80 != null) 'xl_80': xlPoliOr80,
      // if (xlPoliTr1104 != null) 'xl_1104': xlPoliTr1104,
      // if (xlPoliRe2128 != null) 'xl_2128': xlPoliRe2128,
      // if (xlPorOr90 != null) 'xl_90': xlPorOr90,
      // if (xlPorTr1114 != null) 'xl_1114': xlPorTr1114,
      // if (xlPorRe2138 != null) 'xl_2138': xlPorRe2138,
      // if (xlRuOr100 != null) 'xl_100': xlRuOr100,
      // if (xlRuTr1124 != null) 'xl_1124': xlRuTr1124,
      // if (xlRuRe2148 != null) 'xl_2148': xlRuRe2148,
      // if (xlSpaOr110 != null) 'xl_110': xlSpaOr110,
      // if (xlSpaTr1134 != null) 'xl_1134': xlSpaTr1134,
      // if (xlSpaRe2158 != null) 'xl_2158': xlSpaRe2158,
      // if (xlThaiOr120 != null) 'xl_120': xlThaiOr120,
      // if (xlThaiTr1144 != null) 'xl_1144': xlThaiTr1144,
      // if (xlThaiRe2168 != null) 'xl_2168': xlThaiRe2168,
      // if (xlVieOr130 != null) 'xl_130': xlVieOr130,
      // if (xlVieTr1154 != null) 'xl_1154': xlVieTr1154,
      // if (xlVieRe2178 != null) 'xl_2178': xlVieRe2178,
      // if (xlNaOr254 != null) 'xl_254': xlNaOr254,
      // if (xlNaTr1278 != null) 'xl_1278': xlNaTr1278,
      // if (xlNaRe2302 != null) 'xl_2302': xlNaRe2302,
      // if (xlOthOr255 != null) 'xl_255': xlOthOr255,
      // if (xlOthTr1279 != null) 'xl_1279': xlOthTr1279,
      // if (xlOthRe2303 != null) 'xl_2303': xlOthRe2303,

      if (tagFilteringThreshold != null) 'ft': tagFilteringThreshold,
      if (tagWatchingThreshold != null) 'wt': tagWatchingThreshold,
      if (excludedLanguages != null) '': excludedLanguages,
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
    };

    for (final _xn in xn) {
      param['xn_${_xn.ser}'] = _xn.value;
    }

    for (final _xl in xl) {
      param['xl_${_xl.ser}'] = _xl.value;
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
