import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:minds_sdk/src/modules/datasources/models/datasource_model.dart';

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
  final Logger _logger = Logger('DatasourcesController');
  DatasourcesController({
    required Dio client,
  }) : _client = client;

  @override
  Future<DataSourceModel?> get(
      {required String dataSourceName, bool checkConnection = true}) async {
    try {
      final response = await _client.get(
          "/api/datasources/$dataSourceName?check_connection=$checkConnection");
      return DataSourceModel.fromJson(response.data);
    } on DioException catch (e) {
      _logger.severe(
        "Error fetching datasource '$dataSourceName': ${e.message}",
      );
      return null; // Handle error, return null if failed
    }
  }

  @override
  Future<DataSourceModel> create({
    required DataSourceModel dataSource,
  }) async {
    try {
      final existingDatasource = await get(dataSourceName: dataSource.name);
      if (existingDatasource != null) {
        await delete(dataSourceName: existingDatasource.name);
      }

      await _client.post(
        "/api/datasources",
        data: dataSource.toJson(),
      );

      final newDataSource = await get(dataSourceName: dataSource.name);
      return newDataSource!;
    } on DioException catch (e) {
      _logger.severe(
          "Error creating datasource '${dataSource.name}': ${e.message}");
      throw Exception("Failed to create datasource");
    }
  }

  @override
  Future<void> delete({required String dataSourceName}) async {
    try {
      await _client.delete("/api/datasources/$dataSourceName");
    } on DioException catch (e) {
      _logger.severe(
        "Error deleting datasource '$dataSourceName': ${e.message}",
      );
      throw Exception("Failed to delete datasource");
    }
  }

  @override
  Future<List<DataSourceModel>> list() async {
    try {
      final response = await _client.get("/api/datasources");
      List<dynamic> data = response.data;
      return data.map((json) => DataSourceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      _logger.severe("Error fetching datasources list: ${e.message}");
      return []; // Return an empty list if there's an error
    }
  }
}
