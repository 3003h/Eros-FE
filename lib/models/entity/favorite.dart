import 'dart:ui';

class Favorite {}

/// 收藏夹类
class FavcatItemBean {
  const FavcatItemBean(this.title, this.color, {this.favId});

  final String? title;
  final Color? color;
  final String? favId;
}
