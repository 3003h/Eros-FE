// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_image_task.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GalleryImageTaskCWProxy {
  GalleryImageTask filePath(String? filePath);

  GalleryImageTask gid(int gid);

  GalleryImageTask href(String? href);

  GalleryImageTask imageUrl(String? imageUrl);

  GalleryImageTask ser(int ser);

  GalleryImageTask sourceId(String? sourceId);

  GalleryImageTask status(int? status);

  GalleryImageTask token(String token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GalleryImageTask(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GalleryImageTask(...).copyWith(id: 12, name: "My name")
  /// ````
  GalleryImageTask call({
    String? filePath,
    int? gid,
    String? href,
    String? imageUrl,
    int? ser,
    String? sourceId,
    int? status,
    String? token,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGalleryImageTask.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGalleryImageTask.copyWith.fieldName(...)`
class _$GalleryImageTaskCWProxyImpl implements _$GalleryImageTaskCWProxy {
  final GalleryImageTask _value;

  const _$GalleryImageTaskCWProxyImpl(this._value);

  @override
  GalleryImageTask filePath(String? filePath) => this(filePath: filePath);

  @override
  GalleryImageTask gid(int gid) => this(gid: gid);

  @override
  GalleryImageTask href(String? href) => this(href: href);

  @override
  GalleryImageTask imageUrl(String? imageUrl) => this(imageUrl: imageUrl);

  @override
  GalleryImageTask ser(int ser) => this(ser: ser);

  @override
  GalleryImageTask sourceId(String? sourceId) => this(sourceId: sourceId);

  @override
  GalleryImageTask status(int? status) => this(status: status);

  @override
  GalleryImageTask token(String token) => this(token: token);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GalleryImageTask(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GalleryImageTask(...).copyWith(id: 12, name: "My name")
  /// ````
  GalleryImageTask call({
    Object? filePath = const $CopyWithPlaceholder(),
    Object? gid = const $CopyWithPlaceholder(),
    Object? href = const $CopyWithPlaceholder(),
    Object? imageUrl = const $CopyWithPlaceholder(),
    Object? ser = const $CopyWithPlaceholder(),
    Object? sourceId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
  }) {
    return GalleryImageTask(
      filePath: filePath == const $CopyWithPlaceholder()
          ? _value.filePath
          // ignore: cast_nullable_to_non_nullable
          : filePath as String?,
      gid: gid == const $CopyWithPlaceholder() || gid == null
          ? _value.gid
          // ignore: cast_nullable_to_non_nullable
          : gid as int,
      href: href == const $CopyWithPlaceholder()
          ? _value.href
          // ignore: cast_nullable_to_non_nullable
          : href as String?,
      imageUrl: imageUrl == const $CopyWithPlaceholder()
          ? _value.imageUrl
          // ignore: cast_nullable_to_non_nullable
          : imageUrl as String?,
      ser: ser == const $CopyWithPlaceholder() || ser == null
          ? _value.ser
          // ignore: cast_nullable_to_non_nullable
          : ser as int,
      sourceId: sourceId == const $CopyWithPlaceholder()
          ? _value.sourceId
          // ignore: cast_nullable_to_non_nullable
          : sourceId as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as int?,
      token: token == const $CopyWithPlaceholder() || token == null
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
    );
  }
}

extension $GalleryImageTaskCopyWith on GalleryImageTask {
  /// Returns a callable class that can be used as follows: `instanceOfGalleryImageTask.copyWith(...)` or like so:`instanceOfGalleryImageTask.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GalleryImageTaskCWProxy get copyWith => _$GalleryImageTaskCWProxyImpl(this);
}

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, unused_local_variable

extension GetGalleryImageTaskCollection on Isar {
  IsarCollection<GalleryImageTask> get galleryImageTasks => getCollection();
}

const GalleryImageTaskSchema = CollectionSchema(
  name: 'GalleryImageTask',
  schema:
      '{"name":"GalleryImageTask","idName":"id","properties":[{"name":"filePath","type":"String"},{"name":"gid","type":"Long"},{"name":"href","type":"String"},{"name":"imageUrl","type":"String"},{"name":"ser","type":"Long"},{"name":"sourceId","type":"String"},{"name":"status","type":"Long"},{"name":"token","type":"String"}],"indexes":[{"name":"gid","unique":false,"properties":[{"name":"gid","type":"Value","caseSensitive":false}]},{"name":"gid_ser","unique":true,"properties":[{"name":"gid","type":"Value","caseSensitive":false},{"name":"ser","type":"Value","caseSensitive":false}]}],"links":[]}',
  idName: 'id',
  propertyIds: {
    'filePath': 0,
    'gid': 1,
    'href': 2,
    'imageUrl': 3,
    'ser': 4,
    'sourceId': 5,
    'status': 6,
    'token': 7
  },
  listProperties: {},
  indexIds: {'gid': 0, 'gid_ser': 1},
  indexValueTypes: {
    'gid': [
      IndexValueType.long,
    ],
    'gid_ser': [
      IndexValueType.long,
      IndexValueType.long,
    ]
  },
  linkIds: {},
  backlinkLinkNames: {},
  getId: _galleryImageTaskGetId,
  setId: _galleryImageTaskSetId,
  getLinks: _galleryImageTaskGetLinks,
  attachLinks: _galleryImageTaskAttachLinks,
  serializeNative: _galleryImageTaskSerializeNative,
  deserializeNative: _galleryImageTaskDeserializeNative,
  deserializePropNative: _galleryImageTaskDeserializePropNative,
  serializeWeb: _galleryImageTaskSerializeWeb,
  deserializeWeb: _galleryImageTaskDeserializeWeb,
  deserializePropWeb: _galleryImageTaskDeserializePropWeb,
  version: 3,
);

int? _galleryImageTaskGetId(GalleryImageTask object) {
  if (object.id == Isar.autoIncrement) {
    return null;
  } else {
    return object.id;
  }
}

void _galleryImageTaskSetId(GalleryImageTask object, int id) {
  object.id = id;
}

List<IsarLinkBase> _galleryImageTaskGetLinks(GalleryImageTask object) {
  return [];
}

void _galleryImageTaskSerializeNative(
    IsarCollection<GalleryImageTask> collection,
    IsarRawObject rawObj,
    GalleryImageTask object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  var dynamicSize = 0;
  final value0 = object.filePath;
  IsarUint8List? _filePath;
  if (value0 != null) {
    _filePath = IsarBinaryWriter.utf8Encoder.convert(value0);
  }
  dynamicSize += (_filePath?.length ?? 0) as int;
  final value1 = object.gid;
  final _gid = value1;
  final value2 = object.href;
  IsarUint8List? _href;
  if (value2 != null) {
    _href = IsarBinaryWriter.utf8Encoder.convert(value2);
  }
  dynamicSize += (_href?.length ?? 0) as int;
  final value3 = object.imageUrl;
  IsarUint8List? _imageUrl;
  if (value3 != null) {
    _imageUrl = IsarBinaryWriter.utf8Encoder.convert(value3);
  }
  dynamicSize += (_imageUrl?.length ?? 0) as int;
  final value4 = object.ser;
  final _ser = value4;
  final value5 = object.sourceId;
  IsarUint8List? _sourceId;
  if (value5 != null) {
    _sourceId = IsarBinaryWriter.utf8Encoder.convert(value5);
  }
  dynamicSize += (_sourceId?.length ?? 0) as int;
  final value6 = object.status;
  final _status = value6;
  final value7 = object.token;
  final _token = IsarBinaryWriter.utf8Encoder.convert(value7);
  dynamicSize += (_token.length) as int;
  final size = staticSize + dynamicSize;

  rawObj.buffer = alloc(size);
  rawObj.buffer_length = size;
  final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], _filePath);
  writer.writeLong(offsets[1], _gid);
  writer.writeBytes(offsets[2], _href);
  writer.writeBytes(offsets[3], _imageUrl);
  writer.writeLong(offsets[4], _ser);
  writer.writeBytes(offsets[5], _sourceId);
  writer.writeLong(offsets[6], _status);
  writer.writeBytes(offsets[7], _token);
}

GalleryImageTask _galleryImageTaskDeserializeNative(
    IsarCollection<GalleryImageTask> collection,
    int id,
    IsarBinaryReader reader,
    List<int> offsets) {
  final object = GalleryImageTask(
    filePath: reader.readStringOrNull(offsets[0]),
    gid: reader.readLong(offsets[1]),
    href: reader.readStringOrNull(offsets[2]),
    imageUrl: reader.readStringOrNull(offsets[3]),
    ser: reader.readLong(offsets[4]),
    sourceId: reader.readStringOrNull(offsets[5]),
    status: reader.readLongOrNull(offsets[6]),
    token: reader.readString(offsets[7]),
  );
  object.id = id;
  return object;
}

P _galleryImageTaskDeserializePropNative<P>(
    int id, IsarBinaryReader reader, int propertyIndex, int offset) {
  switch (propertyIndex) {
    case -1:
      return id as P;
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw 'Illegal propertyIndex';
  }
}

dynamic _galleryImageTaskSerializeWeb(
    IsarCollection<GalleryImageTask> collection, GalleryImageTask object) {
  final jsObj = IsarNative.newJsObject();
  IsarNative.jsObjectSet(jsObj, 'filePath', object.filePath);
  IsarNative.jsObjectSet(jsObj, 'gid', object.gid);
  IsarNative.jsObjectSet(jsObj, 'href', object.href);
  IsarNative.jsObjectSet(jsObj, 'id', object.id);
  IsarNative.jsObjectSet(jsObj, 'imageUrl', object.imageUrl);
  IsarNative.jsObjectSet(jsObj, 'ser', object.ser);
  IsarNative.jsObjectSet(jsObj, 'sourceId', object.sourceId);
  IsarNative.jsObjectSet(jsObj, 'status', object.status);
  IsarNative.jsObjectSet(jsObj, 'token', object.token);
  return jsObj;
}

GalleryImageTask _galleryImageTaskDeserializeWeb(
    IsarCollection<GalleryImageTask> collection, dynamic jsObj) {
  final object = GalleryImageTask(
    filePath: IsarNative.jsObjectGet(jsObj, 'filePath'),
    gid: IsarNative.jsObjectGet(jsObj, 'gid') ?? double.negativeInfinity,
    href: IsarNative.jsObjectGet(jsObj, 'href'),
    imageUrl: IsarNative.jsObjectGet(jsObj, 'imageUrl'),
    ser: IsarNative.jsObjectGet(jsObj, 'ser') ?? double.negativeInfinity,
    sourceId: IsarNative.jsObjectGet(jsObj, 'sourceId'),
    status: IsarNative.jsObjectGet(jsObj, 'status'),
    token: IsarNative.jsObjectGet(jsObj, 'token') ?? '',
  );
  object.id = IsarNative.jsObjectGet(jsObj, 'id');
  return object;
}

P _galleryImageTaskDeserializePropWeb<P>(Object jsObj, String propertyName) {
  switch (propertyName) {
    case 'filePath':
      return (IsarNative.jsObjectGet(jsObj, 'filePath')) as P;
    case 'gid':
      return (IsarNative.jsObjectGet(jsObj, 'gid') ?? double.negativeInfinity)
          as P;
    case 'href':
      return (IsarNative.jsObjectGet(jsObj, 'href')) as P;
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'imageUrl':
      return (IsarNative.jsObjectGet(jsObj, 'imageUrl')) as P;
    case 'ser':
      return (IsarNative.jsObjectGet(jsObj, 'ser') ?? double.negativeInfinity)
          as P;
    case 'sourceId':
      return (IsarNative.jsObjectGet(jsObj, 'sourceId')) as P;
    case 'status':
      return (IsarNative.jsObjectGet(jsObj, 'status')) as P;
    case 'token':
      return (IsarNative.jsObjectGet(jsObj, 'token') ?? '') as P;
    default:
      throw 'Illegal propertyName';
  }
}

void _galleryImageTaskAttachLinks(
    IsarCollection col, int id, GalleryImageTask object) {}

extension GalleryImageTaskByIndex on IsarCollection<GalleryImageTask> {
  Future<GalleryImageTask?> getByGidSer(int gid, int ser) {
    return getByIndex('gid_ser', [gid, ser]);
  }

  GalleryImageTask? getByGidSerSync(int gid, int ser) {
    return getByIndexSync('gid_ser', [gid, ser]);
  }

  Future<bool> deleteByGidSer(int gid, int ser) {
    return deleteByIndex('gid_ser', [gid, ser]);
  }

  bool deleteByGidSerSync(int gid, int ser) {
    return deleteByIndexSync('gid_ser', [gid, ser]);
  }

  Future<List<GalleryImageTask?>> getAllByGidSer(
      List<int> gidValues, List<int> serValues) {
    final len = gidValues.length;
    assert(
        serValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([gidValues[i], serValues[i]]);
    }

    return getAllByIndex('gid_ser', values);
  }

  List<GalleryImageTask?> getAllByGidSerSync(
      List<int> gidValues, List<int> serValues) {
    final len = gidValues.length;
    assert(
        serValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([gidValues[i], serValues[i]]);
    }

    return getAllByIndexSync('gid_ser', values);
  }

  Future<int> deleteAllByGidSer(List<int> gidValues, List<int> serValues) {
    final len = gidValues.length;
    assert(
        serValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([gidValues[i], serValues[i]]);
    }

    return deleteAllByIndex('gid_ser', values);
  }

  int deleteAllByGidSerSync(List<int> gidValues, List<int> serValues) {
    final len = gidValues.length;
    assert(
        serValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([gidValues[i], serValues[i]]);
    }

    return deleteAllByIndexSync('gid_ser', values);
  }
}

extension GalleryImageTaskQueryWhereSort
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QWhere> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhere> anyId() {
    return addWhereClauseInternal(const IdWhereClause.any());
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhere> anyGid() {
    return addWhereClauseInternal(const IndexWhereClause.any(indexName: 'gid'));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhere> anyGidSer() {
    return addWhereClauseInternal(
        const IndexWhereClause.any(indexName: 'gid_ser'));
  }
}

extension GalleryImageTaskQueryWhere
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QWhereClause> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause> idEqualTo(
      int id) {
    return addWhereClauseInternal(IdWhereClause.between(
      lower: id,
      includeLower: true,
      upper: id,
      includeUpper: true,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      idNotEqualTo(int id) {
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      idGreaterThan(int id, {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.greaterThan(lower: id, includeLower: include),
    );
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      idLessThan(int id, {bool include = false}) {
    return addWhereClauseInternal(
      IdWhereClause.lessThan(upper: id, includeUpper: include),
    );
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause> idBetween(
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidEqualTo(int gid) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'gid',
      value: [gid],
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidNotEqualTo(int gid) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'gid',
        upper: [gid],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'gid',
        lower: [gid],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'gid',
        lower: [gid],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'gid',
        upper: [gid],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidGreaterThan(
    int gid, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'gid',
      lower: [gid],
      includeLower: include,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidLessThan(
    int gid, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'gid',
      upper: [gid],
      includeUpper: include,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidBetween(
    int lowerGid,
    int upperGid, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'gid',
      lower: [lowerGid],
      includeLower: includeLower,
      upper: [upperGid],
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidSerEqualTo(int gid, int ser) {
    return addWhereClauseInternal(IndexWhereClause.equalTo(
      indexName: 'gid_ser',
      value: [gid, ser],
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidSerNotEqualTo(int gid, int ser) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'gid_ser',
        upper: [gid, ser],
        includeUpper: false,
      )).addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'gid_ser',
        lower: [gid, ser],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(IndexWhereClause.greaterThan(
        indexName: 'gid_ser',
        lower: [gid, ser],
        includeLower: false,
      )).addWhereClauseInternal(IndexWhereClause.lessThan(
        indexName: 'gid_ser',
        upper: [gid, ser],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidEqualToSerGreaterThan(
    int gid,
    int ser, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.greaterThan(
      indexName: 'gid_ser',
      lower: [gid, ser],
      includeLower: include,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidEqualToSerLessThan(
    int gid,
    int ser, {
    bool include = false,
  }) {
    return addWhereClauseInternal(IndexWhereClause.lessThan(
      indexName: 'gid_ser',
      upper: [gid, ser],
      includeUpper: include,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidEqualToSerBetween(
    int gid,
    int lowerSer,
    int upperSer, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(IndexWhereClause.between(
      indexName: 'gid_ser',
      lower: [gid, lowerSer],
      includeLower: includeLower,
      upper: [gid, upperSer],
      includeUpper: includeUpper,
    ));
  }
}

extension GalleryImageTaskQueryFilter
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QFilterCondition> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'filePath',
      value: null,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'filePath',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'filePath',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'filePath',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'filePath',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'filePath',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'filePath',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'filePath',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'filePath',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      gidEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'gid',
      value: value,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      gidGreaterThan(
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      gidLessThan(
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      gidBetween(
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'href',
      value: null,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'href',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'href',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'href',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'href',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'href',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'href',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'href',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'href',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      idEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'imageUrl',
      value: null,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'imageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'imageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'imageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'imageUrl',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'imageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'imageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'imageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'imageUrl',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      serEqualTo(int value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'ser',
      value: value,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      serGreaterThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'ser',
      value: value,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      serLessThan(
    int value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'ser',
      value: value,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      serBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'ser',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'sourceId',
      value: null,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'sourceId',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'sourceId',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'sourceId',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'sourceId',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'sourceId',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'sourceId',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'sourceId',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'sourceId',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'status',
      value: null,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusEqualTo(int? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'status',
      value: value,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'status',
      value: value,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusLessThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'status',
      value: value,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'status',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'token',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'token',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'token',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'token',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'token',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'token',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenContains(String value, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'token',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenMatches(String pattern, {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'token',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension GalleryImageTaskQueryLinks
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QFilterCondition> {}

extension GalleryImageTaskQueryWhereSortBy
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QSortBy> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByFilePath() {
    return addSortByInternal('filePath', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByFilePathDesc() {
    return addSortByInternal('filePath', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortByGid() {
    return addSortByInternal('gid', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByGidDesc() {
    return addSortByInternal('gid', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortByHref() {
    return addSortByInternal('href', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByHrefDesc() {
    return addSortByInternal('href', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByImageUrl() {
    return addSortByInternal('imageUrl', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByImageUrlDesc() {
    return addSortByInternal('imageUrl', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortBySer() {
    return addSortByInternal('ser', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortBySerDesc() {
    return addSortByInternal('ser', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortBySourceId() {
    return addSortByInternal('sourceId', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortBySourceIdDesc() {
    return addSortByInternal('sourceId', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByStatus() {
    return addSortByInternal('status', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByStatusDesc() {
    return addSortByInternal('status', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortByToken() {
    return addSortByInternal('token', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByTokenDesc() {
    return addSortByInternal('token', Sort.desc);
  }
}

extension GalleryImageTaskQueryWhereSortThenBy
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QSortThenBy> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByFilePath() {
    return addSortByInternal('filePath', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByFilePathDesc() {
    return addSortByInternal('filePath', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenByGid() {
    return addSortByInternal('gid', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByGidDesc() {
    return addSortByInternal('gid', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenByHref() {
    return addSortByInternal('href', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByHrefDesc() {
    return addSortByInternal('href', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByImageUrl() {
    return addSortByInternal('imageUrl', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByImageUrlDesc() {
    return addSortByInternal('imageUrl', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenBySer() {
    return addSortByInternal('ser', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenBySerDesc() {
    return addSortByInternal('ser', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenBySourceId() {
    return addSortByInternal('sourceId', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenBySourceIdDesc() {
    return addSortByInternal('sourceId', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByStatus() {
    return addSortByInternal('status', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByStatusDesc() {
    return addSortByInternal('status', Sort.desc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenByToken() {
    return addSortByInternal('token', Sort.asc);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByTokenDesc() {
    return addSortByInternal('token', Sort.desc);
  }
}

extension GalleryImageTaskQueryWhereDistinct
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct>
      distinctByFilePath({bool caseSensitive = true}) {
    return addDistinctByInternal('filePath', caseSensitive: caseSensitive);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctByGid() {
    return addDistinctByInternal('gid');
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctByHref(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('href', caseSensitive: caseSensitive);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct>
      distinctByImageUrl({bool caseSensitive = true}) {
    return addDistinctByInternal('imageUrl', caseSensitive: caseSensitive);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctBySer() {
    return addDistinctByInternal('ser');
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct>
      distinctBySourceId({bool caseSensitive = true}) {
    return addDistinctByInternal('sourceId', caseSensitive: caseSensitive);
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct>
      distinctByStatus() {
    return addDistinctByInternal('status');
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctByToken(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('token', caseSensitive: caseSensitive);
  }
}

extension GalleryImageTaskQueryProperty
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QQueryProperty> {
  QueryBuilder<GalleryImageTask, String?, QQueryOperations> filePathProperty() {
    return addPropertyNameInternal('filePath');
  }

  QueryBuilder<GalleryImageTask, int, QQueryOperations> gidProperty() {
    return addPropertyNameInternal('gid');
  }

  QueryBuilder<GalleryImageTask, String?, QQueryOperations> hrefProperty() {
    return addPropertyNameInternal('href');
  }

  QueryBuilder<GalleryImageTask, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<GalleryImageTask, String?, QQueryOperations> imageUrlProperty() {
    return addPropertyNameInternal('imageUrl');
  }

  QueryBuilder<GalleryImageTask, int, QQueryOperations> serProperty() {
    return addPropertyNameInternal('ser');
  }

  QueryBuilder<GalleryImageTask, String?, QQueryOperations> sourceIdProperty() {
    return addPropertyNameInternal('sourceId');
  }

  QueryBuilder<GalleryImageTask, int?, QQueryOperations> statusProperty() {
    return addPropertyNameInternal('status');
  }

  QueryBuilder<GalleryImageTask, String, QQueryOperations> tokenProperty() {
    return addPropertyNameInternal('token');
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryImageTask _$GalleryImageTaskFromJson(Map<String, dynamic> json) =>
    GalleryImageTask(
      gid: json['gid'] as int,
      token: json['token'] as String,
      href: json['href'] as String?,
      sourceId: json['sourceId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      ser: json['ser'] as int,
      filePath: json['filePath'] as String?,
      status: json['status'] as int?,
    )..id = json['id'] as int?;

Map<String, dynamic> _$GalleryImageTaskToJson(GalleryImageTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gid': instance.gid,
      'ser': instance.ser,
      'token': instance.token,
      'href': instance.href,
      'sourceId': instance.sourceId,
      'imageUrl': instance.imageUrl,
      'filePath': instance.filePath,
      'status': instance.status,
    };
