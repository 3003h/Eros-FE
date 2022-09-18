// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_translat.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TagTranslatCWProxy {
  TagTranslat intro(String? intro);

  TagTranslat key(String key);

  TagTranslat links(String? links);

  TagTranslat name(String? name);

  TagTranslat namespace(String namespace);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TagTranslat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TagTranslat(...).copyWith(id: 12, name: "My name")
  /// ````
  TagTranslat call({
    String? intro,
    String? key,
    String? links,
    String? name,
    String? namespace,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTagTranslat.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTagTranslat.copyWith.fieldName(...)`
class _$TagTranslatCWProxyImpl implements _$TagTranslatCWProxy {
  final TagTranslat _value;

  const _$TagTranslatCWProxyImpl(this._value);

  @override
  TagTranslat intro(String? intro) => this(intro: intro);

  @override
  TagTranslat key(String key) => this(key: key);

  @override
  TagTranslat links(String? links) => this(links: links);

  @override
  TagTranslat name(String? name) => this(name: name);

  @override
  TagTranslat namespace(String namespace) => this(namespace: namespace);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TagTranslat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TagTranslat(...).copyWith(id: 12, name: "My name")
  /// ````
  TagTranslat call({
    Object? intro = const $CopyWithPlaceholder(),
    Object? key = const $CopyWithPlaceholder(),
    Object? links = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? namespace = const $CopyWithPlaceholder(),
  }) {
    return TagTranslat(
      intro: intro == const $CopyWithPlaceholder()
          ? _value.intro
          // ignore: cast_nullable_to_non_nullable
          : intro as String?,
      key: key == const $CopyWithPlaceholder() || key == null
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      links: links == const $CopyWithPlaceholder()
          ? _value.links
          // ignore: cast_nullable_to_non_nullable
          : links as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      namespace: namespace == const $CopyWithPlaceholder() || namespace == null
          ? _value.namespace
          // ignore: cast_nullable_to_non_nullable
          : namespace as String,
    );
  }
}

extension $TagTranslatCopyWith on TagTranslat {
  /// Returns a callable class that can be used as follows: `instanceOfTagTranslat.copyWith(...)` or like so:`instanceOfTagTranslat.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TagTranslatCWProxy get copyWith => _$TagTranslatCWProxyImpl(this);
}

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names,
// constant_identifier_names, invalid_use_of_protected_member,
// unnecessary_cast, unused_local_variable,
// no_leading_underscores_for_local_identifiers,
// inference_failure_on_function_invocation, prefer_const_constructors

extension GetTagTranslatCollection on Isar {
  IsarCollection<TagTranslat> get tagTranslats => getCollection();
}

const TagTranslatSchema = CollectionSchema(
  name: 'TagTranslat',
  schema:
      '{"name":"TagTranslat","idName":"id","properties":[{"name":"intro","type":"String"},{"name":"key","type":"String"},{"name":"links","type":"String"},{"name":"name","type":"String"},{"name":"namespace","type":"String"}],"indexes":[{"name":"key","unique":false,"replace":false,"properties":[{"name":"key","type":"Hash","caseSensitive":true}]},{"name":"key_namespace","unique":true,"replace":false,"properties":[{"name":"key","type":"Hash","caseSensitive":true},{"name":"namespace","type":"Hash","caseSensitive":true}]},{"name":"name","unique":false,"replace":false,"properties":[{"name":"name","type":"Hash","caseSensitive":true}]},{"name":"namespace","unique":false,"replace":false,"properties":[{"name":"namespace","type":"Hash","caseSensitive":true}]}],"links":[]}',
  idName: 'id',
  propertyIds: {'intro': 0, 'key': 1, 'links': 2, 'name': 3, 'namespace': 4},
  listProperties: {},
  indexIds: {'key': 0, 'key_namespace': 1, 'name': 2, 'namespace': 3},
  indexValueTypes: {
    'key': [
      IndexValueType.stringHash,
    ],
    'key_namespace': [
      IndexValueType.stringHash,
      IndexValueType.stringHash,
    ],
    'name': [
      IndexValueType.stringHash,
    ],
    'namespace': [
      IndexValueType.stringHash,
    ]
  },
  linkIds: {},
  backlinkLinkNames: {},
  getId: _tagTranslatGetId,
  setId: _tagTranslatSetId,
  getLinks: _tagTranslatGetLinks,
  attachLinks: _tagTranslatAttachLinks,
  serializeNative: _tagTranslatSerializeNative,
  deserializeNative: _tagTranslatDeserializeNative,
  deserializePropNative: _tagTranslatDeserializePropNative,
  serializeWeb: _tagTranslatSerializeWeb,
  deserializeWeb: _tagTranslatDeserializeWeb,
  deserializePropWeb: _tagTranslatDeserializePropWeb,
  version: 4,
);

int? _tagTranslatGetId(TagTranslat object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _tagTranslatSetId(TagTranslat object, int id) {
  object.id = id;
}

List<IsarLinkBase<dynamic>> _tagTranslatGetLinks(TagTranslat object) {
  return [];
}

void _tagTranslatSerializeNative(
    IsarCollection<TagTranslat> collection,
    IsarCObject cObj,
    TagTranslat object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  IsarUint8List? intro$Bytes;
  final intro$Value = object.intro;
  if (intro$Value != null) {
    intro$Bytes = IsarBinaryWriter.utf8Encoder.convert(intro$Value);
  }
  final key$Bytes = IsarBinaryWriter.utf8Encoder.convert(object.key);
  IsarUint8List? links$Bytes;
  final links$Value = object.links;
  if (links$Value != null) {
    links$Bytes = IsarBinaryWriter.utf8Encoder.convert(links$Value);
  }
  IsarUint8List? name$Bytes;
  final name$Value = object.name;
  if (name$Value != null) {
    name$Bytes = IsarBinaryWriter.utf8Encoder.convert(name$Value);
  }
  final namespace$Bytes =
      IsarBinaryWriter.utf8Encoder.convert(object.namespace);
  final size = (staticSize +
      (intro$Bytes?.length ?? 0) +
      (key$Bytes.length) +
      (links$Bytes?.length ?? 0) +
      (name$Bytes?.length ?? 0) +
      (namespace$Bytes.length)) as int;
  cObj.buffer = alloc(size);
  cObj.buffer_length = size;

  final buffer = IsarNative.bufAsBytes(cObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], intro$Bytes);
  writer.writeBytes(offsets[1], key$Bytes);
  writer.writeBytes(offsets[2], links$Bytes);
  writer.writeBytes(offsets[3], name$Bytes);
  writer.writeBytes(offsets[4], namespace$Bytes);
}

TagTranslat _tagTranslatDeserializeNative(
    IsarCollection<TagTranslat> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = TagTranslat(
    intro: reader.readStringOrNull(offsets[0]),
    key: reader.readString(offsets[1]),
    links: reader.readStringOrNull(offsets[2]),
    name: reader.readStringOrNull(offsets[3]),
    namespace: reader.readString(offsets[4]),
  );
  object.id = id;
  return object;
}

P _tagTranslatDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

Object _tagTranslatSerializeWeb(
    IsarCollection<TagTranslat> collection, TagTranslat object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'intro', object.intro);
  IsarNative.jsObjectSet(jsObj, 'key', object.key);
  IsarNative.jsObjectSet(jsObj, 'links', object.links);
  IsarNative.jsObjectSet(jsObj, 'name', object.name);
  IsarNative.jsObjectSet(jsObj, 'namespace', object.namespace);
  return jsObj;
}

