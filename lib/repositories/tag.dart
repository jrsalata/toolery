import 'package:flutter/material.dart';
import 'package:toolery/models/tag.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toolery/database/startdb.dart';
import 'dart:async';

abstract class TagRepository {
  Future<List<Tag>> allTags();
  Future<void> insertTag(Tag tag);
  Future<Tag> getTag(int id);
  Future<void> updateTag(Tag tag);
  Future<void> deleteTag(int id);
  // Future that completes when the repository is ready to be used
  Future<void> get ready;
}

class SqliteTagRepository implements TagRepository {
  late Database db;
  final String table = 'tag';
  final String joinTable = 'tasktag';
  final Completer<void> _ready = Completer<void>();

  SqliteTagRepository() {
    _initDB();
  }

  Future<void> _initDB() async {
    db = await getDatabase();
    // mark repository as ready
    if (!_ready.isCompleted) _ready.complete();
  }

  @override
  Future<void> get ready => _ready.future;

  Tag _fromMap(Map<String, Object?> m) => Tag.fromMap(m);

  Map<String, Object?> _toMap(Tag t) => t.toMap();

  @override
  Future<void> deleteTag(int id) async {
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
    await db.delete(joinTable, where: 'tagID = ?', whereArgs: [id]);
  }

  @override
  Future<void> insertTag(Tag tag) async {
    Map<String, Object?> map = _toMap(tag);
    map.remove('id');
    await db.insert(table, map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<Tag>> allTags() async {
    final rows = await db.query(table);
    return rows.map((r) => _fromMap(r)).toList();
  }

  @override
  Future<Tag> getTag(int id) async {
    final rows = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return Tag(id: -1, name: "Null", color: Colors.red);
    }
    return _fromMap(rows.first);
  }

  @override
  Future<void> updateTag(Tag tag) async {
    final map = _toMap(tag);
    final id = map['id'];
    if (id == null) return;
    await db.update(table, map, where: 'id = ?', whereArgs: [id]);
  }
}
