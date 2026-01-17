// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'package:toolery/database/startdb.dart';
import 'package:toolery/models/tag.dart';

class Task {
  final int id;
  final String name;
  final String description;
  final String task;
  final List<Tag>? tags;

  const Task({
    required this.id,
    required this.name,
    required this.description,
    required this.task,
    this.tags
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'task': task,
    };
  }

  @override
  String toString() {
    return 'Task(id: $id, name: $name, description: $description, task: $task, tags: $tags)';
  }

  Task copyWith({
    int? id,
    String? name,
    String? description,
    String? task,
    List<Tag>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      task: task ?? this.task,
      tags: tags ?? this.tags,
    );
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      task: map['task'] as String,
      tags: map['tags'] != null ? List<Tag>.from((map['tags'] as List<int>).map<Tag?>((x) => Tag.fromMap(x as Map<String,dynamic>),),) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant Task other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.task == task &&
      listEquals(other.tags, tags);
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      task.hashCode ^
      tags.hashCode;
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
    taskMap.remove('tags');
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
