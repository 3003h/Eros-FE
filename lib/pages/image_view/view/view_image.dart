import 'package:dio/dio.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({Key key, this.index, this.previews, this.fade})
      : super(key: key);
  final int index;
  final bool fade;
  final List<GalleryPreview> previews;

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  ViewController get controller => Get.find();

  Future<GalleryPreview> _imageFuture;
  Future<GalleryPreview> fetchImage(int itemIndex) async {
    if (itemIndex < widget.previews.length) {
      logger.v('idx:$itemIndex from previews ');
      return widget.previews[itemIndex];
    } else {
      logger.v('idx:$itemIndex 需要先获取');
      return widget.previews.last;
    }
  }

  @override
  void initState() {
    super.initState();
    _imageFuture = fetchImage(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GalleryPreview>(
        future: _imageFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return LoadingWidget(index: widget.index);
              break;
            case ConnectionState.done:
              if (snapshot.hasError) {
                String _errInfo = '';
                if (snapshot.error is DioError) {
                  final DioError dioErr = snapshot.error as DioError;
                  logger.e('${dioErr.error}');
                  _errInfo = dioErr.type.toString();
                } else {
                  _errInfo = snapshot.error.toString();
                }
                return ErrorWidget(index: widget.index, errInfo: _errInfo);
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: Text('${snapshot.data.ser}\n${snapshot.data.imgUrl}',
                      style: const TextStyle(
                          fontSize: 10,
                          color: CupertinoColors.secondarySystemBackground)),
                );
              }
              break;
            default:
              return Container();
          }
        });
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key key, this.index}) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: context.mediaQueryShortestSide,
          minWidth: context.width / 2,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 50,
                color: CupertinoColors.systemGrey6,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const CupertinoActivityIndicator(),
                const SizedBox(width: 5),
                Text(
                  '${S.of(context).loading}...',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({Key key, this.index, this.errInfo}) : super(key: key);
  final int index;
  final String errInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(
        maxHeight: context.width * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error,
            size: 50,
            color: Colors.red,
          ),
          Text(
            errInfo,
            style: const TextStyle(
                fontSize: 10, color: CupertinoColors.secondarySystemBackground),
          ),
          Text(
            '${index + 1}',
            style: const TextStyle(
                color: CupertinoColors.secondarySystemBackground),
          ),
        ],
      ),
    );
  }
}
