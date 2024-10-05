import 'package:dio/dio.dart';
import 'package:minds_sdk/modules/datasources/models/datasource_model.dart';

abstract class IDatasouces {
  Future<DataSourceModel> create({
    required DataSourceModel dataSource,
  });
  Future<void> delete({required String dataSourceName});
  Future<List<DataSourceModel>> list();
  Future<DataSourceModel?> get({
    required String dataSourceName,
    bool checkConnection = true,
  });
}

class DatasourcesController implements IDatasouces {
  final Dio _client;
  DatasourcesController({
    required Dio client,
  }) : _client = client;

  @override
  Future<DataSourceModel?> get(
      {required String dataSourceName, bool checkConnection = true}) async {
    try {
      final response = await _client.get(
          "/api/datasources/$dataSourceName?check_connection=$checkConnection");
      final results = DataSourceModel.fromJson(response.data);

      return results;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DataSourceModel> create({
    required DataSourceModel dataSource,
  }) async {
    final datasource = await get(dataSourceName: dataSource.name);
    if (datasource != null) {
      await delete(dataSourceName: datasource.name);
    }

    await _client.post(
      "/api/datasources",
      data: dataSource.toJson(),
    );

    final newDataSource = await get(dataSourceName: dataSource.name);
    return newDataSource!;
  }

  @override
  Future<void> delete({required String dataSourceName}) async {
    await _client.delete("/api/datasources/$dataSourceName");
  }

  @override
  Future<List<DataSourceModel>> list() async {
    try {
      final response = await _client.get("/api/datasources");

      List<dynamic> data = response.data;
      List<DataSourceModel> dataSourcesList =
          data.map((json) => DataSourceModel.fromJson(json)).toList();

      return dataSourcesList;
    } catch (_) {
      return [];
    }
  }
}
