import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class GalleryProvider {

  const GalleryProvider({
    this.gid,
    this.token,
    this.showKey,
    this.url,
    this.imgUrl,
    this.imgUrlL,
    this.imgHeight,
    this.imgWidth,
    this.japaneseTitle,
    this.englishTitle,
    this.category,
    this.uploader,
    this.posted,
    this.language,
    this.filecount,
    this.rating,
    this.ratingCount,
    this.torrentcount,
    this.torrents,
    this.filesize,
    this.filesizeText,
    this.visible,
    this.parent,
    this.parentHref,
    this.ratingFallBack,
    this.numberOfReviews,
    this.postTime,
    this.favoritedCount,
    this.favTitle,
    this.favcat,
    this.localFav,
    this.simpleTags,
    this.tagsFromApi,
    this.translated,
    this.tagGroup,
    this.galleryComment,
    this.galleryImages,
    this.chapter,
    this.apikey,
    this.apiuid,
    this.isRatinged,
    this.colorRating,
    this.archiverLink,
    this.torrentLink,
    this.lastViewTime,
    this.pageOfList,
    this.favNote,
    this.expunged,
  });

  final String? gid;
  final String? token;
  final String? showKey;
  final String? url;
  final String? imgUrl;
  final String? imgUrlL;
  final int? imgHeight;
  final int? imgWidth;
  final String? japaneseTitle;
  final String? englishTitle;
  final String? category;
  final String? uploader;
  final String? posted;
  final String? language;
  final String? filecount;
  final double? rating;
  final String? ratingCount;
  final String? torrentcount;
  final List<GalleryTorrent>? torrents;
  final int? filesize;
  final String? filesizeText;
  final String? visible;
  final String? parent;
  final String? parentHref;
  final double? ratingFallBack;
  final String? numberOfReviews;
  final String? postTime;
  final String? favoritedCount;
  final String? favTitle;
  final String? favcat;
  final bool? localFav;
  final List<SimpleTag>? simpleTags;
  final List<dynamic>? tagsFromApi;
  final String? translated;
  final List<TagGroup>? tagGroup;
  final List<GalleryComment>? galleryComment;
  final List<GalleryImage>? galleryImages;
  final List<Chapter>? chapter;
  final String? apikey;
  final String? apiuid;
  final bool? isRatinged;
  final String? colorRating;
  final String? archiverLink;
  final String? torrentLink;
  final int? lastViewTime;
  final int? pageOfList;
  final String? favNote;
  final bool? expunged;

  factory GalleryProvider.fromJson(Map<String,dynamic> json) => GalleryProvider(
    gid: json['gid']?.toString(),
    token: json['token']?.toString(),
    showKey: json['showKey']?.toString(),
    url: json['url']?.toString(),
    imgUrl: json['imgUrl']?.toString(),
    imgUrlL: json['imgUrlL']?.toString(),
    imgHeight: json['imgHeight'] != null ? int.tryParse('${json['imgHeight']}') ?? 0 : null,
    imgWidth: json['imgWidth'] != null ? int.tryParse('${json['imgWidth']}') ?? 0 : null,
    japaneseTitle: json['japaneseTitle']?.toString(),
    englishTitle: json['englishTitle']?.toString(),
    category: json['category']?.toString(),
    uploader: json['uploader']?.toString(),
    posted: json['posted']?.toString(),
    language: json['language']?.toString(),
    filecount: json['filecount']?.toString(),
    rating: json['rating'] != null ? double.tryParse('${json['rating']}') ?? 0.0 : null,
    ratingCount: json['ratingCount']?.toString(),
    torrentcount: json['torrentcount']?.toString(),
    torrents: json['torrents'] != null ? (json['torrents'] as List? ?? []).map((e) => GalleryTorrent.fromJson(e as Map<String, dynamic>)).toList() : null,
    filesize: json['filesize'] != null ? int.tryParse('${json['filesize']}') ?? 0 : null,
    filesizeText: json['filesizeText']?.toString(),
    visible: json['visible']?.toString(),
    parent: json['parent']?.toString(),
    parentHref: json['parentHref']?.toString(),
    ratingFallBack: json['ratingFallBack'] != null ? double.tryParse('${json['ratingFallBack']}') ?? 0.0 : null,
    numberOfReviews: json['numberOfReviews']?.toString(),
    postTime: json['postTime']?.toString(),
    favoritedCount: json['favoritedCount']?.toString(),
    favTitle: json['favTitle']?.toString(),
    favcat: json['favcat']?.toString(),
    localFav: json['localFav'] != null ? bool.tryParse('${json['localFav']}', caseSensitive: false) ?? false : null,
    simpleTags: json['simpleTags'] != null ? (json['simpleTags'] as List? ?? []).map((e) => SimpleTag.fromJson(e as Map<String, dynamic>)).toList() : null,
    tagsFromApi: json['tagsFromApi'] != null ? (json['tagsFromApi'] as List? ?? []).map((e) => e as dynamic).toList() : null,
    translated: json['translated']?.toString(),
    tagGroup: json['tagGroup'] != null ? (json['tagGroup'] as List? ?? []).map((e) => TagGroup.fromJson(e as Map<String, dynamic>)).toList() : null,
    galleryComment: json['galleryComment'] != null ? (json['galleryComment'] as List? ?? []).map((e) => GalleryComment.fromJson(e as Map<String, dynamic>)).toList() : null,
    galleryImages: json['galleryImages'] != null ? (json['galleryImages'] as List? ?? []).map((e) => GalleryImage.fromJson(e as Map<String, dynamic>)).toList() : null,
    chapter: json['chapter'] != null ? (json['chapter'] as List? ?? []).map((e) => Chapter.fromJson(e as Map<String, dynamic>)).toList() : null,
    apikey: json['apikey']?.toString(),
    apiuid: json['apiuid']?.toString(),
    isRatinged: json['isRatinged'] != null ? bool.tryParse('${json['isRatinged']}', caseSensitive: false) ?? false : null,
    colorRating: json['colorRating']?.toString(),
    archiverLink: json['archiverLink']?.toString(),
    torrentLink: json['torrentLink']?.toString(),
    lastViewTime: json['lastViewTime'] != null ? int.tryParse('${json['lastViewTime']}') ?? 0 : null,
    pageOfList: json['pageOfList'] != null ? int.tryParse('${json['pageOfList']}') ?? 0 : null,
    favNote: json['favNote']?.toString(),
    expunged: json['expunged'] != null ? bool.tryParse('${json['expunged']}', caseSensitive: false) ?? false : null
  );
  
  Map<String, dynamic> toJson() => {
    'gid': gid,
    'token': token,
    'showKey': showKey,
    'url': url,
    'imgUrl': imgUrl,
    'imgUrlL': imgUrlL,
    'imgHeight': imgHeight,
    'imgWidth': imgWidth,
    'japaneseTitle': japaneseTitle,
    'englishTitle': englishTitle,
    'category': category,
    'uploader': uploader,
    'posted': posted,
    'language': language,
    'filecount': filecount,
    'rating': rating,
    'ratingCount': ratingCount,
    'torrentcount': torrentcount,
    'torrents': torrents?.map((e) => e.toJson()).toList(),
    'filesize': filesize,
    'filesizeText': filesizeText,
    'visible': visible,
    'parent': parent,
    'parentHref': parentHref,
    'ratingFallBack': ratingFallBack,
    'numberOfReviews': numberOfReviews,
    'postTime': postTime,
    'favoritedCount': favoritedCount,
    'favTitle': favTitle,
    'favcat': favcat,
    'localFav': localFav,
    'simpleTags': simpleTags?.map((e) => e.toJson()).toList(),
    'tagsFromApi': tagsFromApi?.map((e) => e.toString()).toList(),
    'translated': translated,
    'tagGroup': tagGroup?.map((e) => e.toJson()).toList(),
    'galleryComment': galleryComment?.map((e) => e.toJson()).toList(),
    'galleryImages': galleryImages?.map((e) => e.toJson()).toList(),
    'chapter': chapter?.map((e) => e.toJson()).toList(),
    'apikey': apikey,
    'apiuid': apiuid,
    'isRatinged': isRatinged,
    'colorRating': colorRating,
    'archiverLink': archiverLink,
    'torrentLink': torrentLink,
    'lastViewTime': lastViewTime,
    'pageOfList': pageOfList,
    'favNote': favNote,
    'expunged': expunged
  };

  GalleryProvider clone() => GalleryProvider(
    gid: gid,
    token: token,
    showKey: showKey,
    url: url,
    imgUrl: imgUrl,
    imgUrlL: imgUrlL,
    imgHeight: imgHeight,
    imgWidth: imgWidth,
    japaneseTitle: japaneseTitle,
    englishTitle: englishTitle,
    category: category,
    uploader: uploader,
    posted: posted,
    language: language,
    filecount: filecount,
    rating: rating,
    ratingCount: ratingCount,
    torrentcount: torrentcount,
    torrents: torrents?.map((e) => e.clone()).toList(),
    filesize: filesize,
    filesizeText: filesizeText,
    visible: visible,
    parent: parent,
    parentHref: parentHref,
    ratingFallBack: ratingFallBack,
    numberOfReviews: numberOfReviews,
    postTime: postTime,
    favoritedCount: favoritedCount,
    favTitle: favTitle,
    favcat: favcat,
    localFav: localFav,
    simpleTags: simpleTags?.map((e) => e.clone()).toList(),
    tagsFromApi: tagsFromApi?.toList(),
    translated: translated,
    tagGroup: tagGroup?.map((e) => e.clone()).toList(),
    galleryComment: galleryComment?.map((e) => e.clone()).toList(),
    galleryImages: galleryImages?.map((e) => e.clone()).toList(),
    chapter: chapter?.map((e) => e.clone()).toList(),
    apikey: apikey,
    apiuid: apiuid,
    isRatinged: isRatinged,
    colorRating: colorRating,
    archiverLink: archiverLink,
    torrentLink: torrentLink,
    lastViewTime: lastViewTime,
    pageOfList: pageOfList,
    favNote: favNote,
    expunged: expunged
  );


  GalleryProvider copyWith({
    Optional<String?>? gid,
    Optional<String?>? token,
    Optional<String?>? showKey,
    Optional<String?>? url,
    Optional<String?>? imgUrl,
    Optional<String?>? imgUrlL,
    Optional<int?>? imgHeight,
    Optional<int?>? imgWidth,
    Optional<String?>? japaneseTitle,
    Optional<String?>? englishTitle,
    Optional<String?>? category,
    Optional<String?>? uploader,
    Optional<String?>? posted,
    Optional<String?>? language,
    Optional<String?>? filecount,
    Optional<double?>? rating,
    Optional<String?>? ratingCount,
    Optional<String?>? torrentcount,
    Optional<List<GalleryTorrent>?>? torrents,
    Optional<int?>? filesize,
    Optional<String?>? filesizeText,
    Optional<String?>? visible,
    Optional<String?>? parent,
    Optional<String?>? parentHref,
    Optional<double?>? ratingFallBack,
    Optional<String?>? numberOfReviews,
    Optional<String?>? postTime,
    Optional<String?>? favoritedCount,
    Optional<String?>? favTitle,
    Optional<String?>? favcat,
    Optional<bool?>? localFav,
    Optional<List<SimpleTag>?>? simpleTags,
    Optional<List<dynamic>?>? tagsFromApi,
    Optional<String?>? translated,
    Optional<List<TagGroup>?>? tagGroup,
    Optional<List<GalleryComment>?>? galleryComment,
    Optional<List<GalleryImage>?>? galleryImages,
    Optional<List<Chapter>?>? chapter,
    Optional<String?>? apikey,
    Optional<String?>? apiuid,
    Optional<bool?>? isRatinged,
    Optional<String?>? colorRating,
    Optional<String?>? archiverLink,
    Optional<String?>? torrentLink,
    Optional<int?>? lastViewTime,
    Optional<int?>? pageOfList,
    Optional<String?>? favNote,
    Optional<bool?>? expunged
  }) => GalleryProvider(
    gid: checkOptional(gid, () => this.gid),
    token: checkOptional(token, () => this.token),
    showKey: checkOptional(showKey, () => this.showKey),
    url: checkOptional(url, () => this.url),
    imgUrl: checkOptional(imgUrl, () => this.imgUrl),
    imgUrlL: checkOptional(imgUrlL, () => this.imgUrlL),
    imgHeight: checkOptional(imgHeight, () => this.imgHeight),
    imgWidth: checkOptional(imgWidth, () => this.imgWidth),
    japaneseTitle: checkOptional(japaneseTitle, () => this.japaneseTitle),
    englishTitle: checkOptional(englishTitle, () => this.englishTitle),
    category: checkOptional(category, () => this.category),
    uploader: checkOptional(uploader, () => this.uploader),
    posted: checkOptional(posted, () => this.posted),
    language: checkOptional(language, () => this.language),
    filecount: checkOptional(filecount, () => this.filecount),
    rating: checkOptional(rating, () => this.rating),
    ratingCount: checkOptional(ratingCount, () => this.ratingCount),
    torrentcount: checkOptional(torrentcount, () => this.torrentcount),
    torrents: checkOptional(torrents, () => this.torrents),
    filesize: checkOptional(filesize, () => this.filesize),
    filesizeText: checkOptional(filesizeText, () => this.filesizeText),
    visible: checkOptional(visible, () => this.visible),
    parent: checkOptional(parent, () => this.parent),
    parentHref: checkOptional(parentHref, () => this.parentHref),
    ratingFallBack: checkOptional(ratingFallBack, () => this.ratingFallBack),
    numberOfReviews: checkOptional(numberOfReviews, () => this.numberOfReviews),
    postTime: checkOptional(postTime, () => this.postTime),
    favoritedCount: checkOptional(favoritedCount, () => this.favoritedCount),
    favTitle: checkOptional(favTitle, () => this.favTitle),
    favcat: checkOptional(favcat, () => this.favcat),
    localFav: checkOptional(localFav, () => this.localFav),
    simpleTags: checkOptional(simpleTags, () => this.simpleTags),
    tagsFromApi: checkOptional(tagsFromApi, () => this.tagsFromApi),
    translated: checkOptional(translated, () => this.translated),
    tagGroup: checkOptional(tagGroup, () => this.tagGroup),
    galleryComment: checkOptional(galleryComment, () => this.galleryComment),
    galleryImages: checkOptional(galleryImages, () => this.galleryImages),
    chapter: checkOptional(chapter, () => this.chapter),
    apikey: checkOptional(apikey, () => this.apikey),
    apiuid: checkOptional(apiuid, () => this.apiuid),
    isRatinged: checkOptional(isRatinged, () => this.isRatinged),
    colorRating: checkOptional(colorRating, () => this.colorRating),
    archiverLink: checkOptional(archiverLink, () => this.archiverLink),
    torrentLink: checkOptional(torrentLink, () => this.torrentLink),
    lastViewTime: checkOptional(lastViewTime, () => this.lastViewTime),
    pageOfList: checkOptional(pageOfList, () => this.pageOfList),
    favNote: checkOptional(favNote, () => this.favNote),
    expunged: checkOptional(expunged, () => this.expunged),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is GalleryProvider && gid == other.gid && token == other.token && showKey == other.showKey && url == other.url && imgUrl == other.imgUrl && imgUrlL == other.imgUrlL && imgHeight == other.imgHeight && imgWidth == other.imgWidth && japaneseTitle == other.japaneseTitle && englishTitle == other.englishTitle && category == other.category && uploader == other.uploader && posted == other.posted && language == other.language && filecount == other.filecount && rating == other.rating && ratingCount == other.ratingCount && torrentcount == other.torrentcount && torrents == other.torrents && filesize == other.filesize && filesizeText == other.filesizeText && visible == other.visible && parent == other.parent && parentHref == other.parentHref && ratingFallBack == other.ratingFallBack && numberOfReviews == other.numberOfReviews && postTime == other.postTime && favoritedCount == other.favoritedCount && favTitle == other.favTitle && favcat == other.favcat && localFav == other.localFav && simpleTags == other.simpleTags && tagsFromApi == other.tagsFromApi && translated == other.translated && tagGroup == other.tagGroup && galleryComment == other.galleryComment && galleryImages == other.galleryImages && chapter == other.chapter && apikey == other.apikey && apiuid == other.apiuid && isRatinged == other.isRatinged && colorRating == other.colorRating && archiverLink == other.archiverLink && torrentLink == other.torrentLink && lastViewTime == other.lastViewTime && pageOfList == other.pageOfList && favNote == other.favNote && expunged == other.expunged;

  @override
  int get hashCode => gid.hashCode ^ token.hashCode ^ showKey.hashCode ^ url.hashCode ^ imgUrl.hashCode ^ imgUrlL.hashCode ^ imgHeight.hashCode ^ imgWidth.hashCode ^ japaneseTitle.hashCode ^ englishTitle.hashCode ^ category.hashCode ^ uploader.hashCode ^ posted.hashCode ^ language.hashCode ^ filecount.hashCode ^ rating.hashCode ^ ratingCount.hashCode ^ torrentcount.hashCode ^ torrents.hashCode ^ filesize.hashCode ^ filesizeText.hashCode ^ visible.hashCode ^ parent.hashCode ^ parentHref.hashCode ^ ratingFallBack.hashCode ^ numberOfReviews.hashCode ^ postTime.hashCode ^ favoritedCount.hashCode ^ favTitle.hashCode ^ favcat.hashCode ^ localFav.hashCode ^ simpleTags.hashCode ^ tagsFromApi.hashCode ^ translated.hashCode ^ tagGroup.hashCode ^ galleryComment.hashCode ^ galleryImages.hashCode ^ chapter.hashCode ^ apikey.hashCode ^ apiuid.hashCode ^ isRatinged.hashCode ^ colorRating.hashCode ^ archiverLink.hashCode ^ torrentLink.hashCode ^ lastViewTime.hashCode ^ pageOfList.hashCode ^ favNote.hashCode ^ expunged.hashCode;
}
