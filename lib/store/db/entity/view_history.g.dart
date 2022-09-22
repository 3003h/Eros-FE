// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_history.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ViewHistoryCWProxy {
  ViewHistory galleryProviderText(String galleryProviderText);

  ViewHistory gid(int gid);

  ViewHistory lastViewTime(int lastViewTime);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ViewHistory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ViewHistory(...).copyWith(id: 12, name: "My name")
  /// ````
  ViewHistory call({
    String? galleryProviderText,
    int? gid,
    int? lastViewTime,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfViewHistory.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfViewHistory.copyWith.fieldName(...)`
class _$ViewHistoryCWProxyImpl implements _$ViewHistoryCWProxy {
  final ViewHistory _value;

  const _$ViewHistoryCWProxyImpl(this._value);

  @override
  ViewHistory galleryProviderText(String galleryProviderText) =>
      this(galleryProviderText: galleryProviderText);

  @override
  ViewHistory gid(int gid) => this(gid: gid);

  @override
  ViewHistory lastViewTime(int lastViewTime) =>
      this(lastViewTime: lastViewTime);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ViewHistory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ViewHistory(...).copyWith(id: 12, name: "My name")
  /// ````
  ViewHistory call({
    Object? galleryProviderText = const $CopyWithPlaceholder(),
    Object? gid = const $CopyWithPlaceholder(),
    Object? lastViewTime = const $CopyWithPlaceholder(),
  }) {
    return ViewHistory(
      galleryProviderText:
          galleryProviderText == const $CopyWithPlaceholder() ||
                  galleryProviderText == null
              ? _value.galleryProviderText
              // ignore: cast_nullable_to_non_nullable
              : galleryProviderText as String,
      gid: gid == const $CopyWithPlaceholder() || gid == null
          ? _value.gid
          // ignore: cast_nullable_to_non_nullable
          : gid as int,
      lastViewTime:
          lastViewTime == const $CopyWithPlaceholder() || lastViewTime == null
              ? _value.lastViewTime
              // ignore: cast_nullable_to_non_nullable
              : lastViewTime as int,
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

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable

extension GetViewHistoryCollection on Isar {
  IsarCollection<ViewHistory> get viewHistorys => getCollection();
}

const ViewHistorySchema = CollectionSchema(
  name: 'ViewHistory',
  schema:
      '{"name":"ViewHistory","idName":"gid","properties":[{"name":"galleryProviderText","type":"String"},{"name":"lastViewTime","type":"Long"}],"indexes":[{"name":"lastViewTime","unique":false,"properties":[{"name":"lastViewTime","type":"Value","caseSensitive":false}]}],"links":[]}',
  idName: 'gid',
  propertyIds: {'galleryProviderText': 0, 'lastViewTime': 1},
  listProperties: {},
  indexIds: {'lastViewTime': 0},
  indexValueTypes: {
    'lastViewTime': [
      IndexValueType.long,
    ]
  },
  linkIds: {},
  backlinkLinkNames: {},
  getId: _viewHistoryGetId,
  getLinks: _viewHistoryGetLinks,
  attachLinks: _viewHistoryAttachLinks,
  serializeNative: _viewHistorySerializeNative,
  deserializeNative: _viewHistoryDeserializeNative,
  deserializePropNative: _viewHistoryDeserializePropNative,
  serializeWeb: _viewHistorySerializeWeb,
  deserializeWeb: _viewHistoryDeserializeWeb,
  deserializePropWeb: _viewHistoryDeserializePropWeb,
  version: 3,
);

int? _viewHistoryGetId(ViewHistory object) {
  if (object.gid == Isar.autoIncrement) {
    return null;
  } else {
    return object.gid;
  }
}

List<IsarLinkBase> _viewHistoryGetLinks(ViewHistory object) {
  return [];
}

void _viewHistorySerializeNative(
    IsarCollection<ViewHistory> collection,
    IsarRawObject rawObj,
    ViewHistory object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = object.galleryProviderText;
  final _galleryProviderText = IsarBinaryWriter.utf8Encoder.convert(value0);
  dynamicSize += (_galleryProviderText.length) as int;
  final value1 = object.lastViewTime;
  final _lastViewTime = value1;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _galleryProviderText);
  writer.writeLong(offsets[1], _lastViewTime);
}

ViewHistory _viewHistoryDeserializeNative(
    IsarCollection<ViewHistory> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = ViewHistory(
    galleryProviderText: reader.readString(offsets[0]),
    gid: id,
    lastViewTime: reader.readLong(offsets[1]),
  );
  return object;
}

P _viewHistoryDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _viewHistorySerializeWeb(
    IsarCollection<ViewHistory> collection, ViewHistory object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(
      jsObj, 'galleryProviderText', object.galleryProviderText);
  IsarNative.jsObjectSet(jsObj, 'gid', object.gid);
  IsarNative.jsObjectSet(jsObj, 'lastViewTime', object.lastViewTime);
  return jsObj;
}

ViewHistory _viewHistoryDeserializeWeb(
    IsarCollection<ViewHistory> collection, dynamic jsObj) {
  final object = ViewHistory(
    galleryProviderText:
        IsarNative.jsObjectGet(jsObj, 'galleryProviderText') ?? '',
    gid: IsarNative.jsObjectGet(jsObj, 'gid') ?? double.negativeInfinity,
    lastViewTime: IsarNative.jsObjectGet(jsObj, 'lastViewTime') ??
        double.negativeInfinity,
  );
  return object;
}

P _viewHistoryDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'galleryProviderText':
      return (IsarNative.jsObjectGet(jsObj, 'galleryProviderText') ?? '') as P;
    case 'gid':
      return (IsarNative.jsObjectGet(jsObj, 'gid') ?? double.negativeInfinity)
          as P;
    case 'lastViewTime':
      return (IsarNative.jsObjectGet(jsObj, 'lastViewTime') ??
          double.negativeInfinity) as P;
    default:
      throw 'Illegal propertyName';
  }
}

void _viewHistoryAttachLinks(IsarCollection col, int id, ViewHistory object) {}

extension ViewHistoryQueryWhereSort
    on QueryBuilder<ViewHistory, ViewHistory, QWhere> {
  QueryBuilder<ViewHistory, ViewHistory, QAfterWhere> anyGid() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhere> anyLastViewTime() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'lastViewTime'));
  }
}

extension ViewHistoryQueryWhere
    on QueryBuilder<ViewHistory, ViewHistory, QWhereClause> {
  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> gidEqualTo(
      int gid) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: gid,
      includeLower: true,
      upper: gid,
      includeUpper: true,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> gidNotEqualTo(
      int gid) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(
        IdWhereClause.lessThan(upper: gid, includeUpper: false),
      ).addWhereClauseInternal(
        IdWhereClause.greaterThan(lower: gid, includeLower: false),
      );
    } else {
      return addWhereClauseInternal(
        IdWhereClause.greaterThan(lower: gid, includeLower: false),
      ).addWhereClauseInternal(
        IdWhereClause.lessThan(upper: gid, includeUpper: false),
      );
    }
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> gidGreaterThan(
      int gid,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: gid, includeLower: include),
    );
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> gidLessThan(int gid,
      {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: gid, includeUpper: include),
    );
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> gidBetween(
    int lowerGid,
    int upperGid, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: lowerGid,
      includeLower: includeLower,
      upper: upperGid,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> lastViewTimeEqualTo(
      int lastViewTime) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'lastViewTime',
      value: [lastViewTime],
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause>
      lastViewTimeNotEqualTo(int lastViewTime) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'lastViewTime',
        upper: [lastViewTime],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'lastViewTime',
        lower: [lastViewTime],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'lastViewTime',
        lower: [lastViewTime],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'lastViewTime',
        upper: [lastViewTime],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause>
      lastViewTimeGreaterThan(
    int lastViewTime, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'lastViewTime',
      lower: [lastViewTime],
      includeLower: include,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause>
      lastViewTimeLessThan(
    int lastViewTime, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'lastViewTime',
      upper: [lastViewTime],
      includeUpper: include,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterWhereClause> lastViewTimeBetween(
    int lowerLastViewTime,
    int upperLastViewTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'lastViewTime',
      lower: [lowerLastViewTime],
      includeLower: includeLower,
      upper: [upperLastViewTime],
      includeUpper: includeUpper,
    ));
  }
}

extension ViewHistoryQueryFilter
    on QueryBuilder<ViewHistory, ViewHistory, QFilterCondition> {
  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'galleryProviderText',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'galleryProviderText',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'galleryProviderText',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'galleryProviderText',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'galleryProviderText',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'galleryProviderText',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'galleryProviderText',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      galleryProviderTextMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'galleryProviderText',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition> gidEqualTo(
      int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'gid',
      value: value,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition> gidGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'gid',
      value: value,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition> gidLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'gid',
      value: value,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition> gidBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'gid',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      lastViewTimeEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'lastViewTime',
      value: value,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      lastViewTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'lastViewTime',
      value: value,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      lastViewTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'lastViewTime',
      value: value,
    ));
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterFilterCondition>
      lastViewTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'lastViewTime',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }
}

extension ViewHistoryQueryLinks
    on QueryBuilder<ViewHistory, ViewHistory, QFilterCondition> {}

extension ViewHistoryQueryWhereSortBy
    on QueryBuilder<ViewHistory, ViewHistory, QSortBy> {
  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy>
      sortByGalleryProviderText() {
    return addSortByInternal('galleryProviderText', Sort.asc);
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy>
      sortByGalleryProviderTextDesc() {
    return addSortByInternal('galleryProviderText', Sort.desc);
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy> sortByGid() {
    return addSortByInternal('gid', Sort.asc);
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy> sortByGidDesc() {
    return addSortByInternal('gid', Sort.desc);
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy> sortByLastViewTime() {
    return addSortByInternal('lastViewTime', Sort.asc);
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy>
      sortByLastViewTimeDesc() {
    return addSortByInternal('lastViewTime', Sort.desc);
  }
}

extension ViewHistoryQueryWhereSortThenBy
    on QueryBuilder<ViewHistory, ViewHistory, QSortThenBy> {
  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy>
      thenByGalleryProviderText() {
    return addSortByInternal('galleryProviderText', Sort.asc);
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy>
      thenByGalleryProviderTextDesc() {
    return addSortByInternal('galleryProviderText', Sort.desc);
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy> thenByGid() {
    return addSortByInternal('gid', Sort.asc);
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy> thenByGidDesc() {
    return addSortByInternal('gid', Sort.desc);
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy> thenByLastViewTime() {
    return addSortByInternal('lastViewTime', Sort.asc);
  }

  QueryBuilder<ViewHistory, ViewHistory, QAfterSortBy>
      thenByLastViewTimeDesc() {
    return addSortByInternal('lastViewTime', Sort.desc);
  }
}

extension ViewHistoryQueryWhereDistinct
    on QueryBuilder<ViewHistory, ViewHistory, QDistinct> {
  QueryBuilder<ViewHistory, ViewHistory, QDistinct>
      distinctByGalleryProviderText({bool caseSensitive = true}) {
    return addDistinctByInternal('galleryProviderText',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<ViewHistory, ViewHistory, QDistinct> distinctByGid() {
    return addDistinctByInternal('gid');
  }

  QueryBuilder<ViewHistory, ViewHistory, QDistinct> distinctByLastViewTime() {
    return addDistinctByInternal('lastViewTime');
  }
}

extension ViewHistoryQueryProperty
    on QueryBuilder<ViewHistory, ViewHistory, QQueryProperty> {
  QueryBuilder<ViewHistory, String, QQueryOperations>
      galleryProviderTextProperty() {
    return addPropertyNameInternal('galleryProviderText');
  }

  QueryBuilder<ViewHistory, int, QQueryOperations> gidProperty() {
    return addPropertyNameInternal('gid');
  }

  QueryBuilder<ViewHistory, int, QQueryOperations> lastViewTimeProperty() {
    return addPropertyNameInternal('lastViewTime');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewHistory _$ViewHistoryFromJson(Map<String, dynamic> json) => ViewHistory(
      gid: json['gid'] as int,
      lastViewTime: json['lastViewTime'] as int,
      galleryProviderText: json['galleryProviderText'] as String,
    );

Map<String, dynamic> _$ViewHistoryToJson(ViewHistory instance) =>
    <String, dynamic>{
      'gid': instance.gid,
      'lastViewTime': instance.lastViewTime,
      'galleryProviderText': instance.galleryProviderText,
    };
