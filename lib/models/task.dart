// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// Represents a wellness task that a user can reference during difficult moments.
///
/// A [Task] stores a named activity (e.g. a journaling prompt, a reminder, or
/// a coping strategy) together with a short [description] and the full [task]
/// body text. Tasks are persisted to SQLite via [SqliteTaskRepository].
///
/// Example:
/// ```dart
/// const task = Task(
///   id: 1,
///   name: 'Deep Breath',
///   description: 'A quick grounding exercise',
///   task: 'Take 5 slow, deep breaths and focus on how each one feels.',
/// );
/// ```
class Task {
  /// Unique identifier for this task (assigned by the database on insert).
  final int id;

  /// Short display name shown in lists and headings.
  final String name;

  /// A brief summary of what the task is for.
  final String description;

  /// The full body text describing what the user should do.
  final String task;

  const Task({
    required this.id,
    required this.name,
    required this.description,
    required this.task,
  });

  /// Serialises this task to a [Map] suitable for SQLite insertion.
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
    return 'Task(id: $id, name: $name, description: $description, task: $task)';
  }

  /// Returns a copy of this task with the given fields replaced.
  Task copyWith({int? id, String? name, String? description, String? task}) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      task: task ?? this.task,
    );
  }

  /// Serialises this task to a JSON string.
  String toJson() => json.encode(toMap());

  @override
  bool operator ==(covariant Task other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.description == description &&
        other.task == task;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ description.hashCode ^ task.hashCode;
  }

  /// Deserialises a [Task] from a SQLite row [Map].
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      task: map['task'] as String,
    );
  }

  /// Deserialises a [Task] from a JSON string produced by [toJson].
  factory Task.fromJson(String source) =>
      Task.fromMap(json.decode(source) as Map<String, dynamic>);
}