TagTranslat _tagTranslatDeserializeWeb(
    IsarCollection<TagTranslat> collection, Object jsObj) {
  final object = TagTranslat(
    intro: IsarNative.jsObjectGet(jsObj, 'intro'),
    key: IsarNative.jsObjectGet(jsObj, 'key') ?? '',
    links: IsarNative.jsObjectGet(jsObj, 'links'),
    name: IsarNative.jsObjectGet(jsObj, 'name'),
    namespace: IsarNative.jsObjectGet(jsObj, 'namespace') ?? '',
  );
  object.id = IsarNative.jsObjectGet(jsObj, 'id');
  return object;
}

P _tagTranslatDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'intro':
      return (IsarNative.jsObjectGet(jsObj, 'intro')) as P;
    case 'key':
      return (IsarNative.jsObjectGet(jsObj, 'key') ?? '') as P;
    case 'links':
      return (IsarNative.jsObjectGet(jsObj, 'links')) as P;
    case 'name':
      return (IsarNative.jsObjectGet(jsObj, 'name')) as P;
    case 'namespace':
      return (IsarNative.jsObjectGet(jsObj, 'namespace') ?? '') as P;
    default:
      throw 'Illegal propertyName';
  }
}

void _tagTranslatAttachLinks(
    IsarCollection<dynamic> col, int id, TagTranslat object) {}

