import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:minds_sdk/src/modules/completions/models/completions_model.dart';
import 'package:minds_sdk/src/modules/completions/models/completions_request_model.dart';

/// Interface for handling chat completions.
abstract class ICompletions {
  /// Sends a chat completion request and returns the response.
  ///
  /// [request] is the [CompletionsRequestModel] containing the request data.
  /// Returns a [ChatCompletion] representing the completion response.
  Future<ChatCompletion> chat({
    required CompletionsRequestModel request,
  });
}

/// Controller class for managing chat completion operations using an API.
class CompletionsController implements ICompletions {
  /// HTTP client to make API requests.
  final Dio _client;

  /// Logger instance for recording logs.
  final Logger _logger = Logger('CompletionsController');

  /// Constructor for creating a [CompletionsController] with an injected [Dio] client.
  CompletionsController({
    required Dio client,
  }) : _client = client;

  /// Sends a chat completion request to the API and returns the response.
  ///
  /// [request] is a [CompletionsRequestModel] that includes the data to be sent to the completion endpoint.
  ///
  /// Returns a [ChatCompletion] representing the response from the server.
  ///
  /// Throws an [Exception] if the request fails or if an unexpected error occurs.
  @override
  Future<ChatCompletion> chat({
    required CompletionsRequestModel request,
  }) async {
    try {
      // Sends a POST request to the chat completions endpoint
      final response = await _client.post(
        "chat/completions",
        data: request.toJson(), // Serializes the request model into JSON
      );
      // Parses the JSON response into a ChatCompletion model
      return ChatCompletion.fromJson(response.data);
    } on DioException catch (e) {
      // Logs a severe error if the Dio request fails
      _logger.severe("Error in chat completion: ${e.message}", e);
      throw Exception("Failed to get chat completion");
    } catch (e) {
      // Logs any other unexpected errors
      _logger.severe("An unexpected error occurred: ${e.toString()}", e);
      throw Exception("An unexpected error occurred");
    }
  }
}
