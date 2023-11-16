import 'package:flutter/foundation.dart';


@immutable
class MysqlConnectionInfo {
  
  const MysqlConnectionInfo({
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

  factory MysqlConnectionInfo.fromJson(Map<String,dynamic> json) => MysqlConnectionInfo(
    host: json['host'] as String,
    port: json['port'] as int,
    userName: json['userName'] as String,
    password: json['password'] as String,
    databaseName: json['databaseName'] as String,
    secure: json['secure'] != null ? json['secure'] as bool : null,
    collation: json['collation'] != null ? json['collation'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'host': host,
    'port': port,
    'userName': userName,
    'password': password,
    'databaseName': databaseName,
    'secure': secure,
    'collation': collation
  };

  MysqlConnectionInfo clone() => MysqlConnectionInfo(
    host: host,
    port: port,
    userName: userName,
    password: password,
    databaseName: databaseName,
    secure: secure,
    collation: collation
  );

    
  MysqlConnectionInfo copyWith({
    String? host,
    int? port,
    String? userName,
    String? password,
    String? databaseName,
    bool? secure,
    String? collation
  }) => MysqlConnectionInfo(
    host: host ?? this.host,
    port: port ?? this.port,
    userName: userName ?? this.userName,
    password: password ?? this.password,
    databaseName: databaseName ?? this.databaseName,
    secure: secure ?? this.secure,
    collation: collation ?? this.collation,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is MysqlConnectionInfo && host == other.host && port == other.port && userName == other.userName && password == other.password && databaseName == other.databaseName && secure == other.secure && collation == other.collation;

  @override
  int get hashCode => host.hashCode ^ port.hashCode ^ userName.hashCode ^ password.hashCode ^ databaseName.hashCode ^ secure.hashCode ^ collation.hashCode;
}
