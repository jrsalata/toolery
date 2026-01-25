// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/material.dart';

// tags are used to provide some other type of context
// or detail to a task
class Tag {
  final int id;
  final String name;
  final Color color;

  const Tag({required this.id, required this.name, required this.color});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name, 'color': color.toARGB32()};
  }

  @override
  String toString() => 'Tag(id: $id, name: $name, color: $color)';

  Tag copyWith({int? id, String? name, Color? color}) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int,
      name: map['name'] as String,
      color: Color(map['color'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Tag.fromJson(String source) =>
      Tag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant Tag other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.color == color;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ color.hashCode;
}
