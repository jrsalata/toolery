import 'package:flutter_test/flutter_test.dart';
import 'package:toolery/data/data_service.dart';

void main() {
  group('DataService CSV encoding', () {
    test('encodeCSV produces a header row followed by data rows', () {
      final rows = [
        {'id': 1, 'name': 'Tag A', 'color': 4278221563},
      ];
      final csv = DataService.encodeCSV(rows);
      final lines = csv.trim().split('\n');
      expect(lines.length, 2);
      expect(lines[0], 'id,name,color');
      expect(lines[1], '1,Tag A,4278221563');
    });

    test('encodeCSV returns empty string for an empty list', () {
      expect(DataService.encodeCSV([]), '');
    });

    test('encodeCSV quotes fields that contain commas', () {
      final rows = [
        {'id': 1, 'item': 'Hello, World'},
      ];
      final csv = DataService.encodeCSV(rows);
      expect(csv, contains('"Hello, World"'));
    });

    test('encodeCSV escapes double quotes inside fields', () {
      final rows = [
        {'id': 1, 'item': 'Say "hello"'},
      ];
      final csv = DataService.encodeCSV(rows);
      expect(csv, contains('"Say ""hello"""'));
    });
  });

  group('DataService CSV decoding', () {
    test('decodeCSV reconstructs rows from a valid CSV string', () {
      const csv = 'id,name,color\n1,Tag A,4278221563\n';
      final rows = DataService.decodeCSV(csv);
      expect(rows.length, 1);
      expect(rows.first['id'], 1);
      expect(rows.first['name'], 'Tag A');
      expect(rows.first['color'], 4278221563);
    });

    test('decodeCSV returns an empty list for an empty string', () {
      expect(DataService.decodeCSV(''), isEmpty);
    });

    test('decodeCSV handles quoted fields containing commas', () {
      const csv = 'id,item\n1,"Hello, World"\n';
      final rows = DataService.decodeCSV(csv);
      expect(rows.first['item'], 'Hello, World');
    });

    test('decodeCSV handles escaped double quotes inside quoted fields', () {
      const csv = 'id,item\n1,"Say ""hello"""\n';
      final rows = DataService.decodeCSV(csv);
      expect(rows.first['item'], 'Say "hello"');
    });

    test('decodeCSV coerces integer strings to int', () {
      const csv = 'id,count\n42,7\n';
      final rows = DataService.decodeCSV(csv);
      expect(rows.first['id'], isA<int>());
      expect(rows.first['id'], 42);
    });

    test('decodeCSV leaves non-numeric strings as String', () {
      const csv = 'id,name\n1,Journal\n';
      final rows = DataService.decodeCSV(csv);
      expect(rows.first['name'], isA<String>());
      expect(rows.first['name'], 'Journal');
    });
  });

  group('DataService CSV round-trip', () {
    test('encodeCSV → decodeCSV preserves data', () {
      final original = [
        {
          'id': 1,
          'name': 'Task one',
          'description': 'Do it',
          'task': 'Do it now',
        },
        {'id': 2, 'name': 'Task "quoted"', 'description': 'A, B', 'task': 'OK'},
      ];
      final csv = DataService.encodeCSV(original);
      final decoded = DataService.decodeCSV(csv);
      expect(decoded.length, original.length);
      for (int i = 0; i < original.length; i++) {
        for (final key in original[i].keys) {
          expect(decoded[i][key], original[i][key]);
        }
      }
    });

    test('tableNames contains all nine expected tables', () {
      expect(DataService.tableNames, hasLength(9));
      expect(DataService.tableNames, contains('task'));
      expect(DataService.tableNames, contains('tag'));
      expect(DataService.tableNames, contains('breathing'));
      expect(DataService.tableNames, contains('affirmation_list'));
      expect(DataService.tableNames, contains('affirmation_items'));
      expect(DataService.tableNames, contains('tasktag'));
      expect(DataService.tableNames, contains('breathingtag'));
      expect(DataService.tableNames, contains('journal'));
      expect(DataService.tableNames, contains('journaltag'));
    });
  });
}
