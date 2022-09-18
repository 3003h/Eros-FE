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

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names,
// constant_identifier_names, invalid_use_of_protected_member,
// unnecessary_cast, unused_local_variable,
// no_leading_underscores_for_local_identifiers,
// inference_failure_on_function_invocation, prefer_const_constructors

extension GetGalleryImageTaskCollection on Isar {
  IsarCollection<GalleryImageTask> get galleryImageTasks => getCollection();
}

const GalleryImageTaskSchema = CollectionSchema(
  name: 'GalleryImageTask',
  schema:
      '{"name":"GalleryImageTask","idName":"id","properties":[{"name":"filePath","type":"String"},{"name":"gid","type":"Long"},{"name":"href","type":"String"},{"name":"imageUrl","type":"String"},{"name":"ser","type":"Long"},{"name":"sourceId","type":"String"},{"name":"status","type":"Long"},{"name":"token","type":"String"}],"indexes":[{"name":"gid","unique":false,"replace":false,"properties":[{"name":"gid","type":"Value","caseSensitive":false}]},{"name":"gid_ser","unique":true,"replace":false,"properties":[{"name":"gid","type":"Value","caseSensitive":false},{"name":"ser","type":"Value","caseSensitive":false}]}],"links":[]}',
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
  version: 4,
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

List<IsarLinkBase<dynamic>> _galleryImageTaskGetLinks(GalleryImageTask object) {
  return [];
}

void _galleryImageTaskSerializeNative(
    IsarCollection<GalleryImageTask> collection,
    IsarCObject cObj,
    GalleryImageTask object,
    int staticSize,
    List<int> offsets,
    AdapterAlloc alloc) {
  IsarUint8List? filePath$Bytes;
  final filePath$Value = object.filePath;
  if (filePath$Value != null) {
    filePath$Bytes = IsarBinaryWriter.utf8Encoder.convert(filePath$Value);
  }
  IsarUint8List? href$Bytes;
  final href$Value = object.href;
  if (href$Value != null) {
    href$Bytes = IsarBinaryWriter.utf8Encoder.convert(href$Value);
  }
  IsarUint8List? imageUrl$Bytes;
  final imageUrl$Value = object.imageUrl;
  if (imageUrl$Value != null) {
    imageUrl$Bytes = IsarBinaryWriter.utf8Encoder.convert(imageUrl$Value);
  }
  IsarUint8List? sourceId$Bytes;
  final sourceId$Value = object.sourceId;
  if (sourceId$Value != null) {
    sourceId$Bytes = IsarBinaryWriter.utf8Encoder.convert(sourceId$Value);
  }
  final token$Bytes = IsarBinaryWriter.utf8Encoder.convert(object.token);
  final size = (staticSize +
      (filePath$Bytes?.length ?? 0) +
      (href$Bytes?.length ?? 0) +
      (imageUrl$Bytes?.length ?? 0) +
      (sourceId$Bytes?.length ?? 0) +
      (token$Bytes.length)) as int;
  cObj.buffer = alloc(size);
  cObj.buffer_length = size;

  final buffer = IsarNative.bufAsBytes(cObj.buffer, size);
  final writer = IsarBinaryWriter(buffer, staticSize);
  writer.writeBytes(offsets[0], filePath$Bytes);
  writer.writeLong(offsets[1], object.gid);
  writer.writeBytes(offsets[2], href$Bytes);
  writer.writeBytes(offsets[3], imageUrl$Bytes);
  writer.writeLong(offsets[4], object.ser);
  writer.writeBytes(offsets[5], sourceId$Bytes);
  writer.writeLong(offsets[6], object.status);
  writer.writeBytes(offsets[7], token$Bytes);
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

Object _galleryImageTaskSerializeWeb(
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
    IsarCollection<GalleryImageTask> collection, Object jsObj) {
  final object = GalleryImageTask(
    filePath: IsarNative.jsObjectGet(jsObj, 'filePath'),
    gid: IsarNative.jsObjectGet(jsObj, 'gid') ??
        (double.negativeInfinity as int),
    href: IsarNative.jsObjectGet(jsObj, 'href'),
    imageUrl: IsarNative.jsObjectGet(jsObj, 'imageUrl'),
    ser: IsarNative.jsObjectGet(jsObj, 'ser') ??
        (double.negativeInfinity as int),
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
      return (IsarNative.jsObjectGet(jsObj, 'gid') ??
          (double.negativeInfinity as int)) as P;
    case 'href':
      return (IsarNative.jsObjectGet(jsObj, 'href')) as P;
    case 'id':
      return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
    case 'imageUrl':
      return (IsarNative.jsObjectGet(jsObj, 'imageUrl')) as P;
    case 'ser':
      return (IsarNative.jsObjectGet(jsObj, 'ser') ??
          (double.negativeInfinity as int)) as P;
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
    IsarCollection<dynamic> col, int id, GalleryImageTask object) {}

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

  Future<int> putByGidSer(GalleryImageTask object) {
    return putByIndex('gid_ser', object);
  }

  int putByGidSerSync(GalleryImageTask object, {bool saveLinks = false}) {
    return putByIndexSync('gid_ser', object, saveLinks: saveLinks);
  }

  Future<List<int>> putAllByGidSer(List<GalleryImageTask> objects) {
    return putAllByIndex('gid_ser', objects);
  }

  List<int> putAllByGidSerSync(List<GalleryImageTask> objects,
      {bool saveLinks = false}) {
    return putAllByIndexSync('gid_ser', objects, saveLinks: saveLinks);
  }
}

extension GalleryImageTaskQueryWhereSort
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QWhere> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhere> anyGid() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: 'gid'),
      );
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhere> anyGidSer() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: 'gid_ser'),
      );
    });
  }
}

