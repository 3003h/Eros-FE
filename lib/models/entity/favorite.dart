import 'dart:ui';

class Favorite {}

/// 收藏夹类
class FavcatItemBean {
  final String title;
  final Color color;
  final String key;

  const FavcatItemBean(this.title, this.color, {this.key});
}
