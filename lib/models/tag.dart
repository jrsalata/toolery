import 'package:flutter/material.dart';

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
