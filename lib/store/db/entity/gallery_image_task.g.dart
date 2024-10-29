// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_image_task.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GalleryImageTaskCWProxy {
  GalleryImageTask gid(int gid);

  GalleryImageTask token(String token);

  GalleryImageTask href(String? href);

  GalleryImageTask sourceId(String? sourceId);

  GalleryImageTask imageUrl(String? imageUrl);

  GalleryImageTask ser(int ser);

  GalleryImageTask filePath(String? filePath);

  GalleryImageTask status(int? status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GalleryImageTask(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GalleryImageTask(...).copyWith(id: 12, name: "My name")
  /// ````
  GalleryImageTask call({
    int? gid,
    String? token,
    String? href,
    String? sourceId,
    String? imageUrl,
    int? ser,
    String? filePath,
    int? status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGalleryImageTask.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGalleryImageTask.copyWith.fieldName(...)`
class _$GalleryImageTaskCWProxyImpl implements _$GalleryImageTaskCWProxy {
  const _$GalleryImageTaskCWProxyImpl(this._value);

  final GalleryImageTask _value;

  @override
  GalleryImageTask gid(int gid) => this(gid: gid);

  @override
  GalleryImageTask token(String token) => this(token: token);

  @override
  GalleryImageTask href(String? href) => this(href: href);

  @override
  GalleryImageTask sourceId(String? sourceId) => this(sourceId: sourceId);

  @override
  GalleryImageTask imageUrl(String? imageUrl) => this(imageUrl: imageUrl);

  @override
  GalleryImageTask ser(int ser) => this(ser: ser);

  @override
  GalleryImageTask filePath(String? filePath) => this(filePath: filePath);

  @override
  GalleryImageTask status(int? status) => this(status: status);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GalleryImageTask(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GalleryImageTask(...).copyWith(id: 12, name: "My name")
  /// ````
  GalleryImageTask call({
    Object? gid = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
    Object? href = const $CopyWithPlaceholder(),
    Object? sourceId = const $CopyWithPlaceholder(),
    Object? imageUrl = const $CopyWithPlaceholder(),
    Object? ser = const $CopyWithPlaceholder(),
    Object? filePath = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return GalleryImageTask(
      gid: gid == const $CopyWithPlaceholder() || gid == null
          ? _value.gid
          // ignore: cast_nullable_to_non_nullable
          : gid as int,
      token: token == const $CopyWithPlaceholder() || token == null
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
      href: href == const $CopyWithPlaceholder()
          ? _value.href
          // ignore: cast_nullable_to_non_nullable
          : href as String?,
      sourceId: sourceId == const $CopyWithPlaceholder()
          ? _value.sourceId
          // ignore: cast_nullable_to_non_nullable
          : sourceId as String?,
      imageUrl: imageUrl == const $CopyWithPlaceholder()
          ? _value.imageUrl
          // ignore: cast_nullable_to_non_nullable
          : imageUrl as String?,
      ser: ser == const $CopyWithPlaceholder() || ser == null
          ? _value.ser
          // ignore: cast_nullable_to_non_nullable
          : ser as int,
      filePath: filePath == const $CopyWithPlaceholder()
          ? _value.filePath
          // ignore: cast_nullable_to_non_nullable
          : filePath as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as int?,
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
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGalleryImageTaskCollection on Isar {
  IsarCollection<GalleryImageTask> get galleryImageTasks => this.collection();
}

const GalleryImageTaskSchema = CollectionSchema(
  name: r'GalleryImageTask',
  id: -8132713106941185218,
  properties: {
    r'filePath': PropertySchema(
      id: 0,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'gid': PropertySchema(
      id: 1,
      name: r'gid',
      type: IsarType.long,
    ),
    r'href': PropertySchema(
      id: 2,
      name: r'href',
      type: IsarType.string,
    ),
    r'imageUrl': PropertySchema(
      id: 3,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'ser': PropertySchema(
      id: 4,
      name: r'ser',
      type: IsarType.long,
    ),
    r'sourceId': PropertySchema(
      id: 5,
      name: r'sourceId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 6,
      name: r'status',
      type: IsarType.long,
    ),
    r'token': PropertySchema(
      id: 7,
      name: r'token',
      type: IsarType.string,
    )
  },
  estimateSize: _galleryImageTaskEstimateSize,
  serialize: _galleryImageTaskSerialize,
  deserialize: _galleryImageTaskDeserialize,
  deserializeProp: _galleryImageTaskDeserializeProp,
  idName: r'id',
  indexes: {
    r'gid_ser': IndexSchema(
      id: -2521744434897185117,
      name: r'gid_ser',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'gid',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'ser',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'gid': IndexSchema(
      id: -5769570954466121977,
      name: r'gid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'gid',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _galleryImageTaskGetId,
  getLinks: _galleryImageTaskGetLinks,
  attach: _galleryImageTaskAttach,
  version: '3.1.0+1',
);

int _galleryImageTaskEstimateSize(
  GalleryImageTask object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.filePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.href;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.token.length * 3;
  return bytesCount;
}

void _galleryImageTaskSerialize(
  GalleryImageTask object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.filePath);
  writer.writeLong(offsets[1], object.gid);
  writer.writeString(offsets[2], object.href);
  writer.writeString(offsets[3], object.imageUrl);
  writer.writeLong(offsets[4], object.ser);
  writer.writeString(offsets[5], object.sourceId);
  writer.writeLong(offsets[6], object.status);
  writer.writeString(offsets[7], object.token);
}

GalleryImageTask _galleryImageTaskDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
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

P _galleryImageTaskDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
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
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _galleryImageTaskGetId(GalleryImageTask object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _galleryImageTaskGetLinks(GalleryImageTask object) {
  return [];
}

void _galleryImageTaskAttach(
    IsarCollection<dynamic> col, Id id, GalleryImageTask object) {
  object.id = id;
}

extension GalleryImageTaskByIndex on IsarCollection<GalleryImageTask> {
  Future<GalleryImageTask?> getByGidSer(int gid, int ser) {
    return getByIndex(r'gid_ser', [gid, ser]);
  }

  GalleryImageTask? getByGidSerSync(int gid, int ser) {
    return getByIndexSync(r'gid_ser', [gid, ser]);
  }

  Future<bool> deleteByGidSer(int gid, int ser) {
    return deleteByIndex(r'gid_ser', [gid, ser]);
  }

  bool deleteByGidSerSync(int gid, int ser) {
    return deleteByIndexSync(r'gid_ser', [gid, ser]);
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

    return getAllByIndex(r'gid_ser', values);
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

    return getAllByIndexSync(r'gid_ser', values);
  }

  Future<int> deleteAllByGidSer(List<int> gidValues, List<int> serValues) {
    final len = gidValues.length;
    assert(
        serValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([gidValues[i], serValues[i]]);
    }

    return deleteAllByIndex(r'gid_ser', values);
  }

  int deleteAllByGidSerSync(List<int> gidValues, List<int> serValues) {
    final len = gidValues.length;
    assert(
        serValues.length == len, 'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([gidValues[i], serValues[i]]);
    }

    return deleteAllByIndexSync(r'gid_ser', values);
  }

  Future<Id> putByGidSer(GalleryImageTask object) {
    return putByIndex(r'gid_ser', object);
  }

  Id putByGidSerSync(GalleryImageTask object, {bool saveLinks = true}) {
    return putByIndexSync(r'gid_ser', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGidSer(List<GalleryImageTask> objects) {
    return putAllByIndex(r'gid_ser', objects);
  }

  List<Id> putAllByGidSerSync(List<GalleryImageTask> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'gid_ser', objects, saveLinks: saveLinks);
  }
}

extension GalleryImageTaskQueryWhereSort
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QWhere> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhere> anyGidSer() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'gid_ser'),
      );
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhere> anyGid() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'gid'),
      );
    });
  }
}

extension GalleryImageTaskQueryWhere
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QWhereClause> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause> idBetween(
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidEqualToAnySer(int gid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'gid_ser',
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
              indexName: r'gid_ser',
              lower: [],
              upper: [gid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gid_ser',
              lower: [gid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gid_ser',
              lower: [gid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gid_ser',
              lower: [],
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
        indexName: r'gid_ser',
        lower: [gid],
        includeLower: include,
        upper: [],
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
        indexName: r'gid_ser',
        lower: [],
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
        indexName: r'gid_ser',
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
        indexName: r'gid_ser',
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
              indexName: r'gid_ser',
              lower: [gid],
              upper: [gid, ser],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gid_ser',
              lower: [gid, ser],
              includeLower: false,
              upper: [gid],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gid_ser',
              lower: [gid, ser],
              includeLower: false,
              upper: [gid],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gid_ser',
              lower: [gid],
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
        indexName: r'gid_ser',
        lower: [gid, ser],
        includeLower: include,
        upper: [gid],
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
        indexName: r'gid_ser',
        lower: [gid],
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
        indexName: r'gid_ser',
        lower: [gid, lowerSer],
        includeLower: includeLower,
        upper: [gid, upperSer],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterWhereClause>
      gidEqualTo(int gid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'gid',
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
              indexName: r'gid',
              lower: [],
              upper: [gid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gid',
              lower: [gid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gid',
              lower: [gid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gid',
              lower: [],
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
        indexName: r'gid',
        lower: [gid],
        includeLower: include,
        upper: [],
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
        indexName: r'gid',
        lower: [],
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
        indexName: r'gid',
        lower: [lowerGid],
        includeLower: includeLower,
        upper: [upperGid],
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
        property: r'filePath',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'filePath',
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
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filePath',
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
        property: r'filePath',
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
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      gidEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gid',
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
        property: r'gid',
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
        property: r'gid',
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
        property: r'gid',
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
        property: r'href',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'href',
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
        property: r'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'href',
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
        property: r'href',
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
        property: r'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'href',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'href',
        value: '',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      hrefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'href',
        value: '',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
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

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageUrl',
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
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
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
        property: r'imageUrl',
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
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      serEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ser',
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
        property: r'ser',
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
        property: r'ser',
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
        property: r'ser',
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
        property: r'sourceId',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceId',
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
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceId',
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
        property: r'sourceId',
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
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      sourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      statusEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
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
        property: r'status',
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
        property: r'status',
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
        property: r'status',
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
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'token',
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
        property: r'token',
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
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'token',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: '',
      ));
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterFilterCondition>
      tokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'token',
        value: '',
      ));
    });
  }
}

extension GalleryImageTaskQueryObject
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QFilterCondition> {}

extension GalleryImageTaskQueryLinks
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QFilterCondition> {}

extension GalleryImageTaskQuerySortBy
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QSortBy> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortByGid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gid', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByGidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gid', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortByHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'href', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'href', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortBySer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ser', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortBySerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ser', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> sortByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      sortByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }
}

extension GalleryImageTaskQuerySortThenBy
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QSortThenBy> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenByGid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gid', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByGidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gid', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenByHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'href', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'href', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenBySer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ser', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenBySerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ser', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy> thenByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QAfterSortBy>
      thenByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }
}

extension GalleryImageTaskQueryWhereDistinct
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> {
  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct>
      distinctByFilePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctByGid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gid');
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctByHref(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'href', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct>
      distinctByImageUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctBySer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ser');
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct>
      distinctBySourceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<GalleryImageTask, GalleryImageTask, QDistinct> distinctByToken(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'token', caseSensitive: caseSensitive);
    });
  }
}

extension GalleryImageTaskQueryProperty
    on QueryBuilder<GalleryImageTask, GalleryImageTask, QQueryProperty> {
  QueryBuilder<GalleryImageTask, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GalleryImageTask, String?, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<GalleryImageTask, int, QQueryOperations> gidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gid');
    });
  }

  QueryBuilder<GalleryImageTask, String?, QQueryOperations> hrefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'href');
    });
  }

  QueryBuilder<GalleryImageTask, String?, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<GalleryImageTask, int, QQueryOperations> serProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ser');
    });
  }

  QueryBuilder<GalleryImageTask, String?, QQueryOperations> sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<GalleryImageTask, int?, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<GalleryImageTask, String, QQueryOperations> tokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'token');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryImageTask _$GalleryImageTaskFromJson(Map<String, dynamic> json) =>
    GalleryImageTask(
      gid: (json['gid'] as num).toInt(),
      token: json['token'] as String,
      href: json['href'] as String?,
      sourceId: json['sourceId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      ser: (json['ser'] as num).toInt(),
      filePath: json['filePath'] as String?,
      status: (json['status'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GalleryImageTaskToJson(GalleryImageTask instance) =>
    <String, dynamic>{
      'gid': instance.gid,
      'ser': instance.ser,
      'token': instance.token,
      'href': instance.href,
      'sourceId': instance.sourceId,
      'imageUrl': instance.imageUrl,
      'filePath': instance.filePath,
      'status': instance.status,
    };
