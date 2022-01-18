// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorEhDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$EhDatabaseBuilder databaseBuilder(String name) =>
      _$EhDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$EhDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$EhDatabaseBuilder(null);
}

class _$EhDatabaseBuilder {
  _$EhDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$EhDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$EhDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<EhDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$EhDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$EhDatabase extends EhDatabase {
  _$EhDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  GalleryTaskDao? _galleryTaskDaoInstance;

  ImageTaskDao? _imageTaskDaoInstance;

  TagTranslatDao? _tagTranslatDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 10,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `GalleryTask` (`gid` INTEGER NOT NULL, `token` TEXT NOT NULL, `url` TEXT, `title` TEXT NOT NULL, `dirPath` TEXT, `fileCount` INTEGER NOT NULL, `completCount` INTEGER, `status` INTEGER, `coverImage` TEXT, `addTime` INTEGER, `coverUrl` TEXT, `rating` REAL, `category` TEXT, `uploader` TEXT, `jsonString` TEXT, `tag` TEXT, `downloadOrigImage` INTEGER, PRIMARY KEY (`gid`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `GalleryImageTask` (`gid` INTEGER NOT NULL, `ser` INTEGER NOT NULL, `token` TEXT NOT NULL, `href` TEXT, `sourceId` TEXT, `imageUrl` TEXT, `filePath` TEXT, `status` INTEGER, PRIMARY KEY (`gid`, `ser`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `TagTranslat` (`namespace` TEXT NOT NULL, `key` TEXT NOT NULL, `name` TEXT, `intro` TEXT, `links` TEXT, PRIMARY KEY (`namespace`, `key`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  GalleryTaskDao get galleryTaskDao {
    return _galleryTaskDaoInstance ??=
        _$GalleryTaskDao(database, changeListener);
  }

  @override
  ImageTaskDao get imageTaskDao {
    return _imageTaskDaoInstance ??= _$ImageTaskDao(database, changeListener);
  }

  @override
  TagTranslatDao get tagTranslatDao {
    return _tagTranslatDaoInstance ??=
        _$TagTranslatDao(database, changeListener);
  }
}

class _$GalleryTaskDao extends GalleryTaskDao {
  _$GalleryTaskDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _galleryTaskInsertionAdapter = InsertionAdapter(
            database,
            'GalleryTask',
            (GalleryTask item) => <String, Object?>{
                  'gid': item.gid,
                  'token': item.token,
                  'url': item.url,
                  'title': item.title,
                  'dirPath': item.dirPath,
                  'fileCount': item.fileCount,
                  'completCount': item.completCount,
                  'status': item.status,
                  'coverImage': item.coverImage,
                  'addTime': item.addTime,
                  'coverUrl': item.coverUrl,
                  'rating': item.rating,
                  'category': item.category,
                  'uploader': item.uploader,
                  'jsonString': item.jsonString,
                  'tag': item.tag,
                  'downloadOrigImage': item.downloadOrigImage == null
                      ? null
                      : (item.downloadOrigImage! ? 1 : 0)
                },
            changeListener),
        _galleryTaskUpdateAdapter = UpdateAdapter(
            database,
            'GalleryTask',
            ['gid'],
            (GalleryTask item) => <String, Object?>{
                  'gid': item.gid,
                  'token': item.token,
                  'url': item.url,
                  'title': item.title,
                  'dirPath': item.dirPath,
                  'fileCount': item.fileCount,
                  'completCount': item.completCount,
                  'status': item.status,
                  'coverImage': item.coverImage,
                  'addTime': item.addTime,
                  'coverUrl': item.coverUrl,
                  'rating': item.rating,
                  'category': item.category,
                  'uploader': item.uploader,
                  'jsonString': item.jsonString,
                  'tag': item.tag,
                  'downloadOrigImage': item.downloadOrigImage == null
                      ? null
                      : (item.downloadOrigImage! ? 1 : 0)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<GalleryTask> _galleryTaskInsertionAdapter;

  final UpdateAdapter<GalleryTask> _galleryTaskUpdateAdapter;

  @override
  Future<List<GalleryTask>> findAllGalleryTasks() async {
    return _queryAdapter.queryList('SELECT * FROM GalleryTask',
        mapper: (Map<String, Object?> row) => GalleryTask(
            gid: row['gid'] as int,
            token: row['token'] as String,
            url: row['url'] as String?,
            title: row['title'] as String,
            dirPath: row['dirPath'] as String?,
            fileCount: row['fileCount'] as int,
            completCount: row['completCount'] as int?,
            status: row['status'] as int?,
            coverImage: row['coverImage'] as String?,
            addTime: row['addTime'] as int?,
            coverUrl: row['coverUrl'] as String?,
            rating: row['rating'] as double?,
            category: row['category'] as String?,
            uploader: row['uploader'] as String?,
            jsonString: row['jsonString'] as String?,
            tag: row['tag'] as String?,
            downloadOrigImage: row['downloadOrigImage'] == null
                ? null
                : (row['downloadOrigImage'] as int) != 0));
  }

  @override
  Stream<List<GalleryTask>> listenAllGalleryTasks() {
    return _queryAdapter.queryListStream('SELECT * FROM GalleryTask',
        mapper: (Map<String, Object?> row) => GalleryTask(
            gid: row['gid'] as int,
            token: row['token'] as String,
            url: row['url'] as String?,
            title: row['title'] as String,
            dirPath: row['dirPath'] as String?,
            fileCount: row['fileCount'] as int,
            completCount: row['completCount'] as int?,
            status: row['status'] as int?,
            coverImage: row['coverImage'] as String?,
            addTime: row['addTime'] as int?,
            coverUrl: row['coverUrl'] as String?,
            rating: row['rating'] as double?,
            category: row['category'] as String?,
            uploader: row['uploader'] as String?,
            jsonString: row['jsonString'] as String?,
            tag: row['tag'] as String?,
            downloadOrigImage: row['downloadOrigImage'] == null
                ? null
                : (row['downloadOrigImage'] as int) != 0),
        queryableName: 'GalleryTask',
        isView: false);
  }

  @override
  Future<GalleryTask?> findGalleryTaskByGid(int gid) async {
    return _queryAdapter.query('SELECT * FROM GalleryTask WHERE gid = ?1',
        mapper: (Map<String, Object?> row) => GalleryTask(
            gid: row['gid'] as int,
            token: row['token'] as String,
            url: row['url'] as String?,
            title: row['title'] as String,
            dirPath: row['dirPath'] as String?,
            fileCount: row['fileCount'] as int,
            completCount: row['completCount'] as int?,
            status: row['status'] as int?,
            coverImage: row['coverImage'] as String?,
            addTime: row['addTime'] as int?,
            coverUrl: row['coverUrl'] as String?,
            rating: row['rating'] as double?,
            category: row['category'] as String?,
            uploader: row['uploader'] as String?,
            jsonString: row['jsonString'] as String?,
            tag: row['tag'] as String?,
            downloadOrigImage: row['downloadOrigImage'] == null
                ? null
                : (row['downloadOrigImage'] as int) != 0),
        arguments: [gid]);
  }

  @override
  Future<void> deleteTaskByGid(int gid) async {
    await _queryAdapter.queryNoReturn('DELETE FROM GalleryTask WHERE gid = ?1',
        arguments: [gid]);
  }

  @override
  Future<void> updateStatusByGid(int status, int gid) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE GalleryImageTask set status = ?1 WHERE gid = ?2',
        arguments: [status, gid]);
  }

  @override
  Future<void> insertTask(GalleryTask galleryTask) async {
    await _galleryTaskInsertionAdapter.insert(
        galleryTask, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertTasks(List<GalleryTask> galleryTasks) async {
    await _galleryTaskInsertionAdapter.insertList(
        galleryTasks, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertOrReplaceTasks(List<GalleryTask> galleryTasks) async {
    await _galleryTaskInsertionAdapter.insertList(
        galleryTasks, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateTask(GalleryTask galleryTask) async {
    await _galleryTaskUpdateAdapter.update(
        galleryTask, OnConflictStrategy.abort);
  }
}

class _$ImageTaskDao extends ImageTaskDao {
  _$ImageTaskDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _galleryImageTaskInsertionAdapter = InsertionAdapter(
            database,
            'GalleryImageTask',
            (GalleryImageTask item) => <String, Object?>{
                  'gid': item.gid,
                  'ser': item.ser,
                  'token': item.token,
                  'href': item.href,
                  'sourceId': item.sourceId,
                  'imageUrl': item.imageUrl,
                  'filePath': item.filePath,
                  'status': item.status
                }),
        _galleryImageTaskUpdateAdapter = UpdateAdapter(
            database,
            'GalleryImageTask',
            ['gid', 'ser'],
            (GalleryImageTask item) => <String, Object?>{
                  'gid': item.gid,
                  'ser': item.ser,
                  'token': item.token,
                  'href': item.href,
                  'sourceId': item.sourceId,
                  'imageUrl': item.imageUrl,
                  'filePath': item.filePath,
                  'status': item.status
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<GalleryImageTask> _galleryImageTaskInsertionAdapter;

  final UpdateAdapter<GalleryImageTask> _galleryImageTaskUpdateAdapter;

  @override
  Future<List<GalleryImageTask>> findAllTasks() async {
    return _queryAdapter.queryList('SELECT * FROM GalleryImageTask',
        mapper: (Map<String, Object?> row) => GalleryImageTask(
            gid: row['gid'] as int,
            token: row['token'] as String,
            href: row['href'] as String?,
            sourceId: row['sourceId'] as String?,
            imageUrl: row['imageUrl'] as String?,
            ser: row['ser'] as int,
            filePath: row['filePath'] as String?,
            status: row['status'] as int?));
  }

  @override
  Future<List<GalleryImageTask>> findAllTaskByGid(int gid) async {
    return _queryAdapter.queryList(
        'SELECT * FROM GalleryImageTask WHERE gid = ?1',
        mapper: (Map<String, Object?> row) => GalleryImageTask(
            gid: row['gid'] as int,
            token: row['token'] as String,
            href: row['href'] as String?,
            sourceId: row['sourceId'] as String?,
            imageUrl: row['imageUrl'] as String?,
            ser: row['ser'] as int,
            filePath: row['filePath'] as String?,
            status: row['status'] as int?),
        arguments: [gid]);
  }

  @override
  Future<GalleryImageTask?> findTaskByKey(int gid, int ser) async {
    return _queryAdapter.query(
        'SELECT * FROM GalleryImageTask WHERE gid = ?1 and ser = ?2',
        mapper: (Map<String, Object?> row) => GalleryImageTask(
            gid: row['gid'] as int,
            token: row['token'] as String,
            href: row['href'] as String?,
            sourceId: row['sourceId'] as String?,
            imageUrl: row['imageUrl'] as String?,
            ser: row['ser'] as int,
            filePath: row['filePath'] as String?,
            status: row['status'] as int?),
        arguments: [gid, ser]);
  }

  @override
  Future<void> deleteImageTaskByGid(int gid) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM GalleryImageTask WHERE gid = ?1',
        arguments: [gid]);
  }

  @override
  Future<void> updateImageTaskStatus(int gid, int ser, int status) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE GalleryImageTask SET status = ?3 WHERE gid = ?1 AND ser = ?2',
        arguments: [gid, ser, status]);
  }

  @override
  Future<List<GalleryImageTask>> finaAllTaskByGidAndStatus(
      int gid, int status) async {
    return _queryAdapter.queryList(
        'SELECT * FROM GalleryImageTask WHERE gid = ?1 AND status = ?2',
        mapper: (Map<String, Object?> row) => GalleryImageTask(
            gid: row['gid'] as int,
            token: row['token'] as String,
            href: row['href'] as String?,
            sourceId: row['sourceId'] as String?,
            imageUrl: row['imageUrl'] as String?,
            ser: row['ser'] as int,
            filePath: row['filePath'] as String?,
            status: row['status'] as int?),
        arguments: [gid, status]);
  }

  @override
  Future<void> insertImageTask(GalleryImageTask galleryImageTask) async {
    await _galleryImageTaskInsertionAdapter.insert(
        galleryImageTask, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertOrReplaceImageTask(
      GalleryImageTask galleryImageTask) async {
    await _galleryImageTaskInsertionAdapter.insert(
        galleryImageTask, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertImageTasks(
      List<GalleryImageTask> galleryImageTasks) async {
    await _galleryImageTaskInsertionAdapter.insertList(
        galleryImageTasks, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertOrReplaceImageTasks(
      List<GalleryImageTask> galleryImageTasks) async {
    await _galleryImageTaskInsertionAdapter.insertList(
        galleryImageTasks, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateImageTask(GalleryImageTask galleryImageTask) async {
    await _galleryImageTaskUpdateAdapter.update(
        galleryImageTask, OnConflictStrategy.abort);
  }
}

class _$TagTranslatDao extends TagTranslatDao {
  _$TagTranslatDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _tagTranslatInsertionAdapter = InsertionAdapter(
            database,
            'TagTranslat',
            (TagTranslat item) => <String, Object?>{
                  'namespace': item.namespace,
                  'key': item.key,
                  'name': item.name,
                  'intro': item.intro,
                  'links': item.links
                }),
        _tagTranslatUpdateAdapter = UpdateAdapter(
            database,
            'TagTranslat',
            ['namespace', 'key'],
            (TagTranslat item) => <String, Object?>{
                  'namespace': item.namespace,
                  'key': item.key,
                  'name': item.name,
                  'intro': item.intro,
                  'links': item.links
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TagTranslat> _tagTranslatInsertionAdapter;

  final UpdateAdapter<TagTranslat> _tagTranslatUpdateAdapter;

  @override
  Future<List<TagTranslat>?> findAllTagTranslats() async {
    return _queryAdapter.queryList('SELECT * FROM TagTranslat',
        mapper: (Map<String, Object?> row) => TagTranslat(
            namespace: row['namespace'] as String,
            key: row['key'] as String,
            name: row['name'] as String?,
            intro: row['intro'] as String?,
            links: row['links'] as String?));
  }

  @override
  Future<List<TagTranslat>?> findAllTagTranslatByKey(String key) async {
    return _queryAdapter.queryList('SELECT * FROM TagTranslat WHERE key = ?1',
        mapper: (Map<String, Object?> row) => TagTranslat(
            namespace: row['namespace'] as String,
            key: row['key'] as String,
            name: row['name'] as String?,
            intro: row['intro'] as String?,
            links: row['links'] as String?),
        arguments: [key]);
  }

  @override
  Future<TagTranslat?> findTagTranslatByKey(
      String key, String namespace) async {
    return _queryAdapter.query(
        'SELECT * FROM TagTranslat WHERE key = ?1 and namespace = ?2',
        mapper: (Map<String, Object?> row) => TagTranslat(
            namespace: row['namespace'] as String,
            key: row['key'] as String,
            name: row['name'] as String?,
            intro: row['intro'] as String?,
            links: row['links'] as String?),
        arguments: [key, namespace]);
  }

  @override
  Future<List<TagTranslat>> findTagTranslatsWithLike(
      String key, String name, int limit) async {
    return _queryAdapter.queryList(
        'SELECT * FROM TagTranslat WHERE key like ?1 or name like ?2 limit ?3',
        mapper: (Map<String, Object?> row) => TagTranslat(
            namespace: row['namespace'] as String,
            key: row['key'] as String,
            name: row['name'] as String?,
            intro: row['intro'] as String?,
            links: row['links'] as String?),
        arguments: [key, name, limit]);
  }

  @override
  Future<List<TagTranslat>> findAllTagTranslatsByKey(String key) async {
    return _queryAdapter.queryList('SELECT * FROM TagTranslat WHERE key = ?1',
        mapper: (Map<String, Object?> row) => TagTranslat(
            namespace: row['namespace'] as String,
            key: row['key'] as String,
            name: row['name'] as String?,
            intro: row['intro'] as String?,
            links: row['links'] as String?),
        arguments: [key]);
  }

  @override
  Future<void> insertTagTranslat(TagTranslat tagTranslat) async {
    await _tagTranslatInsertionAdapter.insert(
        tagTranslat, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertAllTagTranslats(List<TagTranslat> tagTranslats) async {
    await _tagTranslatInsertionAdapter.insertList(
        tagTranslats, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateTagTranslat(TagTranslat tagTranslat) async {
    await _tagTranslatUpdateAdapter.update(
        tagTranslat, OnConflictStrategy.abort);
  }
}
