library minds_sdk;

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:minds_sdk/src/common/constants.dart';
import 'package:minds_sdk/src/modules/completions/controllers/completions_controller.dart';
import 'package:minds_sdk/src/modules/datasources/controllers/datasources_controller.dart';
import 'package:minds_sdk/src/modules/minds/controllers/minds_controller.dart';

/// A Minds DART SDK.
class MindsClient {
  final String _apiKey;
  late final Dio _client;
  final Logger _logger = Logger('MindsClient');
  MindsClient({required String apiKey}) : _apiKey = apiKey {
    _client = Dio(
      BaseOptions(
        baseUrl: Constants.apiURL,
        headers: {"Authorization": "Bearer $_apiKey"},
        connectTimeout: const Duration(seconds: 5), // Connection timeout
        receiveTimeout: const Duration(seconds: 3), // Data receiving timeout
      ),
    );
    _client.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) {
        _handleDioError(error);
        return handler.next(error);
      },
    ));
  }

  MindsController get minds => MindsController(client: _client);

  CompletionsController get completions =>
      CompletionsController(client: _client);

  DatasourcesController get datasources =>
      DatasourcesController(client: _client);

  void _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      _logger.severe("Connection Timeout: Could not connect to the server.");
    } else if (error.type == DioExceptionType.receiveTimeout) {
      _logger.severe("Receive Timeout: The server took too long to respond.");
    } else if (error.type == DioExceptionType.badResponse) {
      // Handle server-side errors
      _logger.severe("Server Error: ${error.response?.statusCode}");
      _logger.severe("Error Data: ${error.response?.data}");
    } else if (error.type == DioExceptionType.unknown) {
      // Handle no connection or DNS errors
      _logger.severe("Network Error: ${error.message}");
    }
  }
}
