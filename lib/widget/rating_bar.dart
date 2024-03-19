import 'dart:math' as math;

import 'package:flutter/widgets.dart';

const double kMaxRate = 5.0;
const int kNumberOfStarts = 5;
const double kSpacing = 3.0;
const double kSize = 50.0;

/// 静态控件
class StaticRatingBar extends StatelessWidget {
  const StaticRatingBar({
    super.key,
    this.rate = kMaxRate,
    this.colorLight = const Color(0xffeeeeee),
    this.colorDark = const Color(0xffFF962E),
    this.count = kNumberOfStarts,
    this.size = kSize,
    this.radiusRatio = 1.1,
  });

  /// 星星数量
  final int count;

  /// 分数
  final double rate;

  /// 星星大小
  final double size;

  final double radiusRatio;

  final Color? colorLight;

  final Color? colorDark;

  Widget buildStar() {
    return SizedBox(
        width: size * count,
        height: size,
        child: CustomPaint(
          painter: _PainterStars(
              size: size / 2,
              color: colorLight ?? const Color(0xffeeeeee),
              radiusRatio: radiusRatio,
              style: PaintingStyle.fill,
              strokeWidth: 0.0),
        ));
  }

  Widget buildHollowStar() {
    return SizedBox(
        width: size * count,
        height: size,
        child: CustomPaint(
          painter: _PainterStars(
              size: size / 2,
              color: colorDark ?? const Color(0xffFF962E),
              radiusRatio: radiusRatio,
              style: PaintingStyle.fill,
              strokeWidth: 0.0),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        buildHollowStar(),
        ClipRect(
          clipper: _RatingBarClipper(width: rate * size),
          child: buildStar(),
        )
      ],
    );
  }
}

class _RatingBarClipper extends CustomClipper<Rect> {
  _RatingBarClipper({required this.width});

  final double width;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0.0, 0.0, width, size.height);
  }

  @override
  bool shouldReclip(_RatingBarClipper oldClipper) {
    return width != oldClipper.width;
  }
}

/// 角度转弧度公式
double degree2Radian(int degree) {
  return math.pi * degree / 180;
}

Path createStarPath(double radius, double radiusRatio, Path path) {
  // radius 半径 决定大小

  // 36为五角星的角度
  final double radian = degree2Radian(36);

  // 正五角星情况下 中间五边形的半径
  final double radiusInDef = radius * math.sin(radian / 2) / math.cos(radian);

  // 实际中间五边形的半径,太正不是很好看，扩大一点点
  final double radiusIn = radiusInDef * radiusRatio;
//  debugPrint('radius_in $radius_in');

  // 计算外部五边形5个顶点坐标
  final _Point _pointA = _Point(radius * math.cos(radian / 2), 0.0);
  final _Point _pointB = _Point(radius * math.cos(radian / 2) * 2,
      radius - radius * math.sin(radian / 2));
  final _Point _pointC = _Point(
      radius * math.cos(radian / 2) + radius * math.sin(radian),
      radius + radius * math.cos(radian));
  final _Point _pointD = _Point(
      radius * math.cos(radian / 2) - radius * math.sin(radian),
      radius + radius * math.cos(radian));
  final _Point _pointE = _Point(0.0, radius - radius * math.sin(radian / 2));

  // 中心坐标
  final _Point _pointO = _Point(radius * math.cos(radian / 2), radius);
//  _Point _pointO = _Point(0.0, 0.0);
//  debugPrint(_pointO.toString());

//  radius_in = 10.0;
  // 计算内部五边形5个顶点坐标
  final _Point _pointAi = _Point(_pointO.px + radiusIn * math.sin(radian),
      _pointO.py - radiusIn * math.cos(radian));
  final _Point _pointBi = _Point(_pointO.px + radiusIn * math.cos(radian / 2),
      _pointO.py + radiusIn * math.sin(radian / 2));
  final _Point _pointCi = _Point(_pointO.px, _pointO.py + radiusIn);
  final _Point _pointDi = _Point(_pointO.px - radiusIn * math.cos(radian / 2),
      _pointO.py + radiusIn * math.sin(radian / 2));
  final _Point _pointEi = _Point(_pointO.px - radiusIn * math.sin(radian),
      _pointO.py - radiusIn * math.cos(radian));

  // 绘制
  path.moveTo(_pointA.px, _pointA.py);
  path.lineTo(_pointAi.px, _pointAi.py);
  path.lineTo(_pointB.px, _pointB.py);
  path.lineTo(_pointBi.px, _pointBi.py);
  path.lineTo(_pointC.px, _pointC.py);
  path.lineTo(_pointCi.px, _pointCi.py);
  path.lineTo(_pointD.px, _pointD.py);
  path.lineTo(_pointDi.px, _pointDi.py);
  path.lineTo(_pointE.px, _pointE.py);
  path.lineTo(_pointEi.px, _pointEi.py);
  path.lineTo(_pointA.px, _pointA.py);

  return path;
}

