const String dbname = 'eh_database.db';
const String tableTag = 'tag_translat';
const String columnNamespace = 'namespace';
const String columnKey = 'key';
const String columnName = 'name';
const String columnIntro = 'intro';
const String columnLinks = 'links';

class TagTranslat {
  TagTranslat(this.namespace, this.key, this.name,
      {this.intro = '', this.links = ''});
  late String namespace;
  late String key;
  late String name;
  late String intro;
  late String links;

  Map<String, dynamic> toMap() {
    return {
      'namespace': namespace,
      'key': key,
      'name': name,
      'intro': intro,
      'links': links,
    };
  }

  TagTranslat.fromMap(Map<String, dynamic> map) {
    namespace = map[columnNamespace];
    key = map[columnKey];
    name = map[columnName];
    intro = map[columnIntro];
    links = map[columnLinks];
  }

  @override
  String toString() {
    return 'TagTranslat{namespace: $namespace, key: $key, name: $name, intro: $intro, links: $links}';
  }
}
