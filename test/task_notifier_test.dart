import 'package:flutter_test/flutter_test.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/notifiers/task.dart';

import 'helpers/mock_repositories.dart';

Task _makeTask({int id = 0, String name = 'Test Task'}) => Task(
  id: id,
  name: name,
  description: 'A description',
  task: 'Do the thing',
);

void main() {
  late FakeTaskRepository repo;
  late TaskNotifier notifier;

  setUp(() {
    repo = FakeTaskRepository();
    notifier = TaskNotifier(repository: repo);
  });

  tearDown(() => notifier.dispose());

  group('TaskNotifier', () {
    test('starts with an empty task list', () async {
      await Future.microtask(() {});
      expect(notifier.tasks, isEmpty);
    });

    test('create adds a task and updates the list', () async {
      await notifier.create(_makeTask(name: 'New Task'));
      expect(notifier.tasks.length, 1);
      expect(notifier.tasks.first.name, 'New Task');
    });

    test('create returns the inserted task with a generated id', () async {
      final created = await notifier.create(_makeTask());
      expect(created.id, isPositive);
    });

    test('delete removes the task from the list', () async {
      final created = await notifier.create(_makeTask());
      await notifier.delete(created.id);
      expect(notifier.tasks, isEmpty);
    });

    test('update changes task fields', () async {
      final created = await notifier.create(_makeTask(name: 'Original'));
      final updated = created.copyWith(name: 'Updated');
      await notifier.update(updated);
      expect(notifier.tasks.first.name, 'Updated');
    });

    test('addTag associates a tag with a task', () async {
      final created = await notifier.create(_makeTask());
      await notifier.addTag(created.id, 42);
      expect(notifier.getTags(created), contains(42));
    });

    test('removeTag dissociates a tag from a task', () async {
      final created = await notifier.create(_makeTask());
      await notifier.addTag(created.id, 42);
      await notifier.removeTag(created.id, 42);
      expect(notifier.getTags(created), isNot(contains(42)));
    });

    test('getTags returns empty list for task with no tags', () async {
      final created = await notifier.create(_makeTask());
      expect(notifier.getTags(created), isEmpty);
    });

    test('setTags replaces all tags', () async {
      final created = await notifier.create(_makeTask());
      await notifier.addTag(created.id, 1);
      await notifier.addTag(created.id, 2);
      await notifier.setTags(created, [3, 4]);
      final tags = notifier.getTags(created);
      expect(tags, containsAll([3, 4]));
      expect(tags, isNot(contains(1)));
      expect(tags, isNot(contains(2)));
    });

    test('setTags with empty list removes all tags', () async {
      final created = await notifier.create(_makeTask());
      await notifier.addTag(created.id, 1);
      await notifier.setTags(created, []);
      expect(notifier.getTags(created), isEmpty);
    });

    test('getById returns the correct task', () async {
      final created = await notifier.create(_makeTask(name: 'Find Me'));
      final found = await notifier.getById(created.id);
      expect(found.name, 'Find Me');
    });

    test('loadAll notifies listeners', () async {
      bool notified = false;
      notifier.addListener(() => notified = true);
      await notifier.loadAll();
      expect(notified, isTrue);
    });
  });
}
