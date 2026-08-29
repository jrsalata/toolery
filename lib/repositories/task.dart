import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:toolery/database/startdb.dart';
import 'package:toolery/models/task.dart';

/// Defines the data-access contract for [Task] persistence.
///
/// Concrete implementations (e.g. [SqliteTaskRepository]) are injected into
/// [TaskNotifier] so that the notifier remains database-agnostic and is easy
/// to test with a fake in-memory implementation.
abstract class TaskRepository {
  /// Returns all tasks ordered by their insertion sequence.
  Future<List<Task>> allTasks();

  /// Persists [task] and returns the saved copy with its database-assigned id.
  Future<Task> insertTask(Task task);

  /// Returns the task with the given [id], or a sentinel "Null" task if none exists.
  Future<Task> getTask(int id);

  /// Overwrites the stored record that matches [task.id] with new field values.
  Future<void> updateTask(Task task);

  /// Permanently removes the task with [id] and its associated tag links.
  Future<void> deleteTask(int id);

  /// Returns the list of tag IDs currently attached to the task with [taskID].
  Future<List<int>> tagsForTask(int taskID);

  /// Links the tag [tagID] to the task [taskID].
  Future<void> addTag(int taskID, int tagID);

  /// Removes the link between tag [tagID] and task [taskID].
  Future<void> removeTag(int taskID, int tagID);

  /// Completes when the repository has finished initialising and is ready to use.
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
  Future<Task> insertTask(Task task) async {
    Map<String, Object?> map = _toMap(task);
    map.remove('id');
    final id = await db.insert(
      table,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return getTask(id);
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
      return const Task(
        id: -1,
        name: 'Null',
        description: 'If you see this, report it!',
        task: 'This task should not exist!',
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
  Future<List<int>> tagsForTask(int taskID) async {
    final rows = await db.rawQuery(
      'SELECT id, name, color FROM tag JOIN tasktag on tag.id = tasktag.tagID WHERE tasktag.taskID = ?',
      [taskID],
    );
    return rows.map((row) => row['id'] as int).toList();
  }

  @override
  Future<void> addTag(int taskID, int tagID) async {
    await db.insert(joinTable, {
      'taskID': taskID,
      'tagID': tagID,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> removeTag(int taskID, int tagID) async {
    await db.delete(
      joinTable,
      where: 'taskID = ? AND tagID = ?',
      whereArgs: [taskID, tagID],
    );
  }
}
