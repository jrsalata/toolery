import 'package:test/test.dart';
import 'package:toolery/models/task.dart';

void main() {
  group('Task model', () {
    const task = Task(
      id: 1,
      name: 'Test',
      description: 'This is a test',
      task: 'Testing',
    );

    test('toString returns expected format', () {
      expect(
        task.toString(),
        'Task(id: 1, name: Test, description: This is a test, task: Testing)',
      );
    });

    test('toMap returns correct map', () {
      expect(task.toMap(), {
        'id': 1,
        'name': 'Test',
        'description': 'This is a test',
        'task': 'Testing',
      });
    });

    test('fromMap reconstructs a Task', () {
      final map = {
        'id': 2,
        'name': 'FromMap',
        'description': 'desc',
        'task': 'do it',
      };
      final t = Task.fromMap(map);
      expect(t.id, 2);
      expect(t.name, 'FromMap');
      expect(t.description, 'desc');
      expect(t.task, 'do it');
    });

    test('toJson/fromJson round-trip', () {
      final json = task.toJson();
      final restored = Task.fromJson(json);
      expect(restored, task);
    });

    test('copyWith changes only specified fields', () {
      final copy = task.copyWith(name: 'Updated');
      expect(copy.id, task.id);
      expect(copy.name, 'Updated');
      expect(copy.description, task.description);
      expect(copy.task, task.task);
    });

    test('copyWith with no arguments returns equivalent task', () {
      final copy = task.copyWith();
      expect(copy, task);
    });

    test('equality holds for identical data', () {
      const other = Task(
        id: 1,
        name: 'Test',
        description: 'This is a test',
        task: 'Testing',
      );
      expect(task, other);
    });

    test('inequality when fields differ', () {
      final other = task.copyWith(id: 99);
      expect(task == other, isFalse);
    });

    test('hashCode is consistent with equality', () {
      const other = Task(
        id: 1,
        name: 'Test',
        description: 'This is a test',
        task: 'Testing',
      );
      expect(task.hashCode, other.hashCode);
    });
  });
}
