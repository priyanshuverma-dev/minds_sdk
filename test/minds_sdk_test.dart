import 'package:flutter_test/flutter_test.dart';

import 'package:minds_sdk/minds_sdk.dart';

import 'constants.dart';

void main() {
  final sdk = MindsClient(apiKey: "");

  group("Datasources", () {
    test('Create Datasource', () async {
      await sdk.datasources.create(dataSource: TestConstants.testDatasouce);
    });
    test('List Datasources', () async {
      final data = await sdk.datasources.list();
      expect(data.length, 1);
    });

    test('Get Datasource', () async {
      final data = await sdk.datasources.get(
        dataSourceName: TestConstants.testDatasouce.name,
      );

      expect(data?.name, TestConstants.testDatasouce.name);
    });
  });

  group("Minds", () {
    test('Create Mind', () async {
      await sdk.minds.create(name: TestConstants.mindsName, dataSources: []);
    });
    test('Get Mind', () async {
      final data = await sdk.minds.get(name: TestConstants.mindsName);
      expect(data?.name, TestConstants.mindsName);
    });
    test('Get Minds List', () async {
      final data = await sdk.minds.list();
      expect(data.length, 1);
    });

    test('Add Data Source to Mind', () async {
      await sdk.datasources.create(dataSource: TestConstants.testDatasouce1);
      await sdk.minds.addDatasources(
        mindName: TestConstants.mindsName,
        dataSourceName: TestConstants.testDatasouce1.name,
      );
    });
    test('Update Mind', () async {
      await sdk.minds.update(
        name: TestConstants.mindsName,
        newName: TestConstants.mindsNameUpdated,
      );
    });

    // test('Delete Mind', () async {
    //   await sdk.minds.delete(name: TestConstants.mindsNameUpdated);
    //   await sdk.datasources
    //       .delete(dataSourceName: TestConstants.testDatasouce1.name);
    // });
  });
}
