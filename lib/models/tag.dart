// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/material.dart';

/// A coloured label used to categorise [Task]s and breathing exercises.
///
/// Tags give users a quick visual way to group or filter their content.
/// Each tag has a [name] and a [color] (stored as a 32-bit ARGB integer in
/// the database). Tags are managed via [TagNotifier] and persisted through
/// [SqliteTagRepository].
///
/// Example:
/// ```dart
/// const tag = Tag(id: 1, name: 'Calm', color: Colors.blue);
/// ```
class Tag {
  /// Unique identifier (assigned by the database on insert).
  final int id;

  /// Human-readable label displayed next to the colour chip.
  final String name;

  /// The display colour for this tag.
  final Color color;

  const Tag({required this.id, required this.name, required this.color});

  /// Serialises this tag to a [Map] suitable for SQLite insertion.
  ///
  /// The [color] is stored as a 32-bit ARGB integer via [Color.toARGB32].
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name, 'color': color.toARGB32()};
  }

  @override
  String toString() => 'Tag(id: $id, name: $name, color: $color)';

  /// Returns a copy of this tag with the given fields replaced.
  Tag copyWith({int? id, String? name, Color? color}) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  /// Deserialises a [Tag] from a SQLite row [Map].
  ///
  /// Expects the [color] field to be a 32-bit ARGB integer.
  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int,
      name: map['name'] as String,
      color: Color(map['color'] as int),
    );
  }

  /// Serialises this tag to a JSON string.
  String toJson() => json.encode(toMap());

  /// Deserialises a [Tag] from a JSON string produced by [toJson].
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
