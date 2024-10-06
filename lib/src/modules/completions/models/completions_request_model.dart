import 'package:minds_sdk/src/modules/completions/models/completions_message_model.dart';

class CompletionsRequestModel {
  final String model;
  final List<Message> messages;
  final bool stream;

  CompletionsRequestModel({
    required this.model,
    required this.messages,
    required this.stream,
  });

  factory CompletionsRequestModel.fromJson(Map<String, dynamic> json) {
    return CompletionsRequestModel(
      model: json['model'],
      messages: (json['messages'] as List)
          .map((message) => Message.fromJson(message))
          .toList(),
      stream: json['stream'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((message) => message.toJson()).toList(),
      'stream': stream,
    };
  }
}