extension TagTranslatByIndex on IsarCollection<TagTranslat> {
  Future<TagTranslat?> getByKeyNamespace(String key, String namespace) {
    return getByIndex('key_namespace', [key, namespace]);
  }

  TagTranslat? getByKeyNamespaceSync(String key, String namespace) {
    return getByIndexSync('key_namespace', [key, namespace]);
  }

  Future<bool> deleteByKeyNamespace(String key, String namespace) {
    return deleteByIndex('key_namespace', [key, namespace]);
  }

  bool deleteByKeyNamespaceSync(String key, String namespace) {
    return deleteByIndexSync('key_namespace', [key, namespace]);
  }

  Future<List<TagTranslat?>> getAllByKeyNamespace(
      List<String> keyValues, List<String> namespaceValues) {
    final len = keyValues.length;
    assert(namespaceValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([keyValues[i], namespaceValues[i]]);
    }

    return getAllByIndex('key_namespace', values);
  }

  List<TagTranslat?> getAllByKeyNamespaceSync(
      List<String> keyValues, List<String> namespaceValues) {
    final len = keyValues.length;
    assert(namespaceValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([keyValues[i], namespaceValues[i]]);
    }

    return getAllByIndexSync('key_namespace', values);
  }

  Future<int> deleteAllByKeyNamespace(
      List<String> keyValues, List<String> namespaceValues) {
    final len = keyValues.length;
    assert(namespaceValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([keyValues[i], namespaceValues[i]]);
    }

    return deleteAllByIndex('key_namespace', values);
  }

  int deleteAllByKeyNamespaceSync(
      List<String> keyValues, List<String> namespaceValues) {
    final len = keyValues.length;
    assert(namespaceValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([keyValues[i], namespaceValues[i]]);
    }

    return deleteAllByIndexSync('key_namespace', values);
  }

  Future<int> putByKeyNamespace(TagTranslat object) {
    return putByIndex('key_namespace', object);
  }

  int putByKeyNamespaceSync(TagTranslat object, {bool saveLinks = false}) {
    return putByIndexSync('key_namespace', object, saveLinks: saveLinks);
  }

  Future<List<int>> putAllByKeyNamespace(List<TagTranslat> objects) {
    return putAllByIndex('key_namespace', objects);
  }

  List<int> putAllByKeyNamespaceSync(List<TagTranslat> objects,
      {bool saveLinks = false}) {
    return putAllByIndexSync('key_namespace', objects, saveLinks: saveLinks);
  }
}

extension TagTranslatQueryWhereSort
    on QueryBuilder<TagTranslat, TagTranslat, QWhere> {
  QueryBuilder<TagTranslat, TagTranslat, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhere> anyKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: 'key'),
      );
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhere> anyKeyNamespace() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: 'key_namespace'),
      );
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhere> anyName() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: 'name'),
      );
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhere> anyNamespace() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: 'namespace'),
      );
    });
  }
}

