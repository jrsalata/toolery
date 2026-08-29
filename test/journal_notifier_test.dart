import 'package:flutter_test/flutter_test.dart';
import 'package:toolery/models/journal.dart';
import 'package:toolery/notifiers/journal.dart';

import 'helpers/mock_repositories.dart';

Journal _makeEntry({int id = 0, String title = 'Test Entry'}) => Journal(
  id: id,
  title: title,
  dateWritten: '2024-01-15T08:00:00.000',
  content: '[{"insert":"Test content.\\n"}]',
);

void main() {
  late FakeJournalRepository repo;
  late JournalNotifier notifier;

  setUp(() {
    repo = FakeJournalRepository();
    notifier = JournalNotifier(repository: repo);
  });

  tearDown(() => notifier.dispose());

  group('JournalNotifier', () {
    test('starts with an empty entries list', () async {
      await Future.microtask(() {});
      expect(notifier.entries, isEmpty);
    });

    test('create adds an entry and updates the list', () async {
      await notifier.create(_makeEntry(title: 'New Entry'));
      expect(notifier.entries.length, 1);
      expect(notifier.entries.first.title, 'New Entry');
    });

    test('create returns the inserted entry with a generated id', () async {
      final created = await notifier.create(_makeEntry());
      expect(created.id, isPositive);
    });

    test('delete removes the entry from the list', () async {
      final created = await notifier.create(_makeEntry());
      await notifier.delete(created.id);
      expect(notifier.entries, isEmpty);
    });

    test('update changes entry fields', () async {
      final created = await notifier.create(_makeEntry(title: 'Original'));
      final updated = created.copyWith(title: 'Updated');
      await notifier.update(updated);
      expect(notifier.entries.first.title, 'Updated');
    });

    test('addTag associates a tag with an entry', () async {
      final created = await notifier.create(_makeEntry());
      await notifier.addTag(created.id, 42);
      expect(notifier.getTags(created), contains(42));
    });

    test('removeTag dissociates a tag from an entry', () async {
      final created = await notifier.create(_makeEntry());
      await notifier.addTag(created.id, 42);
      await notifier.removeTag(created.id, 42);
      expect(notifier.getTags(created), isNot(contains(42)));
    });

    test('getTags returns empty list for entry with no tags', () async {
      final created = await notifier.create(_makeEntry());
      expect(notifier.getTags(created), isEmpty);
    });

    test('setTags replaces all tags', () async {
      final created = await notifier.create(_makeEntry());
      await notifier.addTag(created.id, 1);
      await notifier.addTag(created.id, 2);
      await notifier.setTags(created, [3, 4]);
      final tags = notifier.getTags(created);
      expect(tags, containsAll([3, 4]));
      expect(tags, isNot(contains(1)));
      expect(tags, isNot(contains(2)));
    });

    test('setTags with empty list removes all tags', () async {
      final created = await notifier.create(_makeEntry());
      await notifier.addTag(created.id, 1);
      await notifier.setTags(created, []);
      expect(notifier.getTags(created), isEmpty);
    });

    test('getById returns the correct entry', () async {
      final created = await notifier.create(_makeEntry(title: 'Find Me'));
      final found = await notifier.getById(created.id);
      expect(found.title, 'Find Me');
    });

    test('loadAll notifies listeners', () async {
      bool notified = false;
      notifier.addListener(() => notified = true);
      await notifier.loadAll();
      expect(notified, isTrue);
    });
  });
}
