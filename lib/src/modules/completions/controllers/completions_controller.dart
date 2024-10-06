import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:minds_sdk/src/modules/completions/models/completions_model.dart';
import 'package:minds_sdk/src/modules/completions/models/completions_request_model.dart';

abstract class ICompletions {
  Future<ChatCompletion> chat({
    required CompletionsRequestModel request,
  });
}

class CompletionsController implements ICompletions {
  final Dio _client;
  final Logger _logger = Logger('CompletionsController');
  CompletionsController({
    required Dio client,
  }) : _client = client;

  @override
  Future<ChatCompletion> chat({
    required CompletionsRequestModel request,
  }) async {
    try {
      final response = await _client.post(
        "chat/completions",
        data: request.toJson(), // Include the request data in the post
      );
      return ChatCompletion.fromJson(response.data);
    } on DioException catch (e) {
      _logger.severe("Error in chat completion: ${e.message}", e);
      throw Exception("Failed to get chat completion");
    } catch (e) {
      _logger.severe("An unexpected error occurred: ${e.toString()}", e);
      throw Exception("An unexpected error occurred");
    }
  }
}
