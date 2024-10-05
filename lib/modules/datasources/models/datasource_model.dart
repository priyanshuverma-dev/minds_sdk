class DataSourceModel {
  final ConnectionData connectionData;
  final String description;
  final String engine;
  final String name;
  final List<String> tables;

  DataSourceModel({
    required this.connectionData,
    required this.description,
    required this.engine,
    required this.name,
    required this.tables,
  });

  factory DataSourceModel.fromJson(Map<String, dynamic> json) {
    return DataSourceModel(
      connectionData: ConnectionData.fromJson(json['connection_data']),
      description: json['description'],
      engine: json['engine'],
      name: json['name'],
      tables: List<String>.from(json['tables']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connection_data': connectionData.toJson(),
      'description': description,
      'engine': engine,
      'name': name,
      'tables': tables,
    };
  }
}

class DataSourceUpdateModel {
  final ConnectionData connectionData;
  final String description;
  final List<String> tables;

  DataSourceUpdateModel({
    required this.connectionData,
    required this.description,
    required this.tables,
  });

  Map<String, dynamic> toJson() {
    return {
      'connection_data': connectionData.toJson(),
      'description': description,
      'tables': tables,
    };
  }
}

class ConnectionData {
  final String database;
  final String host;
  final String password;
  final String port;
  final String schema;
  final String user;

  ConnectionData({
    required this.database,
    required this.host,
    required this.password,
    required this.port,
    required this.schema,
    required this.user,
  });

  factory ConnectionData.fromJson(Map<String, dynamic> json) {
    return ConnectionData(
      database: json['database'],
      host: json['host'],
      password: json['password'],
      port: json['port'],
      schema: json['schema'],
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'database': database,
      'host': host,
      'password': password,
      'port': port,
      'schema': schema,
      'user': user,
    };
  }
}
