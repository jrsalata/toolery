import 'package:flutter_test/flutter_test.dart';
import 'package:toolery/models/affirmation_item.dart';
import 'package:toolery/models/affirmation_list.dart';
import 'package:toolery/notifiers/affirmation.dart';

import 'helpers/mock_repositories.dart';

void main() {
  late FakeAffirmationRepository repo;
  late AffirmationNotifier notifier;

  setUp(() {
    repo = FakeAffirmationRepository();
    notifier = AffirmationNotifier(repository: repo);
  });

  tearDown(() => notifier.dispose());

  group('AffirmationNotifier', () {
    test('starts with empty lists and items', () async {
      await Future.microtask(() {});
      expect(notifier.lists, isEmpty);
      expect(notifier.items, isEmpty);
    });

    test('createList adds a list', () async {
      await notifier.createList(AffirmationList(id: 0, name: 'Mornings'));
      expect(notifier.lists.length, 1);
      expect(notifier.lists.first.name, 'Mornings');
    });

    test('deleteList removes the list and its items', () async {
      await notifier.createList(AffirmationList(id: 0, name: 'To Delete'));
      final id = notifier.lists.first.id;
      await notifier.deleteList(id);
      expect(notifier.lists, isEmpty);
      expect(notifier.items.containsKey(id), isFalse);
    });

    test('updateList changes list name', () async {
      await notifier.createList(AffirmationList(id: 0, name: 'Original'));
      final list = notifier.lists.first;
      await notifier.updateList(list.copyWith(name: 'Updated'));
      expect(notifier.lists.first.name, 'Updated');
    });

    test('addItem adds an item to the correct list', () async {
      await notifier.createList(AffirmationList(id: 0, name: 'List A'));
      final listId = notifier.lists.first.id;
      await notifier.addItem(
        AffirmationItem(id: 0, listId: listId, item: 'I am strong'),
      );
      expect(notifier.items[listId], isNotEmpty);
      expect(notifier.items[listId]!.first.item, 'I am strong');
    });

    test('updateItem changes item text', () async {
      await notifier.createList(AffirmationList(id: 0, name: 'List B'));
      final listId = notifier.lists.first.id;
      await notifier.addItem(
        AffirmationItem(id: 0, listId: listId, item: 'Original'),
      );
      final item = notifier.items[listId]!.first;
      await notifier.updateItem(item.copyWith(item: 'Updated'));
      expect(notifier.items[listId]!.first.item, 'Updated');
    });

    test('deleteItem removes the item', () async {
      await notifier.createList(AffirmationList(id: 0, name: 'List C'));
      final listId = notifier.lists.first.id;
      await notifier.addItem(
        AffirmationItem(id: 0, listId: listId, item: 'To Remove'),
      );
      final item = notifier.items[listId]!.first;
      await notifier.deleteItem(item.id, listId: listId);
      expect(notifier.items[listId], isEmpty);
    });

    test('randomAffirmation returns one of the items in the list', () async {
      await notifier.createList(AffirmationList(id: 0, name: 'Random'));
      final listId = notifier.lists.first.id;
      await notifier.addItem(
        AffirmationItem(id: 0, listId: listId, item: 'Affirmation A'),
      );
      await notifier.addItem(
        AffirmationItem(id: 0, listId: listId, item: 'Affirmation B'),
      );
      final result = await notifier.randomAffirmation(listId);
      expect(['Affirmation A', 'Affirmation B'], contains(result));
    });

    test('randomAffirmation returns empty string for empty list', () async {
      await notifier.createList(AffirmationList(id: 0, name: 'Empty'));
      final listId = notifier.lists.first.id;
      final result = await notifier.randomAffirmation(listId);
      expect(result, '');
    });

    test('loadAll notifies listeners', () async {
      bool notified = false;
      notifier.addListener(() => notified = true);
      await notifier.loadAll();
      expect(notified, isTrue);
    });

    test('loadItemsForList populates items map for given list', () async {
      await notifier.createList(AffirmationList(id: 0, name: 'Load Test'));
      final listId = notifier.lists.first.id;
      await repo.insertItem(
        AffirmationItem(id: 0, listId: listId, item: 'Seeded item'),
      );
      await notifier.loadItemsForList(listId);
      expect(notifier.items[listId], isNotEmpty);
    });
  });
}
