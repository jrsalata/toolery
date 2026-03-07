import 'package:test/test.dart';
import 'package:toolery/models/affirmation_list.dart';
import 'package:toolery/models/affirmation_item.dart';

void main() {
  group('AffirmationList model', () {
    final list = AffirmationList(id: 1, name: 'Morning Mantras');

    test('toString returns expected format', () {
      expect(list.toString(), 'AffirmationList(id: 1, name: Morning Mantras)');
    });

    test('toMap returns correct map', () {
      expect(list.toMap(), {'id': 1, 'name': 'Morning Mantras'});
    });

    test('fromMap reconstructs an AffirmationList', () {
      final map = {'id': 2, 'name': 'Evening Thoughts'};
      final l = AffirmationList.fromMap(map);
      expect(l.id, 2);
      expect(l.name, 'Evening Thoughts');
    });

    test('toJson/fromJson round-trip', () {
      final json = list.toJson();
      final restored = AffirmationList.fromJson(json);
      expect(restored, list);
    });

    test('copyWith changes only specified fields', () {
      final copy = list.copyWith(name: 'Evening');
      expect(copy.id, list.id);
      expect(copy.name, 'Evening');
    });

    test('copyWith with no arguments returns equivalent list', () {
      expect(list.copyWith(), list);
    });

    test('equality holds for identical data', () {
      final other = AffirmationList(id: 1, name: 'Morning Mantras');
      expect(list, other);
    });

    test('inequality when fields differ', () {
      expect(list == list.copyWith(id: 99), isFalse);
      expect(list == list.copyWith(name: 'Other'), isFalse);
    });

    test('hashCode is consistent with equality', () {
      final other = AffirmationList(id: 1, name: 'Morning Mantras');
      expect(list.hashCode, other.hashCode);
    });
  });

  group('AffirmationItem model', () {
    final item = AffirmationItem(id: 1, listId: 2, item: 'I am capable');

    test('toString returns expected format', () {
      expect(
        item.toString(),
        'AffirmationItem(id: 1, listId: 2, item: I am capable)',
      );
    });

    test('toMap returns correct map with list_id key', () {
      expect(item.toMap(), {'id': 1, 'list_id': 2, 'item': 'I am capable'});
    });

    test('fromMap reconstructs an AffirmationItem using list_id key', () {
      final map = {'id': 3, 'list_id': 5, 'item': 'I am strong'};
      final i = AffirmationItem.fromMap(map);
      expect(i.id, 3);
      expect(i.listId, 5);
      expect(i.item, 'I am strong');
    });

    test('toJson/fromJson round-trip', () {
      final json = item.toJson();
      final restored = AffirmationItem.fromJson(json);
      expect(restored, item);
    });

    test('copyWith changes only specified fields', () {
      final copy = item.copyWith(item: 'I am resilient');
      expect(copy.id, item.id);
      expect(copy.listId, item.listId);
      expect(copy.item, 'I am resilient');
    });

    test('copyWith with no arguments returns equivalent item', () {
      expect(item.copyWith(), item);
    });

    test('equality holds for identical data', () {
      final other = AffirmationItem(id: 1, listId: 2, item: 'I am capable');
      expect(item, other);
    });

    test('inequality when fields differ', () {
      expect(item == item.copyWith(id: 99), isFalse);
      expect(item == item.copyWith(listId: 99), isFalse);
      expect(item == item.copyWith(item: 'different'), isFalse);
    });

    test('hashCode is consistent with equality', () {
      final other = AffirmationItem(id: 1, listId: 2, item: 'I am capable');
      expect(item.hashCode, other.hashCode);
    });
  });
}
