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

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable

extension GetTagTranslatCollection on Isar {
  IsarCollection<TagTranslat> get tagTranslats => getCollection();
}

const TagTranslatSchema = CollectionSchema(
  name: 'TagTranslat',
  schema:
      '{"name":"TagTranslat","idName":"id","properties":[{"name":"intro","type":"String"},{"name":"key","type":"String"},{"name":"links","type":"String"},{"name":"name","type":"String"},{"name":"namespace","type":"String"}],"indexes":[{"name":"key","unique":false,"properties":[{"name":"key","type":"Hash","caseSensitive":true}]},{"name":"key_namespace","unique":true,"properties":[{"name":"key","type":"Hash","caseSensitive":true},{"name":"namespace","type":"Hash","caseSensitive":true}]},{"name":"name","unique":false,"properties":[{"name":"name","type":"Hash","caseSensitive":true}]},{"name":"namespace","unique":false,"properties":[{"name":"namespace","type":"Hash","caseSensitive":true}]}],"links":[]}',
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
  version: 3,
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

List<IsarLinkBase> _tagTranslatGetLinks(TagTranslat object) {
  return [];
}

void _tagTranslatSerializeNative(
    IsarCollection<TagTranslat> collection,
    IsarRawObject rawObj,
    TagTranslat object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = object.intro;
  IsarUint8List? _intro;
  if (value0 != null) {
    _intro = IsarBinaryWriter.utf8Encoder.convert(value0);
  }
  dynamicSize += (_intro?.length ?? 0) as int;
  final value1 = object.key;
  final _key = IsarBinaryWriter.utf8Encoder.convert(value1);
  dynamicSize += (_key.length) as int;
  final value2 = object.links;
  IsarUint8List? _links;
  if (value2 != null) {
    _links = IsarBinaryWriter.utf8Encoder.convert(value2);
  }
  dynamicSize += (_links?.length ?? 0) as int;
  final value3 = object.name;
  IsarUint8List? _name;
  if (value3 != null) {
    _name = IsarBinaryWriter.utf8Encoder.convert(value3);
  }
  dynamicSize += (_name?.length ?? 0) as int;
  final value4 = object.namespace;
  final _namespace = IsarBinaryWriter.utf8Encoder.convert(value4);
  dynamicSize += (_namespace.length) as int;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _intro);
  writer.writeBytes(offsets[1], _key);
  writer.writeBytes(offsets[2], _links);
  writer.writeBytes(offsets[3], _name);
  writer.writeBytes(offsets[4], _namespace);
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

dynamic _tagTranslatSerializeWeb(
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
    IsarCollection<TagTranslat> collection, dynamic jsObj) {
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

void _tagTranslatAttachLinks(IsarCollection col, int id, TagTranslat object) {}

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
}

extension TagTranslatQueryWhereSort
    on QueryBuilder<TagTranslat, TagTranslat, QWhere> {
  QueryBuilder<TagTranslat, TagTranslat, QAfterWhere> anyId() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhere> anyKey() {
    return addWhereClauseInternal(const IndexWhereClause.any(indexName: 'key'));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhere> anyKeyNamespace() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'key_namespace'));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhere> anyName() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'name'));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhere> anyNamespace() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'namespace'));
  }
}

