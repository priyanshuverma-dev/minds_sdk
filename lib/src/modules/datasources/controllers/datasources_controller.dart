import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:minds_sdk/src/modules/datasources/models/datasource_model.dart';

/// Interface defining the operations that can be performed on data sources.
abstract class IDatasouces {
  /// Creates a new data source.
  ///
  /// [dataSource] is the data source object to be created.
  /// Returns a [DataSourceModel] representing the created data source.
  Future<DataSourceModel> create({
    required DataSourceModel dataSource,
  });

  /// Deletes a data source by its name.
  ///
  /// [dataSourceName] is the name of the data source to be deleted.
  Future<void> delete({required String dataSourceName});

  /// Lists all available data sources.
  ///
  /// Returns a [List] of [DataSourceModel] representing all data sources.
  Future<List<DataSourceModel>> list();

  /// Fetches a data source by its name.
  ///
  /// [dataSourceName] is the name of the data source to fetch.
  /// [checkConnection] is an optional flag to check the connection status of the data source.
  /// Returns a [DataSourceModel] if the data source is found, otherwise `null`.
  Future<DataSourceModel?> get({
    required String dataSourceName,
    bool checkConnection = true,
  });
}

/// Controller class to manage CRUD operations on data sources via API.
class DatasourcesController implements IDatasouces {
  /// HTTP client to make API requests.
  final Dio _client;

  /// Logger instance for recording logs.
  final Logger _logger = Logger('DatasourcesController');

  /// Constructor for creating [DatasourcesController] with an injected [Dio] client.
  DatasourcesController({
    required Dio client,
  }) : _client = client;

  /// Fetches a data source by its name.
  ///
  /// [dataSourceName] is the name of the data source to be fetched.
  /// [checkConnection] is an optional flag (defaults to true) to check the connection status.
  ///
  /// Returns a [DataSourceModel] if the data source is found, or `null` if an error occurs or the data source doesn't exist.
  @override
  Future<DataSourceModel?> get({
    required String dataSourceName,
    bool checkConnection = true,
  }) async {
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

  /// Creates a new data source. If the data source already exists, it deletes the existing one before creating a new one.
  ///
  /// [dataSource] is the [DataSourceModel] representing the data source to be created.
  ///
  /// Returns the newly created [DataSourceModel].
  ///
  /// Throws an [Exception] if the creation fails.
  @override
  Future<DataSourceModel> create({
    required DataSourceModel dataSource,
  }) async {
    try {
      // Check if the data source already exists
      final existingDatasource = await get(dataSourceName: dataSource.name);
      if (existingDatasource != null) {
        // Delete the existing data source before creating a new one
        await delete(dataSourceName: existingDatasource.name);
      }

      // Create a new data source
      await _client.post(
        "/api/datasources",
        data: dataSource.toJson(),
      );

      // Fetch and return the newly created data source
      final newDataSource = await get(dataSourceName: dataSource.name);
      return newDataSource!;
    } on DioException catch (e) {
      _logger.severe(
          "Error creating datasource '${dataSource.name}': ${e.message}");
      throw Exception("Failed to create datasource");
    }
  }

  /// Deletes a data source by its name.
  ///
  /// [dataSourceName] is the name of the data source to delete.
  ///
  /// Throws an [Exception] if the deletion fails.
  @override
  Future<void> delete({required String dataSourceName}) async {
    try {
      // Delete the data source
      await _client.delete("/api/datasources/$dataSourceName");
    } on DioException catch (e) {
      _logger.severe(
        "Error deleting datasource '$dataSourceName': ${e.message}",
      );
      throw Exception("Failed to delete datasource");
    }
  }

  /// Lists all available data sources.
  ///
  /// Returns a [List] of [DataSourceModel] representing the available data sources.
  /// Returns an empty list if an error occurs.
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
