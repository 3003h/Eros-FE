// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_history.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ViewHistoryCWProxy {
  ViewHistory gid(int gid);

  ViewHistory lastViewTime(int lastViewTime);

  ViewHistory galleryProviderText(String galleryProviderText);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ViewHistory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ViewHistory(...).copyWith(id: 12, name: "My name")
  /// ````
  ViewHistory call({
    int? gid,
    int? lastViewTime,
    String? galleryProviderText,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfViewHistory.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfViewHistory.copyWith.fieldName(...)`
class _$ViewHistoryCWProxyImpl implements _$ViewHistoryCWProxy {
  const _$ViewHistoryCWProxyImpl(this._value);

  final ViewHistory _value;

  @override
  ViewHistory gid(int gid) => this(gid: gid);

  @override
  ViewHistory lastViewTime(int lastViewTime) =>
      this(lastViewTime: lastViewTime);

  @override
  ViewHistory galleryProviderText(String galleryProviderText) =>
      this(galleryProviderText: galleryProviderText);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ViewHistory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ViewHistory(...).copyWith(id: 12, name: "My name")
  /// ````
  ViewHistory call({
    Object? gid = const $CopyWithPlaceholder(),
    Object? lastViewTime = const $CopyWithPlaceholder(),
    Object? galleryProviderText = const $CopyWithPlaceholder(),
  }) {
    return ViewHistory(
      gid: gid == const $CopyWithPlaceholder() || gid == null
          ? _value.gid
          // ignore: cast_nullable_to_non_nullable
          : gid as int,
      lastViewTime:
          lastViewTime == const $CopyWithPlaceholder() || lastViewTime == null
              ? _value.lastViewTime
              // ignore: cast_nullable_to_non_nullable
              : lastViewTime as int,
      galleryProviderText:
          galleryProviderText == const $CopyWithPlaceholder() ||
                  galleryProviderText == null
              ? _value.galleryProviderText
              // ignore: cast_nullable_to_non_nullable
              : galleryProviderText as String,
    );
  }
}

extension $ViewHistoryCopyWith on ViewHistory {
  /// Returns a callable class that can be used as follows: `instanceOfViewHistory.copyWith(...)` or like so:`instanceOfViewHistory.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ViewHistoryCWProxy get copyWith => _$ViewHistoryCWProxyImpl(this);
}

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetViewHistoryCollection on Isar {
  IsarCollection<ViewHistory> get viewHistorys => this.collection();
}

const ViewHistorySchema = CollectionSchema(
  name: r'ViewHistory',
  id: -689102202586410121,
  properties: {
    r'galleryProviderText': PropertySchema(
      id: 0,
      name: r'galleryProviderText',
      type: IsarType.string,
    ),
    r'lastViewTime': PropertySchema(
      id: 1,
      name: r'lastViewTime',
      type: IsarType.long,
    )
  },
  estimateSize: _viewHistoryEstimateSize,
  serialize: _viewHistorySerialize,
  deserialize: _viewHistoryDeserialize,
  deserializeProp: _viewHistoryDeserializeProp,
  idName: r'gid',
  indexes: {
    r'lastViewTime': IndexSchema(
      id: 9140181846964812605,
      name: r'lastViewTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastViewTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _viewHistoryGetId,
  getLinks: _viewHistoryGetLinks,
  attach: _viewHistoryAttach,
  version: '3.1.0+1',
);

int _viewHistoryEstimateSize(
  ViewHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.galleryProviderText.length * 3;
  return bytesCount;
}

void _viewHistorySerialize(
  ViewHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.galleryProviderText);
  writer.writeLong(offsets[1], object.lastViewTime);
}

ViewHistory _viewHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ViewHistory(
    galleryProviderText: reader.readString(offsets[0]),
    gid: id,
    lastViewTime: reader.readLong(offsets[1]),
  );
  return object;
}

P _viewHistoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _viewHistoryGetId(ViewHistory object) {
  return object.gid;
}

List<IsarLinkBase<dynamic>> _viewHistoryGetLinks(ViewHistory object) {
  return [];
}

void _viewHistoryAttach(
    IsarCollection<dynamic> col, Id id, ViewHistory object) {}

extension ViewHistoryQueryWhereSort
    on QueryBuilder<ViewHistory, ViewHistory, QWhere> {
  QueryBuilder<ViewHistory, ViewHistory, QAfterWhere> anyGid() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhere> anyLastViewTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastViewTime'),
      );
    });
  }
}

