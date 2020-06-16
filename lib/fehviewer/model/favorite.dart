import 'dart:ui';

class Favorite {}

/// 收藏夹类
class FavcatItemBean {
  final String title;
  final Color color;
  final int num;

  const FavcatItemBean(this.title, this.color, {this.num});
}
