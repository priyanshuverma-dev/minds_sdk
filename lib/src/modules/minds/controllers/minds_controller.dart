import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:minds_sdk/src/modules/datasources/models/datasource_model.dart';
import 'package:minds_sdk/src/modules/minds/models/mind_model.dart';

/// Interface defining operations to manage Minds.
abstract class IMinds {
  /// Lists all available minds.
  Future<List<MindsModel>> list();

  /// Fetches a mind by its name.
  ///
  /// [name] is the name of the mind to be fetched.
  /// Returns a [MindsModel] representing the mind, or `null` if not found or an error occurs.
  Future<MindsModel?> get({required String name});

  /// Creates a new mind with optional data sources.
  ///
  /// [name] is the name of the mind to be created.
  /// [dataSources] is an optional list of data source names to be associated with the mind.
  Future<void> create({required String name, List<String>? dataSources});

  /// Updates an existing mind.
  ///
  /// [name] is the current name of the mind to be updated.
  /// [newName] is the new name for the mind.
  /// [dataSources] is an optional list of data source names to update the mind's data sources.
  Future<void> update({
    required String name,
    required String newName,
    List<String>? dataSources,
  });

  /// Deletes a mind by its name.
  ///
  /// [name] is the name of the mind to delete.
  Future<void> delete({required String name});

  /// Adds a data source to a mind.
  ///
  /// [mindName] is the name of the mind.
  /// [dataSourceName] is the name of the data source to add.
  /// Returns a boolean indicating success, or `null` if an error occurs.
  Future<bool?> addDatasources({
    required String mindName,
    required String dataSourceName,
  });

  /// Removes a data source from a mind.
  ///
  /// [mindName] is the name of the mind.
  /// [dataSourceName] is the name of the data source to remove.
  Future<void> deleteDatasources({
    required String mindName,
    required String dataSourceName,
  });
}

/// Controller class to manage Minds operations using an API.
class MindsController implements IMinds {
  /// HTTP client to make API requests.
  final Dio _client;

  /// Logger instance for recording logs.
  final Logger _logger = Logger('MindsController');

  /// Constructor for creating a [MindsController] with an injected [Dio] client.
  MindsController({
    required Dio client,
  }) : _client = client;

  /// Fetches a mind by its name.
  ///
  /// [name] is the name of the mind to be fetched.
  /// Returns a [MindsModel] if the mind is found, or `null` if an error occurs or the mind doesn't exist.
  @override
  Future<MindsModel?> get({required String name}) async {
    try {
      final response = await _client.get("/api/projects/mindsdb/minds/$name");
      return MindsModel.fromJson(response.data);
    } on DioException catch (e) {
      _logger.severe("Error fetching mind: ${e.message}");
      return null;
    }
  }

  /// Lists all available minds.
  ///
  /// Returns a [List] of [MindsModel] representing all available minds, or an empty list if an error occurs.
  @override
  Future<List<MindsModel>> list() async {
    try {
      final response = await _client.get("/api/projects/mindsdb/minds");
      List<dynamic> data = response.data;
      return data.map((json) => MindsModel.fromJson(json)).toList();
    } on DioException catch (e) {
      _logger.severe("Error fetching minds list: ${e.message}");
      return [];
    }
  }

  /// Creates a new mind with optional associated data sources.
  ///
  /// [name] is the name of the mind to be created.
  /// [dataSources] is an optional list of data source names.
  ///
  /// Throws an [Exception] if the creation fails.
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

  /// Updates an existing mind.
  ///
  /// [name] is the current name of the mind to be updated.
  /// [newName] is the new name for the mind.
  /// [dataSources] is an optional list of data source names to update.
  ///
  /// Throws an [Exception] if the update fails.
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

  /// Deletes a mind by its name.
  ///
  /// [name] is the name of the mind to delete.
  ///
  /// Throws an [Exception] if the deletion fails.
  @override
  Future<void> delete({required String name}) async {
    try {
      await _client.delete("/api/projects/mindsdb/minds/$name");
    } on DioException catch (e) {
      _logger.severe("Error deleting mind: ${e.message}");
      throw Exception("Failed to delete mind");
    }
  }

  /// Adds a data source to a mind.
  ///
  /// [mindName] is the name of the mind.
  /// [dataSourceName] is the name of the data source to add.
  ///
  /// Returns `true` if successful, `false` if unsuccessful, or `null` if an error occurs.
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

  /// Removes a data source from a mind.
  ///
  /// [mindName] is the name of the mind.
  /// [dataSourceName] is the name of the data source to remove.
  ///
  /// Throws an [Exception] if the removal fails.
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

  /// Fetches a data source by its name.
  ///
  /// [dataSourceName] is the name of the data source.
  /// Returns a [DataSourceModel] if found, or `null` if an error occurs or the data source doesn't exist.
  Future<DataSourceModel?> _getDatasource(String dataSourceName) async {
    try {
      final response = await _client.get("/api/datasources/$dataSourceName");
      return DataSourceModel.fromJson(response.data);
    } on DioException catch (e) {
      _logger.severe("Error fetching datasource: ${e.message}");
      return null;
    }
  }

  /// Processes a list of data source names and fetches their details.
  ///
  /// [dataSources] is an optional list of data source names.
  /// Returns a [List] of data source names that were successfully fetched.
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
