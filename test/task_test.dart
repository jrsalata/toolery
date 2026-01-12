import 'package:toolery/models/task.dart';
import 'package:test/test.dart';

void main() {
  test('Task should stringify cleanly', () {
    final Task test = Task(
      id: 1,
      name: "Test",
      description: "This is a test",
      task: "Testing",
    );
    String testString = test.toString();
    expect(
      testString,
      "Task: {'id': 1, 'name': Test, 'description': This is a test, 'task': Testing}",
    );
  });

  test('Task should map properly', () {
    final Task test = Task(
      id: 1,
      name: "Test",
      description: "This is a test",
      task: "Testing",
    );
    Map<String, Object?> testString = test.toMap();
    expect(
      testString,
      {'id': 1, 'name': "Test", 'description': "This is a test", 'task': "Testing"},
    );
  });
}