extension TagTranslatQueryWhere
    on QueryBuilder<TagTranslat, TagTranslat, QWhereClause> {
  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> idEqualTo(int id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        includeLower: true,
        upper: id,
        includeUpper: true,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> idNotEqualTo(
      int id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> idGreaterThan(
      int id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> idLessThan(int id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> idBetween(
    int lowerId,
    int upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> keyEqualTo(
      String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: 'key',
        value: [key],
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> keyNotEqualTo(
      String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'key',
              lower: [],
              includeLower: true,
              upper: [key],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'key',
              lower: [key],
              includeLower: false,
              upper: [],
              includeUpper: true,
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'key',
              lower: [key],
              includeLower: false,
              upper: [],
              includeUpper: true,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'key',
              lower: [],
              includeLower: true,
              upper: [key],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause>
      keyEqualToAnyNamespace(String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: 'key_namespace',
        value: [key],
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause>
      keyNotEqualToAnyNamespace(String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'key_namespace',
              lower: [],
              includeLower: true,
              upper: [key],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'key_namespace',
              lower: [key],
              includeLower: false,
              upper: [],
              includeUpper: true,
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'key_namespace',
              lower: [key],
              includeLower: false,
              upper: [],
              includeUpper: true,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'key_namespace',
              lower: [],
              includeLower: true,
              upper: [key],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> keyNamespaceEqualTo(
      String key, String namespace) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: 'key_namespace',
        value: [key, namespace],
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause>
      keyEqualToNamespaceNotEqualTo(String key, String namespace) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'key_namespace',
              lower: [key],
              includeLower: true,
              upper: [key, namespace],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'key_namespace',
              lower: [key, namespace],
              includeLower: false,
              upper: [key],
              includeUpper: true,
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'key_namespace',
              lower: [key, namespace],
              includeLower: false,
              upper: [key],
              includeUpper: true,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'key_namespace',
              lower: [key],
              includeLower: true,
              upper: [key, namespace],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> nameEqualTo(
      String? name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: 'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> nameNotEqualTo(
      String? name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'name',
              lower: [],
              includeLower: true,
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'name',
              lower: [name],
              includeLower: false,
              upper: [],
              includeUpper: true,
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'name',
              lower: [name],
              includeLower: false,
              upper: [],
              includeUpper: true,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'name',
              lower: [],
              includeLower: true,
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: 'name',
        value: [null],
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: 'name',
        lower: [null],
        includeLower: false,
        upper: [],
        includeUpper: true,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> namespaceEqualTo(
      String namespace) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: 'namespace',
        value: [namespace],
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> namespaceNotEqualTo(
      String namespace) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'namespace',
              lower: [],
              includeLower: true,
              upper: [namespace],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'namespace',
              lower: [namespace],
              includeLower: false,
              upper: [],
              includeUpper: true,
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'namespace',
              lower: [namespace],
              includeLower: false,
              upper: [],
              includeUpper: true,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'namespace',
              lower: [],
              includeLower: true,
              upper: [namespace],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TagTranslatQueryFilter
    on QueryBuilder<TagTranslat, TagTranslat, QFilterCondition> {
  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: 'id',
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> idEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> idGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> idLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> idBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: 'intro',
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'intro',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      introGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'intro',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'intro',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'intro',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: 'intro',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: 'intro',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: 'intro',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: 'intro',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: 'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: 'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: 'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: 'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: 'links',
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'links',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      linksGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'links',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'links',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'links',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: 'links',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: 'links',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: 'links',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: 'links',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: 'name',
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: 'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: 'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: 'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: 'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'namespace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'namespace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'namespace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'namespace',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: 'namespace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: 'namespace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: 'namespace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: 'namespace',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }
}

extension TagTranslatQueryLinks
    on QueryBuilder<TagTranslat, TagTranslat, QFilterCondition> {}

extension TagTranslatQueryWhereSortBy
    on QueryBuilder<TagTranslat, TagTranslat, QSortBy> {
  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByIntro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('intro', Sort.asc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByIntroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('intro', Sort.desc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('key', Sort.asc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('key', Sort.desc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByLinks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('links', Sort.asc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByLinksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('links', Sort.desc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('name', Sort.asc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('name', Sort.desc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByNamespace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('namespace', Sort.asc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByNamespaceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('namespace', Sort.desc);
    });
  }
}

extension TagTranslatQueryWhereSortThenBy
    on QueryBuilder<TagTranslat, TagTranslat, QSortThenBy> {
  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('id', Sort.asc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('id', Sort.desc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByIntro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('intro', Sort.asc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByIntroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('intro', Sort.desc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('key', Sort.asc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('key', Sort.desc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByLinks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('links', Sort.asc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByLinksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('links', Sort.desc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('name', Sort.asc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('name', Sort.desc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByNamespace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('namespace', Sort.asc);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByNamespaceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('namespace', Sort.desc);
    });
  }
}

extension TagTranslatQueryWhereDistinct
    on QueryBuilder<TagTranslat, TagTranslat, QDistinct> {
  QueryBuilder<TagTranslat, TagTranslat, QDistinct> distinctByIntro(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('intro', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QDistinct> distinctByKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QDistinct> distinctByLinks(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('links', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TagTranslat, TagTranslat, QDistinct> distinctByNamespace(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('namespace', caseSensitive: caseSensitive);
    });
  }
}

extension TagTranslatQueryProperty
    on QueryBuilder<TagTranslat, TagTranslat, QQueryProperty> {
  QueryBuilder<TagTranslat, int?, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('id');
    });
  }

  QueryBuilder<TagTranslat, String?, QQueryOperations> introProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('intro');
    });
  }

  QueryBuilder<TagTranslat, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('key');
    });
  }

  QueryBuilder<TagTranslat, String?, QQueryOperations> linksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('links');
    });
  }

  QueryBuilder<TagTranslat, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('name');
    });
  }

  QueryBuilder<TagTranslat, String, QQueryOperations> namespaceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('namespace');
    });
  }
}