extension GalleryImageTaskQueryWhere
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QWhereClause> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause> idEqualTo(
      int id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        includeLower: true,
        upper: id,
        includeUpper: true,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      idGreaterThan(int id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      idLessThan(int id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause> idBetween(
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidEqualTo(int gid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: 'gid',
        value: [gid],
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidNotEqualTo(int gid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'gid',
              lower: [],
              includeLower: true,
              upper: [gid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'gid',
              lower: [gid],
              includeLower: false,
              upper: [],
              includeUpper: true,
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'gid',
              lower: [gid],
              includeLower: false,
              upper: [],
              includeUpper: true,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'gid',
              lower: [],
              includeLower: true,
              upper: [gid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidGreaterThan(
    int gid, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: 'gid',
        lower: [gid],
        includeLower: include,
        upper: [],
        includeUpper: true,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidLessThan(
    int gid, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: 'gid',
        lower: [],
        includeLower: true,
        upper: [gid],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidBetween(
    int lowerGid,
    int upperGid, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: 'gid',
        lower: [lowerGid],
        includeLower: includeLower,
        upper: [upperGid],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidEqualToAnySer(int gid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: 'gid_ser',
        value: [gid],
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidNotEqualToAnySer(int gid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'gid_ser',
              lower: [],
              includeLower: true,
              upper: [gid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'gid_ser',
              lower: [gid],
              includeLower: false,
              upper: [],
              includeUpper: true,
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'gid_ser',
              lower: [gid],
              includeLower: false,
              upper: [],
              includeUpper: true,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'gid_ser',
              lower: [],
              includeLower: true,
              upper: [gid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidGreaterThanAnySer(
    int gid, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: 'gid_ser',
        lower: [gid],
        includeLower: include,
        upper: [],
        includeUpper: true,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidLessThanAnySer(
    int gid, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: 'gid_ser',
        lower: [],
        includeLower: true,
        upper: [gid],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidBetweenAnySer(
    int lowerGid,
    int upperGid, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: 'gid_ser',
        lower: [lowerGid],
        includeLower: includeLower,
        upper: [upperGid],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidSerEqualTo(int gid, int ser) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: 'gid_ser',
        value: [gid, ser],
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidEqualToSerNotEqualTo(int gid, int ser) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'gid_ser',
              lower: [gid],
              includeLower: true,
              upper: [gid, ser],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'gid_ser',
              lower: [gid, ser],
              includeLower: false,
              upper: [gid],
              includeUpper: true,
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: 'gid_ser',
              lower: [gid, ser],
              includeLower: false,
              upper: [gid],
              includeUpper: true,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: 'gid_ser',
              lower: [gid],
              includeLower: true,
              upper: [gid, ser],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidEqualToSerGreaterThan(
    int gid,
    int ser, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: 'gid_ser',
        lower: [gid, ser],
        includeLower: include,
        upper: [gid],
        includeUpper: true,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidEqualToSerLessThan(
    int gid,
    int ser, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: 'gid_ser',
        lower: [gid],
        includeLower: true,
        upper: [gid, ser],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidEqualToSerBetween(
    int gid,
    int lowerSer,
    int upperSer, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: 'gid_ser',
        lower: [gid, lowerSer],
        includeLower: includeLower,
        upper: [gid, upperSer],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension GalleryImageTaskQueryFilter
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QFilterCondition> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: 'filePath',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'filePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: 'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: 'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: 'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: 'filePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      gidEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'gid',
        value: value,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      gidGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'gid',
        value: value,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      gidLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'gid',
        value: value,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      gidBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'gid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: 'href',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'href',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: 'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: 'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: 'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: 'href',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: 'id',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      idEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: 'imageUrl',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: 'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: 'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: 'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: 'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      serEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'ser',
        value: value,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      serGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'ser',
        value: value,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      serLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'ser',
        value: value,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      serBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'ser',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: 'sourceId',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdGreaterThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdLessThan(
    String? value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'sourceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: 'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: 'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: 'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: 'sourceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: 'status',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'status',
        value: value,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'status',
        value: value,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'status',
        value: value,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: 'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: 'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: 'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: 'token',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: 'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: 'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: 'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: 'token',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }
}

extension GalleryImageTaskQueryLinks
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QFilterCondition> {}

extension GalleryImageTaskQueryWhereSortBy
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QSortBy> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('filePath', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('filePath', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortByGid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('gid', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByGidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('gid', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortByHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('href', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('href', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('imageUrl', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('imageUrl', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortBySer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('ser', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortBySerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('ser', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('sourceId', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('sourceId', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('status', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('status', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('token', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('token', Sort.desc);
    });
  }
}

extension GalleryImageTaskQueryWhereSortThenBy
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QSortThenBy> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('filePath', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('filePath', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenByGid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('gid', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByGidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('gid', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenByHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('href', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('href', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('id', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('id', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('imageUrl', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('imageUrl', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenBySer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('ser', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenBySerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('ser', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('sourceId', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('sourceId', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('status', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('status', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('token', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy('token', Sort.desc);
    });
  }
}

extension GalleryImageTaskQueryWhereDistinct
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct>
      distinctByFilePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctByGid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('gid');
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctByHref(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('href', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct>
      distinctByImageUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctBySer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('ser');
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct>
      distinctBySourceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('sourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('status');
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctByToken(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy('token', caseSensitive: caseSensitive);
    });
  }
}

extension GalleryImageTaskQueryProperty
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QQueryProperty> {
  QueryBuilder<GalleryImageTask, String?, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('filePath');
    });
  }

  QueryBuilder<GalleryImageTask, int, QQueryOperations> gidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('gid');
    });
  }

  QueryBuilder<GalleryImageTask, String?, QQueryOperations> hrefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('href');
    });
  }

  QueryBuilder<GalleryImageTask, int?, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('id');
    });
  }

  QueryBuilder<GalleryImageTask, String?, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('imageUrl');
    });
  }

  QueryBuilder<GalleryImageTask, int, QQueryOperations> serProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('ser');
    });
  }

  QueryBuilder<GalleryImageTask, String?, QQueryOperations> sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('sourceId');
    });
  }

  QueryBuilder<GalleryImageTask, int?, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('status');
    });
  }

  QueryBuilder<GalleryImageTask, String, QQueryOperations> tokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName('token');
    });
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
