class GalleryItemBean {
  final String url;
  final String imgUrl;
  final String japanese_title;
  final String english_title;

  // 类型
  final String category;
  final String uploader;
  final String posted;
  final String language;
  final String length;
  final String rating;
  final String numberOfReviews;
  final String postTime;
  final List<String> simpleTags;

  GalleryItemBean(
      {this.url,
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
    return 'GalleryItemBean{url: $url, imgUrl: $imgUrl, japanese_title: $japanese_title, english_title: $english_title, category: $category, uploader: $uploader, posted: $posted, language: $language, length: $length, rating: $rating, numberOfReviews: $numberOfReviews, postTime: $postTime, simpleTags: $simpleTags}';
  }
}
