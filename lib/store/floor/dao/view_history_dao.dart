import 'package:floor/floor.dart';

import '../entity/view_history.dart';

@dao
abstract class ViewHistoryDao {
  @Query('SELECT * FROM ViewHistory WHERE gid = :gid')
  Future<ViewHistory?> findViewHistory(int gid);

  @Query('SELECT * FROM ViewHistory')
  Future<List<ViewHistory>> findAllViewHistorys();

  @Query(
      'SELECT * FROM ViewHistory Limit :maxInPage offset :page order by lastViewTime desc')
  Future<List<ViewHistory>?> findViewHistorysByPage(int page, int maxInPage);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertOrReplaceHistory(ViewHistory viewHistory);

  @insert
  Future<void> insertHistorys(List<ViewHistory> viewHistorys);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertOrReplaceViewHistorys(List<ViewHistory> viewHistorys);

  @Query('DELETE ViewHistory WHERE gid = :gid')
  Future<void> deleteViewHistory(int gid);

  @Query('DELETE ViewHistory')
  Future<void> deleteAllViewHistory();
}
