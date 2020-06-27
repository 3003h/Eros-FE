class GalleryItemBean {
  final String gid;
  final String token;

  String url;
  String imgUrl;
  String imgUrlL;
  String japaneseTitle;
  String englishTitle;

  // 类型
  String category;
  String uploader;
  String posted;
  String language;
  String filecount;
  double rating;
  String numberOfReviews;
  String postTime;
  List<String> simpleTags;
  List<String> simpleTagsTranslat;

  GalleryItemBean(
      {this.gid,
      this.token,
      this.url,
      this.imgUrl,
      this.imgUrlL,
      this.japaneseTitle,
      this.englishTitle,
      this.category,
      this.uploader,
      this.posted,
      this.language,
      this.filecount,
      this.rating,
      this.numberOfReviews,
      this.postTime,
      this.simpleTags,
      this.simpleTagsTranslat});

  @override
  String toString() {
    return 'GalleryItemBean{gid: $gid, token: $token, url: $url, imgUrl: $imgUrl, imgUrlL: $imgUrlL, japaneseTitle: $japaneseTitle, englishTitle: $englishTitle, category: $category, uploader: $uploader, posted: $posted, language: $language, filecount: $filecount, rating: $rating, numberOfReviews: $numberOfReviews, postTime: $postTime, simpleTags: $simpleTags, simpleTagsTranslat: $simpleTagsTranslat}';
  }
}
