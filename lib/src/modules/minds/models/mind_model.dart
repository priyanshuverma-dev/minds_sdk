class MindsModel {
  final String createdAt;
  final List<String> datasources;
  final String modelName;
  final String name;
  final Map<String, dynamic> parameters; // Dynamic parameters
  final String provider;
  final String updatedAt;

  MindsModel({
    required this.createdAt,
    required this.datasources,
    required this.modelName,
    required this.name,
    required this.parameters,
    required this.provider,
    required this.updatedAt,
  });

  factory MindsModel.fromJson(Map<String, dynamic> json) {
    return MindsModel(
      createdAt: json['created_at'],
      datasources: List<String>.from(json['datasources']),
      modelName: json['model_name'],
      name: json['name'],
      parameters: Map<String, dynamic>.from(json['parameters']),
      provider: json['provider'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'datasources': datasources,
      'model_name': modelName,
      'name': name,
      'parameters': parameters,
      'provider': provider,
      'updated_at': updatedAt,
    };
  }
}
