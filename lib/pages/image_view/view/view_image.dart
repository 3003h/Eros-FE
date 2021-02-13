import 'package:fehviewer/models/base/eh_models.dart';
import 'package:flutter/cupertino.dart';

class ViewImage extends StatelessWidget {
  const ViewImage({Key key, this.index, this.previews, this.fade})
      : super(key: key);
  final int index;
  final bool fade;
  final List<GalleryPreview> previews;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
