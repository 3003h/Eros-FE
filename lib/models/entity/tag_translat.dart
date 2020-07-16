final String dbname = 'eh_database.db';
final String tableTag = 'tag_translat';
final String columnNamespace = 'namespace';
final String columnKey = 'key';
final String columnName = 'name';
final String columnIntro = 'intro';
final String columnLinks = 'links';

class TagTranslat {
  String namespace;
  String key;
  String name;
  String intro;
  String links;

  TagTranslat(this.namespace, this.key, this.name, {this.intro, this.links});

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
}
