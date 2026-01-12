import 'package:flutter/material.dart';

// tags are used to provide some other type of context
// or detail to a task
class Tag {
  final int id;
  final String name;
  final Color color;

  const Tag({required this.id, required this.name, required this.color});

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'color': color.toString()};
  }

  @override
  String toString() {
    return "Tag: {'id': $id, 'name': $name, 'color': ${color.toString()}}";
  }
}
