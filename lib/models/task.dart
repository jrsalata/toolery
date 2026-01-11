import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toolery/database/startdb.dart';

class Task {
  final int id;
  final String name;
  final String description;
  final String task;

  const Task({
    required this.id,
    required this.name,
    required this.description,
    required this.task,
  });

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'description': description, 'task': task};
  }

  @override
  String toString() {
    return "Task: {'id': $id, 'name': $name, 'description': $description, 'task': $task}";
  }
}

// in order to maintain a single state among everything
// we will create a ChangeNotifier with our tasks
// to access tasks, interact with the TaskChangeNotifier.tasks
class TaskChangeNotifier with ChangeNotifier {

  // create a list with a getter
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  TaskChangeNotifier() {
    _loadTasks();
  }

  // after any CREATE, UPDATE, or DELETE activity
  // run _loadTasks() to send up to date info
  // to all of our listeners
  Future<void> _loadTasks() async {
    _tasks = await allTasks();
    notifyListeners();
  }

  Future<List<Task>> allTasks() async {
    
    // open up the db
    final db = await getDatabase();

    // get all of the tasks
    final List<Map<String, Object?>> taskMaps = await db.query('task');

    // convert the map to tasks
    return [
      for (final {
            'id': id as int,
            'name': name as String,
            'description': description as String,
            'task': task as String,
          }
          in taskMaps)
        Task(id: id, name: name, description: description, task: task),
    ];
  }

  Future<void> insertTask(Task task) async {
    // note that we are removing the ID field
    // so we can let SQLite autoincrement
    // https://sqlite.org/autoinc.html
    Map<String, Object?> taskMap = task.toMap();
    taskMap.remove('id');

    final db = await getDatabase();

    await db.insert('task', taskMap, conflictAlgorithm: ConflictAlgorithm.fail);
    _loadTasks();
  }

  Future<Task> getTask(int id) async {
    final db = await getDatabase();

    final List<Map<String, Object?>> task = await db.query(
      'task',
      where: 'id=?',
      whereArgs: [id],
    );

    Map<String, Object?> rawTask = task[0];

    return Task(
      id: rawTask["id"] as int,
      name: rawTask["name"] as String,
      description: rawTask["description"] as String,
      task: rawTask["task"] as String,
    );
  }

  Future<void> updateTask(Task task) async {
    final db = await getDatabase();

    await db.update('task', task.toMap(), where: 'id=?', whereArgs: [task.id]);
    _loadTasks();
  }

  Future<void> deleteTask(int id) async {
    final db = await getDatabase();

    await db.delete('task', where: 'id=?', whereArgs: [id]);
    _loadTasks();
  }
}
