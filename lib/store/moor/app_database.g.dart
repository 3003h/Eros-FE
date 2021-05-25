// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class GalleryImageTaskData extends DataClass
    implements Insertable<GalleryImageTaskData> {
  final int gid;
  final String token;
  final int ser;
  final String href;

  GalleryImageTaskData(
      {required this.gid,
      required this.token,
      required this.ser,
      required this.href});

  factory GalleryImageTaskData.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return GalleryImageTaskData(
      gid: intType.mapFromDatabaseResponse(data['${effectivePrefix}gid'])!,
      token:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}token'])!,
      ser: intType.mapFromDatabaseResponse(data['${effectivePrefix}ser'])!,
      href: stringType.mapFromDatabaseResponse(data['${effectivePrefix}href'])!,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['gid'] = Variable<int>(gid);
    map['token'] = Variable<String>(token);
    map['ser'] = Variable<int>(ser);
    map['href'] = Variable<String>(href);
    return map;
  }

  GalleryImageTaskCompanion toCompanion(bool nullToAbsent) {
    return GalleryImageTaskCompanion(
      gid: Value(gid),
      token: Value(token),
      ser: Value(ser),
      href: Value(href),
    );
  }

  factory GalleryImageTaskData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return GalleryImageTaskData(
      gid: serializer.fromJson<int>(json['gid']),
      token: serializer.fromJson<String>(json['token']),
      ser: serializer.fromJson<int>(json['ser']),
      href: serializer.fromJson<String>(json['href']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gid': serializer.toJson<int>(gid),
      'token': serializer.toJson<String>(token),
      'ser': serializer.toJson<int>(ser),
      'href': serializer.toJson<String>(href),
    };
  }

  GalleryImageTaskData copyWith(
          {int? gid, String? token, int? ser, String? href}) =>
      GalleryImageTaskData(
        gid: gid ?? this.gid,
        token: token ?? this.token,
        ser: ser ?? this.ser,
        href: href ?? this.href,
      );

  @override
  String toString() {
    return (StringBuffer('GalleryImageTaskData(')
          ..write('gid: $gid, ')
          ..write('token: $token, ')
          ..write('ser: $ser, ')
          ..write('href: $href')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      gid.hashCode, $mrjc(token.hashCode, $mrjc(ser.hashCode, href.hashCode))));

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is GalleryImageTaskData &&
          other.gid == this.gid &&
          other.token == this.token &&
          other.ser == this.ser &&
          other.href == this.href);
}

class GalleryImageTaskCompanion extends UpdateCompanion<GalleryImageTaskData> {
  final Value<int> gid;
  final Value<String> token;
  final Value<int> ser;
  final Value<String> href;

  const GalleryImageTaskCompanion({
    this.gid = const Value.absent(),
    this.token = const Value.absent(),
    this.ser = const Value.absent(),
    this.href = const Value.absent(),
  });

  GalleryImageTaskCompanion.insert({
    required int gid,
    required String token,
    required int ser,
    required String href,
  })   : gid = Value(gid),
        token = Value(token),
        ser = Value(ser),
        href = Value(href);

  static Insertable<GalleryImageTaskData> custom({
    Expression<int>? gid,
    Expression<String>? token,
    Expression<int>? ser,
    Expression<String>? href,
  }) {
    return RawValuesInsertable({
      if (gid != null) 'gid': gid,
      if (token != null) 'token': token,
      if (ser != null) 'ser': ser,
      if (href != null) 'href': href,
    });
  }

  GalleryImageTaskCompanion copyWith(
      {Value<int>? gid,
      Value<String>? token,
      Value<int>? ser,
      Value<String>? href}) {
    return GalleryImageTaskCompanion(
      gid: gid ?? this.gid,
      token: token ?? this.token,
      ser: ser ?? this.ser,
      href: href ?? this.href,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gid.present) {
      map['gid'] = Variable<int>(gid.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (ser.present) {
      map['ser'] = Variable<int>(ser.value);
    }
    if (href.present) {
      map['href'] = Variable<String>(href.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GalleryImageTaskCompanion(')
          ..write('gid: $gid, ')
          ..write('token: $token, ')
          ..write('ser: $ser, ')
          ..write('href: $href')
          ..write(')'))
        .toString();
  }
}

class $GalleryImageTaskTable extends GalleryImageTask
    with TableInfo<$GalleryImageTaskTable, GalleryImageTaskData> {
  final GeneratedDatabase _db;
  final String? _alias;

  $GalleryImageTaskTable(this._db, [this._alias]);

  final VerificationMeta _gidMeta = const VerificationMeta('gid');
  @override
  late final GeneratedIntColumn gid = _constructGid();

  GeneratedIntColumn _constructGid() {
    return GeneratedIntColumn(
      'gid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedTextColumn token = _constructToken();

  GeneratedTextColumn _constructToken() {
    return GeneratedTextColumn(
      'token',
      $tableName,
      false,
    );
  }

  final VerificationMeta _serMeta = const VerificationMeta('ser');
  @override
  late final GeneratedIntColumn ser = _constructSer();

  GeneratedIntColumn _constructSer() {
    return GeneratedIntColumn(
      'ser',
      $tableName,
      false,
    );
  }

  final VerificationMeta _hrefMeta = const VerificationMeta('href');
  @override
  late final GeneratedTextColumn href = _constructHref();

  GeneratedTextColumn _constructHref() {
    return GeneratedTextColumn(
      'href',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [gid, token, ser, href];

  @override
  $GalleryImageTaskTable get asDslTable => this;

  @override
  String get $tableName => _alias ?? 'gallery_image_task';
  @override
  final String actualTableName = 'gallery_image_task';

  @override
  VerificationContext validateIntegrity(
      Insertable<GalleryImageTaskData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('gid')) {
      context.handle(
          _gidMeta, gid.isAcceptableOrUnknown(data['gid']!, _gidMeta));
    } else if (isInserting) {
      context.missing(_gidMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('ser')) {
      context.handle(
          _serMeta, ser.isAcceptableOrUnknown(data['ser']!, _serMeta));
    } else if (isInserting) {
      context.missing(_serMeta);
    }
    if (data.containsKey('href')) {
      context.handle(
          _hrefMeta, href.isAcceptableOrUnknown(data['href']!, _hrefMeta));
    } else if (isInserting) {
      context.missing(_hrefMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};

  @override
  GalleryImageTaskData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return GalleryImageTaskData.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $GalleryImageTaskTable createAlias(String alias) {
    return $GalleryImageTaskTable(_db, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $GalleryImageTaskTable galleryImageTask =
      $GalleryImageTaskTable(this);

  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [galleryImageTask];
}
