import 'package:mysql_client/mysql_client.dart';

class Migration {
  Migration(
    this.originVersion,
    this.targetVersion,
    this.execute,
  );

  final int originVersion;
  final int targetVersion;
  final Function(MySQLConnection) execute;
}
