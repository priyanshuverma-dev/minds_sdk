import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:minds_sdk/src/common/constants.dart';
import 'package:minds_sdk/src/modules/completions/controllers/completions_controller.dart';
import 'package:minds_sdk/src/modules/datasources/controllers/datasources_controller.dart';
import 'package:minds_sdk/src/modules/minds/controllers/minds_controller.dart';

/// `MindsClient` is the primary entry point for interacting with the Minds API.
/// It provides access to the following controllers:
///
/// - [MindsController] for managing Minds
/// - [DatasourcesController] for handling data sources
/// - [CompletionsController] for chat completions
///
/// The client is initialized with an API key for authentication, and manages
/// network requests via a [Dio] instance, which handles timeouts and errors.
///
/// Example:
/// ```dart
/// final mindsClient = MindsClient(apiKey: 'your_api_key');
/// final minds = await mindsClient.minds.list();
/// ```
///
/// The client handles various types of network errors, logging them accordingly.
class MindsClient {
  /// The API key used for authentication.
  final String _apiKey;

  /// The Dio HTTP client used to make network requests.
  late final Dio _client;

  /// A logger instance for recording internal events and errors.
  final Logger _logger = Logger('MindsClient');

  /// Creates a new `MindsClient` instance with the provided [apiKey].
  /// The client configures the Dio instance with connection and response timeouts.
  MindsClient({required String apiKey}) : _apiKey = apiKey {
    _client = Dio(
      BaseOptions(
        baseUrl: Constants.apiURL,
        headers: {"Authorization": "Bearer $_apiKey"},
        connectTimeout: const Duration(seconds: 5), // Connection timeout
        receiveTimeout: const Duration(seconds: 3), // Data receiving timeout
      ),
    );

    // Add an interceptor to handle Dio errors and log them.
    _client.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) {
        _handleDioError(error);
        return handler.next(error);
      },
    ));
  }

  /// Returns an instance of [MindsController] to manage Mind operations.
  MindsController get minds => MindsController(client: _client);

  /// Returns an instance of [CompletionsController] for handling chat completions.
  CompletionsController get completions =>
      CompletionsController(client: _client);

  /// Returns an instance of [DatasourcesController] for managing data sources.
  DatasourcesController get datasources =>
      DatasourcesController(client: _client);

  /// Handles Dio-specific errors such as connection timeouts, server errors,
  /// and network issues. Logs detailed messages for each error type.
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
