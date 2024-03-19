import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    host: json['host'].toString(),
    port: int.tryParse('${json['port']}') ?? 0,
    userName: json['userName'].toString(),
    password: json['password'].toString(),
    databaseName: json['databaseName'].toString(),
    secure: json['secure'] != null ? bool.tryParse('${json['secure']}', caseSensitive: false) ?? false : null,
    collation: json['collation']?.toString()
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
    Optional<bool?>? secure,
    Optional<String?>? collation
  }) => MysqlConnectionInfo(
    host: host ?? this.host,
    port: port ?? this.port,
    userName: userName ?? this.userName,
    password: password ?? this.password,
    databaseName: databaseName ?? this.databaseName,
    secure: checkOptional(secure, () => this.secure),
    collation: checkOptional(collation, () => this.collation),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is MysqlConnectionInfo && host == other.host && port == other.port && userName == other.userName && password == other.password && databaseName == other.databaseName && secure == other.secure && collation == other.collation;

  @override
  int get hashCode => host.hashCode ^ port.hashCode ^ userName.hashCode ^ password.hashCode ^ databaseName.hashCode ^ secure.hashCode ^ collation.hashCode;
}
