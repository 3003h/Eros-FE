// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  GalleryTaskDao _galleryTaskDaoInstance;

  ImageTaskDao _imageTaskDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
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
            'CREATE TABLE IF NOT EXISTS `GalleryTask` (`gid` INTEGER, `token` TEXT, `url` TEXT, `title` TEXT, `fileCount` INTEGER, `completCount` INTEGER, `status` INTEGER, PRIMARY KEY (`gid`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `GalleryImageTask` (`gid` INTEGER, `ser` INTEGER, `token` TEXT, `href` TEXT, `imageUrl` TEXT, `filePath` TEXT, PRIMARY KEY (`gid`, `ser`))');

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
}

class _$GalleryTaskDao extends GalleryTaskDao {
  _$GalleryTaskDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _galleryTaskInsertionAdapter = InsertionAdapter(
            database,
            'GalleryTask',
            (GalleryTask item) => <String, dynamic>{
                  'gid': item.gid,
                  'token': item.token,
                  'url': item.url,
                  'title': item.title,
                  'fileCount': item.fileCount,
                  'completCount': item.completCount,
                  'status': item.status
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<GalleryTask> _galleryTaskInsertionAdapter;

  @override
  Future<List<GalleryTask>> findAllGalleryTasks() async {
    return _queryAdapter.queryList('SELECT * FROM GalleryTask',
        mapper: (Map<String, dynamic> row) => GalleryTask(
            gid: row['gid'] as int,
            token: row['token'] as String,
            url: row['url'] as String,
            title: row['title'] as String,
            fileCount: row['fileCount'] as int,
            completCount: row['completCount'] as int,
            status: row['status'] as int));
  }

  @override
  Future<GalleryTask> findGalleryTaskByGid(int gid) async {
    return _queryAdapter.query('SELECT * FROM GalleryTask WHERE gid = ?',
        arguments: <dynamic>[gid],
        mapper: (Map<String, dynamic> row) => GalleryTask(
            gid: row['gid'] as int,
            token: row['token'] as String,
            url: row['url'] as String,
            title: row['title'] as String,
            fileCount: row['fileCount'] as int,
            completCount: row['completCount'] as int,
            status: row['status'] as int));
  }

  @override
  Future<void> insertTask(GalleryTask galleryTask) async {
    await _galleryTaskInsertionAdapter.insert(
        galleryTask, OnConflictStrategy.abort);
  }
}

class _$ImageTaskDao extends ImageTaskDao {
  _$ImageTaskDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _galleryImageTaskInsertionAdapter = InsertionAdapter(
            database,
            'GalleryImageTask',
            (GalleryImageTask item) => <String, dynamic>{
                  'gid': item.gid,
                  'ser': item.ser,
                  'token': item.token,
                  'href': item.href,
                  'imageUrl': item.imageUrl,
                  'filePath': item.filePath
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<GalleryImageTask> _galleryImageTaskInsertionAdapter;

  @override
  Future<List<GalleryImageTask>> findAllImageTasks() async {
    return _queryAdapter.queryList('SELECT * FROM GalleryImageTask',
        mapper: (Map<String, dynamic> row) => GalleryImageTask(
            gid: row['gid'] as int,
            token: row['token'] as String,
            href: row['href'] as String,
            imageUrl: row['imageUrl'] as String,
            ser: row['ser'] as int,
            filePath: row['filePath'] as String));
  }

  @override
  Future<List<GalleryImageTask>> findAllGalleryTaskByGid(int gid) async {
    return _queryAdapter.queryList(
        'SELECT * FROM GalleryImageTask WHERE gid = ?',
        arguments: <dynamic>[gid],
        mapper: (Map<String, dynamic> row) => GalleryImageTask(
            gid: row['gid'] as int,
            token: row['token'] as String,
            href: row['href'] as String,
            imageUrl: row['imageUrl'] as String,
            ser: row['ser'] as int,
            filePath: row['filePath'] as String));
  }

  @override
  Future<GalleryImageTask> findGalleryTaskByKey(int gid, int ser) async {
    return _queryAdapter.query(
        'SELECT * FROM GalleryImageTask WHERE gid = ? and ser = ?',
        arguments: <dynamic>[gid, ser],
        mapper: (Map<String, dynamic> row) => GalleryImageTask(
            gid: row['gid'] as int,
            token: row['token'] as String,
            href: row['href'] as String,
            imageUrl: row['imageUrl'] as String,
            ser: row['ser'] as int,
            filePath: row['filePath'] as String));
  }

  @override
  Future<void> insertImageTask(GalleryImageTask galleryImageTask) async {
    await _galleryImageTaskInsertionAdapter.insert(
        galleryImageTask, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertImageTasks(
      List<GalleryImageTask> galleryImageTasks) async {
    await _galleryImageTaskInsertionAdapter.insertList(
        galleryImageTasks, OnConflictStrategy.abort);
  }
}
