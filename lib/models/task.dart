// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

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

  Task copyWith({int? id, String? name, String? description, String? task}) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      task: task ?? this.task,
    );
  }

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

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      task: map['task'] as String,
    );
  }

  factory Task.fromJson(String source) =>
      Task.fromMap(json.decode(source) as Map<String, dynamic>);
}
