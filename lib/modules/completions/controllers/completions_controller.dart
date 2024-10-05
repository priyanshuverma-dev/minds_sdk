import 'package:dio/dio.dart';
import 'package:minds_sdk/modules/completions/models/completions_model.dart';
import 'package:minds_sdk/modules/completions/models/completions_request_model.dart';

abstract class ICompletions {
  Future<ChatCompletion> chat({
    required CompletionsRequestModel request,
  });
}

class CompletionsController implements ICompletions {
  final Dio _client;
  CompletionsController({
    required Dio client,
  }) : _client = client;

  @override
  Future<ChatCompletion> chat({
    required CompletionsRequestModel request,
  }) async {
    final response = await _client.post("chat/completions");
    final results = ChatCompletion.fromJson(response.data);
    return results;
  }
}
