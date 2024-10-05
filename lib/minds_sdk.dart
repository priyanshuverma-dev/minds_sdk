library minds_sdk;

import 'package:dio/dio.dart';
import 'package:minds_sdk/common/constants.dart';
import 'package:minds_sdk/modules/completions/controllers/completions_controller.dart';
import 'package:minds_sdk/modules/datasources/controllers/datasources_controller.dart';
import 'package:minds_sdk/modules/minds/controllers/minds_controller.dart';

/// A Minds DART SDK.
class MindsClient {
  final String _apiKey;
  late final Dio _client;

  MindsClient({required String apiKey}) : _apiKey = apiKey {
    _client = Dio(
      BaseOptions(
        baseUrl: Constants.apiURL,
        headers: {"Authorization": "Bearer $_apiKey"},
      ),
    );
    _client.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) {
        print("STATUS: ${error.response?.statusCode}");
        print(error.response?.data);

        return handler.next(error);
      },
    ));
  }

  MindsController get minds => MindsController(client: _client);

  CompletionsController get completions =>
      CompletionsController(client: _client);

  DatasourcesController get datasources =>
      DatasourcesController(client: _client);
}