// 坐标点类
class _Point {
  _Point(this.px, this.py);

  final double px;
  final double py;

  @override
  String toString() {
    return '_Point{px: $px, py: $py}';
  }
}

class _PainterStars extends CustomPainter {
  _PainterStars(
      {required this.size,
      required this.color,
      required this.strokeWidth,
      required this.style,
      required this.radiusRatio});

  final double size;
  final Color color;
  final PaintingStyle style;
  final double strokeWidth;
  final double radiusRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    //   paint.color = Colors.redAccent;
    paint.strokeWidth = strokeWidth;
    paint.color = color;
    paint.style = style;

    Path path = Path();

    final double offset = strokeWidth > 0 ? strokeWidth + 2 : 0.0;

    path = createStarPath(this.size - offset, radiusRatio, path);
    path = path.shift(Offset(this.size * 2, 0.0));
    path = createStarPath(this.size - offset, radiusRatio, path);
    path = path.shift(Offset(this.size * 2, 0.0));
    path = createStarPath(this.size - offset, radiusRatio, path);
    path = path.shift(Offset(this.size * 2, 0.0));
    path = createStarPath(this.size - offset, radiusRatio, path);
    path = path.shift(Offset(this.size * 2, 0.0));
    path = createStarPath(this.size - offset, radiusRatio, path);

    if (offset > 0) {
      path = path.shift(Offset(offset, offset));
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PainterStars oldDelegate) {
    return oldDelegate.size != size;
  }
}

class RatingBar extends StatefulWidget {
  const RatingBar({
    this.onChange,
    required this.value,
    this.size = kSize,
    this.count = kNumberOfStarts,
    this.strokeWidth = 0,
    this.radiusRatio = 1.1,
    this.colorDark = const Color(0xffDADBDF),
    this.colorLight = const Color(0xffFF962E),
  });

  /// 回调
  final ValueChanged<int>? onChange;

  /// 大小， 默认 50
  final double size;

  /// 值 1-5
  final int value;

  /// 数量 5 个默认
  final int count;

  /// 高亮
  final Color colorLight;

  /// 底色
  final Color colorDark;

  /// 如果有值，那么就是空心的
  final double? strokeWidth;

  /// 越大，五角星越圆
  final double radiusRatio;

  @override
  State<StatefulWidget> createState() {
    return _RatingBarState();
  }
}

class _PainterStar extends CustomPainter {
  _PainterStar({
    required this.size,
    required this.color,
    required this.strokeWidth,
    required this.style,
    required this.radiusRatio,
  });

  final double size;
  final Color color;
  final PaintingStyle style;
  final double strokeWidth;
  final double radiusRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    paint.strokeWidth = strokeWidth;
    paint.color = color;
    paint.style = style;
    Path path = Path();
    final double offset = strokeWidth > 0 ? strokeWidth + 2 : 0.0;

    path = createStarPath(this.size - offset, radiusRatio, path);

    if (offset > 0) {
      path = path.shift(Offset(offset, offset));
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PainterStar oldDelegate) {
    return oldDelegate.size != size ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _RatingBarState extends State<RatingBar> {
  int? _value;

  @override
  void initState() {
    _value = widget.value;
    super.initState();
  }

  Widget buildItem(int index, double size, int count) {
    final bool selected = _value != null && _value! > index;

    final bool stroke = widget.strokeWidth != null && widget.strokeWidth! > 0;

    return GestureDetector(
      onTap: () {
        if (widget.onChange != null) {
          widget.onChange!(index + 1);
        }

        setState(() {
          _value = index + 1;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _PainterStar(
                radiusRatio: widget.radiusRatio,
                size: size / 2,
                color: selected ? widget.colorLight : widget.colorDark,
                style: !selected && stroke
                    ? PaintingStyle.stroke
                    : PaintingStyle.fill,
                strokeWidth:
                    !selected && stroke ? (widget.strokeWidth ?? 0.0) : 0.0),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;
    final int count = widget.count;

    final List<Widget> list = <Widget>[];
    for (int i = 0; i < count; ++i) {
      list.add(buildItem(i, size, count));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );
  }
}
