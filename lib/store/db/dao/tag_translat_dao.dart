import 'package:fehviewer/store/db/entity/tag_translat.dart';
import 'package:floor/floor.dart';

@dao
abstract class TagTranslatDao {
  @Query('SELECT * FROM TagTranslat')
  Future<List<TagTranslat>> findAllTagTranslats();

  @Query('SELECT * FROM TagTranslat WHERE key = :key')
  Future<List<TagTranslat>> findAllTagTranslatByKey(String key);

  @Query(
      'SELECT * FROM TagTranslat WHERE key = :key and namespace = :namespace')
  Future<TagTranslat> findTagTranslatByKey(String key, String namespace);

  @Query(
      'SELECT * FROM TagTranslat WHERE key like :key or name like :name limit :limit')
  Future<List<TagTranslat>> findTagTranslatsWithLike(
      String key, String name, int limit);

  @insert
  Future<void> insertTagTranslat(TagTranslat tagTranslat);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAllTagTranslats(List<TagTranslat> tagTranslats);

  @update
  Future<void> updateTagTranslat(TagTranslat tagTranslat);
}
