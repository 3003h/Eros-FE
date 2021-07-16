import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/pages/image_view/controller/view_local_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class ViewLocalPage extends StatefulWidget {
  const ViewLocalPage(
      {Key? key, this.index = 0, required this.pics, required this.dirPath})
      : super(key: key);

  final int index;
  final String dirPath;
  final List<String> pics;

  @override
  _ViewLocalPageState createState() => _ViewLocalPageState();
}

class _ViewLocalPageState extends State<ViewLocalPage> {
  final ViewLocalController viewLocalController =
      Get.put(ViewLocalController());

  int? _currentIndex = 0;

  @override
  void initState() {
    _currentIndex = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(BuildContext context, int index) {
      final String item = path.join(widget.dirPath, widget.pics[index]);
      Widget image = ExtendedImage.file(
        File(item),
        fit: BoxFit.contain,
        enableSlideOutPage: true,
        mode: ExtendedImageMode.gesture,
      );

      return image.paddingSymmetric(horizontal: 2.0);
    }

    Widget result = Material(
      color: Colors.black,
      shadowColor: Colors.transparent,
      child: ExtendedImageGesturePageView.builder(
        controller: PageController(
          initialPage: widget.index,
        ),
        itemBuilder: itemBuilder,
        itemCount: widget.pics.length,
        onPageChanged: (int index) {
          _currentIndex = index;
        },
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
      ),
    );

    return ExtendedImageSlidePage(
      child: result,
      slideAxis: SlideAxis.vertical,
      slideType: SlideType.onlyImage,
    );
  }
}
