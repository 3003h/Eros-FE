import 'package:flutter/foundation.dart';

import 'gallery_comment.dart';
import 'gallery_preview.dart';
import 'gallery_torrent.dart';
import 'simple_tag.dart';
import 'tag_group.dart';

@immutable
class GalleryItem {
  const GalleryItem({
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
    this.galleryPreview,
    this.apikey,
    this.apiuid,
    this.isRatinged,
    this.colorRating,
    this.archiverLink,
    this.torrentLink,
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
  final List<GalleryPreview>? galleryPreview;
  final String? apikey;
  final String? apiuid;
  final bool? isRatinged;
  final String? colorRating;
  final String? archiverLink;
  final String? torrentLink;

  factory GalleryItem.fromJson(Map<String, dynamic> json) => GalleryItem(
      gid: json['gid'] != null ? json['gid'] as String : null,
      token: json['token'] != null ? json['token'] as String : null,
      showKey: json['show_key'] != null ? json['show_key'] as String : null,
      url: json['url'] != null ? json['url'] as String : null,
      imgUrl: json['img_url'] != null ? json['img_url'] as String : null,
      imgUrlL: json['img_url_l'] != null ? json['img_url_l'] as String : null,
      imgHeight:
          json['img_height'] != null ? json['img_height'] as double : null,
      imgWidth: json['img_width'] != null ? json['img_width'] as double : null,
      japaneseTitle: json['japanese_title'] != null
          ? json['japanese_title'] as String
          : null,
      englishTitle: json['english_title'] != null
          ? json['english_title'] as String
          : null,
      category: json['category'] != null ? json['category'] as String : null,
      uploader: json['uploader'] != null ? json['uploader'] as String : null,
      posted: json['posted'] != null ? json['posted'] as String : null,
      language: json['language'] != null ? json['language'] as String : null,
      filecount: json['filecount'] != null ? json['filecount'] as String : null,
      rating: json['rating'] != null ? json['rating'] as double : null,
      ratingCount:
          json['rating_count'] != null ? json['rating_count'] as String : null,
      torrentcount:
          json['torrentcount'] != null ? json['torrentcount'] as String : null,
      torrents: json['torrents'] != null
          ? (json['torrents'] as List)
              .map((e) => GalleryTorrent.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      filesize: json['filesize'] != null ? json['filesize'] as int : null,
      filesizeText: json['filesize_text'] != null
          ? json['filesize_text'] as String
          : null,
      visible: json['visible'] != null ? json['visible'] as String : null,
      parent: json['parent'] != null ? json['parent'] as String : null,
      ratingFallBack: json['rating_fall_back'] != null
          ? json['rating_fall_back'] as double
          : null,
      numberOfReviews: json['number_of_reviews'] != null
          ? json['number_of_reviews'] as String
          : null,
      postTime: json['post_time'] != null ? json['post_time'] as String : null,
      favoritedCount: json['favorited_count'] != null
          ? json['favorited_count'] as String
          : null,
      favTitle: json['fav_title'] != null ? json['fav_title'] as String : null,
      favcat: json['favcat'] != null ? json['favcat'] as String : null,
      localFav: json['local_fav'] != null ? json['local_fav'] as bool : null,
      simpleTags: json['simple_tags'] != null
          ? (json['simple_tags'] as List)
              .map((e) => SimpleTag.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      tagsFromApi: json['tags_from_api'] != null
          ? json['tags_from_api'] as List<dynamic>
          : null,
      translated:
          json['translated'] != null ? json['translated'] as String : null,
      tagGroup: json['tag_group'] != null
          ? (json['tag_group'] as List)
              .map((e) => TagGroup.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      galleryComment: json['gallery_comment'] != null
          ? (json['gallery_comment'] as List)
              .map((e) => GalleryComment.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      galleryPreview: json['gallery_preview'] != null
          ? (json['gallery_preview'] as List)
              .map((e) => GalleryPreview.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      apikey: json['apikey'] != null ? json['apikey'] as String : null,
      apiuid: json['apiuid'] != null ? json['apiuid'] as String : null,
      isRatinged:
          json['is_ratinged'] != null ? json['is_ratinged'] as bool : null,
      colorRating:
          json['color_rating'] != null ? json['color_rating'] as String : null,
      archiverLink: json['archiver_link'] != null
          ? json['archiver_link'] as String
          : null,
      torrentLink:
          json['torrent_link'] != null ? json['torrent_link'] as String : null);

  Map<String, dynamic> toJson() => {
        'gid': gid,
        'token': token,
        'show_key': showKey,
        'url': url,
        'img_url': imgUrl,
        'img_url_l': imgUrlL,
        'img_height': imgHeight,
        'img_width': imgWidth,
        'japanese_title': japaneseTitle,
        'english_title': englishTitle,
        'category': category,
        'uploader': uploader,
        'posted': posted,
        'language': language,
        'filecount': filecount,
        'rating': rating,
        'rating_count': ratingCount,
        'torrentcount': torrentcount,
        'torrents': torrents?.map((e) => e.toJson()).toList(),
        'filesize': filesize,
        'filesize_text': filesizeText,
        'visible': visible,
        'parent': parent,
        'rating_fall_back': ratingFallBack,
        'number_of_reviews': numberOfReviews,
        'post_time': postTime,
        'favorited_count': favoritedCount,
        'fav_title': favTitle,
        'favcat': favcat,
        'local_fav': localFav,
        'simple_tags': simpleTags?.map((e) => e.toJson()).toList(),
        'tags_from_api': tagsFromApi,
        'translated': translated,
        'tag_group': tagGroup?.map((e) => e.toJson()).toList(),
        'gallery_comment': galleryComment?.map((e) => e.toJson()).toList(),
        'gallery_preview': galleryPreview?.map((e) => e.toJson()).toList(),
        'apikey': apikey,
        'apiuid': apiuid,
        'is_ratinged': isRatinged,
        'color_rating': colorRating,
        'archiver_link': archiverLink,
        'torrent_link': torrentLink
      };

  GalleryItem clone() => GalleryItem(
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
      tagsFromApi: tagsFromApi,
      translated: translated,
      tagGroup: tagGroup?.map((e) => e.clone()).toList(),
      galleryComment: galleryComment?.map((e) => e.clone()).toList(),
      galleryPreview: galleryPreview?.map((e) => e.clone()).toList(),
      apikey: apikey,
      apiuid: apiuid,
      isRatinged: isRatinged,
      colorRating: colorRating,
      archiverLink: archiverLink,
      torrentLink: torrentLink);

  GalleryItem copyWith(
          {String? gid,
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
          List<GalleryPreview>? galleryPreview,
          String? apikey,
          String? apiuid,
          bool? isRatinged,
          String? colorRating,
          String? archiverLink,
          String? torrentLink}) =>
      GalleryItem(
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
        galleryPreview: galleryPreview ?? this.galleryPreview,
        apikey: apikey ?? this.apikey,
        apiuid: apiuid ?? this.apiuid,
        isRatinged: isRatinged ?? this.isRatinged,
        colorRating: colorRating ?? this.colorRating,
        archiverLink: archiverLink ?? this.archiverLink,
        torrentLink: torrentLink ?? this.torrentLink,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryItem &&
          gid == other.gid &&
          token == other.token &&
          showKey == other.showKey &&
          url == other.url &&
          imgUrl == other.imgUrl &&
          imgUrlL == other.imgUrlL &&
          imgHeight == other.imgHeight &&
          imgWidth == other.imgWidth &&
          japaneseTitle == other.japaneseTitle &&
          englishTitle == other.englishTitle &&
          category == other.category &&
          uploader == other.uploader &&
          posted == other.posted &&
          language == other.language &&
          filecount == other.filecount &&
          rating == other.rating &&
          ratingCount == other.ratingCount &&
          torrentcount == other.torrentcount &&
          torrents == other.torrents &&
          filesize == other.filesize &&
          filesizeText == other.filesizeText &&
          visible == other.visible &&
          parent == other.parent &&
          ratingFallBack == other.ratingFallBack &&
          numberOfReviews == other.numberOfReviews &&
          postTime == other.postTime &&
          favoritedCount == other.favoritedCount &&
          favTitle == other.favTitle &&
          favcat == other.favcat &&
          localFav == other.localFav &&
          simpleTags == other.simpleTags &&
          tagsFromApi == other.tagsFromApi &&
          translated == other.translated &&
          tagGroup == other.tagGroup &&
          galleryComment == other.galleryComment &&
          galleryPreview == other.galleryPreview &&
          apikey == other.apikey &&
          apiuid == other.apiuid &&
          isRatinged == other.isRatinged &&
          colorRating == other.colorRating &&
          archiverLink == other.archiverLink &&
          torrentLink == other.torrentLink;

  @override
  int get hashCode =>
      gid.hashCode ^
      token.hashCode ^
      showKey.hashCode ^
      url.hashCode ^
      imgUrl.hashCode ^
      imgUrlL.hashCode ^
      imgHeight.hashCode ^
      imgWidth.hashCode ^
      japaneseTitle.hashCode ^
      englishTitle.hashCode ^
      category.hashCode ^
      uploader.hashCode ^
      posted.hashCode ^
      language.hashCode ^
      filecount.hashCode ^
      rating.hashCode ^
      ratingCount.hashCode ^
      torrentcount.hashCode ^
      torrents.hashCode ^
      filesize.hashCode ^
      filesizeText.hashCode ^
      visible.hashCode ^
      parent.hashCode ^
      ratingFallBack.hashCode ^
      numberOfReviews.hashCode ^
      postTime.hashCode ^
      favoritedCount.hashCode ^
      favTitle.hashCode ^
      favcat.hashCode ^
      localFav.hashCode ^
      simpleTags.hashCode ^
      tagsFromApi.hashCode ^
      translated.hashCode ^
      tagGroup.hashCode ^
      galleryComment.hashCode ^
      galleryPreview.hashCode ^
      apikey.hashCode ^
      apiuid.hashCode ^
      isRatinged.hashCode ^
      colorRating.hashCode ^
      archiverLink.hashCode ^
      torrentLink.hashCode;
}
