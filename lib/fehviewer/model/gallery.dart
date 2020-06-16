class GalleryItemBean {
  final String gid;
  final String token;

  String url;
  String imgUrl;
  String imgUrl_l;
  String japanese_title;
  String english_title;

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
      this.imgUrl_l,
      this.japanese_title,
      this.english_title,
      this.category,
      this.uploader,
      this.posted,
      this.language,
      this.filecount,
      this.rating,
      this.numberOfReviews,
      this.postTime,
      this.simpleTags});

}
