import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/pages/gallery_view/controller/view_controller.dart';

import '../index.dart';

extension ExtGC on GalleryCache {
  ColumnMode get columnMode =>
      EnumToString.fromString(ColumnMode.values, columnModeVal);
  set columnMode(ColumnMode val) =>
      columnModeVal = EnumToString.convertToString(val);
}
