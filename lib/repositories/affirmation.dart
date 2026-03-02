import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:toolery/database/startdb.dart';
import 'package:toolery/models/affirmation_item.dart';
import 'package:toolery/models/affirmation_list.dart';

abstract class AffirmationRepository {
  Future<List<AffirmationList>> allLists();
  Future<void> insertList(AffirmationList list);
  Future<AffirmationList> getList(int id);
  Future<void> updateList(AffirmationList list);
  Future<void> deleteList(int id);

  Future<List<AffirmationItem>> itemsForList(int listId);
  Future<void> insertItem(AffirmationItem item);
  Future<AffirmationItem> getItem(int id);
  Future<void> updateItem(AffirmationItem item);
  Future<void> deleteItem(int id);

  Future<void> get ready;
}

class SqliteAffirmationRepository implements AffirmationRepository {
  late Database db;
  final Completer<void> _ready = Completer<void>();

  SqliteAffirmationRepository() {
    _initDB();
  }

  Future<void> _initDB() async {
    db = await getDatabase();
    if (!_ready.isCompleted) _ready.complete();
  }

  @override
  Future<void> get ready => _ready.future;

  @override
  Future<void> deleteList(int id) async {
    await db.delete('affirmation_items', where: 'list_id = ?', whereArgs: [id]);
    await db.delete('affirmation_list', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> insertList(AffirmationList list) async {
    final map = list.toMap();
    map.remove('id');
    await db.insert(
      'affirmation_list',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<AffirmationList>> allLists() async {
    final rows = await db.query('affirmation_list');
    return rows.map((r) => AffirmationList.fromMap(r)).toList();
  }

  @override
  Future<AffirmationList> getList(int id) async {
    final rows = await db.query(
      'affirmation_list',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return AffirmationList(id: -1, name: 'Null');
    return AffirmationList.fromMap(rows.first);
  }

  @override
  Future<void> updateList(AffirmationList list) async {
    final map = list.toMap();
    final id = map['id'];
    if (id == null) return;
    await db.update('affirmation_list', map, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<AffirmationItem>> itemsForList(int listId) async {
    final rows = await db.query(
      'affirmation_items',
      where: 'list_id = ?',
      whereArgs: [listId],
    );
    return rows.map((r) => AffirmationItem.fromMap(r)).toList();
  }

  @override
  Future<void> insertItem(AffirmationItem item) async {
    final map = item.toMap();
    map.remove('id');
    await db.insert(
      'affirmation_items',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<AffirmationItem> getItem(int id) async {
    final rows = await db.query(
      'affirmation_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return AffirmationItem(id: -1, listId: -1, item: '');
    return AffirmationItem.fromMap(rows.first);
  }

  @override
  Future<void> updateItem(AffirmationItem item) async {
    final map = item.toMap();
    final id = map['id'];
    if (id == null) return;
    await db.update('affirmation_items', map, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteItem(int id) async {
    await db.delete('affirmation_items', where: 'id = ?', whereArgs: [id]);
  }
}
