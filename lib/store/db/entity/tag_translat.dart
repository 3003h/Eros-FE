import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:isar/isar.dart';

part 'tag_translat.g.dart';

@CopyWith()
@Collection()
class TagTranslat {
  TagTranslat({
    required this.namespace,
    required this.key,
    this.name,
    this.intro,
    this.links,
  });

  @Id()
  int? id;
  @Index()
  final String namespace;
  @Index(composite: [CompositeIndex('namespace')], unique: true)
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
