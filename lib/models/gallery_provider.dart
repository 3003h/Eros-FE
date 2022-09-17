import 'package:flutter/foundation.dart';
import 'gallery_torrent.dart';
import 'simple_tag.dart';
import 'tag_group.dart';
import 'gallery_comment.dart';
import 'gallery_image.dart';
import 'chapter.dart';

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
  final double? imgHeight;
  final double? imgWidth;
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
    gid: json['gid'] != null ? json['gid'] as String : null,
    token: json['token'] != null ? json['token'] as String : null,
    showKey: json['showKey'] != null ? json['showKey'] as String : null,
    url: json['url'] != null ? json['url'] as String : null,
    imgUrl: json['imgUrl'] != null ? json['imgUrl'] as String : null,
    imgUrlL: json['imgUrlL'] != null ? json['imgUrlL'] as String : null,
    imgHeight: json['imgHeight'] != null ? json['imgHeight'] as double : null,
    imgWidth: json['imgWidth'] != null ? json['imgWidth'] as double : null,
    japaneseTitle: json['japaneseTitle'] != null ? json['japaneseTitle'] as String : null,
    englishTitle: json['englishTitle'] != null ? json['englishTitle'] as String : null,
    category: json['category'] != null ? json['category'] as String : null,
    uploader: json['uploader'] != null ? json['uploader'] as String : null,
    posted: json['posted'] != null ? json['posted'] as String : null,
    language: json['language'] != null ? json['language'] as String : null,
    filecount: json['filecount'] != null ? json['filecount'] as String : null,
    rating: json['rating'] != null ? json['rating'] as double : null,
    ratingCount: json['ratingCount'] != null ? json['ratingCount'] as String : null,
    torrentcount: json['torrentcount'] != null ? json['torrentcount'] as String : null,
    torrents: json['torrents'] != null ? (json['torrents'] as List? ?? []).map((e) => GalleryTorrent.fromJson(e as Map<String, dynamic>)).toList() : null,
    filesize: json['filesize'] != null ? json['filesize'] as int : null,
    filesizeText: json['filesizeText'] != null ? json['filesizeText'] as String : null,
    visible: json['visible'] != null ? json['visible'] as String : null,
    parent: json['parent'] != null ? json['parent'] as String : null,
    ratingFallBack: json['ratingFallBack'] != null ? json['ratingFallBack'] as double : null,
    numberOfReviews: json['numberOfReviews'] != null ? json['numberOfReviews'] as String : null,
    postTime: json['postTime'] != null ? json['postTime'] as String : null,
    favoritedCount: json['favoritedCount'] != null ? json['favoritedCount'] as String : null,
    favTitle: json['favTitle'] != null ? json['favTitle'] as String : null,
    favcat: json['favcat'] != null ? json['favcat'] as String : null,
    localFav: json['localFav'] != null ? json['localFav'] as bool : null,
    simpleTags: json['simpleTags'] != null ? (json['simpleTags'] as List? ?? []).map((e) => SimpleTag.fromJson(e as Map<String, dynamic>)).toList() : null,
    tagsFromApi: json['tagsFromApi'] != null ? (json['tagsFromApi'] as List? ?? []).map((e) => e as dynamic).toList() : null,
    translated: json['translated'] != null ? json['translated'] as String : null,
    tagGroup: json['tagGroup'] != null ? (json['tagGroup'] as List? ?? []).map((e) => TagGroup.fromJson(e as Map<String, dynamic>)).toList() : null,
    galleryComment: json['galleryComment'] != null ? (json['galleryComment'] as List? ?? []).map((e) => GalleryComment.fromJson(e as Map<String, dynamic>)).toList() : null,
    galleryImages: json['galleryImages'] != null ? (json['galleryImages'] as List? ?? []).map((e) => GalleryImage.fromJson(e as Map<String, dynamic>)).toList() : null,
    chapter: json['chapter'] != null ? (json['chapter'] as List? ?? []).map((e) => Chapter.fromJson(e as Map<String, dynamic>)).toList() : null,
    apikey: json['apikey'] != null ? json['apikey'] as String : null,
    apiuid: json['apiuid'] != null ? json['apiuid'] as String : null,
    isRatinged: json['isRatinged'] != null ? json['isRatinged'] as bool : null,
    colorRating: json['colorRating'] != null ? json['colorRating'] as String : null,
    archiverLink: json['archiverLink'] != null ? json['archiverLink'] as String : null,
    torrentLink: json['torrentLink'] != null ? json['torrentLink'] as String : null,
    lastViewTime: json['lastViewTime'] != null ? json['lastViewTime'] as int : null,
    pageOfList: json['pageOfList'] != null ? json['pageOfList'] as int : null,
    favNote: json['favNote'] != null ? json['favNote'] as String : null,
    expunged: json['expunged'] != null ? json['expunged'] as bool : null
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
    String? gid,
    String? token,
    String? showKey,
    String? url,
    String? imgUrl,
    String? imgUrlL,
    double? imgHeight,
    double? imgWidth,
    String? japaneseTitle,
    String? englishTitle,
    String? category,
    String? uploader,
    String? posted,
    String? language,
    String? filecount,
    double? rating,
    String? ratingCount,
    String? torrentcount,
    List<GalleryTorrent>? torrents,
    int? filesize,
    String? filesizeText,
    String? visible,
    String? parent,
    double? ratingFallBack,
    String? numberOfReviews,
    String? postTime,
    String? favoritedCount,
    String? favTitle,
    String? favcat,
    bool? localFav,
    List<SimpleTag>? simpleTags,
    List<dynamic>? tagsFromApi,
    String? translated,
    List<TagGroup>? tagGroup,
    List<GalleryComment>? galleryComment,
    List<GalleryImage>? galleryImages,
    List<Chapter>? chapter,
    String? apikey,
    String? apiuid,
    bool? isRatinged,
    String? colorRating,
    String? archiverLink,
    String? torrentLink,
    int? lastViewTime,
    int? pageOfList,
    String? favNote,
    bool? expunged
  }) => GalleryProvider(
    gid: gid ?? this.gid,
    token: token ?? this.token,
    showKey: showKey ?? this.showKey,
    url: url ?? this.url,
    imgUrl: imgUrl ?? this.imgUrl,
    imgUrlL: imgUrlL ?? this.imgUrlL,
    imgHeight: imgHeight ?? this.imgHeight,
    imgWidth: imgWidth ?? this.imgWidth,
    japaneseTitle: japaneseTitle ?? this.japaneseTitle,
    englishTitle: englishTitle ?? this.englishTitle,
    category: category ?? this.category,
    uploader: uploader ?? this.uploader,
    posted: posted ?? this.posted,
    language: language ?? this.language,
    filecount: filecount ?? this.filecount,
    rating: rating ?? this.rating,
    ratingCount: ratingCount ?? this.ratingCount,
    torrentcount: torrentcount ?? this.torrentcount,
    torrents: torrents ?? this.torrents,
    filesize: filesize ?? this.filesize,
    filesizeText: filesizeText ?? this.filesizeText,
    visible: visible ?? this.visible,
    parent: parent ?? this.parent,
    ratingFallBack: ratingFallBack ?? this.ratingFallBack,
    numberOfReviews: numberOfReviews ?? this.numberOfReviews,
    postTime: postTime ?? this.postTime,
    favoritedCount: favoritedCount ?? this.favoritedCount,
    favTitle: favTitle ?? this.favTitle,
    favcat: favcat ?? this.favcat,
    localFav: localFav ?? this.localFav,
    simpleTags: simpleTags ?? this.simpleTags,
    tagsFromApi: tagsFromApi ?? this.tagsFromApi,
    translated: translated ?? this.translated,
    tagGroup: tagGroup ?? this.tagGroup,
    galleryComment: galleryComment ?? this.galleryComment,
    galleryImages: galleryImages ?? this.galleryImages,
    chapter: chapter ?? this.chapter,
    apikey: apikey ?? this.apikey,
    apiuid: apiuid ?? this.apiuid,
    isRatinged: isRatinged ?? this.isRatinged,
    colorRating: colorRating ?? this.colorRating,
    archiverLink: archiverLink ?? this.archiverLink,
    torrentLink: torrentLink ?? this.torrentLink,
    lastViewTime: lastViewTime ?? this.lastViewTime,
    pageOfList: pageOfList ?? this.pageOfList,
    favNote: favNote ?? this.favNote,
    expunged: expunged ?? this.expunged,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryProvider && gid == other.gid && token == other.token && showKey == other.showKey && url == other.url && imgUrl == other.imgUrl && imgUrlL == other.imgUrlL && imgHeight == other.imgHeight && imgWidth == other.imgWidth && japaneseTitle == other.japaneseTitle && englishTitle == other.englishTitle && category == other.category && uploader == other.uploader && posted == other.posted && language == other.language && filecount == other.filecount && rating == other.rating && ratingCount == other.ratingCount && torrentcount == other.torrentcount && torrents == other.torrents && filesize == other.filesize && filesizeText == other.filesizeText && visible == other.visible && parent == other.parent && ratingFallBack == other.ratingFallBack && numberOfReviews == other.numberOfReviews && postTime == other.postTime && favoritedCount == other.favoritedCount && favTitle == other.favTitle && favcat == other.favcat && localFav == other.localFav && simpleTags == other.simpleTags && tagsFromApi == other.tagsFromApi && translated == other.translated && tagGroup == other.tagGroup && galleryComment == other.galleryComment && galleryImages == other.galleryImages && chapter == other.chapter && apikey == other.apikey && apiuid == other.apiuid && isRatinged == other.isRatinged && colorRating == other.colorRating && archiverLink == other.archiverLink && torrentLink == other.torrentLink && lastViewTime == other.lastViewTime && pageOfList == other.pageOfList && favNote == other.favNote && expunged == other.expunged;

  @override
  int get hashCode => gid.hashCode ^ token.hashCode ^ showKey.hashCode ^ url.hashCode ^ imgUrl.hashCode ^ imgUrlL.hashCode ^ imgHeight.hashCode ^ imgWidth.hashCode ^ japaneseTitle.hashCode ^ englishTitle.hashCode ^ category.hashCode ^ uploader.hashCode ^ posted.hashCode ^ language.hashCode ^ filecount.hashCode ^ rating.hashCode ^ ratingCount.hashCode ^ torrentcount.hashCode ^ torrents.hashCode ^ filesize.hashCode ^ filesizeText.hashCode ^ visible.hashCode ^ parent.hashCode ^ ratingFallBack.hashCode ^ numberOfReviews.hashCode ^ postTime.hashCode ^ favoritedCount.hashCode ^ favTitle.hashCode ^ favcat.hashCode ^ localFav.hashCode ^ simpleTags.hashCode ^ tagsFromApi.hashCode ^ translated.hashCode ^ tagGroup.hashCode ^ galleryComment.hashCode ^ galleryImages.hashCode ^ chapter.hashCode ^ apikey.hashCode ^ apiuid.hashCode ^ isRatinged.hashCode ^ colorRating.hashCode ^ archiverLink.hashCode ^ torrentLink.hashCode ^ lastViewTime.hashCode ^ pageOfList.hashCode ^ favNote.hashCode ^ expunged.hashCode;
}
