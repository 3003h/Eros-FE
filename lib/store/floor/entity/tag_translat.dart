import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:floor/floor.dart';

part 'tag_translat.g.dart';

@CopyWith()
@Entity(tableName: 'TagTranslat', primaryKeys: ['namespace', 'key'])
class TagTranslat {
  TagTranslat({
    required this.namespace,
    required this.key,
    this.name,
    this.intro,
    this.links,
  });
  final String namespace;
  final String key;
  final String? name;
  final String? intro;
  final String? links;
}
