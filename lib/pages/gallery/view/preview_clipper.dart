import 'dart:async';
import 'dart:ui' as ui;

import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double kScale = 1.0;

class PreviewImageClipper extends StatelessWidget {
  const PreviewImageClipper(
      {Key? key,
      required this.imgUrl,
      required this.offset,
      required this.width,
      required this.height})
      : super(key: key);

  final String imgUrl;
  final double offset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
        future: _loadPreviewImge(imgUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Icon(Icons.error, color: Colors.red));
            } else {
              final ui.Image uiImage = snapshot.data!;
              return Container(
                child: CustomPaint(
                  painter: ImageClipper(uiImage,
                      width: width, height: height, offset: offset),
                  size: Size(width * kScale, height * kScale),
                ),
              );
            }
          } else {
            return const Center(child: CupertinoActivityIndicator());
          }
        });
  }

  /// 监听图片加载
  Future<ui.Image> _loadPreviewImge(String imgUrl) async {
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile.user.cookie,
      'host': Uri.parse(imgUrl).host,
    };

    final ImageStream imageStream = ExtendedNetworkImageProvider(
      imgUrl.handleUrl,
      scale: kScale,
      headers: _httpHeaders,
    ).resolve(const ImageConfiguration());

//    imageStream =
//        CachedNetworkImageProvider(imgUrl).resolve(ImageConfiguration());
    final Completer<ui.Image> completer = Completer<ui.Image>();
    void imageListener(ImageInfo info, bool synchronousCall) {
      final ui.Image image = info.image;
      completer.complete(image);
      imageStream.removeListener(ImageStreamListener(imageListener));
    }

    imageStream.addListener(ImageStreamListener(imageListener));
    return completer.future;
  }
}

/// 图片裁剪
class ImageClipper extends CustomPainter {
  final ui.Image image;

  final double offset;

  // 宽高
  final double width;
  final double height;

  ImageClipper(this.image, {this.offset = 0, this.width = 0, this.height = 0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    canvas.drawImageRect(image, Rect.fromLTWH(offset, 0, width, height),
        Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// 预览图小图裁剪
/// 不满足需求
class PreviewClipper extends CustomClipper<Path> {
  final double offset;

  // 宽高
  final double width;
  final double height;

  /// 构造函数，接收传递过来的宽高
  PreviewClipper(
      {this.offset = 0.0, required this.width, required this.height});

  /// 获取剪裁区域的接口
  /// 返回一个矩形 path
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(offset, 0.0);
    path.lineTo(offset + width, 0.0);
    path.lineTo(offset + width, height);
    path.lineTo(offset, height);
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
