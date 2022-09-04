import 'package:floor/floor.dart';

import '../entity/tag_translat.dart';

@dao
abstract class TagTranslatDao {
  @Query('SELECT * FROM TagTranslat')
  Future<List<TagTranslat>?> findAllTagTranslats();

  @Query('SELECT * FROM TagTranslat WHERE key = :key')
  Future<List<TagTranslat>?> findAllTagTranslatByKey(String key);

  @Query(
      'SELECT * FROM TagTranslat WHERE key = :key and namespace = :namespace')
  Future<TagTranslat?> findTagTranslatByKey(String key, String namespace);

  @Query(
      "SELECT * FROM TagTranslat WHERE ( key like :key or name like :name or namespace like :namespace ) and namespace not in ('rows') limit :limit")
  Future<List<TagTranslat>> findTagTranslatsWithLike(
      String key, String name, String namespace, int limit);

  @Query('SELECT * FROM TagTranslat WHERE key = :key')
  Future<List<TagTranslat>> findAllTagTranslatsByKey(String key);

  @insert
  Future<void> insertTagTranslat(TagTranslat tagTranslat);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAllTagTranslats(List<TagTranslat> tagTranslats);

  @update
  Future<void> updateTagTranslat(TagTranslat tagTranslat);
}
