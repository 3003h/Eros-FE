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
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetTagTranslateInfoCollection on Isar {
  IsarCollection<TagTranslateInfo> get tagTranslateInfos => this.collection();
}

const TagTranslateInfoSchema = CollectionSchema(
  name: r'TagTranslateInfo',
  id: -257380212034583058,
  properties: {
    r'localVersion': PropertySchema(
      id: 0,
      name: r'localVersion',
      type: IsarType.string,
    )
  },
  estimateSize: _tagTranslateInfoEstimateSize,
  serialize: _tagTranslateInfoSerialize,
  deserialize: _tagTranslateInfoDeserialize,
  deserializeProp: _tagTranslateInfoDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _tagTranslateInfoGetId,
  getLinks: _tagTranslateInfoGetLinks,
  attach: _tagTranslateInfoAttach,
  version: '3.0.2',
);

int _tagTranslateInfoEstimateSize(
  TagTranslateInfo object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.localVersion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _tagTranslateInfoSerialize(
  TagTranslateInfo object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.localVersion);
}

TagTranslateInfo _tagTranslateInfoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TagTranslateInfo(
    localVersion: reader.readStringOrNull(offsets[0]),
  );
  object.id = id;
  return object;
}

P _tagTranslateInfoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tagTranslateInfoGetId(TagTranslateInfo object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tagTranslateInfoGetLinks(TagTranslateInfo object) {
  return [];
}

void _tagTranslateInfoAttach(
    IsarCollection<dynamic> col, Id id, TagTranslateInfo object) {
  object.id = id;
}

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
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterWhereClause>
      idNotEqualTo(Id id) {
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
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
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
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
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
    Id value, {
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
    Id lower,
    Id upper, {
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
      localVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
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
    bool include = false,
    bool caseSensitive = true,
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
    bool include = false,
    bool caseSensitive = true,
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
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
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

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      localVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<TagTranslateInfo, TagTranslateInfo, QAfterFilterCondition>
      localVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localVersion',
        value: '',
      ));
    });
  }
}

extension TagTranslateInfoQueryObject
    on QueryBuilder<TagTranslateInfo, TagTranslateInfo, QFilterCondition> {}

extension TagTranslateInfoQueryLinks
    on QueryBuilder<TagTranslateInfo, TagTranslateInfo, QFilterCondition> {}

extension TagTranslateInfoQuerySortBy
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

extension TagTranslateInfoQuerySortThenBy
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
