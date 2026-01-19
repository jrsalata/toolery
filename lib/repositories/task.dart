import 'package:toolery/models/task.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toolery/database/startdb.dart';
import 'package:toolery/models/tag.dart';
import 'dart:async';

abstract class TaskRepository {
  Future<List<Task>> allTasks();
  Future<void> insertTask(Task task);
  Future<Task> getTask(int id);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(int id);
  Future<List<Tag>> tagsForTask(int taskID);
  Future<void> addTag(int taskID, int tagID);
  Future<void> removeTag(int taskID, int tagID);

  // flag if the repository is ready
  Future<void> get ready;
}

class SqliteTaskRepository implements TaskRepository {
  late Database db;
  final String table = 'task';
  final String joinTable = 'tasktag';
  final Completer<void> _ready = Completer<void>();

  SqliteTaskRepository() {
    _initDB();
  }

  Future<void> _initDB() async {
    db = await getDatabase();

    // mark the repository as ready to be used
    if (!_ready.isCompleted) _ready.complete();
  }

  // return the status of the completer
  @override
  Future<void> get ready => _ready.future;

  Task _fromMap(Map<String, Object?> m) => Task.fromMap(m);

  Map<String, Object?> _toMap(Task t) => t.toMap();

  @override
  Future<void> deleteTask(int id) async {
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
    await db.delete(joinTable, where: 'taskID = ?', whereArgs: [id]);
  }

  @override
  Future<void> insertTask(Task task) async {
    Map<String, Object?> map = _toMap(task);
    map.remove('id');
    await db.insert(table, map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<Task>> allTasks() async {
    final rows = await db.query(table);
    return rows.map((r) => _fromMap(r)).toList();
  }

  @override
  Future<Task> getTask(int id) async {
    final rows = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return Task(
        id: -1,
        name: "Null",
        description: "If you see this, report it!",
        task: "This task should not exist!",
      );
    }
    return _fromMap(rows.first);
  }

  @override
  Future<void> updateTask(Task task) async {
    final map = _toMap(task);
    final id = map['id'];
    if (id == null) return;
    await db.update(table, map, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Tag>> tagsForTask(int taskID) async {
    final rows = await db.rawQuery(
      'SELECT id, name, color FROM tag JOIN tasktag on tag.id = tasktag.tagID WHERE tasktag.taskID = ?',
      [taskID],
    );
    return rows.map((row) => Tag.fromMap(row)).toList();
  }

  @override
  Future<void> addTag(int taskID, int tagID) async {
    await db.insert(joinTable, {
      'taskID': taskID,
      'tagID': tagID,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  @override
  Future<void> removeTag(int taskID, int tagID) async {
    await db.delete(
      joinTable,
      where: "taskID = ? AND tagID = ?",
      whereArgs: [taskID, tagID],
    );
  }
}
