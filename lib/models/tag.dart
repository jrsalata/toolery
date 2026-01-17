// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toolery/database/startdb.dart';

// tags are used to provide some other type of context
// or detail to a task
class Tag {
  final int id;
  final String name;
  final Color color;

  const Tag({
    required this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'color': color.toARGB32(),
    };
  }

  @override
  String toString() => 'Tag(id: $id, name: $name, color: $color)';

  Tag copyWith({
    int? id,
    String? name,
    Color? color,
  }) {
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

  factory Tag.fromJson(String source) => Tag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant Tag other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.color == color;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ color.hashCode;
}

class TagChangeNotifier with ChangeNotifier {

  // create a list with a getter
  List<Tag> _tags = [];
  List<Tag> get tags => _tags;

  TagChangeNotifier() {
    _loadTags();
  }

  // after any CREATE, UPDATE, or DELETE activity
  // run _loadTags() to send up to date info
  // to all of our listeners
  Future<void> _loadTags() async {
    _tags = await allTags();
    notifyListeners();
  }

  Future<List<Tag>> allTags() async {
    
    // open up the db
    final db = await getDatabase();

    // get all of the tags
    final List<Map<String, Object?>> tagMaps = await db.query('tag');

    // convert the map to tags
    return [
      for (final {
            'id': id as int,
            'name': name as String,
            'color': color as int,
          }
          in tagMaps)
        Tag(id: id, name: name, color: Color(color)),
    ];
  }

  Future<void> insertTag(Tag tag) async {
    Map<String, Object?> tagMap = tag.toMap();
    tagMap.remove('id');

    final db = await getDatabase();

    await db.insert('tag', tagMap, conflictAlgorithm: ConflictAlgorithm.fail);
    _loadTags();
  }

  Future<Tag> getTag(int id) async {
    final db = await getDatabase();

    final List<Map<String, Object?>> tag = await db.query(
      'tag',
      where: 'id=?',
      whereArgs: [id],
    );

    Map<String, Object?> rawTag = tag[0];
    Color convertedColor = Color(rawTag["color"] as int);

    return Tag(
      id: rawTag["id"] as int,
      name: rawTag["name"] as String,
      color: convertedColor
    );
  }

  Future<void> updateTag(Tag tag) async {
    final db = await getDatabase();

    await db.update('tag', tag.toMap(), where: 'id=?', whereArgs: [tag.id]);
    _loadTags();
  }

  Future<void> deleteTag(int id) async {
    final db = await getDatabase();

    await db.delete('tag', where: 'id=?', whereArgs: [id]);
    await db.delete('tasktag', where: 'tagID=?', whereArgs: [id]);
    _loadTags();
  }
}
