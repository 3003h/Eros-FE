import 'package:dio/dio.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 页面滑条
class PageSlider extends StatefulWidget {
  const PageSlider({
    Key? key,
    required this.max,
    required this.sliderValue,
    required this.onChangedEnd,
    required this.onChanged,
  }) : super(key: key);

  final double max;
  final double sliderValue;
  final ValueChanged<double> onChangedEnd;
  final ValueChanged<double> onChanged;

  @override
  _PageSliderState createState() => _PageSliderState();
}

class _PageSliderState extends State<PageSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.sliderValue;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _value = widget.sliderValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            '${widget.sliderValue.round() + 1}',
            style: const TextStyle(color: CupertinoColors.systemGrey6),
          ),
          Expanded(
            child: CupertinoSlider(
                min: 0,
                max: widget.max,
                value: widget.sliderValue,
                onChanged: (double newValue) {
                  setState(() {
                    _value = newValue;
                  });
                  widget.onChanged(newValue);
                },
                onChangeEnd: (double newValue) {
                  widget.onChangedEnd(newValue);
                }),
          ),
          Text(
            '${widget.max.round() + 1}',
            style: const TextStyle(color: CupertinoColors.systemGrey6),
          ),
        ],
      ),
    );
  }
}

typedef DidFinishLayoutCallBack = dynamic Function(
    int firstIndex, int lastIndex);

class ViewChildBuilderDelegate extends SliverChildBuilderDelegate {
  ViewChildBuilderDelegate(
    Widget Function(BuildContext, int) builder, {
    int? childCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    this.onDidFinishLayout,
  }) : super(builder,
            childCount: childCount,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries);

  final DidFinishLayoutCallBack? onDidFinishLayout;

  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    onDidFinishLayout?.call(firstIndex, lastIndex);
  }
}

Future<void> showShareActionSheet(BuildContext context, String imageUrl) {
  return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final CupertinoActionSheet dialog = CupertinoActionSheet(
          cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
              },
              child: Text(S.of(context)!.cancel)),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  logger.v('保存到相册');
                  Api.saveImage(context, imageUrl).then((rult) {
                    Get.back();
                    if (rult != null && rult) {
                      showToast('保存成功');
                    }
                  }).catchError((e) {
                    showToast(e);
                  });
                },
                child: const Text('保存到相册')),
            CupertinoActionSheetAction(
                onPressed: () {
                  logger.v('系统分享');
                  // Api.shareImage(imageUrl);
                  Api.shareImageExtended(imageUrl);
                },
                child: const Text('系统分享')),
          ],
        );
        return dialog;
      });
}

Future<void> showImageSheet(
    BuildContext context, String imageUrl, VoidCallback reload,
    {String? title}) {
  return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final CupertinoActionSheet dialog = CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
              },
              child: Text(S.of(context)!.cancel)),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  reload();
                  Get.back();
                },
                child: Text(S.of(context)!.reload_image)),
            CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                  showShareActionSheet(context, imageUrl);
                },
                child: Text(S.of(context)!.share_image)),
          ],
        );
        return dialog;
      });
}
