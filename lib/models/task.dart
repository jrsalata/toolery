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

Future<void> insertTask(Task task) async {

  // note that we are removing the ID field
  // so we can let SQLite autoincrement
  // https://sqlite.org/autoinc.html
  Map<String, Object?> taskMap = task.toMap();
  taskMap.remove('id');

  final db = await getDatabase();

  await db.insert(
    'task',
    taskMap,
    conflictAlgorithm: ConflictAlgorithm.fail,
  );
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

Future<Task> getTask(int id) async {
  final db = await getDatabase();
  
  final List<Map<String, Object?>> task = await db.query(
    'task',
    where: 'id=?',
    whereArgs: [id]
  );
  
  Map<String, Object?> rawTask = task[0];

  return Task(id: rawTask["id"] as int, name: rawTask["name"] as String, description: rawTask["description"] as String, task: rawTask["task"] as String);
  
}


Future<void> updateTask(Task task) async {
  final db = await getDatabase();

  await db.update(
    'task',
    task.toMap(),
    where: 'id=?',
    whereArgs: [task.id]
  );
}

Future<void> deleteTask(Task task) async {
  final db = await getDatabase();

  await db.delete(
    'task',
    where: 'id=?',
    whereArgs: [task.id]
  );
}
