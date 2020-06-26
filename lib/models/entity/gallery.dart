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
      this.simpleTags});

  @override
  String toString() {
    return 'GalleryItemBean{gid: $gid, token: $token, url: $url, imgUrl: $imgUrl, imgUrl_l: $imgUrlL, japanese_title: $japaneseTitle, english_title: $englishTitle, category: $category, uploader: $uploader, posted: $posted, language: $language, filecount: $filecount, rating: $rating, numberOfReviews: $numberOfReviews, postTime: $postTime, simpleTags: $simpleTags}';
  }
}
