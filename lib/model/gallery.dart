class GalleryItemBean {
  final String gid;
  final String token;

  String url;
  String imgUrl;
  String japanese_title;
  String english_title;

  // 类型
  String category;
  String uploader;
  String posted;
  String language;
  String length;
  double rating;
  String numberOfReviews;
  String postTime;
  List<String> simpleTags;

  GalleryItemBean(
      {this.gid,
      this.token,
      this.url,
      this.imgUrl,
      this.japanese_title,
      this.english_title,
      this.category,
      this.uploader,
      this.posted,
      this.language,
      this.length,
      this.rating,
      this.numberOfReviews,
      this.postTime,
      this.simpleTags});

  @override
  String toString() {
    return 'GalleryItemBean{gid: $gid, token: $token, url: $url, imgUrl: $imgUrl, japanese_title: $japanese_title, english_title: $english_title, category: $category, uploader: $uploader, posted: $posted, language: $language, length: $length, rating: $rating, numberOfReviews: $numberOfReviews, postTime: $postTime, simpleTags: $simpleTags}';
  }
}
