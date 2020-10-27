import 'package:flutter/material.dart';

class CategoryClipper extends CustomClipper<Path> {
  /// 构造函数，接收传递过来的宽高
  CategoryClipper({@required this.width, @required this.height});

  // 三角形底和高
  final double width;
  final double height;

  /// 获取剪裁区域的接口
  /// 返回一个三角形 path
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(width, 0.0);
    path.lineTo(width, height);
    path.close();
    return path;
  }

  /// 接口决定是否重新剪裁
  /// 如果在应用中，剪裁区域始终不会发生变化时应该返回 false，这样就不会触发重新剪裁，避免不必要的性能开销。
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
