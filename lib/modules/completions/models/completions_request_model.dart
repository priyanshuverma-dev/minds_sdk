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

class Message {
  final String role;
  final String content;

  Message({
    required this.role,
    required this.content,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}
