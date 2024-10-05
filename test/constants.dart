import 'package:minds_sdk/modules/datasources/models/datasource_model.dart';

class TestConstants {
  static const String mindsName = "testingMinds";
  static const String mindsNameUpdated = "Updated_testingMinds";

  static final DataSourceModel testDatasouce = DataSourceModel(
    name: "Dart_SDK_TEST_0120_938",
    description: "House Sales Data",
    engine: "postgres",
    tables: ["house_sales"],
    connectionData: ConnectionData(
      user: "demo_user",
      password: "demo_password",
      host: "samples.mindsdb.com",
      port: "5432",
      database: "demo",
      schema: "demo_data",
    ),
  );
  static final DataSourceModel testDatasouce1 = DataSourceModel(
    name: "Dart_SDK_TEST_0122_9_1938wd",
    description: "House Sales Data",
    engine: "postgres",
    tables: ["house_sales"],
    connectionData: ConnectionData(
      user: "demo_user",
      password: "demo_password",
      host: "samples.mindsdb.com",
      port: "5432",
      database: "demo",
      schema: "demo_data",
    ),
  );
}
