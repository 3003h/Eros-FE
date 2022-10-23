// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_translate_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TagTranslateInfoCWProxy {
  TagTranslateInfo localVersion(String? localVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TagTranslateInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TagTranslateInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  TagTranslateInfo call({
    String? localVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTagTranslateInfo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTagTranslateInfo.copyWith.fieldName(...)`
class _$TagTranslateInfoCWProxyImpl implements _$TagTranslateInfoCWProxy {
  final TagTranslateInfo _value;

  const _$TagTranslateInfoCWProxyImpl(this._value);

  @override
  TagTranslateInfo localVersion(String? localVersion) =>
      this(localVersion: localVersion);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TagTranslateInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TagTranslateInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  TagTranslateInfo call({
    Object? localVersion = const $CopyWithPlaceholder(),
  }) {
    return TagTranslateInfo(
      localVersion: localVersion == const $CopyWithPlaceholder()
          ? _value.localVersion
          // ignore: cast_nullable_to_non_nullable
          : localVersion as String?,
    );
  }
}

extension $TagTranslateInfoCopyWith on TagTranslateInfo {
  /// Returns a callable class that can be used as follows: `instanceOfTagTranslateInfo.copyWith(...)` or like so:`instanceOfTagTranslateInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TagTranslateInfoCWProxy get copyWith => _$TagTranslateInfoCWProxyImpl(this);
}

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings

extension GetTagTranslateInfoCollection on Isar {
  IsarCollection<TagTranslateInfo> get tagTranslateInfos => collection();
}

const TagTranslateInfoSchema = CollectionSchema(
  name: r'TagTranslateInfo',
  schema:
      r'{"name":"TagTranslateInfo","idName":"id","properties":[{"name":"localVersion","type":"String"}],"indexes":[],"links":[]}',
  idName: r'id',
  propertyIds: {r'localVersion': 0},
  listProperties: {},
  indexIds: {},
  indexValueTypes: {},
  linkIds: {},
  backlinkLinkNames: {},
  getId: _tagTranslateInfoGetId,
  setId: _tagTranslateInfoSetId,
  getLinks: _tagTranslateInfoGetLinks,
  attachLinks: _tagTranslateInfoAttachLinks,
  serializeNative: _tagTranslateInfoSerializeNative,
  deserializeNative: _tagTranslateInfoDeserializeNative,
  deserializePropNative: _tagTranslateInfoDeserializePropNative,
  serializeWeb: _tagTranslateInfoSerializeWeb,
  deserializeWeb: _tagTranslateInfoDeserializeWeb,
  deserializePropWeb: _tagTranslateInfoDeserializePropWeb,
  version: 4,
);

int? _tagTranslateInfoGetId(TagTranslateInfo object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _tagTranslateInfoSetId(TagTranslateInfo object, int id) {
  object.id = id;
}

List<IsarLinkBase<dynamic>> _tagTranslateInfoGetLinks(TagTranslateInfo object) {
  return [];
}

void _tagTranslateInfoSerializeNative(
    IsarCollection<TagTranslateInfo> collection,
    IsarCObject cObj,
    TagTranslateInfo object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  IsarUint8List? localVersion$Bytes;
  final localVersion$Value = object.localVersion;
  if (localVersion$Value != null) {
    localVersion$Bytes =
        IsarBinaryWriter.utf8Encoder.convert(localVersion$Value);
  }
  final size = (staticSize + 3 + (localVersion$Bytes?.length ?? 0)) as int;
  cObj.buffer = alloc(size);
  cObj.buffer_length = size;

  final buffer = IsarNative.bufAsBytes(cObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeHeader();
  writer.writeByteList(offsets[0], localVersion$Bytes);
}

TagTranslateInfo _tagTranslateInfoDeserializeNative(
    IsarCollection<TagTranslateInfo> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = TagTranslateInfo(
    localVersion: reader.readStringOrNull(offsets[0]),
  );
  object.id = id;
  return object;
}

P _tagTranslateInfoDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Illegal propertyIndex');
  }
}

Object _tagTranslateInfoSerializeWeb(
    IsarCollection<TagTranslateInfo> collection, TagTranslateInfo object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, r'id', object.id);
  IsarNative.jsObjectSet(jsObj, r'localVersion', object.localVersion);
  return jsObj;
}

TagTranslateInfo _tagTranslateInfoDeserializeWeb(
    IsarCollection<TagTranslateInfo> collection, Object jsObj) {
  final object = TagTranslateInfo(
    localVersion: IsarNative.jsObjectGet(jsObj, r'localVersion'),
  );
  object.id = IsarNative.jsObjectGet(jsObj, r'id');
  return object;
}

P _tagTranslateInfoDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case r'id':
      return (IsarNative.jsObjectGet(jsObj, r'id')) as P;
    case r'localVersion':
      return (IsarNative.jsObjectGet(jsObj, r'localVersion')) as P;
    default:
      throw IsarError('Illegal propertyName');
  }
}

void _tagTranslateInfoAttachLinks(
    IsarCollection<dynamic> col, int id, TagTranslateInfo object) {}

extension TagTranslateInfoQueryWhereSort
    on QueryBuilder<TagTranslateInfo, TagTranslateInfo, QWhere> {
  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TagTranslateInfoQueryWhere
    on QueryBuilder<TagTranslateInfo, TagTranslateInfo, QWhereClause> {
  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterWhereClause> idEqualTo(
      int id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterWhereClause>
      idNotEqualTo(int id) {
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

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterWhereClause>
      idGreaterThan(int id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterWhereClause>
      idLessThan(int id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterWhereClause> idBetween(
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
}

extension TagTranslateInfoQueryFilter
    on QueryBuilder<TagTranslateInfo, TagTranslateInfo, QFilterCondition> {
  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      idEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      idGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      idLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      idBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      localVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localVersion',
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      localVersionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      localVersionGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      localVersionLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      localVersionBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      localVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      localVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      localVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      localVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }
}

extension TagTranslateInfoQueryLinks
    on QueryBuilder<TagTranslateInfo, TagTranslateInfo, QFilterCondition> {}

extension TagTranslateInfoQueryWhereSortBy
    on QueryBuilder<TagTranslateInfo, TagTranslateInfo, QSortBy> {
  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterSortBy>
      sortByLocalVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localVersion', Sort.asc);
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterSortBy>
      sortByLocalVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localVersion', Sort.desc);
    });
  }
}

extension TagTranslateInfoQueryWhereSortThenBy
    on QueryBuilder<TagTranslateInfo, TagTranslateInfo, QSortThenBy> {
  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterSortBy>
      thenByLocalVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localVersion', Sort.asc);
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterSortBy>
      thenByLocalVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localVersion', Sort.desc);
    });
  }
}

extension TagTranslateInfoQueryWhereDistinct
    on QueryBuilder<TagTranslateInfo, TagTranslateInfo, QDistinct> {
  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QDistinct>
      distinctByLocalVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localVersion', caseSensitive: caseSensitive);
    });
  }
}

extension TagTranslateInfoQueryProperty
    on QueryBuilder<TagTranslateInfo, TagTranslateInfo, QQueryProperty> {
  QueryBuilder<TagTranslateInfo, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TagTranslateInfo, String?, QQueryOperations>
      localVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localVersion');
    });
  }
}
