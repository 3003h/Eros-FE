import 'dart:ui';

class Favorite {}

/// 收藏夹类
class FavcatItemBean {
  final String title;
  final Color color;
  final String favId;

  const FavcatItemBean(this.title, this.color, {this.favId});
}
