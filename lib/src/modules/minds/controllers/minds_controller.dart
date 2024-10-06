import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:minds_sdk/src/modules/datasources/models/datasource_model.dart';
import 'package:minds_sdk/src/modules/minds/models/mind_model.dart';

abstract class IMinds {
  Future<List<MindsModel>> list();
  Future<MindsModel?> get({required String name});
  Future<void> create({required String name, List<String>? dataSources});
  Future<void> update({
    required String name,
    required String newName,
    List<String>? dataSources,
  });
  Future<void> delete({required String name});
  Future<bool?> addDatasources({
    required String mindName,
    required String dataSourceName,
  });
  Future<void> deleteDatasources({
    required String mindName,
    required String dataSourceName,
  });
}

class MindsController implements IMinds {
  final Dio _client;
  final Logger _logger = Logger('MindsController');
  MindsController({
    required Dio client,
  }) : _client = client;

  @override
  Future<MindsModel?> get({required String name}) async {
    try {
      final response = await _client.get("/api/projects/mindsdb/minds/$name");
      final results = MindsModel.fromJson(response.data);

      return results;
    } on DioException catch (e) {
      _logger.severe("Error fetching mind: ${e.message}");
      return null; // Handle error, return null if failed
    }
  }

  @override
  Future<List<MindsModel>> list() async {
    try {
      final response = await _client.get("/api/projects/mindsdb/minds");

      List<dynamic> data = response.data;
      List<MindsModel> mindsList =
          data.map((json) => MindsModel.fromJson(json)).toList();

      return mindsList;
    } on DioException catch (e) {
      _logger.severe("Error fetching minds list: ${e.message}");
      return []; // Return an empty list if there's an error
    }
  }

  @override
  Future<void> create({required String name, List<String>? dataSources}) async {
    final List<String> dsList = await _processDataSources(dataSources);

    try {
      await _client.post(
        "/api/projects/mindsdb/minds",
        data: jsonEncode({
          "name": name,
          "datasources": dsList,
        }),
      );
    } on DioException catch (e) {
      _logger.severe("Error creating mind: ${e.message}");
      throw Exception("Failed to create mind");
    }
  }

  @override
  Future<void> update({
    required String name,
    required String newName,
    List<String>? dataSources,
  }) async {
    final List<String> dsList = await _processDataSources(dataSources);
    try {
      await _client.patch(
        "/api/projects/mindsdb/minds/$name",
        data: jsonEncode({
          "name": newName,
          if (dsList.isNotEmpty) "datasources": dsList,
        }),
      );
    } on DioException catch (e) {
      _logger.severe("Error updating mind: ${e.message}");
      throw Exception("Failed to update mind");
    }
  }

  @override
  Future<void> delete({required String name}) async {
    try {
      await _client.delete("/api/projects/mindsdb/minds/$name");
    } on DioException catch (e) {
      _logger.severe("Error deleting mind: ${e.message}");
      throw Exception("Failed to delete mind");
    }
  }

  @override
  Future<bool?> addDatasources({
    required String mindName,
    required String dataSourceName,
  }) async {
    try {
      final datasource = await _getDatasource(dataSourceName);
      if (datasource == null) {
        throw Exception("Datasource doesn't exist.");
      }
      final response = await _client.post(
        "/api/projects/mindsdb/minds/$mindName/datasources",
        data: jsonEncode({"name": datasource.name}),
      );

      final data = jsonDecode(response.data);

      return data['success'] as bool;
    } on DioException catch (e) {
      _logger.severe("Error adding datasource: ${e.message}");
      return null;
    }
  }

  @override
  Future<void> deleteDatasources({
    required String mindName,
    required String dataSourceName,
  }) async {
    try {
      final datasource = await _getDatasource(dataSourceName);
      if (datasource == null) {
        throw Exception("Datasource doesn't exist.");
      }
      await _client.post(
        "/api/projects/mindsdb/minds/$mindName/datasources",
        data: jsonEncode({"name": datasource.name}),
      );
    } on DioException catch (e) {
      _logger.severe("Error deleting datasource: ${e.message}");
      throw Exception("Failed to delete datasource");
    }
  }

  Future<DataSourceModel?> _getDatasource(String dataSourceName) async {
    try {
      final response = await _client.get("/api/datasources/$dataSourceName");
      return DataSourceModel.fromJson(response.data);
    } on DioException catch (e) {
      _logger.severe("Error fetching datasource: ${e.message}");
      return null;
    }
  }

  Future<List<String>> _processDataSources(List<String>? dataSources) async {
    final List<String> dsList = [];
    if (dataSources != null) {
      for (var ds in dataSources) {
        final d = await _getDatasource(ds);
        if (d != null) {
          dsList.add(d.name);
        }
      }
    }
    return dsList;
  }
}