extension ViewHistoryQueryWhere
    on QueryBuilder<ViewHistory, ViewHistory, QWhereClause> {
  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> gidEqualTo(Id gid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: gid,
        upper: gid,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> gidNotEqualTo(
      Id gid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: gid, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: gid, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: gid, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: gid, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> gidGreaterThan(
      Id gid,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: gid, includeLower: include),
      );
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> gidLessThan(Id gid,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: gid, includeUpper: include),
      );
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> gidBetween(
    Id lowerGid,
    Id upperGid, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerGid,
        includeLower: includeLower,
        upper: upperGid,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> lastViewTimeEqualTo(
      int lastViewTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastViewTime',
        value: [lastViewTime],
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause>
      lastViewTimeNotEqualTo(int lastViewTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastViewTime',
              lower: [],
              upper: [lastViewTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastViewTime',
              lower: [lastViewTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastViewTime',
              lower: [lastViewTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastViewTime',
              lower: [],
              upper: [lastViewTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause>
      lastViewTimeGreaterThan(
    int lastViewTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastViewTime',
        lower: [lastViewTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause>
      lastViewTimeLessThan(
    int lastViewTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastViewTime',
        lower: [],
        upper: [lastViewTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> lastViewTimeBetween(
    int lowerLastViewTime,
    int upperLastViewTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastViewTime',
        lower: [lowerLastViewTime],
        includeLower: includeLower,
        upper: [upperLastViewTime],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ViewHistoryQueryFilter
    on QueryBuilder<ViewHistory, ViewHistory, QFilterCondition> {
  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'galleryProviderText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'galleryProviderText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'galleryProviderText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'galleryProviderText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'galleryProviderText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'galleryProviderText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'galleryProviderText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'galleryProviderText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'galleryProviderText',
        value: '',
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'galleryProviderText',
        value: '',
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition> gidEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gid',
        value: value,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition> gidGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gid',
        value: value,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition> gidLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gid',
        value: value,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition> gidBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      lastViewTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastViewTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      lastViewTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastViewTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      lastViewTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastViewTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      lastViewTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastViewTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ViewHistoryQueryObject
    on QueryBuilder<ViewHistory, ViewHistory, QFilterCondition> {}

extension ViewHistoryQueryLinks
    on QueryBuilder<ViewHistory, ViewHistory, QFilterCondition> {}

extension ViewHistoryQuerySortBy
    on QueryBuilder<ViewHistory, ViewHistory, QSortBy> {
  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy>
      sortByGalleryProviderText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'galleryProviderText', Sort.asc);
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy>
      sortByGalleryProviderTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'galleryProviderText', Sort.desc);
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy> sortByLastViewTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewTime', Sort.asc);
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy>
      sortByLastViewTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewTime', Sort.desc);
    });
  }
}

extension ViewHistoryQuerySortThenBy
    on QueryBuilder<ViewHistory, ViewHistory, QSortThenBy> {
  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy>
      thenByGalleryProviderText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'galleryProviderText', Sort.asc);
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy>
      thenByGalleryProviderTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'galleryProviderText', Sort.desc);
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy> thenByGid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gid', Sort.asc);
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy> thenByGidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gid', Sort.desc);
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy> thenByLastViewTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewTime', Sort.asc);
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy>
      thenByLastViewTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewTime', Sort.desc);
    });
  }
}

extension ViewHistoryQueryWhereDistinct
    on QueryBuilder<ViewHistory, ViewHistory, QDistinct> {
  QueryBuilder<ViewHistory, ViewHistory, QDistinct>
      distinctByGalleryProviderText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'galleryProviderText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ViewHistory, ViewHistory, QDistinct> distinctByLastViewTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastViewTime');
    });
  }
}

extension ViewHistoryQueryProperty
    on QueryBuilder<ViewHistory, ViewHistory, QQueryProperty> {
  QueryBuilder<ViewHistory, int, QQueryOperations> gidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gid');
    });
  }

  QueryBuilder<ViewHistory, String, QQueryOperations>
      galleryProviderTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'galleryProviderText');
    });
  }

  QueryBuilder<ViewHistory, int, QQueryOperations> lastViewTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastViewTime');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewHistory _$ViewHistoryFromJson(Map<String, dynamic> json) => ViewHistory(
      gid: (json['gid'] as num).toInt(),
      lastViewTime: (json['lastViewTime'] as num).toInt(),
      galleryProviderText: json['galleryProviderText'] as String,
    );

Map<String, dynamic> _$ViewHistoryToJson(ViewHistory instance) =>
    <String, dynamic>{
      'gid': instance.gid,
      'lastViewTime': instance.lastViewTime,
      'galleryProviderText': instance.galleryProviderText,
    };
