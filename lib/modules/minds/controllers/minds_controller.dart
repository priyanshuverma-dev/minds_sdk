import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:minds_sdk/modules/datasources/models/datasource_model.dart';
import 'package:minds_sdk/modules/minds/models/mind.dart';

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
  MindsController({
    required Dio client,
  }) : _client = client;

  @override
  Future<MindsModel?> get({required String name}) async {
    try {
      final response = await _client.get("/api/projects/mindsdb/minds/$name");
      final results = MindsModel.fromJson(response.data);

      return results;
    } catch (_) {
      return null;
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
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> create({required String name, List<String>? dataSources}) async {
    final dsList = [];
    if (dataSources != null) {
      for (var ds in dataSources) {
        final d = await _getDatasource(dataSourceName: ds);
        if (d != null) {
          dsList.add(d.name);
        }
      }
    }

    await _client.post(
      "/api/projects/mindsdb/minds",
      data: jsonEncode({
        "name": name,
        "datasources": dsList,
      }),
    );
  }

  @override
  Future<void> delete({required String name}) async {
    await _client.delete("/api/projects/mindsdb/minds/$name");
  }

  @override
  Future<void> update(
      {required String name,
      required String newName,
      List<String>? dataSources}) async {
    final dsList = [];
    if (dataSources != null) {
      for (var ds in dataSources) {
        final d = await _getDatasource(dataSourceName: ds);
        if (d != null) {
          dsList.add(d.name);
        }
      }
    }
    await _client.patch(
      "/api/projects/mindsdb/minds/$name",
      data: jsonEncode({
        "name": newName,
        if (dsList.isNotEmpty) "datasources": dataSources,
      }),
    );
  }

  @override
  Future<bool?> addDatasources({
    required String mindName,
    required String dataSourceName,
  }) async {
    try {
      final datasource = await _getDatasource(dataSourceName: dataSourceName);
      if (datasource == null) {
        throw Error.safeToString("Datasource doesn't exists.");
      }
      final response = await _client.post(
        "/api/projects/mindsdb/minds/$mindName/datasources",
        data: jsonEncode({"name": datasource.name}),
      );

      final data = jsonDecode(response.data);

      return data['success'] as bool;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteDatasources(
      {required String mindName, required String dataSourceName}) async {
    try {
      final datasource = await _getDatasource(dataSourceName: dataSourceName);
      if (datasource == null) {
        throw Error.safeToString("Datasource doesn't exists.");
      }
      await _client.post(
        "/api/projects/mindsdb/minds/$mindName/datasources",
        data: jsonEncode({"name": datasource.name}),
      );
    } catch (_) {}
  }

  Future<DataSourceModel?> _getDatasource({
    required String dataSourceName,
  }) async {
    try {
      final response = await _client.get("/api/datasources/$dataSourceName");
      final results = DataSourceModel.fromJson(response.data);

      return results;
    } catch (_) {
      return null;
    }
  }
}
