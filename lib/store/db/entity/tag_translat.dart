import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:floor/floor.dart' hide Index;
import 'package:isar/isar.dart';

part 'tag_translat.g.dart';

@CopyWith()
@Entity(tableName: 'TagTranslat', primaryKeys: ['namespace', 'key'])
@Collection()
class TagTranslat {
  TagTranslat({
    required this.namespace,
    required this.key,
    this.name,
    this.intro,
    this.links,
  });
  int? id;
  @Index()
  final String namespace;
  @Index()
  final String key;
  @Index()
  final String? name;
  final String? intro;
  final String? links;

  @override
  String toString() {
    return 'TagTranslat{namespace: $namespace, key: $key, name: $name, intro: $intro, links: $links}';
  }
}
