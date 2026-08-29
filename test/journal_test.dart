import 'package:test/test.dart';
import 'package:toolery/models/journal.dart';

void main() {
  group('Journal model', () {
    const entry = Journal(
      id: 1,
      title: 'Test Entry',
      dateWritten: '2024-01-15T08:00:00.000',
      content: '[{"insert":"Hello world.\\n"}]',
    );

    test('toString returns expected format', () {
      expect(
        entry.toString(),
        'Journal(id: 1, title: Test Entry, dateWritten: 2024-01-15T08:00:00.000)',
      );
    });

    test('toMap returns correct map', () {
      expect(entry.toMap(), {
        'id': 1,
        'title': 'Test Entry',
        'dateWritten': '2024-01-15T08:00:00.000',
        'content': '[{"insert":"Hello world.\\n"}]',
      });
    });

    test('fromMap reconstructs a Journal', () {
      final map = {
        'id': 2,
        'title': 'Another Entry',
        'dateWritten': '2024-02-01T10:00:00.000',
        'content': '[{"insert":"Some text.\\n"}]',
      };
      final e = Journal.fromMap(map);
      expect(e.id, 2);
      expect(e.title, 'Another Entry');
      expect(e.dateWritten, '2024-02-01T10:00:00.000');
      expect(e.content, '[{"insert":"Some text.\\n"}]');
    });

    test('toJson/fromJson round-trip', () {
      final json = entry.toJson();
      final restored = Journal.fromJson(json);
      expect(restored, entry);
    });

    test('copyWith changes only specified fields', () {
      final copy = entry.copyWith(title: 'Updated Title');
      expect(copy.id, entry.id);
      expect(copy.title, 'Updated Title');
      expect(copy.dateWritten, entry.dateWritten);
      expect(copy.content, entry.content);
    });

    test('copyWith with no arguments returns equivalent entry', () {
      final copy = entry.copyWith();
      expect(copy, entry);
    });

    test('equality holds for identical data', () {
      const other = Journal(
        id: 1,
        title: 'Test Entry',
        dateWritten: '2024-01-15T08:00:00.000',
        content: '[{"insert":"Hello world.\\n"}]',
      );
      expect(entry, other);
    });

    test('inequality when fields differ', () {
      final other = entry.copyWith(id: 99);
      expect(entry == other, isFalse);
    });

    test('hashCode is consistent with equality', () {
      const other = Journal(
        id: 1,
        title: 'Test Entry',
        dateWritten: '2024-01-15T08:00:00.000',
        content: '[{"insert":"Hello world.\\n"}]',
      );
      expect(entry.hashCode, other.hashCode);
    });
  });
}
