class ConnectionInfo {
  ConnectionInfo({
    required this.host,
    required this.port,
    required this.userName,
    required this.password,
    required this.databaseName,
    this.secure,
    this.collation,
  });

  final String host;
  final int port;
  final String userName;
  final String password;
  final String databaseName;
  final bool? secure;
  final String? collation;
}