extension TagTranslatQueryWhere
    on QueryBuilder<TagTranslat, TagTranslat, QWhereClause> {
  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> idEqualTo(int id) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: id,
      includeLower: true,
      upper: id,
      includeUpper: true,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> idNotEqualTo(
      int id) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(
        IdWhereClause.lessThan(upper: id, includeUpper: false),
      ).addWhereClauseInternal(
        IdWhereClause.greaterThan(lower: id, includeLower: false),
      );
    } else {
      return addWhereClauseInternal(
        IdWhereClause.greaterThan(lower: id, includeLower: false),
      ).addWhereClauseInternal(
        IdWhereClause.lessThan(upper: id, includeUpper: false),
      );
    }
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> idGreaterThan(
      int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: id, includeLower: include),
    );
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> idLessThan(int id,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: id, includeUpper: include),
    );
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> idBetween(
    int lowerId,
    int upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: lowerId,
      includeLower: includeLower,
      upper: upperId,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> keyEqualTo(
      String key) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'key',
      value: [key],
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> keyNotEqualTo(
      String key) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'key',
        upper: [key],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'key',
        lower: [key],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'key',
        lower: [key],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'key',
        upper: [key],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> keyNamespaceEqualTo(
      String key, String namespace) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'key_namespace',
      value: [key, namespace],
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause>
      keyNamespaceNotEqualTo(String key, String namespace) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'key_namespace',
        upper: [key, namespace],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'key_namespace',
        lower: [key, namespace],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'key_namespace',
        lower: [key, namespace],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'key_namespace',
        upper: [key, namespace],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> nameEqualTo(
      String? name) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'name',
      value: [name],
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> nameNotEqualTo(
      String? name) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'name',
        upper: [name],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'name',
        lower: [name],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'name',
        lower: [name],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'name',
        upper: [name],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> nameIsNull() {
    return addWhereClauseInternal(const IndexWhereClause.equalTo(
      indexName: 'name',
      value: [null],
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> nameIsNotNull() {
    return addWhereClauseInternal(const IndexWhereClause.greaterThan(
      indexName: 'name',
      lower: [null],
      includeLower: false,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> namespaceEqualTo(
      String namespace) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'namespace',
      value: [namespace],
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterWhereClause> namespaceNotEqualTo(
      String namespace) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'namespace',
        upper: [namespace],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'namespace',
        lower: [namespace],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'namespace',
        lower: [namespace],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'namespace',
        upper: [namespace],
        includeUpper: false,
      ));
    }
  }
}

extension TagTranslatQueryFilter
    on QueryBuilder<TagTranslat, TagTranslat, QFilterCondition> {
  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> idEqualTo(
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> idGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> idLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> idBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'id',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'intro',
      value: null,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'intro',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      introGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'intro',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'intro',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'intro',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'intro',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'intro',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'intro',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> introMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'intro',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'key',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'key',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'key',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'key',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'key',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'key',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'key',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> keyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'key',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'links',
      value: null,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'links',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      linksGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'links',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'links',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'links',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'links',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'links',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'links',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> linksMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'links',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'name',
      value: null,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'name',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'name',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'name',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'namespace',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'namespace',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'namespace',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'namespace',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'namespace',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'namespace',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'namespace',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterFilterCondition>
      namespaceMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'namespace',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension TagTranslatQueryLinks
    on QueryBuilder<TagTranslat, TagTranslat, QFilterCondition> {}

extension TagTranslatQueryWhereSortBy
    on QueryBuilder<TagTranslat, TagTranslat, QSortBy> {
  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByIntro() {
    return addSortByInternal('intro', Sort.asc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByIntroDesc() {
    return addSortByInternal('intro', Sort.desc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByKey() {
    return addSortByInternal('key', Sort.asc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByKeyDesc() {
    return addSortByInternal('key', Sort.desc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByLinks() {
    return addSortByInternal('links', Sort.asc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByLinksDesc() {
    return addSortByInternal('links', Sort.desc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByName() {
    return addSortByInternal('name', Sort.asc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByNameDesc() {
    return addSortByInternal('name', Sort.desc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByNamespace() {
    return addSortByInternal('namespace', Sort.asc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> sortByNamespaceDesc() {
    return addSortByInternal('namespace', Sort.desc);
  }
}

extension TagTranslatQueryWhereSortThenBy
    on QueryBuilder<TagTranslat, TagTranslat, QSortThenBy> {
  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByIntro() {
    return addSortByInternal('intro', Sort.asc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByIntroDesc() {
    return addSortByInternal('intro', Sort.desc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByKey() {
    return addSortByInternal('key', Sort.asc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByKeyDesc() {
    return addSortByInternal('key', Sort.desc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByLinks() {
    return addSortByInternal('links', Sort.asc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByLinksDesc() {
    return addSortByInternal('links', Sort.desc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByName() {
    return addSortByInternal('name', Sort.asc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByNameDesc() {
    return addSortByInternal('name', Sort.desc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByNamespace() {
    return addSortByInternal('namespace', Sort.asc);
  }

  QueryBuilder<TagTranslat, TagTranslat, QAfterSortBy> thenByNamespaceDesc() {
    return addSortByInternal('namespace', Sort.desc);
  }
}

extension TagTranslatQueryWhereDistinct
    on QueryBuilder<TagTranslat, TagTranslat, QDistinct> {
  QueryBuilder<TagTranslat, TagTranslat, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<TagTranslat, TagTranslat, QDistinct> distinctByIntro(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('intro', caseSensitive: caseSensitive);
  }

  QueryBuilder<TagTranslat, TagTranslat, QDistinct> distinctByKey(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('key', caseSensitive: caseSensitive);
  }

  QueryBuilder<TagTranslat, TagTranslat, QDistinct> distinctByLinks(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('links', caseSensitive: caseSensitive);
  }

  QueryBuilder<TagTranslat, TagTranslat, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('name', caseSensitive: caseSensitive);
  }

  QueryBuilder<TagTranslat, TagTranslat, QDistinct> distinctByNamespace(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('namespace', caseSensitive: caseSensitive);
  }
}

extension TagTranslatQueryProperty
    on QueryBuilder<TagTranslat, TagTranslat, QQueryProperty> {
  QueryBuilder<TagTranslat, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<TagTranslat, String?, QQueryOperations> introProperty() {
    return addPropertyNameInternal('intro');
  }

  QueryBuilder<TagTranslat, String, QQueryOperations> keyProperty() {
    return addPropertyNameInternal('key');
  }

  QueryBuilder<TagTranslat, String?, QQueryOperations> linksProperty() {
    return addPropertyNameInternal('links');
  }

  QueryBuilder<TagTranslat, String?, QQueryOperations> nameProperty() {
    return addPropertyNameInternal('name');
  }

  QueryBuilder<TagTranslat, String, QQueryOperations> namespaceProperty() {
    return addPropertyNameInternal('namespace');
  }
}
