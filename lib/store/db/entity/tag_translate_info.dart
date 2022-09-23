import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:isar/isar.dart';

part 'tag_translate_info.g.dart';

@CopyWith()
@Collection()
class TagTranslateInfo {
  TagTranslateInfo({
    this.localVersion,
  }) : id = 0;

  @Index(unique: true, replace: true)
  Id id;
  final String? localVersion;
}
